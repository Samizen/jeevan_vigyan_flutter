class FinancialTransaction {
  int? id;
  int memberId;
  double amount;
  int categoryId;
  String description;
  String transactionDate;

  FinancialTransaction({
    this.id,
    required this.memberId,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'amount': amount,
      'category_id': categoryId,
      'description': description,
      'transaction_date': transactionDate,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'],
      memberId: map['member_id'],
      amount: map['amount'],
      categoryId: map['category_id'],
      description: map['description'],
      transactionDate: map['transaction_date'],
    );
  }
}
