extends PanelContainer

class_name LogicBlocks

@export var is_given_block = false

@export var index_node: Label
@export var input_node: Node2D
@export var origin_node: VBoxContainer
@export var dragging_node: Node2D

var moving = false # 是否被抓起
var to_mouse_position # 被抓起时相对鼠标的坐标
var shadow_block # 积木阴影


signal mouse_motion(pressed)

func pre_compile():
	return false

func compile():
	push_error("积木脚本尚未设置导出函数： " + self.name)
	return ""

func save_block():
	pass


func _on_gui_input(event: InputEvent):
	
	# 当被鼠标抓起
	if event is InputEventMouseButton:
		
		if not event.pressed:
			return false
		
		if not ((event.button_index == MOUSE_BUTTON_LEFT) or
			(event.button_index == MOUSE_BUTTON_RIGHT)):
			return false
		
		if moving:
			return false
		
		else:
			
			if is_given_block:
				emit_signal("mouse_motion",event.pressed)
			
				var block = self.duplicate()
				block.is_given_block = false
				block.to_mouse_position = global_position - get_global_mouse_position()
				block.moving = true
				block.origin_node = origin_node
				block.input_node = input_node
				block.index_node = null

				dragging_node.add_child(block)
				
				block.spawn_shadow()
				return false
				
			if event.button_index == MOUSE_BUTTON_LEFT:
				
				if index_node:
					index_node.visible = false
				
				z_index = 1
				emit_signal("mouse_motion",event.pressed)
				
				to_mouse_position = global_position - get_global_mouse_position()
				reparent(dragging_node)
				moving = true
				
				spawn_shadow()
			
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				
				emit_signal("mouse_motion",event.pressed)
				
				var block = self.duplicate()
				block.is_given_block = false
				block.to_mouse_position = global_position - get_global_mouse_position()
				block.moving = true
				block.origin_node = origin_node
				block.z_index = 1
				block.input_node = input_node
				
				dragging_node.add_child(block)
				
				block.spawn_shadow()
				
				
				

func _init() -> void:
	gui_input.connect(_on_gui_input)


func load_value(value: Array):
	push_error("积木脚本尚未设置加载函数： " + self.name)


func _process(delta: float) -> void:
	
	logic_process()
	


func _ready():
	
	spawn_index_node()
	get_nodes()
	
	
# 生成积木阴影，一般在积木被拿起时生成，用于预览积木放下的位置
func spawn_shadow():
	
	shadow_block = PanelContainer.new()
	shadow_block.custom_minimum_size = self.size
	origin_node.add_child(shadow_block)

	return(shadow_block)

func logic_process():
	
	if index_node:
		index_node.text = str(self.get_index())
	
	# 被拿起
	if moving:
		
		
		global_position = get_global_mouse_position() + to_mouse_position
		
		# 计算阴影位置
		
		if shadow_block != null:
			
			if origin_node != null:
				
				var min_dis = INF
				var min_block = origin_node.get_child(0)
				
				for i in origin_node.get_children():
			
					if abs(i.global_position.y + i.size.y - get_global_mouse_position().y) < min_dis:
				
						min_block = i
						min_dis = abs(i.global_position.y + i.size.y - get_global_mouse_position().y)

				origin_node.move_child(shadow_block, min_block.get_index() )
				
		# 基于 shadow_block 进行预放置位置移动判定
		if self.global_position.x < origin_node.global_position.x - 100:
			modulate = Color(1 , 1 , 1 , 0.6)
		else:
			modulate = Color(1 , 1 , 1 , 1)
			
		
		# 当自身被松开
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) == false and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) == false:
			
			if index_node:
				index_node.visible = true
			
			if self.global_position.x < origin_node.global_position.x - 100:
				if shadow_block != null:
					shadow_block.queue_free()
				self.queue_free()
				
				pass
			
			z_index = 0
			moving = false
			reparent(origin_node)
			
			origin_node.move_child(self , shadow_block.get_index())
				
			shadow_block.queue_free()

func get_nodes():
	
	dragging_node = get_tree().get_current_scene().get_node("Dragging")

func spawn_index_node():
	
	for i in self.get_children():
		if i.get_child_count() <= 0:
			continue
		
		if i.get_children()[0].name == "IndexLabel":
			i.queue_free()
	
	var node = Node2D.new()
	self.add_child(node)
	node.name = "Index"
	node.position = Vector2(-25, self.size.y * 0.5)
	
	var index_node_i = load("res://Scenes/index_label.tscn")
	index_node = index_node_i.instantiate()
	node.add_child(index_node)
	
	if (not is_given_block) and (get_parent() is VBoxContainer):
		index_node.visible = true

func _on_any_block_moved():
	pass
