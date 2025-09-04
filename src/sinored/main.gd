class_name SinoRED
extends Node


#region Your Mod


signal loaded ## Emitted once all setup methods for this mod are called

## Short identifier for your mod. It must be unique among all other mods used by
## a player. It should also match the folder name in the res:// folder where you
## put your mod's files!
const MOD_KEY: String = "sinored"

## A global reference to your mod. Its type must match the class_name (line 1)
static var instance: SinoRED

## There is a Kit class in LORED which has many useful methods for modders. You
## cannot access it directly; so you must call it via get_node("/root/Kit").
## This var is assigned in _ready.
static var kit: Node


#region Ready


## Called when the mod is loaded into LORED for the first time
func _ready() -> void:
	if not kit:
		kit = get_node("/root/Kit")
		kit.signals.mods_loaded.connect(_on_mods_loaded)

	if not instance:
		instance = self


## Called when all mods finish loading
func _on_mods_loaded() -> void:
	# Disconnect so that this method is not called again
	kit.signals.mods_loaded.disconnect(_on_mods_loaded)
	
	#kill_all()
	add_all_lored_resources()
	refresh_all()
	
	# Alert your mod that it finished loading key elements
	loaded.emit()


#endregion


#endregion


#region LORED Modding Kit Methods


### NOTE These methods are designed for modders. 
### Feel free to delete this region.


## Adds all LORED-type resources in the order they must be added. See the method
## descriptions for more details
func add_all_lored_resources() -> void:
	add_stages_in_folder("res://%s/stages" % MOD_KEY)
	add_currencies_in_folder("res://%s/currencies" % MOD_KEY)
	add_jobs_in_folder("res://%s/jobs" % MOD_KEY)
	add_loreds_in_folder("res://%s/loreds" % MOD_KEY)
	add_upgrade_trees_in_folder("res://%s/upgrade trees" % MOD_KEY)
	add_upgrades_in_folder("res://%s/upgrades" % MOD_KEY)


## Results in a blank slate of a game, allowing you to fill it with entirely
## custom LOREDs, currencies, Stages, and Upgrades
static func kill_all() -> void:
	kill_loreds()
	kill_stages()
	kill_upgrades()
	kill_upgrade_trees()
	kill_currencies()
	
	# Kill the leftovers:
	# - Buffs
	# - Dice
	kit.kill_all_else()


static func refresh_all() -> void:
	refresh_stages()
	refresh_trees()


static func reset_all() -> void:
	reset_upgrades()
	reset_currencies()
	reset_stages()
	reset_loreds()


## Returns the signal which is emitted after a prestige finishes resetting everything
static func get_prestiged_signal() -> Signal:
	return kit.signals.prestiged


#region Currency


## Creates a new Currency and stores it in memory. Must be called after its
## Stage has been created (if using a base Stage, you're safe)
static func add_currency(currency_key: StringName, json_path: String) -> void:
	kit.add_currency(currency_key, json_path)


## Scans `path` and subfolders for json files, calling add_currency on valid files
static func add_currencies_in_folder(path: String) -> void:
	var folder_contents: Dictionary[String, String] = dir_contents(path, ".json")
	for key: String in folder_contents.keys():
		add_currency(key, folder_contents[key])


## Adds `amount` to a specified Currency. `amount` can be an int or float,
## or a string in the format of "'mantissa'e'exponent'", e.g. "1e6" or "5.5e20"
static func currency_add_amount(currency_key: StringName, amount: Variant) -> void:
	kit.currency_add_amount(currency_key, amount)


## Sets a specified Currency amount to `amount`
static func currency_set_amount(currency_key: StringName, amount: Variant) -> void:
	kit.currency_set_amount(currency_key, amount)


## Returns the amount of a Currency converted to an int. This will crash the
## game if called when the exponent is greater than 307ish
static func currency_to_int(currency_key: StringName) -> int:
	return kit.currency_to_int(currency_key)


## Returns the amount of a Currency converted to log10
static func currency_to_log10(currency_key: StringName) -> float:
	return kit.currency_to_log10(currency_key)


## Uses the same number formatting function all other Big class Objects in LORED
## use and follows the player's number notation setting
static func currency_get_text(currency_key: StringName) -> String:
	return kit.currency_get_text(currency_key)


#region Comparisons


static func currency_is_equal_to(currency_key: StringName, n: Variant) -> bool:
	return kit.currency_is_equal_to(currency_key, n)


static func currency_is_greater_than(currency_key: StringName, n: Variant) -> bool:
	return kit.currency_is_greater_than(currency_key, n)


static func currency_is_greater_than_or_equal_to(currency_key: StringName, n: Variant) -> bool:
	return kit.currency_is_greater_than_or_equal_to(currency_key, n)


static func currency_is_less_than(currency_key: StringName, n: Variant) -> bool:
	return kit.currency_is_less_than(currency_key, n)


static func currency_is_less_than_or_equal_to(currency_key: StringName, n: Variant) -> bool:
	return kit.currency_is_less_than_or_equal_to(currency_key, n)


#endregion


## Returns a signal which is emitted whenever a Currency amount increases or
## decreases
static func currency_get_changed_signal(currency_key: StringName) -> Signal:
	return kit.currency_get_changed_signal(currency_key)


## Resets the amount, rate, and pending values of all Currencies
static func reset_currencies() -> void:
	kit.reset_currencies()


## This should update the Offline Earnings window with all of the currently-
## existing Currencies
static func refresh_currencies() -> void:
	kit.refresh_currencies()


## Remove Currencies from memory by their keys. If `currencies_to_kill` is
## empty, all Currencies will be killed
static func kill_currencies(currencies_to_kill: Array[StringName] = []) -> void:
	kit.kill_currencies(currencies_to_kill)


#endregion


#region LORED


## Creates a Job using a .json file and stores it in memory for any LORED to use
## Jobs must be added before adding LOREDs which use them.
static func add_job(job_key: StringName, json_path: String) -> void:
	kit.add_job(job_key, json_path)


## Scans `path` and subfolders for json files, calling add_job on valid files
static func add_jobs_in_folder(path: String) -> void:
	var folder_contents: Dictionary[String, String] = dir_contents(path, ".json")
	for key: String in folder_contents.keys():
		add_job(key, folder_contents[key])


## Creates a new LORED using a .json file and stores them in memory. This will
## NOT create a LOREDNode. You must create a Stage scene and place LORED
## placeholder nodes in them. Refer to stage_templace.tscn for help :D
static func add_lored(lored_key: StringName, json_path: String) -> void:
	kit.add_lored(lored_key, json_path)


## Scans `path` and subfolders for json files, calling add_lored on valid files
static func add_loreds_in_folder(path: String) -> void:
	var folder_contents: Dictionary[String, String] = dir_contents(path, ".json")
	for key: String in folder_contents.keys():
		add_lored(key, folder_contents[key])


## Removes LOREDs from memory by their keys. If `loreds_to_kill` is empty,
## it will kill every LORED. Murdered LOREDs cannot be resurrected.
static func kill_loreds(loreds_to_kill: Array[StringName] = []) -> void:
	kit.kill_loreds(loreds_to_kill)


## Resets all of the current LOREDs in memory to level 1.
static func reset_loreds() -> void:
	kit.reset_loreds()


#endregion


#region Save


static func edit_save_data(mod_key: StringName, data: Variant) -> void:
	kit.edit_save_data(mod_key, data)


#endregion


#region Stage


## Creates a new Stage using a .json file
static func add_stage(stage_key: StringName, json_path: String) -> void:
	kit.add_stage(stage_key, json_path)


## Scans `path` and subfolders for json files, calling add_stage on valid files
static func add_stages_in_folder(path: String) -> void:
	var folder_contents: Dictionary[String, String] = dir_contents(path, ".json")
	for key: String in folder_contents.keys():
		add_stage(key, folder_contents[key])


## Must be called once you're done adding Stages and LOREDs
static func refresh_stages() -> void:
	kit.refresh_stages()


## Resets the statistics of every Stage in memory
static func reset_stages() -> void:
	kit.reset_stages()


## Removes Stages from memory by their keys. Does not affect LOREDs who are
## kept in memory. Deletes Stage UI and stats only.
static func kill_stages(stages_to_kill: Array[StringName] = []) -> void:
	kit.kill_stages(stages_to_kill)


#endregion


#region UI


## Spawns a lil label with (optionally) an icon. It lasts for about 1 second
static func throw_text_from_node(spawn_node: Node, text: String, icon: Texture2D = null) -> void:
	kit.throw_text_from_node(spawn_node, text, icon)


#endregion


#region Upgrade


## Stores a new Upgrade in memory by a key and a path to the json containing the
## Upgrade's data
static func add_upgrade(upgrade_key: StringName, json_path: String) -> void:
	kit.add_upgrade(upgrade_key, json_path)


## Scans `path` and subfolders for json files, calling add_upgrade on valid files
static func add_upgrades_in_folder(path: String) -> void:
	var folder_contents: Dictionary[String, String] = dir_contents(path, ".json")
	for upgrade_key: String in folder_contents.keys():
		add_upgrade(upgrade_key, folder_contents[upgrade_key])


## Returns a signal that is emitted whenever an Upgrade is purchased or reset
func upgrade_get_times_purchased_signal(currency_key: StringName) -> Signal:
	return kit.upgrade_get_times_purchased_signal(currency_key)


## Sets all Upgrades in memory to unpurchased
## (except `unlock_upgrades` which unlocks the Upgrades window)
static func reset_upgrades() -> void:
	kit.reset_upgrades()


## Remove Upgrades from memory by their keys. If `upgrades_to_kill` is empty,
## all Upgrades will be killed
static func kill_upgrades(upgrades_to_kill: Array[StringName] = []) -> void:
	kit.kill_upgrades(upgrades_to_kill)


#endregion


#region Upgrade Tree


## Stores a new Upgrade Tree in memory by a key and a path to the json
## containing the Upgrade Tree's data
static func add_upgrade_tree(tree_key: StringName, json_path: String) -> void:
	kit.add_upgrade_tree(tree_key, json_path)


## Scans `path` and subfolders for json files, calling add_upgrade_tree on valid files
static func add_upgrade_trees_in_folder(path: String) -> void:
	var folder_contents: Dictionary[String, String] = dir_contents(path, ".json")
	for key: String in folder_contents.keys():
		add_upgrade_tree(key, folder_contents[key])


## This will scan all Upgrade Tree scenes for nodes which must be replaced with
## Upgrade Nodes. This should be called once all Tree and Upgrades are added
static func refresh_trees() -> void:
	kit.refresh_trees()


## Remove Upgrade Trees from memory by their keys. If `trees_to_kill` is empty,
## all Upgrade Trees will be killed
static func kill_upgrade_trees(trees_to_kill: Array[StringName] = []) -> void:
	kit.kill_upgrade_trees(trees_to_kill)


#endregion


#region Utility


## Uses the same number formatting function all other numbers in LORED use and
## follows the player's number notation setting.
## Example: 3.234897239 -> "3.2"
## Example: 2_398_745_982 -> "2.4B"
static func format_number(number: float) -> String:
	return kit.format_number(number)


static func get_random_color() -> Color:
	return Color(randf(), randf(), randf(), 1.0)


## Given a float, has a chance to return the value either rounded up or down
## based on the decimal value of the float
static func roll_as_int(value: float) -> int:
	var chance_to_return_plus_one := value - floorf(value)
	var result: int = floori(value)
	if randf() < chance_to_return_plus_one:
		result += 1
	return result


## Returns a dictionary of filename: paths on files found in `path` matching
## extension `required_extension`
static func dir_contents(
		path: String,
		required_extension: String,
		_result: Dictionary[String, String] = {}
	) -> Dictionary[String, String]:
	
	required_extension = required_extension.trim_prefix(".")
	path = path.trim_suffix("/")
	
	var directory := DirAccess.open(path)
	if not directory:
		return _result
	
	directory.list_dir_begin()
	var filename: String = directory.get_next()
	
	while not filename.is_empty():
		if directory.current_is_dir():
			dir_contents(path + "/" + str(filename), required_extension, _result)
		else:
			var _name: String = filename.split(".")[0]
			var extension: String = filename
			extension = extension.replace(".remap", "")
			extension = extension.replace(".import", "")
			extension = extension.get_extension()
			
			if required_extension == extension:
				var _path: String = "%s/%s.%s" % [path, _name, extension]
				_result[_name] = _path
		
		filename = directory.get_next()
	
	return _result


#endregion


#endregion
