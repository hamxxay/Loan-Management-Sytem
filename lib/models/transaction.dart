/// Represents the type of transaction
enum TransactionType {
  /// Money given to someone (increases amountToGet)
  loan,

  /// Money received from someone (increases amountToPay)
  payment,
}

/// Represents a single financial transaction in the loan management system
class Transaction {
  /// Unique identifier for the transaction
  final String id;

  /// Date and time when the transaction occurred
  final DateTime date;

  /// Amount of money involved in the transaction
  final double amount;

  /// Description of what the transaction was for
  final String description;

  /// Type of transaction (loan or payment)
  final TransactionType type;

  /// Optional category for grouping transactions
  final String? category;

  /// Optional payment method used for the transaction
  final String? paymentMethod;

  /// Status of the transaction
  final TransactionStatus status;

  /// Creates a new transaction
  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.type,
    this.category,
    this.paymentMethod,
    this.status = TransactionStatus.completed,
  });

  /// Creates a copy of this transaction with the given fields replaced with new values
  Transaction copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? description,
    TransactionType? type,
    String? category,
    String? paymentMethod,
    TransactionStatus? status,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }

  /// Converts a transaction to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'description': description,
      'type': type.index,
      'category': category,
      'paymentMethod': paymentMethod,
      'status': status.index,
    };
  }

  /// Creates a transaction from a database map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      amount: map['amount'],
      description: map['description'],
      type: TransactionType.values[map['type']],
      category: map['category'],
      paymentMethod: map['paymentMethod'],
      status: map['status'] != null
          ? TransactionStatus.values[map['status']]
          : TransactionStatus.completed,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, date: $date, amount: $amount, description: $description, type: $type, category: $category, paymentMethod: $paymentMethod, status: $status)';
  }
}

/// Represents the status of a transaction
enum TransactionStatus {
  /// Transaction is pending completion
  pending,

  /// Transaction has been completed
  completed,

  /// Transaction has been cancelled
  cancelled,
}
