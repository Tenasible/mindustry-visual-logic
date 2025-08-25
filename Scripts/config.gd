extends Resource

class_name EditorConfig

@export var max_fps: int = 60
@export var compile_when_close: bool = false
@export var ui_scale: float = 1.0
@export var current_version: int = 0

func save_file():
	var file = {
		"max_fps" : max_fps,
		"compile_when_close" : compile_when_close,
		"ui_scale" : ui_scale,
		"current_version" : current_version,
	}
	return file
	

func load_file(file):
	
	var config = JSON.parse_string(file)
	#var is_ok: bool = true
	
	if config == null:
		push_error("加载编辑器设置出错，JSON解析失败")
		return false
	
	if not (
		config.has("max_fps") and
		config.has("compile_when_close") and 
		config.has("ui_scale") and
		config.has("current_version")
	):
		# 重置所有设置
		load_file( str(save_file()) )
		return false
		
	max_fps = config["max_fps"]
	compile_when_close = config["compile_when_close"]
	ui_scale = config["ui_scale"]
	current_version = config["current_version"]
	
	return true
