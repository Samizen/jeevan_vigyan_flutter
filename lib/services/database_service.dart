import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:jeevan_vigyan/models/category.dart';
import 'package:jeevan_vigyan/models/member.dart';
import 'package:jeevan_vigyan/models/financial_transaction.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'jeevan_vigyan.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Members (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        contact_no TEXT,
        member_added_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Category (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Transactions (
        id INTEGER PRIMARY KEY,
        member_id INTEGER,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        description TEXT,
        transaction_date TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES Members(id),
        FOREIGN KEY (category_id) REFERENCES Category(id)
      )
    ''');
  }

  Future<void> populateDummyData() async {
    final db = await database;

    await db.delete('Members');
    await db.delete('Category');
    await db.delete('Transactions');

    final member1Id = await db.insert(
      'Members',
      Member(
        name: 'राम बहादुर',
        contactNo: '9841000000',
        memberAddedDate: '2082/01/01',
      ).toMap(),
    );
    final member2Id = await db.insert(
      'Members',
      Member(
        name: 'सिता देवी',
        contactNo: '9841111111',
        memberAddedDate: '2082/02/01',
      ).toMap(),
    );

    final incomeCategoryId = await db.insert(
      'Category',
      Category(type: 'आय', name: 'मासिक सदस्यता').toMap(),
    );
    final expenseCategoryId = await db.insert(
      'Category',
      Category(type: 'खर्च', name: 'कार्यालय भाडा').toMap(),
    );
    final otherIncomeId = await db.insert(
      'Category',
      Category(type: 'आय', name: 'चन्दा/दान').toMap(),
    );
    final otherExpenseId = await db.insert(
      'Category',
      Category(type: 'खर्च', name: 'बिजुलीको बिल').toMap(),
    );

    await db.insert(
      'Transactions',
      FinancialTransaction(
        memberId: member2Id,
        amount: 3000.0,
        categoryId: incomeCategoryId,
        description: 'श्रावण महिनाको सदस्यता',
        transactionDate: '2082/04/17',
      ).toMap(),
    );

    await db.insert(
      'Transactions',
      FinancialTransaction(
        memberId: member1Id,
        amount: 3000.0,
        categoryId: expenseCategoryId,
        description: 'श्रावण महिनाको भाडा',
        transactionDate: '2082/04/17',
      ).toMap(),
    );

    await db.insert(
      'Transactions',
      FinancialTransaction(
        memberId: member2Id,
        amount: 2500.0,
        categoryId: otherIncomeId,
        description: 'पौराणिक चन्दा',
        transactionDate: '2082/04/16',
      ).toMap(),
    );

    await db.insert(
      'Transactions',
      FinancialTransaction(
        memberId: member1Id,
        amount: 1500.0,
        categoryId: otherExpenseId,
        description: 'भदौ महिनाको बिल',
        transactionDate: '2082/05/10',
      ).toMap(),
    );

    print('Database populated with dummy data.');
  }

  Future<List<Member>> getMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Members');
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Category');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<FinancialTransaction>> getTransactionsByMonth(
    int year,
    int month,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Transactions',
      where:
          'SUBSTR(transaction_date, 1, 4) = ? AND SUBSTR(transaction_date, 6, 2) = ?',
      whereArgs: [year.toString(), month.toString().padLeft(2, '0')],
      orderBy: 'transaction_date DESC',
    );
    return List.generate(
      maps.length,
      (i) => FinancialTransaction.fromMap(maps[i]),
    );
  }

  Future<int> insertTransaction(FinancialTransaction transaction) async {
    final db = await database;
    return await db.insert('Transactions', transaction.toMap());
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('Category', category.toMap());
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Category',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> insertMember(Member member) async {
    final db = await database;
    return await db.insert(
      'Members',
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMember(Member member) async {
    final db = await database;
    await db.update(
      'Members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> deleteMember(int id) async {
    final db = await database;
    await db.delete('Members', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<int, Map<int, double>>> getMonthlyContributions(int year) async {
    final db = await database;
    final membershipFeeCategoryId = await _getMembershipFeeCategoryId();

    if (membershipFeeCategoryId == null) {
      return {};
    }

    final List<Map<String, dynamic>> transactions = await db.rawQuery(
      '''
      SELECT member_id, amount, transaction_date FROM Transactions
      WHERE category_id = ? AND SUBSTR(transaction_date, 1, 4) = ?
      ''',
      [membershipFeeCategoryId, year.toString()],
    );

    return _convertTransactionToMonthlyMap(transactions);
  }

  Future<int?> _getMembershipFeeCategoryId() async {
    final db = await database;
    final result = await db.query(
      'Category',
      where: 'name = ?',
      whereArgs: ['मासिक सदस्यता'],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;
  }

  Map<int, Map<int, double>> _convertTransactionToMonthlyMap(
    List<Map<String, dynamic>> transactionData,
  ) {
    Map<int, Map<int, double>> monthlyContributions = {};

    for (var transaction in transactionData) {
      final memberId = transaction['member_id'] as int?;
      if (memberId == null) continue;

      final amount = transaction['amount'] as double;
      final dateString = transaction['transaction_date'] as String;

      // Extract month from the date string 'YYYY/MM/DD'
      final month = int.parse(dateString.substring(5, 7));

      monthlyContributions.putIfAbsent(memberId, () => {});
      monthlyContributions[memberId]!.update(
        month,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    return monthlyContributions;
  }

  Future<List<FinancialTransaction>> getTransactionsByDateRange({
    required NepaliDateTime startDate,
    required NepaliDateTime endDate,
  }) async {
    final db = await database;

    final formattedStartDate = startDate
        .toString()
        .substring(0, 10)
        .replaceAll('-', '/');
    final formattedEndDate = endDate
        .toString()
        .substring(0, 10)
        .replaceAll('-', '/');

    final List<Map<String, dynamic>> maps = await db.query(
      'Transactions',
      where: 'transaction_date >= ? AND transaction_date <= ?',
      whereArgs: [formattedStartDate, formattedEndDate],
      orderBy: 'transaction_date DESC',
    );

    return List.generate(
      maps.length,
      (i) => FinancialTransaction.fromMap(maps[i]),
    );
  }
}
