extends Node2D
@export var ContainerNode : SidewaysUContainer = null
var RunningAGame = false
var CurrentlyRunning
var TimeSinceInput = 0

var dataDictionary = {}

var BaseGameScene = preload("res://buttonTest1.tscn")

func _process(delta):
	if !ContainerNode:
		return
	if Input.is_action_just_pressed("ui_down"):
		ContainerNode.changeToIndex(ContainerNode.getCurrentIndex() + 1)
		updateSelect()
	if Input.is_action_just_pressed("ui_up"):
		ContainerNode.changeToIndex(ContainerNode.getCurrentIndex() - 1)
		updateSelect()
	
	if Input.is_action_just_pressed("ui_accept") and !RunningAGame:
		if ContainerNode.FocusedNode.get_meta("type","") == "play":
			
			var gameName = ContainerNode.FocusedNode.get_meta("game","")
			var exe_path = ProjectSettings.globalize_path("user://" + gameName  + "/game.exe")
			print(exe_path)
			CurrentlyRunning = OS.create_process(exe_path,["--fullscreen","--locale=" + TranslationServer.get_locale()])
			RunningAGame = true
		elif  ContainerNode.FocusedNode.get_meta("type","") == "translate":
			if TranslationServer.get_locale() == 'en':
				TranslationServer.set_locale('ja')
			else:
				TranslationServer.set_locale('en')
	
	if RunningAGame:
		if not OS.is_process_running(RunningAGame):
			# Process exited
			RunningAGame = false
			print("Game crashed or closed unexpectedly.")
	
	if TranslationServer.get_locale() == 'en':
		$Label.text = "choose a game"
	else:
		$Label.text = "ゲームを選ぶ"

func updateSelect():
	if ContainerNode.FocusedNode.get_meta("type","") == "play":
		$GameShowcase.visible = true
		var gameName = ContainerNode.FocusedNode.get_meta("game","")
		$GameShowcase/NinePatchRect/Creator.texture = dataDictionary[gameName].get("creator",null)
		$GameShowcase/NinePatchRect/GameLogo.texture = dataDictionary[gameName].get("logo",null)
		$GameShowcase/ImageSkewer/ColorRect/Promo.texture = dataDictionary[gameName].get("promo",null)
		var complexScore = dataDictionary[gameName]["data"].get("complexityScore",-1)
		
		if complexScore == -1:
			$GameShowcase/ComplexityScoreHolder.visible = false
		else:
			$GameShowcase/ComplexityScoreHolder/TextureProgressBar.value = complexScore
			$GameShowcase/ComplexityScoreHolder.visible = true
		
		if TranslationServer.get_locale() == 'en':
			$GameShowcase/ImageSkewer/ColorRect/Desc.text = dataDictionary[gameName]["data"].get("desc","")
			$GameShowcase/NinePatchRect/GameName.text = dataDictionary[gameName]["data"].get("game_name","???")
			$GameShowcase/NinePatchRect/CreatorName.text = "By " + dataDictionary[gameName]["data"].get("creator_name","???")
			$GameShowcase/NinePatchRect/Time.text = dataDictionary[gameName]["data"].get("hours","") + " Hours"
		else:
			$GameShowcase/ImageSkewer/ColorRect/Desc.text = dataDictionary[gameName]["data"].get("desc_ja","")
			$GameShowcase/NinePatchRect/GameName.text = dataDictionary[gameName]["data"].get("game_name_ja","???")
			# NOTE TO SELF LATER: ADD PROPER TRANSLATED 'BY NAME' HERE
			
		
	else:
		$GameShowcase.visible = false



func _ready():
	$Point/AnimationPlayer.play("move")
	TranslationServer.set_locale('en')
	parseInfo()
	createButtons()
	ContainerNode.changeToIndex(1)
	updateSelect()

func createButtons():
	#for E in $DisplayContainer/Container.get_children():
	#	E.queue_free()
	for dataDict in dataDictionary.keys():
		var NewButton = BaseGameScene.instantiate()
		NewButton.set_meta("type","play")
		NewButton.set_meta("game",dataDict)
		NewButton.get_node("Control/NinePatchRect/Logo").texture = dataDictionary[dataDict].get("logo",null)
		NewButton.get_node("Control/NinePatchRect/Dev").texture = dataDictionary[dataDict].get("creator",null)
		$DisplayContainer/Container.add_child(NewButton)

func parseInfo():
	var directories = DirAccess.get_directories_at("user://")
	for dir in directories:
		var files = DirAccess.get_files_at("user://" + dir)
		if "data.json" in files: # check if we have the json that defines a game
			dataDictionary[dir] = {}
			var opening = FileAccess.open("user://" + dir + "/data.json",FileAccess.READ)
			var datastring = opening.get_as_text()
			opening.close()
			
			
			dataDictionary[dir]["data"] = JSON.parse_string(datastring)
			var cutFiles = {}
			for filename in files:
				cutFiles[filename.get_basename()] = filename
			
			var seekingFiles = ["creator","logo","promo"]
			for type in seekingFiles:
				# Add the things
				if type in cutFiles: dataDictionary[dir][type] = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path("user://"+dir +"/"+ cutFiles[type] )))
			
			
			
	print(dataDictionary)

func _on_container_re_shuffled():
	if ContainerNode.FocusedNode:
		var colorToSet = ContainerNode.FocusedNode.get_meta("bgColor",Color("7e7ec4"))
		create_tween().tween_property($DisplayContainer/BGColor/TextureRect,"self_modulate",colorToSet,1)
