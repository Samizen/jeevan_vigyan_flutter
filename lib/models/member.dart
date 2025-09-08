class Member {
  int? id;
  String name;
  String contactNo;
  String memberAddedDate; // Keep this as String

  Member({
    this.id,
    required this.name,
    required this.contactNo,
    required this.memberAddedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_no': contactNo,
      'member_added_date': memberAddedDate,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      contactNo: map['contact_no'],
      memberAddedDate: map['member_added_date'],
    );
  }
}
