extends Node2D
@export var ContainerNode : SidewaysUContainer = null
func _process(delta):
	if !ContainerNode:
		return
	if Input.is_action_just_pressed("ui_down"):
		ContainerNode.changeToIndex(ContainerNode.getCurrentIndex() + 1)
	if Input.is_action_just_pressed("ui_up"):
		ContainerNode.changeToIndex(ContainerNode.getCurrentIndex() - 1)
