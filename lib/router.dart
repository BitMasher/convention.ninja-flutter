const _wildcardParam = '*';
const _plusParam = '+';
const _optionalParam = '?';
const _paramStarterChar = ':';
const _slashDelimiter = '/';
const _escapeChar = '\\';

// slash has a special role, unlike the other parameters it must not be interpreted as a parameter
var _routeDelimiter = [_slashDelimiter, '-', '.'];
// list of greedy parameters
var _greedyParameters = [_wildcardParam, _plusParam];
// list of chars for the parameter recognising
var _parameterStartChars = [_wildcardParam, _plusParam, _paramStarterChar];
// list of chars of delimiters and the starting parameter name char
var _parameterDelimiterChars = [_paramStarterChar, ..._routeDelimiter];
// list of chars to find the end of a parameter
var _parameterEndChars = [_optionalParam, ..._parameterDelimiterChars];

class _RouteSegment {
  String constant = '';
  bool isParam = false;
  String paramName = '';
  String comparePart = '';
  int partCount = 0;
  bool isGreedy = false;
  bool isOptional = false;
  bool isLast = false;
  bool hasOptionalSlash = false;
  int length = 0;

  _RouteSegment(
      {this.constant = '',
      this.isParam = false,
      this.paramName = '',
      this.comparePart = '',
      this.partCount = 0,
      this.isGreedy = false,
      this.isOptional = false,
      this.isLast = false,
      this.hasOptionalSlash = false,
      this.length = 0});
}

class RouteParser {
  List<_RouteSegment> segments = [];
  List<String> params = [];
  int wildcardCount = 0;
  int plusCount = 0;

  static RouteParser parseRoute(String pattern) {
    var parser = RouteParser();

    var part = '';
    while (pattern.isNotEmpty) {
      var nextParamPosition = RouteParser._findNextParamPosition(pattern);
      // handle the parameter part
      if (nextParamPosition == 0) {
        var analysisResult = parser.analyseParameterPart(pattern);
        var processedPart = analysisResult.processedPart;
        var seg = analysisResult.segment;
        parser.params.add(seg.paramName);
        parser.segments.add(seg);
        part = processedPart;
      } else {
        var analysisResult =
            parser.analyseConstantPart(pattern, nextParamPosition);
        var processedPart = analysisResult.processedPart;
        var seg = analysisResult.segment;
        parser.segments.add(seg);
        part = processedPart;
      }

      // reduce the pattern by the processed parts
      if (part.length == pattern.length) {
        break;
      }
      pattern = pattern.substring(part.length);
    }
    // mark last segment
    if (parser.segments.isNotEmpty) {
      parser.segments[parser.segments.length - 1].isLast = true;
    }
    parser.segments = RouteParser._addParameterMetaInfo(parser.segments);

    return parser;
  }

  static int _findNextParamPosition(String pattern) {
    var nextParamPosition = RouteParser._findNextNonEscapedCharsetPosition(
        pattern, _parameterStartChars);
    if (nextParamPosition != -1 &&
        pattern.length > nextParamPosition &&
        pattern[nextParamPosition] != _wildcardParam) {
      // search for parameter characters for the found parameter start,
      // if there are more, move the parameter start to the last parameter char
      for (var found = RouteParser._findNextNonEscapedCharsetPosition(
              pattern.substring(nextParamPosition + 1), _parameterStartChars);
          found == 0;) {
        nextParamPosition++;
        if (pattern.length > nextParamPosition) {
          break;
        }
      }
    }

    return nextParamPosition;
  }

  static _findNextNonEscapedCharsetPosition(
      String search, List<String> charset) {
    var pos = RouteParser._findNextCharsetPosition(search, charset);
    while (pos > 0 && search[pos - 1] == _escapeChar) {
      if (search.length == pos + 1) {
        // escaped character is at the end
        return -1;
      }
      var nextPossiblePos = RouteParser._findNextCharsetPosition(
          search.substring(pos + 1), charset);
      if (nextPossiblePos == -1) {
        return -1;
      }
      // the previous character is taken into consideration
      pos = nextPossiblePos + pos + 1;
    }

    return pos;
  }

  static _findNextCharsetPosition(String search, List<String> charset) {
    var nextPosition = -1;
    for (var char in charset) {
      var pos = search.indexOf(char);
      if (pos != -1 && (pos < nextPosition || nextPosition == -1)) {
        nextPosition = pos;
      }
    }

    return nextPosition;
  }

  _AnalysisResult analyseParameterPart(String pattern) {
    var isWildCard = pattern[0] == _wildcardParam;
    var isPlusParam = pattern[0] == _plusParam;
    var parameterEndPosition = RouteParser._findNextNonEscapedCharsetPosition(
        pattern.substring(1), _parameterEndChars);

    // handle wildcard end
    if (isWildCard || isPlusParam) {
      parameterEndPosition = 0;
    } else if (parameterEndPosition == -1) {
      parameterEndPosition = pattern.length - 1;
    } else if (!RouteParser._isInCharset(
        pattern.substring(parameterEndPosition + 1),
        _parameterDelimiterChars)) {
      parameterEndPosition++;
    }
    // cut params part
    var processedPart = pattern.substring(0, parameterEndPosition + 1);

    var paramName = RouteParser.removeEscapeChar(
        RouteParser.getTrimmedParam(processedPart));
    // add access iterator to wildcard and plus
    if (isWildCard) {
      wildcardCount++;
      paramName += wildcardCount.toString();
    } else if (isPlusParam) {
      plusCount++;
      paramName += plusCount.toString();
    }

    return _AnalysisResult(
        processedPart,
        _RouteSegment(
          paramName: paramName,
          isParam: true,
          isOptional:
              isWildCard || pattern[parameterEndPosition] == _optionalParam,
          isGreedy: isWildCard || isPlusParam,
        ));
  }

  static bool _isInCharset(String searchChar, List<String> charset) {
    for (var char in charset) {
      if (char == searchChar) {
        return true;
      }
    }
    return false;
  }

  static getTrimmedParam(String param) {
    var start = 0;
    var end = param.length;

    if (end == 0 || param[start] != _paramStarterChar) {
      // is not a param
      return param;
    }
    start++;
    if (param[end - 1] == _optionalParam) {
      // is ?
      end--;
    }

    return param.substring(start, end);
  }

  static removeEscapeChar(String word) {
    if (word.contains(_escapeChar)) {
      return word.replaceAll(_escapeChar, '');
    }
    return word;
  }

  _AnalysisResult analyseConstantPart(String pattern, int nextParamPosition) {
    // handle the constant part
    var processedPart = pattern;
    if (nextParamPosition != -1) {
      // remove the constant part until the parameter
      processedPart = pattern.substring(0, nextParamPosition);
    }
    var constPart = RouteParser.removeEscapeChar(processedPart);
    return _AnalysisResult(
        processedPart,
        _RouteSegment(
          constant: constPart,
          length: constPart.length,
        ));
  }

  static String _trimRight(String from, String pattern) {
    int i = from.length;
    while (from.startsWith(pattern, i - pattern.length)) {
      i -= pattern.length;
    }
    return from.substring(0, i);
  }

  static List<_RouteSegment> _addParameterMetaInfo(List<_RouteSegment> segs) {
    String comparePart = '';
    var segLen = segs.length;
    // loop from end to begin
    for (var i = segLen - 1; i >= 0; i--) {
      // set the compare part for the parameter
      if (segs[i].isParam) {
        // important for finding the end of the parameter
        segs[i].comparePart = removeEscapeChar(comparePart);
      } else {
        comparePart = segs[i].constant;
        if (comparePart.length > 1) {
          comparePart = _trimRight(comparePart, _slashDelimiter);
        }
      }
    }

    // loop from begin to end
    for (var i = 0; i < segLen; i++) {
      // check how often the compare part is in the following const parts
      if (segs[i].isParam) {
        // check if parameter segments are directly after each other and if one of them is greedy
        // in case the next parameter or the current parameter is not a wildcard its not greedy, we only want one character
        if (segLen > i + 1 &&
            !segs[i].isGreedy &&
            segs[i + 1].isParam &&
            !segs[i + 1].isGreedy) {
          segs[i].length = 1;
        }
        if (segs[i].comparePart == "") {
          continue;
        }
        for (var j = i + 1; j <= segs.length - 1; j++) {
          if (!segs[j].isParam) {
            // count is important for the greedy match
            segs[i].partCount +=
                segs[i].comparePart.allMatches(segs[j].constant).length;
          }
        }
        // check if the end of the segment is a optional slash and then if the segement is optional or the last one
      } else if (segs[i].constant[segs[i].constant.length - 1] ==
              _slashDelimiter &&
          (segs[i].isLast || (segLen > i + 1 && segs[i + 1].isOptional))) {
        segs[i].hasOptionalSlash = true;
      }
    }

    return segs;
  }

  bool getMatch(String detectionPath, String path, List<String> params,
      bool partialCheck) {
    var i = 0;
    var paramsIterator = 0;
    var partLen = 0;
    for (var segment in segments) {
      partLen = detectionPath.length;
      // check const segment
      if (!segment.isParam) {
        i = segment.length;
        // is optional part or the const part must match with the given string
        // check if the end of the segment is a optional slash
        if (segment.hasOptionalSlash &&
            partLen == i - 1 &&
            detectionPath == segment.constant.substring(0, i - 1)) {
          i--;
        } else if (!(i <= partLen &&
            detectionPath.substring(0, i) == segment.constant)) {
          return false;
        }
      } else {
        // determine parameter length
        i = _findParamLen(detectionPath, segment);
        if (!segment.isOptional && i == 0) {
          return false;
        }
        // take over the params positions
        params.add(path.substring(0, i));
        paramsIterator++;
      }

      // reduce founded part from the string
      if (partLen > 0) {
        detectionPath = detectionPath.substring(i);
        path = path.substring(i);
      }
    }
    if (detectionPath != "" && !partialCheck) {
      return false;
    }

    return true;
  }

  static int _findParamLen(String s, _RouteSegment segment) {
    if (segment.isLast) {
      return RouteParser._findParamLenForLastSegment(s, segment);
    }

    if (segment.length != 0 && s.length >= segment.length) {
      return segment.length;
    } else if (segment.isGreedy) {
      // Search the parameters until the next constant part
      // special logic for greedy params
      var searchCount = segment.comparePart.allMatches(s).length;
      if (searchCount > 1) {
        return RouteParser._findGreedyParamLen(s, searchCount, segment);
      }
    }

    if (segment.comparePart.length == 1) {
      var constPosition = s.indexOf(segment.comparePart[0]);
      if (constPosition != -1) {
        return constPosition;
      }
    } else {
      var constPosition = s.indexOf(segment.comparePart);
      if (constPosition != -1) {
        // if the compare part was found, but contains a slash although this part is not greedy, then it must not match
        // example: /api/:param/fixedEnd -> path: /api/123/456/fixedEnd = no match , /api/123/fixedEnd = match
        if (!segment.isGreedy &&
            s.substring(0, constPosition).contains(_slashDelimiter)) {
          return 0;
        }
        return constPosition;
      }
    }

    return s.length;
  }

  static int _findParamLenForLastSegment(s, _RouteSegment seg) {
    if (!seg.isGreedy) {
      var i = s.indexOf(_slashDelimiter);
      if (i != -1) {
        return i;
      }
    }

    return s.length;
  }

  static int _findGreedyParamLen(
      String s, int searchCount, _RouteSegment segment) {
    // check all from right to left segments
    for (var i = segment.partCount; i > 0 && searchCount > 0; i--) {
      searchCount--;
      var constPosition = s.lastIndexOf(segment.comparePart);
      if (constPosition != -1) {
        s = s.substring(0, constPosition);
      } else {
        break;
      }
    }

    return s.length;
  }
}

class _AnalysisResult {
  String processedPart;
  _RouteSegment segment;

  _AnalysisResult(this.processedPart, this.segment);
}
