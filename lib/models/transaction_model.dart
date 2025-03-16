import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final DateTime data;
  final double valor;
  final String tipo;

  TransactionModel({
    required this.data,
    required this.valor,
    required this.tipo,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> json) {
    return TransactionModel(
      data: (json['data'] as Timestamp).toDate(),
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
      tipo: json['tipo'] ?? '',
    );
  }
}
