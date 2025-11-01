@tool
@icon("res://icons/SidewaysUContainer.svg")
extends Container
class_name SidewaysUContainer

## A container that moves it stuff in a ⸧ like shape. Like a hyperbola.


@export var FocusedNode : Control = null: ## Determines the node that is currently selected.
		set(value): FocusedNode = value; queue_sort()

@export var YSpacing : float = 120.0: ## Determines the Y spacing between each control node that is a child
		set(value): YSpacing = value; queue_sort()

@export var XSpacing : float = -30.0: ## The horizontal offset applied per distance step from the FocusedNode.
		set(value): XSpacing = value; queue_sort()
@export var MoveDuration : float = 1.0 ## The duration (in seconds) of tweens when adjusting node positions.
@export var Wrap = false ## When this is true, using changeToIndex on a index that is out of range will cause it to loop around
@export var SelectedXOffset : float = 30.0: ## The horizontal offset applied to the focused node.
		set(value): SelectedXOffset = value; queue_sort()
@export var Exponent : float = 1.0: ## Exponent applied to the x offset. This can give it a less linear curve.
		set(value): Exponent = value; queue_sort()


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var focusedID = get_children().find(FocusedNode)
		for c in get_children():
			if c is Control:
				
				var target_pos = Vector2(
					abs(get_children().find(c) - focusedID)**Exponent * XSpacing,
					(get_children().find(c) - focusedID) * YSpacing + (size.y / 2)
				)
				if c == FocusedNode:
					target_pos.x = SelectedXOffset
				var tween = create_tween()
				tween.tween_property(c, "position", target_pos, MoveDuration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func getCurrentIndex() -> int:
	return get_children().find(FocusedNode)

func changeToIndex(index):
	if Wrap:
		FocusedNode = get_child(wrap(index,0,get_children().size()))
	else:
		FocusedNode = get_child(clamp(index,0,get_children().size() - 1))
