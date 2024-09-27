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
		currentNode[numberOfLetters] = newWord

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

static func letterIsValid(letter: String) -> bool:
	var index = letterToIndex(letter)
	if index >= 0 and index < numberOfLetters:
		return true
	return false

func _ready() -> void:
	_readFile("dict/data.noun")
	_readFile("dict/data.verb")
	_readFile("dict/data.adj")
	_readFile("dict/data.adv")
	
	return

func _process(dt: float) -> void:
	return

static func indexToLetter(index: int) -> String:
	return String.chr(index + 97);

static func letterToIndex(letter: String) -> int:
	var loweredLetter = letter.to_lower()
	return loweredLetter.unicode_at(0) - 97;

func getWordDefinitions(word: String) -> Array:
	var currentNode = dictionaryTree
	var words = []
	for letter in word:
		if letterIsValid(letter) == false or currentNode[letterToIndex(letter)] == null:
			return []
		currentNode = currentNode[letterToIndex(letter)]
	words.append(currentNode[numberOfLetters])
	return words
