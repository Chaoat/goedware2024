extends Node

@export var worldReference : NPCSpawner
@export var boardReference : ScrabbleBoard

var playerReference : Player3D

var isInConversation:bool = false

func _ready() -> void:
	playerReference = worldReference.find_child("Player")

var conversingNPC:NPC = null
func _startConversation(npc:NPC):
	isInConversation = true
	conversingNPC = npc
	playerReference.lockMovement(true)
	for i in range(npc.conversationDifficulty):
		boardReference.randomlySelectDesiredWord()

func _endConversation():
	isInConversation = false
	conversingNPC.talking = false
	playerReference.lockMovement(false)
	for i in range(0,conversingNPC.conversationDifficulty + 1):
		boardReference.addWordToBoard(boardReference.find_child("dictionary").randomlyGenerateWord())

func _process(delta: float) -> void:
	if isInConversation == false:
		for npc:NPC in worldReference.npcList:
			if npc.talking and npc.conversationDifficulty > 0 and boardReference.confirmedWords.size() >= npc.conversationDifficulty:
				_startConversation(npc)
			elif npc.talking:
				npc.talking = false
	else:
		if boardReference.areDesiresCleared():
			_endConversation()
