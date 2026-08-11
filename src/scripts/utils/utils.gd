## Has static functions to call from anywhere for general purpose
class_name Utils

## Removes the "uid" prefix if there is, to get a valid node name.
static func get_raw_uid(uid: String) -> String:
	return uid.trim_prefix("uid://")

## Generate a random string of the given length.
## The sample is the base64 characters.
## If length is less than 0, return an empty string.
## The max length is 1000.
static func get_random_string(length: int) -> String:
	assert(length >= 0, "Can't have a negative string length!")
	length = clampi(length, 0, 1000)
	var sample: String = "abdcefghijklmnopqrstuvwxyzABDCEFGHIJKLMNOPQRSTUVWXYZ0123456789+/"
	var res: String = ""

	for i: int in range(length):
		res += sample[randi() % 63]

	return res
