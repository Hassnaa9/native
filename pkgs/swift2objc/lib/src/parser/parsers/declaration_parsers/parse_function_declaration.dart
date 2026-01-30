// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../../ast/_core/shared/parameter.dart';
import '../../../ast/_core/shared/referred_type.dart';
import '../../../ast/declarations/compounds/members/method_declaration.dart';
import '../../../ast/declarations/globals/globals.dart';
import '../../../context.dart';
import '../../_core/json.dart';
import '../../_core/parsed_symbolgraph.dart';
import '../../_core/token_list.dart';
import '../../_core/utils.dart';
import '../parse_type.dart';

GlobalFunctionDeclaration parseGlobalFunctionDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph,
) {
  final info = parseFunctionInfo(
    context,
    symbol.json['declarationFragments'],
    symbolgraph,
  );
  return GlobalFunctionDeclaration(
    id: parseSymbolId(symbol.json),
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    returnType: _parseFunctionReturnType(context, symbol.json, symbolgraph),
    params: info.params,
    throws: info.throws,
    async: info.async,
  );
}

MethodDeclaration parseMethodDeclaration(
  Context context,
  ParsedSymbol symbol,
  ParsedSymbolgraph symbolgraph, {
  bool isStatic = false,
}) {
  final info = parseFunctionInfo(
    context,
    symbol.json['declarationFragments'],
    symbolgraph,
  );
  return MethodDeclaration(
    id: parseSymbolId(symbol.json),
    name: parseSymbolName(symbol.json),
    source: symbol.source,
    availability: parseAvailability(symbol.json),
    returnType: _parseFunctionReturnType(context, symbol.json, symbolgraph),
    params: info.params,
    hasObjCAnnotation: parseSymbolHasObjcAnnotation(symbol.json),
    isStatic: isStatic,
    throws: info.throws,
    async: info.async,
    mutating: info.mutating,
  );
}

typedef ParsedFunctionInfo = ({
  List<Parameter> params,
  bool throws,
  bool async,
  bool mutating,
});

ParsedFunctionInfo parseFunctionInfo(
  Context context,
  Json declarationFragments,
  ParsedSymbolgraph symbolgraph, {
  bool isEnumCase = false,
}) {
  final parameters = <Parameter>[];
  final malformedInitializerException = Exception(
    'Malformed parameter list at ${declarationFragments.path}: '
    '$declarationFragments',
  );

  var tokens = TokenList(declarationFragments);

  String? maybeConsume(String kind) {
    if (tokens.isEmpty) return null;
    final spelling = getSpellingForKind(tokens[0], kind);
    if (spelling != null) tokens = tokens.slice(1);
    return spelling;
  }

  final prefixAnnotations = <String>{};

  while (tokens.isNotEmpty) {
    if (tokens[0]['spelling'].get<String>().contains('(')) {
      break;
    }

    final keyword = maybeConsume('keyword');
    if (keyword != null) {
      if (keyword == 'func' || keyword == 'init' || keyword == 'case') {
        continue;
      }
      prefixAnnotations.add(keyword);
      continue;
    }

    tokens = tokens.slice(1);
  }

  final openParen = tokens.indexWhere(
    (tok) => tok['spelling'].get<String>().contains('('),
  );

  if (openParen != -1) {
    tokens = tokens.slice(openParen + 1);

    final firstText = maybeConsume('text');
    if (firstText != null && firstText.contains(')')) {
      // Empty param list.
    } else {
      while (true) {
        final externalParam = maybeConsume('externalParam');
        String? internalParam;
        if (externalParam != null) {
          var sep = maybeConsume('text');
          if (sep == '') {
            internalParam = maybeConsume('internalParam');
            if (internalParam == null) {
              throw malformedInitializerException;
            }
            sep = maybeConsume('text');
          }

          if (sep != ':') {
            throw malformedInitializerException;
          }
        } else if (!isEnumCase) {
          if (tokens.isEmpty ||
              tokens[0]['spelling'].get<String>().contains(')')) {
            break;
          }
        }
        final (type, remainingTokens) = parseType(context, symbolgraph, tokens);
        tokens = remainingTokens;

        parameters.add(
          Parameter(
            name: externalParam ?? '',
            internalName: internalParam,
            type: type,
          ),
        );

        final end = maybeConsume('text');
        if (end != null && end.contains(')')) break;
        if (end != ',') {
          throw malformedInitializerException;
        }
      }
    }
  }

  final annotations = <String>{};
  while (true) {
    final keyword = maybeConsume('keyword');
    if (keyword == null) {
      final text = maybeConsume('text');
      if (text != '' && text != ' ') break;
    } else {
      annotations.add(keyword);
    }
  }

  return (
    params: parameters,
    throws: annotations.contains('throws'),
    async: annotations.contains('async'),
    mutating: prefixAnnotations.contains('mutating'),
  );
}

ReferredType _parseFunctionReturnType(
  Context context,
  Json symbolJson,
  ParsedSymbolgraph symbolgraph,
) {
  final returnJson = TokenList(symbolJson['functionSignature']['returns']);
  final (returnType, unparsed) = parseType(context, symbolgraph, returnJson);
  assert(unparsed.isEmpty, '$returnJson\n\n$returnType\n\n$unparsed\n');
  return returnType;
}
