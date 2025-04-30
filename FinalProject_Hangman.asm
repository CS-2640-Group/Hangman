# Final Project: Hangman

# We will recreate the classic children's game "hangman." The objective of the game is to guess the word before the entire stick figure
# ("the hangman") is drawn. Player 1 chooses a word. Our program prints out underscores for each letter in the word. Player 2 must try to figure
# out what the word is by guessing one letter at a time. If Player 2 guesses a correct letter, the corresponding underscore(s) will be replaced 
# with that letter. If Player 2 guesses the word incorrectly, another limb (e.g. arm, torso, leg) will be added to the hangman. Player 2 can also
# guess the entire word to finish the game, but if they get it wrong any correct letters within the word will be ignored. 

# Athena Ballensky, Scott Baroni, Adam Mitchell, William Mo
# 4/18/2025
# CS 2610.02
.include "Bitmap_Macros.asm"
.include "Strings.asm"

# Bitmap Colors
.eqv green, 0x0000FF00		# green color
.eqv red, 0x00FF0000       	# red color
.eqv white, 0xFFFFFFFF    	 # white color

.data
# strings in MARS are just an array of characters
# even though this looks like one string, we will be able to access it character by character 
alphabet: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
underscore: .asciiz "_ "
enterWord: .asciiz "Player 1, please enter a word for Player 2 to guess: "
enterCharGuess: .asciiz "\nPlayer 2, enter your next character guess or type 1 to guess a word: "
enterWordGuess: .asciiz "\nPlayer 2, enter your word guess: "
wordBuffer: .space 200 #buffer to hold Player 1's word
wordGuessBuffer: .space 200 #buffer to hold Player 2's word guess
correctGuess: .asciiz "\nCorrect guess" #used for branch testing - DELETE LATER
incorrectGuess: .asciiz "\nIncorrect guess" #used for branch testing - DELETE LATER
aMsg: .asciiz "A" #used as a filler - DELETE LATER
newline: .asciiz "\n"

.text
main:
	.eqv loopCounter $t1
	.eqv wordCounter $t2 #number of characters in Player 1's word
	.eqv wordBufferAdd $t3 #address for the wordBuffer
	.eqv currByte $t4 #current byte
	.eqv currChar $t5 #Player 2's current 1-character guess 
	.eqv limbCounter $t6 #count limbs on Hangman to determine if Player 2 has lost or can continue to guess 
	.eqv one $s0 #will store the ASCII value of one
	
	
	printLabel(enterWord) #ask Player 1 to enter a word
	readString(wordBuffer, 201) #get Player 1's word
	
	
	
	la wordBufferAdd, wordBuffer #store wordBuffer address in wordBufferAdd
	
	#CODE LATER if there's extra time: convert Player 1's word plus Player 2's char and word guesses to uppercase so that word casing doesn't matter
	toUpperCase(wordBufferAdd)
	
	move wordCounter, $zero #set wordCounter to 0
	move loopCounter, $zero #set loopCounter to 0 
	
#count the number of characters in Player 1's word 
## -- Using stringGetLength instead
stringGetLength(wordBufferAdd, wordCounter)
#wordLoop:
#	lb currByte, 0(wordBufferAdd) #load the current byte at wordBufferAdd into currByte
#	beqz currByte, printUnderscores #if current byte is 0 (we've hit the null terminator), exit loop
#	
#	addi wordBufferAdd, wordBufferAdd, 1 #increment wordBufferAdd by 1
#	addi wordCounter, wordCounter, 1 #increment wordCounter by 1
#	j wordLoop #repeat loop

#preparation to use the printUnderscoresLoop to print underscores
printUnderscores:
	subi wordCounter, wordCounter, 1 #subtract 1 from wordCounter because it's counted one too many times

#print 1 underscore per 1 char in Player 1's word
printUnderscoresLoop: 
	printLabel(underscore)
	addi loopCounter, loopCounter, 1 # increment loopCounter by 1
	blt loopCounter, wordCounter, printUnderscoresLoop # if loopCounter < number of chars in Player 1's word, repeat loop

# Get Player 2's one letter guess
#	- if they type 1, jump to getWordGuess (the code for guessing a word)
#	- if they guess a correct letter, jump to correctCharGuess to replace appropriate underscore(s) with that letter
#	- if they guess an incorrect letter, jump to incorrectCharGuess to add a limb to the Hangman bitmap and increment limb counter	
getCharGuess:
	printLabel(enterCharGuess) #prompt Player 2 to guess a character 
	readChar(currChar) #save char from user to currChar
	
	# Uppercase the char
	toUpperCaseByte(currChar)
	
	li one, 49 #load ASCII code for '1' into one
	beq currChar, one, getWordGuess #if the currChar is 1, jump to getWordGuess
	
	#CODE SOON: conditions to exit getCharGuess:
	#	- hangman has been fully drawn (use limb counter from wrongCharGuess to keep track)
	#	- every invidual character of Player 1's word has been guessed
	
	la wordBufferAdd, wordBuffer #store wordBuffer address in wordBufferAdd
	
	#loops through all of the characters in Player 1's word to check for a match with Player's 2's currChar guess
	wordLoop2:
		lb currByte, 0(wordBufferAdd) #load the current byte at wordBufferAdd into currByte
		#if current byte is 0, we've hit the null terminator, which means we've looped through Player 2's entire word without finding currChar
		#therefore, Player 2's currChar guess was incorrect, and we jump to incorrectCharGuess
		beqz currByte, incorrectCharGuess 
		
		beq currByte, currChar, correctCharGuess #if the current char in Player 2's word matches currChar, branch to correctCharGuess
		
		addi wordBufferAdd, wordBufferAdd, 1 #increment wordBufferAdd by 1
		j wordLoop2 #repeat loop
		
#For when Player 2 guesses a correct character 
#	- Replace appropriate underscore(s) with the character
#		- Reminder: for words with repeated letters (e.g. two "l"s in "hello"), must replace all appropriate underscores with the guessed character.
#		  We should loop through the entire word again, comparing it against our guess to acomplish this 
correctCharGuess:
	printLabel(newline)
	la wordBufferAdd, wordBuffer #store wordBuffer address in wordBufferAdd
	
	wordLoop3:
		lb currByte, 0(wordBufferAdd) #load the current byte at wordBufferAdd into currByte
		beqz currByte, reprompt #if currByte is 0 (null), reprompt
		
		addi wordBufferAdd, wordBufferAdd, 1 #increment wordBufferAdd by 1
		
		beq currByte, 10, exit # if new line char, exit program ( program prints extra underscore without this) 
		bne currByte, currChar, printUnderscore #if currByte of Player 1's word /= Player 2's currChar guess, print underscore
		beq currByte, currChar, printCurrChar #if currByte of Player 1's word == Player 2's currChar guess, print the character
	
	#FIX: this currently prints one too many underscores at the end of the word - idk why 
	printUnderscore:
		printLabel(underscore)
		j wordLoop3
	
	printCurrChar:
		printChar(currChar) # This works better im pretty sure
		printSpace # print space for formatting
		# printAddress(currByte) #code broken idk
		# printLabel(aMsg) #prints "A" as a filler for testing until I fix the above line 
		j wordLoop3
	
	reprompt:
	# Reprompt for guess
	j getCharGuess
		

#For when Player 2 guesses an incorrect character
#	- Add one limb to hangman 
#	- Increment limb counter
incorrectCharGuess:
	#code below is being used for branch testing - DELETE LATER
	printLabel(incorrectGuess)
	#j exit
	
	# Add to Limb Counter
	addi limbCounter, limbCounter, 1
	
	printLiteral("\nLimb Count: ")
	printInt(limbCounter)
	
	# Check if the limb counter is equal to 6
	# If so, end game
	beq limbCounter, 6, exit # Exit is temporary, later write a game over screen or something
	
	# Else, add to limbCounter and reprompt for new guess
	j getCharGuess
	
	

# Get Player 2's word guess
#	- triggered when Player 2 types "1" for the next guess prompt 
#	- verify that they entered a word of the correct length, print an error message and prompt them again if they didn't 
#	- if they guess a correct word, print you win and exit
#	- if they guess an incorrect word, add limb, increment limb counter, and return to prompting them for single letter guesses 
getWordGuess:
	printLabel(enterWordGuess) #prompt Player 2 for their word guess
	readString(wordGuessBuffer, 201) #get Player 2's word guess of maximum 200 chars and save it to wordGuessBuffer


# To use the Bitmap Display Tool:
# Go to Tools > Bitmap Display
# Set width and height to 256, base address should be 0x10010000 (static data)
# Select 'Connect to MIPS' then run the main file. Now the drawing should appear
launchDrawing:	# initial drawing when game is launched
	drawHorizLine(100, 90, 150, white)	# draw top short line of gallow
	drawHorizLine(50, 220, 150, white)	# draw bottom long line of gallow
	drawHorizLine(50, 221, 150, white)	# (second line to make it thicker)
	
	drawVertLine(100, 90, 220, white)	# draw long vertical line of gallow
	drawVertLine(99, 90, 220, white)	# (second line to make it thicker)
	drawVertLine(150, 90, 120, white)	# draw short vertical line of gallow

# Drawing parts of body
# Commented out lines are to make the drawing thicker if needed
drawHead:
	# (square head for now)
	drawHorizLine(140, 140, 161, green)	# bottom of head
	#drawHorizLine(140, 141, 161, green)
	drawHorizLine(140, 120, 160, green)	# top of head
	#drawHorizLine(140, 121, 160, green)
	drawVertLine(140, 120, 140, green)	# left of head
	#drawVertLine(141, 120, 140, green)
	drawVertLine(160, 120, 141, green)	# right of head
	#drawVertLine(161, 120, 141, green)
drawBody:
	drawVertLine(150, 140, 180, green)
drawLeftArm:
	drawDiagFrontLine(130, 159, 150, green)	# draw left arm
	#drawDiagFrontLine(130, 160, 150, green)	# make left arm thicker
drawRightArm:
	drawDiagBackLine(150, 140, 160, green)	# draw right arm
	#drawDiagBackLine(151, 140, 160, green)	# make right arm thicker
drawLeftLeg:
	drawDiagFrontLine(130, 199, 150, green)	# draw left leg
	#drawDiagFrontLine(130, 200, 150, green)	# make left leg thicker
drawRightLeg:
	drawDiagBackLine(150, 180, 200, green)	# draw right leg
	#drawDiagBackLine(151, 180, 200, green)	# make right leg thicker
	
# End of program
exit:
	li $v0, 10
	syscall
