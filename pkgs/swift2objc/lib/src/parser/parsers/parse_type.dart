// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../ast/_core/interfaces/declaration.dart';
import '../../ast/_core/shared/referred_type.dart';
import '../../ast/declarations/built_in/built_in_declaration.dart';
import '../../context.dart';
import '../_core/json.dart';
import '../_core/parsed_symbolgraph.dart';
import '../_core/token_list.dart';
import 'parse_declarations.dart';

(ReferredType, TokenList) parseType(
  Context context,
  ParsedSymbolgraph symbolgraph,
  TokenList fragments,
) {
  var (type, suffix) = _parsePrefixTypeExpression(
    context,
    symbolgraph,
    fragments,
  );
  while (true) {
    final (nextType, nextSuffix) = _maybeParseSuffixTypeExpression(
      context,
      symbolgraph,
      type,
      suffix,
    );
    if (nextType == null) break;
    type = nextType;
    suffix = nextSuffix;
  }
  return (type, suffix);
}

(ReferredType, TokenList) _parsePrefixTypeExpression(
  Context context,
  ParsedSymbolgraph symbolgraph,
  TokenList fragments,
) {
  if (fragments.isEmpty) {
    throw Exception('Empty fragments while parsing type');
  }
  final token = fragments[0];
  final parselet = _prefixParsets[_tokenId(token)];
  if (parselet == null) {
    throw Exception('Invalid type at "${token.path}": $token');
  }
  return parselet(context, symbolgraph, token, fragments.slice(1));
}

(ReferredType?, TokenList) _maybeParseSuffixTypeExpression(
  Context context,
  ParsedSymbolgraph symbolgraph,
  ReferredType prefixType,
  TokenList fragments,
) {
  if (fragments.isEmpty) return (null, fragments);
  final token = fragments[0];
  final parselet = _suffixParsets[_tokenId(token)];
  if (parselet == null) return (null, fragments);
  return parselet(context, symbolgraph, prefixType, token, fragments.slice(1));
}

String _tokenId(Json token) {
  final kind = token['kind'].get<String>();
  if (kind == 'text' || kind == 'keyword') {
    return '$kind: ${token['spelling'].get<String>()}';
  }
  return kind;
}

typedef PrefixParselet =
    (ReferredType, TokenList) Function(
      Context context,
      ParsedSymbolgraph symbolgraph,
      Json token,
      TokenList fragments,
    );

(ReferredType, TokenList) _typeIdentifierParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  Json token,
  TokenList fragments,
) {
  final id = token['preciseIdentifier'].get<String>();
  final spelling = token['spelling'].get<String>();
  final symbol = symbolgraph.symbols[id];

  if (symbol == null) {
    return (
      DeclaredType(
        id: id,
        declaration: BuiltInDeclaration(id: id, name: spelling),
      ),
      fragments,
    );
  }

  final type = parseDeclaration(context, symbol, symbolgraph).asDeclaredType;
  return (type, fragments);
}

(ReferredType, TokenList) _tupleParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  Json token,
  TokenList fragments,
) {
  if (fragments.isNotEmpty && _tokenId(fragments[0]) == 'text: )') {
    return (voidType, fragments.slice(1));
  }
  throw Exception('Tuples not supported yet, at ${token.path}');
}

(ReferredType, TokenList) _inoutParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  Json token,
  TokenList fragments,
) {
  if (fragments.isNotEmpty && _tokenId(fragments[0]) == 'text: ') {
    fragments = fragments.slice(1);
  }
  return parseType(context, symbolgraph, fragments);
}

Map<String, PrefixParselet> _prefixParsets = {
  'typeIdentifier': _typeIdentifierParselet,
  'text: (': _tupleParselet,
  'keyword: inout': _inoutParselet,
};

typedef SuffixParselet =
    (ReferredType, TokenList) Function(
      Context context,
      ParsedSymbolgraph symbolgraph,
      ReferredType prefixType,
      Json token,
      TokenList fragments,
    );

(ReferredType, TokenList) _optionalParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  ReferredType prefixType,
  Json token,
  TokenList fragments,
) => (OptionalType(prefixType), fragments);

(ReferredType, TokenList) _nestedTypeParselet(
  Context context,
  ParsedSymbolgraph symbolgraph,
  ReferredType prefixType,
  Json token,
  TokenList fragments,
) {
  return parseType(context, symbolgraph, fragments);
}

Map<String, SuffixParselet> _suffixParsets = {
  'text: ?': _optionalParselet,
  'text: .': _nestedTypeParselet,
};
