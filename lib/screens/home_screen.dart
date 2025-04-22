import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loan_provider.dart';
import '../models/loan.dart';
import 'loan_detail_screen.dart';
import '../widgets/add_loan_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<LoanProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      await provider.addSampleData();
      await prefs.setBool('isFirstRun', false);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Manager')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<LoanProvider>(
              builder: (ctx, loanProvider, _) {
                final loans = loanProvider.loans;

                if (loans.isEmpty) {
                  return const Center(
                    child: Text(
                      'No loans yet. Tap the + button to add one.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildTableHeader(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: loans.length,
                          itemBuilder: (ctx, index) {
                            final loan = loans[index];
                            return LoanListItem(loan: loan);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const AddLoanDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
          ),
          children: [
            _TableHeaderCell('Person'),
            _TableHeaderCell('To Pay', alignRight: true),
            _TableHeaderCell('To Get', alignRight: true),
            _TableHeaderCell('Balance', alignRight: true),
          ],
        ),
      ],
    );
  }

  Widget _TableHeaderCell(String text, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}

class LoanListItem extends StatelessWidget {
  final Loan loan;

  const LoanListItem({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final balance = loan.amountToGet - loan.amountToPay;
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;
    final balanceIndicator =
        balance >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => LoanDetailScreen(loanId: loan.id),
          ),
        );
      },
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            children: [
              _buildTableCell(loan.personName, alignCenter: true),
              _buildTableCell('Rs${loan.amountToPay}',
                  color: Colors.red, alignRight: true),
              _buildTableCell('Rs${loan.amountToGet}',
                  color: Colors.green, alignRight: true),
              _buildBalanceCell(balance, balanceColor, balanceIndicator),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text,
      {Color? color, bool alignRight = false, bool alignCenter = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: alignRight
            ? TextAlign.right
            : alignCenter
                ? TextAlign.center
                : TextAlign.left,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBalanceCell(double balance, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Rs${balance.abs()}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 14),
        ],
      ),
    );
  }
}
