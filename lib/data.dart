enum Account { manager, worker }

class JobData {
  int id;
  String crop;
  String location;
  String description;
  int priority;
  int isCompleted;

  JobData({
    required this.id,
    required this.crop,
    required this.location,
    required this.description,
    required this.priority,
    required this.isCompleted,
  });

  JobData.fromMap(Map<String, Object?> map)
    : id = map["id"] as int,
      crop = map["crop"] as String,
      location = map["location"] as String,
      description = map["description"] as String,
      priority = map["priority"] as int,
      isCompleted = map["is_completed"] as int;

  Map<String, Object?> toMap() {
    return {
      "crop": crop,
      "location": location,
      "description": description,
      "priority": priority,
      "is_completed": isCompleted,
    };
  }
}
