import 'dart:collection';

import 'package:flutter/foundation.dart' show ChangeNotifier;

enum AccountType { manager, worker }

class AccountModel extends ChangeNotifier {
  AccountType _type = .manager;

  AccountType get type => _type;

  void setType(AccountType type) {
    _type = type;
    notifyListeners();
  }
}

class JobData {
  int id;
  String crop;
  String location;
  String description;
  int priority;
  int isCompleted;
  int assigned;

  JobData({
    required this.id,
    required this.crop,
    required this.location,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.assigned,
  });

  JobData.fromMap(Map<String, Object?> map)
    : id = map["id"] as int,
      crop = map["crop"] as String,
      location = map["location"] as String,
      description = map["description"] as String,
      priority = map["priority"] as int,
      isCompleted = map["is_completed"] as int,
      assigned = map["assigned"] as int;

  Map<String, Object?> toMap() {
    return {
      "crop": crop,
      "location": location,
      "description": description,
      "priority": priority,
      "is_completed": isCompleted,
      "assigned": assigned,
    };
  }
}

class JobList extends ChangeNotifier {
  final List<JobData> _jobs = [];

  UnmodifiableListView<JobData> get items => UnmodifiableListView(_jobs);

  void add(JobData job) {
    _jobs.add(job);
    notifyListeners();
  }

  void removeJob(JobData job) {
    _jobs.remove(job);
    notifyListeners();
  }

  void removeAll() {
    _jobs.clear();
    notifyListeners();
  }

  bool has(JobData job) {
    return _jobs.contains(job);
  }
}
