extends Node2D
@export var ContainerNode : SidewaysUContainer = null
var RunningAGame = false
var CurrentlyRunning

var TimeSinceInput = 0
func _process(delta):
	if !ContainerNode:
		return
	if Input.is_action_just_pressed("ui_down"):
		ContainerNode.changeToIndex(ContainerNode.getCurrentIndex() + 1)
	if Input.is_action_just_pressed("ui_up"):
		ContainerNode.changeToIndex(ContainerNode.getCurrentIndex() - 1)
	if Input.is_action_just_pressed("ui_accept") and !RunningAGame:
		var exe_path = ProjectSettings.globalize_path("user://index.exe")
		CurrentlyRunning = OS.create_process(exe_path,["--fullscreen"])
		RunningAGame = true
	
	if RunningAGame:
		if not OS.is_process_running(RunningAGame):
			# Process exited
			RunningAGame = false
			print("Game crashed or closed unexpectedly.")
func _ready():
	$Point/AnimationPlayer.play("move")


func _on_container_re_shuffled():
	var colorToSet = ContainerNode.FocusedNode.get_meta("bgColor",Color("7e7ec4"))
	create_tween().tween_property($DisplayContainer/BGColor/TextureRect,"self_modulate",colorToSet,1)
