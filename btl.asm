.data
	array: .word  	592,-377,-148,114,-467,861,-923,822,-497,8,862,292,-802,-216,-479,-597,613,461,43,290,-120,-766,-197,-822,-536,-666,115,-133,-84,577,-984,809,117,948,-577,-650,-253,-886,303,-382,-389,-951,364,510,-274,-233,817,561,-650,-941          	# input
	size:  .word	50			# size of input
	from: .word	0			# from index 
	to: .word	49			# to index 
	newl: .asciiz "\n"			# newline
	space: .asciiz " "			# space
	text: .asciiz  "Array after sort: " 	# text
	text1: .asciiz "Array before sort: "	# text
	text2: .asciiz "step "			# text
	text3: .asciiz ":"			# text
	tmp: .word 0:50				# temporary array
.text

main:				# main
	la $s0,array		# load array
	lw $a1,from		# from index or low
	lw $a2,to		# to index or high
	addi $s4,$0,1		# set step number
	
	la $a0,text1		# print input
	li $v0,4
	syscall
	jal print 		# jump to print func
	la $a0,newl		# print newline
	li $v0,4
	syscall
	
	jal mergesort		# start mergesort(low,high)

	la $a0,text		# print answer
	li $v0,4
	syscall
	jal print 		# jump to print func
	la $a0,newl		# print newline
	li $v0,4
	syscall

	li $v0,10		# exit
	syscall
	
	
print:				# print helper function
	lw $t0,size		# load size to t0
	add $t1,$0,$0		# set $t1 as index of array at 0
for:	
	sll $t2,$t1,2		
	add $t2,$t2,$s0		# add offset to the address of a[0] -> $t2= address of array[i]
	
	lw  $a0,0($t2)		# print a[i]
	li $v0,1
	syscall
	
	la $a0,space		# print space
	li $v0,4
	syscall
	
	addi $t1,$t1,1		# increase index
	beq $t1,$t0,return	# if index equal size, return
	j for			# else continue the print process
	
	
return:				# return helper function
	jr $ra 
	
	
mergesort:			# mergesort
	slt $t0, $a1, $a2	
	bne $t0, 1, return	# if low < high , return 
	
	add $a3,$a1,$a2		# compute mid=(low+high)/2 
	srl $a3,$a3,1	
	
	addi $sp,$sp,-16	# make space
	sw $ra,12($sp)		# save return address
	sw $a2, 8($sp)		# save high
	sw $a3, 4($sp)		# save mid
	sw $a1, 0($sp)		# save low
	
	add $a2, $a3,$0   	# high = mid
	jal mergesort		# mergesort(low,mid)
	
	lw $a1,4($sp)		# load mid
	addi $a1,$a1,1		# set mid = mid +1
	lw $a2,8($sp)		# load high
	jal mergesort   	# mergesort(mid+1,high)
	
	lw $a2, 8($sp)		# load high
	lw $a3, 4($sp)		# load mid
	lw $a1, 0($sp)		# load low
	jal merge 		# merge(low,mid,high)
	
	la $a0,text2		# print step 
	li $v0,4
	syscall
	addi $a0,$s4,0		# print step 
	li $v0,1
	syscall
	la $a0,text3		# print step
	li $v0,4
	syscall
	la $a0,space		# print space
	li $v0,4
	syscall
	jal print 		# jump to print func to print array at step i
	la $a0,newl		# print newline
	li $v0,4
	syscall
	
	addi $s4, $s4,1		# increase step
	
	lw $ra, 12($sp)		# load return address
	addi $sp,$sp,16		# restore stack pointer
	jr $ra			
	
	
merge:				# merge 2 array fi and se
	la $s1,tmp		# set s1 as a temporary array 'tmp'
	
	addi $t0,$a3,1 		# set the bound 'sz' for the first array -> $t0 = mid+1
	addi $t1,$a2,1 		# set the bound 'sz1' for the second array -> $t1 = high+1
	
	add $t2,$a1,$0 		# set index i at the beginning of first array 'fi' -> $t2 = low

	addi $t3,$a3,1		# set index j at the beginning of second array 'se' -> $t3 = mid+1
	add $t4,$a1,$0		# set index k of input array -> $t4 = low
	
while:				# while i < sz and j < sz1
	slt $t5,$t2,$t0  	# check if index i of first array not exceed the bound sz
	slt $t6,$t3,$t1		# check if index j of second array not exceed the bound sz1
	add $t7,$t5,$t6		
	bne $t7,2,while1 	# check if  i < sz and j < sz1 , if not go to while1
	
	sll $t5, $t2,2 
	sll $t6, $t3,2		
	add $t5, $s0, $t5	# $t5 = address of a[i] - element of first array
	add $t6, $s0, $t6	# $t6 = address of a[j] - element of second array
	
	lw $t5, 0($t5)		# load a[i]
	lw $t6, 0($t6)		# load a[j]
	
	slt $t7, $t5,$t6	# check if a[i]<a[j]
	bne $t7, 1,else		# if a[i]>=a[j] go to else
if:				# if a[i]<a[j] branch , add a[i] to temporary array
	sll $t6,$t4,2
	add $t6,$s1,$t6 	# $t6 = address of tmp[k]
	sw  $t5,0($t6)		# tmp[k] = a[i]
	addi $t2,$t2,1		# i++
	addi $t4,$t4,1		# k++
	j while                 # jump back to while
else:				# if fi[i] >= se[j] branch, add a[j] to temporary array
	sll $t5,$t4,2
	add $t5,$s1,$t5		# $t5 = address of tmp[k]
	sw  $t6,0($t5)    	# tmp[k] = a[j]
	addi $t3,$t3,1		# j++
	addi $t4,$t4,1		# k++
	j while
while1:				# while ( i < sz )
	slt $t5,$t2,$t0    	# check if i < sz
	bne $t5,1,while2  	# if i>=sz go to while 2
	
	sll $t5, $t2,2 
	add $t5, $s0, $t5	
	lw $t5, 0($t5)		# $t5 = a[i]
	
	sll $t6,$t4,2
	add $t6,$s1,$t6
	sw  $t5,0($t6)		# tmp[k]=a[i]
	addi $t2,$t2,1		# i++
	addi $t4,$t4,1		# k++
	j while1
while2:				# while ( j < sz 1)
	slt $t6,$t3,$t1	
	bne $t6,1,copy		# if j>=sz1 go to copy
	
	sll $t6, $t3,2
	add $t6, $s0, $t6	
	lw $t6, 0($t6)		# $t6 = a[j]
	
	sll $t5,$t4,2
	add $t5,$s1,$t5
	sw  $t6,0($t5)		# tmp[k]=a[j]
	addi $t3,$t3,1		# j++
	addi $t4,$t4,1		# k++
	j while2
copy:				# copy temporary array tmp to initial array function
	addi $t0,$a1,0		# set index i at the beginning of tmp , also the beginning of the segment of initial array copy to
	addi $t1,$a2,1		# set the bound sz for tmp 
for1:				# for loop to copy data
	sll $t2,$t0,2
	add $t2,$s1,$t2
	lw $t2,0($t2)		# $t2 = tmp[i]
	
	sll $t3,$t0,2
	add $t3,$s0,$t3
	sw $t2,0($t3)		# a[i]=tmp[i]
	
	addi $t0,$t0,1		# i++
	beq $t0,$t1,return	# if i = sz, return
	j for1
	

