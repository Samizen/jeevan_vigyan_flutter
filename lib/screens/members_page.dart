import 'package:flutter/material.dart';
import 'package:jeevan_vigyan/constants/colors.dart';
import 'package:jeevan_vigyan/models/member.dart';
import 'package:jeevan_vigyan/services/database_service.dart';
import 'package:jeevan_vigyan/screens/add_member_form.dart';

// Helper function to convert numbers to Nepali
String _convertToNepali(String number) {
  const Map<String, String> nepaliNumbers = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
  };
  return number.replaceAllMapped(RegExp(r'[0-9]'), (match) {
    return nepaliNumbers[match.group(0)!]!;
  });
}

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final DatabaseService _dbService = DatabaseService();
  List<Member> _members = [];
  final TextEditingController _searchController = TextEditingController();
  List<Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    final members = await _dbService.getMembers();
    if (mounted) {
      setState(() {
        _members = members;
        _filteredMembers = _members;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        return member.name.toLowerCase().contains(query) ||
            member.contactNo.contains(query);
      }).toList();
    });
  }

  void _showAddMemberForm({Member? member}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddMemberForm(memberToEdit: member);
      },
    );
    _fetchMembers();
  }

  void _deleteMember(int memberId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('सदस्य हटाउनुहोस्'),
          content: const Text('के तपाई यो सदस्य हटाउन निश्चित हुनुहुन्छ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('होइन'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('हो'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _dbService.deleteMember(memberId);
      _fetchMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'जीवन विज्ञान, गठ्ठाघर शाखा',
                    style: TextStyle(
                      fontFamily: 'Yantramanav',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.maroonishRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'अर्थ व्यवस्थापन',
                    style: TextStyle(
                      fontFamily: 'Yantramanav',
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      color: AppColors.maroonishRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _showAddMemberForm(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.lighterGray),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.charcoalBlack,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'सदस्य थप्नुहोस्',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.charcoalBlack),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lighterGray),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'सदस्य खोज्नुहोस्',
                    hintStyle: const TextStyle(color: AppColors.gray),
                    prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'सदस्य सूची',
                  style: TextStyle(
                    fontFamily: 'Yantramanav',
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: AppColors.maroonishRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_filteredMembers.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_add_disabled,
                        size: 60,
                        color: AppColors.gray,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'हाल कुनै सदस्य छैनन्।',
                        style: TextStyle(
                          fontFamily: 'Yantramanav',
                          fontSize: 18,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.lighterGray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _filteredMembers.map((member) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: MemberListItem(
                          member: member,
                          onEdit: () => _showAddMemberForm(member: member),
                          onDelete: () => _deleteMember(member.id!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// A widget to display each member in the list, with swipe actions
class MemberListItem extends StatelessWidget {
  final Member member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberListItem({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(member.id.toString()), // Use a stable key
      background: Container(
        color: AppColors.brightGreen,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: AppColors.maroonishRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        return false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                member.name,
                style: const TextStyle(
                  fontFamily: 'Yantramanav',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.charcoalBlack,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                if (member.contactNo.isNotEmpty)
                  Text(
                    _convertToNepali(member.contactNo),
                    style: const TextStyle(
                      fontFamily: 'Yantramanav',
                      fontSize: 16,
                      color: AppColors.charcoalBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _convertToNepali(member.memberAddedDate),
                  style: const TextStyle(
                    fontFamily: 'Yantramanav',
                    fontSize: 14,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
