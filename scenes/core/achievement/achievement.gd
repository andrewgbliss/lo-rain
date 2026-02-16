class_name Achievement extends Resource

var achievement_id: String
var achievement_name: String
var achievement_description: String
var achievement_status: AchievementStatus = AchievementStatus.AVAILABLE

enum AchievementStatus {
	AVAILABLE,
  STARTED,
	COMPLETED,
}
