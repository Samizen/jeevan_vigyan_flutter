class Transaction {
  final int? id;
  final int? memberId;
  final double amount;
  final int categoryId;
  final String? description;
  final DateTime transactionDate;

  Transaction({
    this.id,
    this.memberId,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'amount': amount,
      'category_id': categoryId,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      memberId: map['member_id'],
      amount: map['amount'],
      categoryId: map['category_id'],
      description: map['description'],
      transactionDate: DateTime.parse(map['transaction_date']),
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, memberId: $memberId, amount: $amount, categoryId: $categoryId, description: $description, transactionDate: $transactionDate}';
  }
}
