class_name WordDictionary
extends Node

const maximumWordLenth = 7
const numberOfLetters = 26
const licenseLength = 29
var dictionaryTree = []

class WordDefinition:
	var words: Array
	var definition: String

func _addWordToDictionary(newWord: WordDefinition) -> void:
	for word: String in newWord.words:
		var currentNode = dictionaryTree
		for letterI in range(word.length()):
			var asciiLetter = word.unicode_at(letterI) - 97
			if asciiLetter < 0:
				print(word[letterI])
			if currentNode.is_empty():
				currentNode.resize(numberOfLetters + 1)
			if currentNode[asciiLetter] == null:
				currentNode[asciiLetter] = []
			currentNode = currentNode[asciiLetter]
		
		if currentNode.is_empty():
			currentNode.resize(numberOfLetters + 1)
		currentNode[numberOfLetters] = word

func _bannedCharacterCheck(word: String) -> bool:
	return word.contains("_") or word.contains("-") or word.contains("0") or word.contains("1") or word.contains("2") or word.contains("3") or word.contains("4") or word.contains("5") or word.contains("6") or word.contains("7") or word.contains("8") or word.contains("9") or word.contains("(") or word.contains(")")

func _parseWord(inputLine: String, outputWord: WordDefinition) -> bool:
	var splitArray = inputLine.split(" ")
	
	if splitArray.size() < 4:
		return false
	
	var numWords = splitArray[3].to_float()
	for i in range(numWords):
		var index = 4 + 2*i
		var word = splitArray[index]
		if _bannedCharacterCheck(word) == false:
			word = word.to_lower()
			word = word.replace("'", "")
			word = word.replace(".", "")
			word = word.replace("/", "")
			word = word.replace("-", "")
			outputWord.words.append(word)
	
	if outputWord.words.is_empty():
		return false
	
	var definitionSplit = inputLine.split(" | ")
	outputWord.definition = definitionSplit[1]
	
	return true

func _readFile(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var lineI = 0
	while file.eof_reached() == false:
		var nextLine = file.get_line()
		if lineI >= licenseLength:
			var newWord = WordDefinition.new()
			if _parseWord(nextLine, newWord):
				_addWordToDictionary(newWord)
		
		lineI = lineI + 1

func _readRawText(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var lineI = 0
	while file.eof_reached() == false:
		var nextLine = file.get_line()
		var newWord = WordDefinition.new()
		newWord.words = [nextLine.to_lower()]
		_addWordToDictionary(newWord)
		
		lineI = lineI + 1


static func letterIsValid(letter: String) -> bool:
	var index = letterToIndex(letter)
	if index >= 0 and index < numberOfLetters:
		return true
	return false

func _ready() -> void:
	#_readFile("dict/data.noun")
	#_readFile("dict/data.verb")
	#_readFile("dict/data.adj")
	#_readFile("dict/data.adv")
	_readRawText("res://dict/scrabbleWords.txt")
	
	return

func _process(_dt: float) -> void:
	return

static func indexToLetter(index: int) -> String:
	return String.chr(index + 97);

static func letterToIndex(letter: String) -> int:
	var loweredLetter = letter.to_lower()
	return loweredLetter.unicode_at(0) - 97;

func getWordDefinitions(word: String) -> Array:
	var currentNodes = [dictionaryTree]
	var nextNodes = []
	for letter in word:
		for currentNode in currentNodes:
			if letter == "?":
				for i in range(numberOfLetters):
					if currentNode[i] != null:
						nextNodes.append(currentNode[i])
			elif letterIsValid(letter) == true and currentNode[letterToIndex(letter)] != null:
				nextNodes.append(currentNode[letterToIndex(letter)])
		currentNodes = nextNodes
		nextNodes = []
	
	var words = []
	for currentNode in currentNodes:
		if currentNode[numberOfLetters] != null:
			words.append(currentNode[numberOfLetters])
		
	return words

func randomlyGenerateWord() -> String:
	var letterIndex = randi()%numberOfLetters
	var currentNode = dictionaryTree
	var word = ""
	while currentNode[letterIndex] != null:
		currentNode = currentNode[letterIndex]
		word = word + indexToLetter(letterIndex)
		letterIndex = randi()%numberOfLetters
		if currentNode[numberOfLetters] == null:
			while currentNode[letterIndex] == null:
				letterIndex = (letterIndex + 1)%numberOfLetters
	return word
