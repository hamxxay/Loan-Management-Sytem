import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'loan.dart';
import 'transaction.dart';
import '../helpers/database_helper.dart';

class LoanProvider with ChangeNotifier {
  List<Loan> _loans = [];
  final _uuid = const Uuid();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoaded = false;

  LoanProvider() {
    _loadLoans();
  }

  List<Loan> get loans => [..._loans];

  Future<void> _loadLoans() async {
    if (_isLoaded) return;
    _loans = await _dbHelper.getLoans();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addLoan(String personName) async {
    final newLoan = Loan(
      id: _uuid.v4(),
      personName: personName,
      amountToPay: 0,
      amountToGet: 0,
      transactions: [],
    );

    await _dbHelper.insertLoan(newLoan);
    _loans.add(newLoan);
    notifyListeners();
  }

  Future<void> addTransaction(
    String loanId,
    double amount,
    String description,
    TransactionType type, {
    String? category,
    String? paymentMethod,
    TransactionStatus status = TransactionStatus.completed,
  }) async {
    final loanIndex = _loans.indexWhere((loan) => loan.id == loanId);
    if (loanIndex >= 0) {
      final loan = _loans[loanIndex];
      final newTransaction = Transaction(
        id: _uuid.v4(),
        date: DateTime.now(),
        amount: amount,
        description: description,
        type: type,
        category: category,
        paymentMethod: paymentMethod,
        status: status,
      );

      // Add transaction to database
      await _dbHelper.insertTransaction(loanId, newTransaction);

      final updatedTransactions = [...loan.transactions, newTransaction];
      double amountToPay = loan.amountToPay;
      double amountToGet = loan.amountToGet;

      if (type == TransactionType.payment) {
        amountToPay += amount;
      } else {
        amountToGet += amount;
      }

      final updatedLoan = loan.copyWith(
        amountToPay: amountToPay,
        amountToGet: amountToGet,
        transactions: updatedTransactions,
      );

      // Update loan in database
      await _dbHelper.updateLoan(updatedLoan);

      _loans[loanIndex] = updatedLoan;
      notifyListeners();
    }
  }

  Loan? getLoanById(String id) {
    try {
      return _loans.firstWhere((loan) => loan.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteLoan(String id) async {
    await _dbHelper.deleteLoan(id);
    _loans.removeWhere((loan) => loan.id == id);
    notifyListeners();
  }

  // Add sample data for testing
  Future<void> addSampleData() async {
    if (_loans.isEmpty) {
      // Sample loan 1
      final loan1Id = _uuid.v4();
      final loan1 = Loan(
        id: loan1Id,
        personName: "John Smith",
        amountToPay: 1500,
        amountToGet: 2000,
        transactions: [],
      );
      await _dbHelper.insertLoan(loan1);

      // Add transactions for loan 1
      final transaction1 = Transaction(
        id: _uuid.v4(),
        date: DateTime.now().subtract(const Duration(days: 30)),
        amount: 2000,
        description: "Home renovation loan",
        type: TransactionType.loan,
        category: "Home",
        paymentMethod: "Bank Transfer",
      );
      await _dbHelper.insertTransaction(loan1Id, transaction1);

      final transaction2 = Transaction(
        id: _uuid.v4(),
        date: DateTime.now().subtract(const Duration(days: 15)),
        amount: 500,
        description: "First payment",
        type: TransactionType.payment,
        category: "Repayment",
        paymentMethod: "Cash",
      );
      await _dbHelper.insertTransaction(loan1Id, transaction2);

      final transaction3 = Transaction(
        id: _uuid.v4(),
        date: DateTime.now().subtract(const Duration(days: 5)),
        amount: 1000,
        description: "Second payment",
        type: TransactionType.payment,
        category: "Repayment",
        paymentMethod: "UPI",
      );
      await _dbHelper.insertTransaction(loan1Id, transaction3);

      // Sample loan 2
      final loan2Id = _uuid.v4();
      final loan2 = Loan(
        id: loan2Id,
        personName: "Sarah Johnson",
        amountToPay: 0,
        amountToGet: 1200,
        transactions: [],
      );
      await _dbHelper.insertLoan(loan2);

      // Add transaction for loan 2
      final transaction4 = Transaction(
        id: _uuid.v4(),
        date: DateTime.now().subtract(const Duration(days: 10)),
        amount: 1200,
        description: "Car repair loan",
        type: TransactionType.loan,
        category: "Vehicle",
        paymentMethod: "Credit Card",
      );
      await _dbHelper.insertTransaction(loan2Id, transaction4);

      // Sample loan 3
      final loan3Id = _uuid.v4();
      final loan3 = Loan(
        id: loan3Id,
        personName: "Michael Brown",
        amountToPay: 800,
        amountToGet: 0,
        transactions: [],
      );
      await _dbHelper.insertLoan(loan3);

      // Add transaction for loan 3
      final transaction5 = Transaction(
        id: _uuid.v4(),
        date: DateTime.now().subtract(const Duration(days: 60)),
        amount: 800,
        description: "Borrowed for business supplies",
        type: TransactionType.payment,
        category: "Business",
        paymentMethod: "Check",
      );
      await _dbHelper.insertTransaction(loan3Id, transaction5);

      // Reload loans from database
      _loans = await _dbHelper.getLoans();
      notifyListeners();
    }
  }
}
