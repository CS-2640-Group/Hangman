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
.include "Strings_Macros.asm"

# Bitmap Colors
.eqv green, 0x0000FF00		# green color
.eqv red, 0x00FF0000       	# red color
.eqv orange 0x00FFA500	# orange color
.eqv white, 0xFFFFFFFF    	 # white color
.eqv black, 0x00000000		# black color

.data
# strings in MARS are just an array of characters
# even though this looks like one string, we will be able to access it character by character 
alphabet: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
underscore: .asciiz "_ "
enterWord: .asciiz "Player 1, please enter a word for Player 2 to guess: "
enterCharGuess: .asciiz "\nPlayer 2, enter your next character guess or type 1 to guess a word: "
enterWordGuess: .asciiz "\nPlayer 2, enter your word guess: "
youWinMsg: .asciiz "\nYou win!"
youLoseMsg:	.asciiz "\nYou lost..."
exitMsg:	.asciiz	"\n\nThank you for playing!"
wordBuffer: .space 200 #buffer to hold Player 1's word
wordGuessBuffer: .space 200 #buffer to hold Player 2's word guess
wordGuessingBuffer: .space 200 # Buffer to hold Player 2's guessing progress
correctGuess: .asciiz "\nCorrect guess"
incorrectGuessMsg: .asciiz "\nIncorrect guess"
newline: .asciiz "\n"

.text
#Set .eqv for the registers
#Get Player 1's word
#Launch drawing
main:
	.eqv loopCounter $t1
	.eqv wordCounter $t2 #number of characters in Player 1's word
	.eqv wordBufferAdd $t3 #address for the wordBuffer
	.eqv currByte $t4 #current byte
	.eqv currChar $t5 #Player 2's current 1-character guess 
	.eqv limbCounter $t6 #count limbs on Hangman to determine if Player 2 has lost or can continue to guess 
	.eqv currWord $t7 #Player 2's current 1-word guess
	.eqv correctCharCounter $t8 #counts the number of correct characters in Player 2's word guess
	.eqv wordGuessBufferAdd $t9
	.eqv one $s0 #will store the ASCII value of one
	
	printLabel(enterWord) #ask Player 1 to enter a word
	readString(wordBuffer, 201) #get Player 1's word
	#print a few newlines to "hide" Player 1's word	
	printLabel(newline)
	printLabel(newline)
	printLabel(newline)
	printLabel(newline)
	printLabel(newline)
	printLabel(newline)
	printLabel(newline)
	
	jal launchDrawing	#draw the gallows
	
	la wordBufferAdd, wordBuffer #store wordBuffer address in wordBufferAdd
	
	toUpperCase(wordBufferAdd)
	
	move wordCounter, $zero #set wordCounter to 0
	move loopCounter, $zero #set loopCounter to 0 
	
	#count the number of characters in Player 1's word 
	stringGetLength(wordBufferAdd, wordCounter)

#preparation to use the printUnderscoresLoop to print underscores
printUnderscores:
	subi wordCounter, wordCounter, 1 #subtract 1 from wordCounter because it's counted one too many times

# Copy Player 1's word count to wordGuessBuffer
# And replace each letter with underscores
fillWordGuessBuffer:
	# Get the address of the buffer
	la $s1, wordGuessingBuffer
	# Get the byte of underscore
	lb $s2, underscore
	# Copy address of wordBufferAdd
	la $s3, wordBuffer
	
	loop:
		# Get the character from the set word
		lb $t7, 0($s3)
	
		# If the character is null terminator / new line then return
		beq $t7, $0, return
		beq $t7, 10, return # 10 is the ascii value for \n
		# Else store an underscore byte into the wordGuessBuffer
		sb $s2, 0($s1)
	
		# Increment and loop
		addi $s3, $s3, 1 # Next character in wordBuffer
		addi $s1, $s1, 1 # Next character in wordGuessBuffer
	
		j loop
	
	return:
	# Print the wordGuessBuffer
	la $s1, wordGuessingBuffer
	printSpacedString($s1)

#print 1 underscore per 1 char in Player 1's word
#printUnderscoresLoop: 
#	printLabel(underscore)
#	addi loopCounter, loopCounter, 1 # increment loopCounter by 1
#	blt loopCounter, wordCounter, printUnderscoresLoop # if loopCounter < number of chars in Player 1's word, repeat loop

# Get Player 2's one letter guess
#	- if they type 1, jump to getWordGuess (the code for guessing a word)
#	- if they guess a correct letter, jump to correctCharGuess to replace appropriate underscore(s) with that letter
#	- if they guess an incorrect letter, jump to incorrectGuess to add a limb to the Hangman bitmap and increment limb counter	
getCharGuess:
	printLabel(enterCharGuess) #prompt Player 2 to guess a character 
	readChar(currChar) #save char from user to currChar
	
	# Uppercase the char
	toUpperCaseByte(currChar)
	
	li one, 49 #load ASCII code for '1' into one
	beq currChar, one, getWordGuess #if the currChar is 1, jump to getWordGuess
	
	
	la wordBufferAdd, wordBuffer #store wordBuffer address in wordBufferAdd
	
	#loops through all of the characters in Player 1's word to check for a match with Player's 2's currChar guess
	wordLoop2:
		lb currByte, 0(wordBufferAdd) #load the current byte at wordBufferAdd into currByte
		#if current byte is 0, we've hit the null terminator, which means we've looped through Player 2's entire word without finding currChar
		#therefore, Player 2's currChar guess was incorrect, and we jump to incorrectGuess
		beqz currByte, incorrectGuess 
		
		beq currByte, currChar, correctCharGuess #if the current char in Player 2's word matches currChar, branch to correctCharGuess
		
		addi wordBufferAdd, wordBufferAdd, 1 #increment wordBufferAdd by 1
		j wordLoop2 #repeat loop
		
#For when Player 2 guesses a correct character 
#	- Replace appropriate underscore(s) with the character
#		- Reminder: for words with repeated letters (e.g. two "l"s in "hello"), must replace all appropriate underscores with the guessed character.
#		  We should loop through the entire word again, comparing it against our guess to acomplish this 
correctCharGuess:
	printLabel(newline)
	la wordBufferAdd, wordBuffer # Store wordBuffer address in wordBufferAdd
	la $s1, wordGuessingBuffer # Save the address of wordGuessingBuffer
	
	wordLoop3:
		lb currByte, 0(wordBufferAdd) #load the current byte at wordBufferAdd into currByte
		beqz currByte, reprompt #if currByte is 0 (null), reprompt
		
		addi wordBufferAdd, wordBufferAdd, 1 #increment wordBufferAdd by 1
		
		
		# Since this loop runs through the characters in the string instead of a counter, it checks
		# The null terminator / new line character as well
		# Exit the loop when the null terminator / new line character is found
		beq currByte, $0, reprompt
		beq currByte, 10, reprompt # 10 is the ascii value for \n
		
		
		# Replace the corrosponding underscore in wordGuessBuffer with the new character
		
		# If the characters are the same, replace the character at the same position in wordGuessBuffer
		beq currByte, currChar, saveChar #if currByte of Player 1's word == Player 2's currChar guess, save the character
		
		addi $s1, $s1, 1 # increment wordGuessBuffer
		j wordLoop3 # Continue looping through until the end of string
	
	saveChar:
		sb currChar, 0($s1)
		addi $s1, $s1, 1 # increment wordGuessBuffer
		j wordLoop3
	
	reprompt:
		# Print the resulting string
		la $s1, wordGuessingBuffer
		printSpacedString($s1)
	
		# Save the underscore
		lb $s2, underscore
	
		# Check if the word has been guessed
		stringContains($s1, $s2, $s3)
	
		beq $s3, 0, youWin #Player 2 won if the word has no underscores
	
		# Else do nothing and continue
	
		# Reprompt for guess
		j getCharGuess
		

#For when Player 2 guesses an incorrect word or character
#	- Add one limb to hangman 
#	- Increment limb counter
incorrectGuess:
	printLabel(incorrectGuessMsg)
	
	# Add to Limb Counter
	addi limbCounter, limbCounter, 1
	
	# Print Limb Counter
	printLiteral("\nLimb Count: ")
	printInt(limbCounter)
	
	# Else, add to limbCounter and reprompt for new guess
	# Print current guessing string
	printLiteral("\n")
	la $s1, wordGuessingBuffer
	printSpacedString($s1)
	
	###################################################
	# Draw Limb code in Bitmap Display  #
	###################################################
	# Add appropriate limb drawing based on limb counter
	beq limbCounter, 1, drawHead
	beq limbCounter 2, drawBody
	beq limbCounter 3, drawFace
	beq limbCounter 4, drawRightArm
	beq limbCounter 5, drawLeftArm
	beq limbCounter 6, drawLeftLeg
	beq limbCounter 7, drawRightLeg		# at 7 limbs, game is over
		
	# Reprompt (fail-safe)
	j getCharGuess

# Get Player 2's word guess
#	- triggered when Player 2 types "1" for the next guess prompt 
#	- verify that they entered a word of the correct length, print an error message and prompt them again if they didn't 
#	- if they guess a correct word, print you win and exit
#	- if they guess an incorrect word, add limb, increment limb counter, and return to prompting them for single letter guesses 
getWordGuess:
	printLabel(enterWordGuess) #prompt Player 2 for their word guess
	readString(wordGuessBuffer, 201) #get Player 2's word guess of maximum 200 chars and save it to wordGuessBuffer
	
	la wordBufferAdd, wordBuffer #store wordBuffer address in wordBufferAdd
	la wordGuessBufferAdd, wordGuessBuffer
	
	toUpperCase(wordGuessBufferAdd)
	
	# Check the lengths of the strings
	stringGetLength(wordBufferAdd, $s1)
	stringGetLength(wordGuessBufferAdd, $s2)
	
	bne $s1, $s2, incorrectGuess # If the lengths don't match, branch to incorrectGuess
	
	wordLoop4:
		lb currByte, 0(wordBufferAdd) #get the current character of Player 1's word
		addi wordBufferAdd, wordBufferAdd, 1
		
		lb currChar, 0(wordGuessBufferAdd) #get the current character of Player 2's guess
		addi wordGuessBufferAdd, wordGuessBufferAdd, 1
		
		# beqz currByte, youWin # jump to win if check makes it all the way to new line without finding discrepency
		beq currByte, 10, youWin # jump to win if check makes it all the way to new line without finding discrepency
		bne currByte, currChar, incorrectGuess # if at any point BEFORE the new line character or null terminator the chars dont match then we jump to incorrect guess
		j wordLoop4 # loop


# To use the Bitmap Display Tool:
# Go to Tools > Bitmap Display > Connect to MIPS and then run the program
# Set BOTH display width and height to 256 OR 512, BOTH unit width and height to 1 OR 2 respectively
# Base address should be 0x10010000 (static data)
# Select 'Connect to MIPS' then run the main file. Now the drawing should appear
launchDrawing:	# initial drawing when game is launched
	drawHorizLine(100, 90, 150, white)	# draw top short line of gallow
	drawHorizLine(50, 220, 150, white)	# draw bottom long line of gallow
	drawHorizLine(50, 221, 150, white)	# (second line to make it thicker)
	
	drawVertLine(100, 90, 220, white)	# draw long vertical line of gallow
	drawVertLine(99, 90, 220, white)	# (second line to make it thicker)
	drawVertLine(150, 90, 120, white)	# draw short vertical line of gallow
	
	jr $ra

# Drawing parts of body
drawHead:
	drawHorizLine(145, 140, 155, orange)	# bottom of head
	drawHorizLine(145, 120, 155, orange)	# top of head
	drawVertLine(140, 125, 135, orange)	# left of head
	drawVertLine(160, 125, 135, orange)	# right of head
	drawDiagBackLine(155, 120, 125, orange)	# diagonal lines to connect head lines
	drawDiagBackLine(140, 135, 140, orange)
	drawDiagFrontLine(140, 125, 145, orange)
	drawDiagFrontLine(155, 140, 161, orange)
	# Reprompt
	j getCharGuess
drawBody:
	drawVertLine(150, 140, 180, orange)
	# Reprompt
	j getCharGuess
drawFace:
	# Draw eyes
	drawVertLine(147, 125, 130, orange)	# left eye
	drawVertLine(153, 125, 130, orange)	# right eye
	# Draw frown
	drawHorizLine(147, 133, 154, orange)
	drawVertLine(147, 133, 136, orange)
	drawVertLine(153, 133, 136, orange)
	# Reprompt
	j getCharGuess
drawLeftArm:
	drawDiagFrontLine(130, 159, 150, orange)	# draw left arm
	# Reprompt
	j getCharGuess
drawRightArm:
	drawDiagBackLine(150, 140, 160, orange)	# draw right arm
	# Reprompt
	j getCharGuess
drawLeftLeg:
	drawDiagFrontLine(130, 199, 150, orange)	# draw left leg
	# Reprompt
	j getCharGuess
drawRightLeg:
	drawDiagBackLine(150, 180, 200, orange)	# draw right leg
	# last limb drawn, so end the game
	j youLose

#Player 2 Won!
#For when Player 2 guessed each invidual character correctly before exceeding the max limb counter
#OR
#Player 2 guessed the full word correctly before exceeding the max limb counter 
youWin:
	jal drawWin
	printLabel(youWinMsg)
	j exit
	
youLose:
	jal drawLose
	printLabel(youLoseMsg)
	j exit
	
# End of program
exit:
	printLabel(exitMsg)
	li $v0, 10
	syscall
	
# Draw win and lose screens
drawWin:	# draws the text "WIN!"
#W
	drawVertLine(60, 10, 50, green)
	drawVertLine(90, 10, 50, green)
	drawVertLine(75, 30, 50, green)
	drawHorizLine(60, 50, 91, green)
#I
	drawVertLine(115, 10, 50, green)
	drawHorizLine(100, 10, 130, green)
	drawHorizLine(100, 50, 130, green)
#N
	drawVertLine(140, 10, 50, green)
	drawHorizLine(140, 20, 150, green)
	drawVertLine(150, 20, 40, green)
	drawHorizLine(150, 40, 160, green)
	drawVertLine(160, 10, 50, green)	
#!
	drawVertLine(170, 10, 30, green)
	drawVertLine(170, 40, 50, green)
	drawVertLine(175, 10, 30, green)
	drawVertLine(175, 40, 50, green)
	
	drawHorizLine(170, 10, 176, green)
	drawHorizLine(170, 30, 176, green)
	drawHorizLine(170, 40, 176, green)
	drawHorizLine(170, 50, 176, green)

	bge limbCounter, 3 drawSmile
	jr $ra
	drawSmile:
		# Turn that frown upside down if head exists
		drawHorizLine(147, 133, 154, black)
		drawHorizLine(147, 136, 154, orange)
		jr $ra
	
drawLose:	# draws the text "HANGMAN"
#H
	drawVertLine(30, 10, 50, red)
	drawVertLine(50, 10, 50, red)
	drawHorizLine(30, 30, 50, red)
#A
	drawVertLine(60, 10, 50, red)
	drawVertLine(80, 10, 50, red)
	drawHorizLine(60, 30, 80, red)
	drawHorizLine(60, 10, 80, red)
#N
	drawVertLine(90, 10, 50, red)
	drawHorizLine(90, 20, 100, red)
	drawVertLine(100, 20, 40, red)
	drawHorizLine(100, 40, 110, red)
	drawVertLine(110, 10, 50, red)
#G
	drawVertLine(120, 10, 50, red)
	drawHorizLine(120, 10, 140, red)
	drawHorizLine(120, 49, 140, red)
	drawVertLine(140, 30, 49, red)
	drawHorizLine(130, 30, 140, red)
#M
	drawVertLine(150, 10, 50, red)
	drawHorizLine(150, 10, 170, red)
	drawVertLine(160, 10, 30, red)
	drawVertLine(170, 10, 50, red)
#A
	drawVertLine(180, 10, 50, red)
	drawVertLine(200, 10, 50, red)
	drawHorizLine(180, 30, 200, red)
	drawHorizLine(180, 10, 200, red)	
#N
	drawVertLine(210, 10, 50, red)
	drawHorizLine(210, 20, 220, red)
	drawVertLine(220, 20, 40, red)
	drawHorizLine(220, 40, 230, red)
	drawVertLine(230, 10, 50, red)
	jr $ra
