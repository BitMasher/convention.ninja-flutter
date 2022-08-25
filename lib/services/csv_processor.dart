import 'dart:convert';
import 'dart:typed_data';

class CsvFile {
  final List<String> headers;
  final List<Map<String,String>> rows;
  CsvFile({required this.headers, required this.rows});

  static CsvFile? fromBytes(Uint8List bytes) {
    if(bytes.isEmpty) {
      return null;
    }
    String data = "";
    try {
      data = utf8.decoder.convert(bytes);
    } catch(_) {
      return null;
    }
    if(!data.contains(",") && !data.contains("\n")) {
      return null;
    }
    var rows = data.split("\n");
    var headers = rows.removeAt(0).split(",").map((e) => (e.startsWith('"') ? e.substring(1,e.length-1).replaceAll('""', '"') : e).trim()).toList();
    var datarows = rows.map((e) {
      var record = <String, String>{};
      var splt = e.split(",");
      for(var i = 0; i < splt.length && i < headers.length; i++) {
        record[headers[i]] = (splt[i].startsWith('"') ? splt[i].substring(1,splt[i].length-1).replaceAll('""', '"') : splt[i]).trim();
      }
      return record;
    }).toList();
    return CsvFile(headers: headers, rows: datarows);
  }
}