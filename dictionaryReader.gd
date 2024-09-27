extends Node

const maximumWordLenth = 7
const numberOfLetters = 26
const licenseLength = 29
var dictionaryTree = []

func recursiveLetterAdd(node: Array, depth: int) -> void:
	if depth == maximumWordLenth:
		return
	
	print(depth)
	
	node.resize(26)
	for i in range(26):
		node[i] = []
		recursiveLetterAdd(node[i], depth + 1)

class WordDefinition:
	var words: Array
	var definition: String

func parseWord(inputLine: String, outputWord: WordDefinition) -> bool:
	var splitArray = inputLine.split(" ")
	
	if splitArray.size() < 4:
		return false
	
	var numWords = splitArray[3].to_float()
	for i in range(numWords):
		var index = 4 + 2*i
		var word = splitArray[index]
		if word.contains("_") == false:
			outputWord.words.append(word)
	
	if outputWord.words.is_empty():
		return false
	
	var definitionSplit = inputLine.split(" | ")
	outputWord.definition = definitionSplit[1]
	
	return true

func readFile(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var lineI = 0
	while file.eof_reached() == false:
		var nextLine = file.get_line()
		if lineI >= licenseLength:
			var newWord = WordDefinition.new()
			if parseWord(nextLine, newWord):
				dictionaryTree.append(newWord)
		
		lineI = lineI + 1

func _ready() -> void:
	readFile("dict/data.noun")
	readFile("dict/data.verb")
	readFile("dict/data.adj")
	readFile("dict/data.adv")
	print(dictionaryTree.size())
	return

func _process(dt: float) -> void:
	return
	# print("HOILY FUCKKKK " + String.num(dictionaryTree.size()))
