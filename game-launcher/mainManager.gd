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

func _ready():
	$Point/AnimationPlayer.play("move")
