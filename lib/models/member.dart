class Member {
  final int? id;
  final String name;
  final String? contactNo;
  final DateTime memberAddedDate;

  Member({
    this.id,
    required this.name,
    this.contactNo,
    required this.memberAddedDate,
  });

  // Convert a Member object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_no': contactNo,
      'member_added_date': memberAddedDate.toIso8601String(),
    };
  }

  // A factory constructor to create a Member from a Map (e.g., from a database query result).
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      contactNo: map['contact_no'],
      memberAddedDate: DateTime.parse(map['member_added_date']),
    );
  }

  @override
  String toString() {
    return 'Member{id: $id, name: $name, contact_no: $contactNo, member_added_date: $memberAddedDate}';
  }
}
