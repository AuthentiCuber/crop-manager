class JobData {
  int id;
  String crop;
  String location;
  String description;
  int priority;

  JobData({
    required this.id,
    required this.crop,
    required this.location,
    required this.description,
    required this.priority,
  });

  JobData.fromMap(Map<String, Object?> map)
    : id = map["id"] as int,
      crop = map["crop"] as String,
      location = map["location"] as String,
      description = map["description"] as String,
      priority = map["priority"] as int;

  Map<String, Object?> toMap() {
    return {
      "crop": crop,
      "location": location,
      "description": description,
      "priority": priority,
    };
  }
}
