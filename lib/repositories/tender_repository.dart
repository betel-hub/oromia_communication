import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/tender.dart';

class TenderRepository {
  Future<List<Tender>> getTenders() async {
    final jsonString = await rootBundle.loadString('assets/mock/tenders.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => Tender.fromJson(j)).toList();
  }
}