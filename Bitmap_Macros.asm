# Macros for bitmap drawings

# eqv definitions to make variables more readable
.eqv width, 256			# display width = 256 pixels
.eqv pixelSize, 4			# each pixel is 4 bytes

.data
frameBuffer:	.space	0x100000		# 256 pixels  x 256 pixels = 65536 pixels

# To modify horiz. lines in drawHoriz(x, y, length, color):
	# move left by decreasing x, move right by increasing
	# move up by decreasing y, move down by increasing y
	# when moving pixel left/increasing x, increase the length as well
.macro drawHorizLine(%x, %y, %length, %color)
	la $t0, frameBuffer		# base address of the frameBuffer
	li $t1, %x				# column index (x) for horizontal position
	li $t2, %y				# row for vertical position (y) of horizontal line
	li $t3, %color			# load color of choice into $t3
	li $t6, %length		# number of columns for line
	
	horizLoop:
		# To calculate the position for each pixel, the address of the pixel gets calculated
		# using the equation: address = base address + ((row * width) + column) * 4 bytes
		mul $t4, $t2, width		# $t4 = row * width <-- how far pixel is from top
		add $t4, $t4, $t1		# + column to put pixel in correct horizontal position
		mul $t4, $t4, pixelSize	# multiply by 4 bytes/pixel size
		add $t5, $t0, $t4	# $t5 = final address of pixel
		sw $t3, 0($t5)		# store color into pixel to display on bitmap
	
		addi $t1, $t1, 1		# move to next column
		blt $t1, $t6, horizLoop	# loop to draw next pixel
.end_macro

# To modify vert. lines in drawVert(x, y, length, color):
	# move up by decreasing y, move down by increasing y
	# move left by decreasing x, move right by increasing x
	# when moving pixel downward/increasing y, increase the length as well
.macro drawVertLine(%x, %y, %length, %color)
	la $t0, frameBuffer		# base address of the frameBuffer
	li $t1, %x				# column index (x) for horizontal position
	li $t2, %y				# row for vertical position (y) of horizontal line
	li $t3, %color			# load color of choice into $t3
	li $t6, %length		# number of columns for line
	
	vertLoop:
		#  address = base address + ((row * width) + column) * 4 bytes
		mul $t4, $t2, width		# $t4 = row * width
		add $t4, $t4, $t1		# + column
		mul $t4, $t4, pixelSize	# multiply by 4 bytes
		add $t5, $t0, $t4		# $t5 = final address of pixel
		sw $t3, 0($t5)			# store color into pixel to display on bitmap
	
		addi $t2, $t2, 1		# move down to next row
		blt $t2, $t6, vertLoop	# loop to draw next pixel
.end_macro

.macro drawDiagBackLine(%x, %y, %length, %color)
	la $t0, frameBuffer		# base address of the frameBuffer
	li $t1, %x				# column index (x) for horizontal position
	li $t2, %y				# row for vertical position (y) of horizontal line
	li $t3, %color			# load color of choice into $t3
	li $t6, %length		# number of columns for line
	
	backLoop:
		#  address = base address + ((row * width) + column) * 4 bytes
		mul $t4, $t2, width		# $t4 = row * width
		add $t4, $t4, $t1		# + column
		mul $t4, $t4, pixelSize	# multiply by 4 bytes
		add $t5, $t0, $t4		# $t5 = final address of pixel
		sw $t3, 0($t5)			# store color into pixel to display on bitmap
		
		addi $t1, $t1, 1		# move to next column
		addi $t2, $t2, 1	# move down to next row
		blt $t2, $t6, backLoop
.end_macro

.macro drawDiagFrontLine(%x, %y, %length, %color)
	la $t0, frameBuffer		# base address of the frameBuffer
	li $t1, %x				# column index (x) for horizontal position
	li $t2, %y				# row for vertical position (y) of horizontal line
	li $t3, %color			# load color of choice into $t3
	li $t6, %length		# number of columns for line
	
	backLoop:
		#  address = base address + ((row * width) + column) * 4 bytes
		mul $t4, $t2, width		# $t4 = row * width
		add $t4, $t4, $t1		# + column
		mul $t4, $t4, pixelSize	# multiply by 4 bytes
		add $t5, $t0, $t4		# $t5 = final address of pixel
		sw $t3, 0($t5)			# store color into pixel to display on bitmap
		
		addi $t1, $t1, 1		# move to next column
		sub $t2, $t2, 1		# move up to next row
		blt $t1, $t6, backLoop
.end_macro	
	
	
	
	
