class ExpenseDetailModel {
  final String id;
  final String date;
  final String description;
  final String currency;
  final String expenseAmount;
  final String costCenter;
  final String expenseAnalysis;
  final String amountInEmployeeCurrency;

  ExpenseDetailModel({
    required this.id,
    required this.date,
    required this.description,
    required this.currency,
    required this.expenseAmount,
    required this.costCenter,
    required this.expenseAnalysis,
    required this.amountInEmployeeCurrency,
  });

  ExpenseDetailModel copyWith({
    String? id,
    String? date,
    String? description,
    String? currency,
    String? expenseAmount,
    String? costCenter,
    String? expenseAnalysis,
    String? amountInEmployeeCurrency,
  }) {
    return ExpenseDetailModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      expenseAmount: expenseAmount ?? this.expenseAmount,
      costCenter: costCenter ?? this.costCenter,
      expenseAnalysis: expenseAnalysis ?? this.expenseAnalysis,
      amountInEmployeeCurrency:
          amountInEmployeeCurrency ?? this.amountInEmployeeCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'currency': currency,
      'expenseAmount': expenseAmount,
      'costCenter': costCenter,
      'expenseAnalysis': expenseAnalysis,
      'amountInEmployeeCurrency': amountInEmployeeCurrency,
    };
  }

  factory ExpenseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExpenseDetailModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      currency: json['currency'] ?? '',
      expenseAmount: json['expenseAmount'] ?? '',
      costCenter: json['costCenter'] ?? '',
      expenseAnalysis: json['expenseAnalysis'] ?? '',
      amountInEmployeeCurrency: json['amountInEmployeeCurrency'] ?? '',
    );
  }

  // Calculate total amount for summary
  double get totalAmount {
    try {
      return double.parse(expenseAmount.isEmpty ? '0' : expenseAmount);
    } catch (e) {
      return 0.0;
    }
  }
}
