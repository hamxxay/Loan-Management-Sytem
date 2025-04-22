import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/loan.dart';
import '../models/transaction.dart' as txn; // Alias to resolve conflict

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'loan_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create loans table
    await db.execute('''
      CREATE TABLE loans(
        id TEXT PRIMARY KEY,
        personName TEXT NOT NULL,
        amountToPay REAL NOT NULL,
        amountToGet REAL NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        loanId TEXT NOT NULL,
        date INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        type INTEGER NOT NULL,
        FOREIGN KEY (loanId) REFERENCES loans (id) ON DELETE CASCADE
      )
    ''');
  }

  // Loan CRUD operations
  Future<void> insertLoan(Loan loan) async {
    final db = await database;
    await db.insert(
      'loans',
      {
        'id': loan.id,
        'personName': loan.personName,
        'amountToPay': loan.amountToPay,
        'amountToGet': loan.amountToGet,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLoan(Loan loan) async {
    final db = await database;
    await db.update(
      'loans',
      {
        'personName': loan.personName,
        'amountToPay': loan.amountToPay,
        'amountToGet': loan.amountToGet,
      },
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  Future<void> deleteLoan(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete all transactions for this loan
      await txn.delete(
        'transactions',
        where: 'loanId = ?',
        whereArgs: [id],
      );
      // Delete the loan
      await txn.delete(
        'loans',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<List<Loan>> getLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> loanMaps = await db.query('loans');

    if (loanMaps.isEmpty) {
      return [];
    }

    List<Loan> loans = [];
    for (var loanMap in loanMaps) {
      final transactions = await getTransactionsForLoan(loanMap['id']);
      loans.add(Loan(
        id: loanMap['id'],
        personName: loanMap['personName'],
        amountToPay: loanMap['amountToPay'],
        amountToGet: loanMap['amountToGet'],
        transactions: transactions,
      ));
    }
    return loans;
  }

  // Transaction CRUD operations
  Future<void> insertTransaction(
      String loanId, txn.Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      {
        'id': transaction.id,
        'loanId': loanId,
        'date': transaction.date.millisecondsSinceEpoch,
        'amount': transaction.amount,
        'description': transaction.description,
        'type': transaction.type.index,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<txn.Transaction>> getTransactionsForLoan(String loanId) async {
    final db = await database;
    final List<Map<String, dynamic>> transactionMaps = await db.query(
      'transactions',
      where: 'loanId = ?',
      whereArgs: [loanId],
    );

    return List.generate(transactionMaps.length, (i) {
      return txn.Transaction(
        id: transactionMaps[i]['id'],
        date: DateTime.fromMillisecondsSinceEpoch(transactionMaps[i]['date']),
        amount: transactionMaps[i]['amount'],
        description: transactionMaps[i]['description'],
        type: txn.TransactionType.values[transactionMaps[i]['type']],
      );
    });
  }

  // Clear all data (for testing)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('loans');
  }
}
