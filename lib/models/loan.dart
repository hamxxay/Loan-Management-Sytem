import 'transaction.dart';

class Loan {
  final String id;
  final String personName;
  final double amountToPay;
  final double amountToGet;
  final List<Transaction> transactions;

  Loan({
    required this.id,
    required this.personName,
    required this.amountToPay,
    required this.amountToGet,
    required this.transactions,
  });

  /// Get the current balance (positive means you'll get money, negative means you'll pay)
  double get balance => amountToGet - amountToPay;

  /// Creates a copy of this loan with the given fields replaced with new values
  Loan copyWith({
    String? id,
    String? personName,
    double? amountToPay,
    double? amountToGet,
    List<Transaction>? transactions,
  }) {
    return Loan(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amountToPay: amountToPay ?? this.amountToPay,
      amountToGet: amountToGet ?? this.amountToGet,
      transactions: transactions ?? this.transactions,
    );
  }

  /// Converts a loan to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amountToPay': amountToPay,
      'amountToGet': amountToGet,
    };
  }

  /// Creates a loan from a database map (without transactions)
  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      personName: map['personName'],
      amountToPay: map['amountToPay'],
      amountToGet: map['amountToGet'],
      transactions: [],
    );
  }

  @override
  String toString() {
    return 'Loan(id: $id, personName: $personName, amountToPay: $amountToPay, amountToGet: $amountToGet, transactions: ${transactions.length})';
  }
}
