extends Node

@export var worldReference : NPCSpawner
@export var boardReference : ScrabbleBoard
@export var playerReference : PlayerController
@export var borderReference : TextureRect
@export var barReference : TextureProgressBar

var tutorialLabelSettings:LabelSettings

func _ready() -> void:
	playerReference.isGameRunning = false
	barReference.isDecaying = false
	tutorialLabelSettings = LabelSettings.new()
	tutorialLabelSettings.outline_color = Color.BLACK
	tutorialLabelSettings.font_size = 20
	tutorialLabelSettings.outline_size = 4
	pass # Replace with function body.

var tutorialStep = 0

var shrinkTimer = 5.0
var isShrinking:bool = false
func _process(delta: float) -> void:
	for i in range(tutorialTexts.size() - 1, -1, -1):
		var text:TutorialText = tutorialTexts[i]
		if text.lastTutStep < tutorialStep:
			text.timeTillFade = text.timeTillFade - delta
			text.label.modulate.a = text.timeTillFade
			if text.timeTillFade <= 0:
				tutorialTexts.remove_at(i)
				text.label.queue_free()
	
	_doTutorialStep(delta)
	
	if isShrinking:
		boardReference.anchor_left = lerpf(boardReference.anchor_left, 0.525, delta)
		boardReference.anchor_top = lerpf(boardReference.anchor_top, 0.01, delta)
		boardReference.anchor_right = lerpf(boardReference.anchor_right, 0.99, delta)
		boardReference.anchor_bottom = lerpf(boardReference.anchor_bottom, 0.99, delta)
		borderReference.modulate = Color(1, 1, 1, lerpf(borderReference.modulate.a, 1, delta))
		barReference.modulate = Color(1, 1, 1, lerpf(barReference.modulate.a, 1, delta))
		shrinkTimer = shrinkTimer - delta
		if shrinkTimer <= 0:
			queue_free()

func _setAnchors(label:Label, anchors:Vector4):
	label.anchor_left = anchors[0]
	label.anchor_right = anchors[1]
	label.anchor_top = anchors[2]
	label.anchor_bottom = anchors[3]

var timerTillFinish = 3.0
func _doTutorialStep(delta:float):
	match tutorialStep:
			0:
				var label:Label = _newTutorialText("Use Left Mouse Button to drag letters onto the board. Try and form English words!", 1)
				boardReference.add_child(label)
				_setAnchors(label, Vector4(0.01, 0.5, 0.01, 1))
				
				var panLabel:Label = _newTutorialText("Use Right Mouse Button to pan the camera", 1)
				boardReference.add_child(panLabel)
				_setAnchors(panLabel, Vector4(0.01, 0.5, 0.2, 1))
				
				tutorialStep = 1
			1:
				if boardReference.validWords.size() > 0:
					var completeWord:Label = _newTutorialText("Double left click a valid word to complete it", 2)
					boardReference.add_child(completeWord)
					_setAnchors(completeWord, Vector4(0.6, 0.99, 0.4, 1))
					tutorialStep = 2
			2:
				if boardReference.confirmedWords.size() > 1:
					var desiredWord:Label = _newTutorialText("When a word is highlighted blue, it can be sent out of the mouth. A trail of connecting words must be made from that word to the speech center in the frontal lobe (blue part).", 4)
					boardReference.add_child(desiredWord)
					_setAnchors(desiredWord, Vector4(0.01, 0.5, 0.01, 1))
					boardReference.selectDesiredWord("party")
					tutorialStep = 3
			3:
				var tiles = boardReference.find_child("board").getTilesInEndzone()
				if tiles.size() > 0:
					var desiredWord:Label = _newTutorialText("Double click a blue highlighted word to send it to the speech center.", 4)
					boardReference.add_child(desiredWord)
					_setAnchors(desiredWord, Vector4(0.55, 0.99, 0.7, 1))
					tutorialStep = 4
			4:
				if boardReference.desiredWords.size() == 0:
					tutorialStep = 5
			5:
				timerTillFinish = timerTillFinish - delta
				$Label.visible = (1 == ceili(10*timerTillFinish)%2)
				if timerTillFinish <= 0:
					_shrinkToBox()
					tutorialStep = 6

func _shrinkToBox():
	isShrinking = true
	borderReference.visible = true
	barReference.visible = true
	playerReference.isGameRunning = true
	barReference.isDecaying = true
	$wakeup.play()

class TutorialText:
	var label:Label
	var lastTutStep:int
	var timeTillFade = 1.0
	
	func _init(inputLabel:Label, step:int, labelSettings:LabelSettings):
		label = inputLabel
		label.label_settings = labelSettings
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		lastTutStep = step

var tutorialTexts:Array = []
func _newTutorialText(text:String, lastTutStep:int) -> Label:
	var newLabel = Label.new()
	newLabel.text = text
	var newText = TutorialText.new(newLabel, lastTutStep, tutorialLabelSettings)
	tutorialTexts.append(newText)
	return newLabel
