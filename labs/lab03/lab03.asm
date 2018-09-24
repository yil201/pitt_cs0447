.data
	   prompt1:         .asciiz   "Please enter a positive integer: "
           prompt2:         .asciiz   "Please enter another positive integer: "
           warning:         .asciiz   "A negative integer is not allowed. "
           equal_sign:      .asciiz   " = "
           mult_sign:       .asciiz   " * "
           pow_sign:        .asciiz   " ^ "
           new_line:        .asciiz   "\n"
         
.text
           # print a string
	   .macro print_str (%str)
           li $v0, 4
	   la $a0, %str
	   syscall
	   .end_macro
	   
	   # print an int
	   .macro print_int (%int)
           li  $v0, 1
	   add $a0, $zero, %int
	   syscall
	   .end_macro
	   
	   # print multiplication arithmetic 
	   .macro print_mult (%multiplicand, %multiplier)
	   print_int(%multiplicand)
	   print_str(mult_sign)
	   print_int(%multiplier)
	   print_str(equal_sign)
	   .end_macro 
	   
	   # print power arithmetic
	   .macro print_pow (%multiplicand, %multiplier)
	   print_str(new_line)
	   print_int(%multiplicand)
	   print_str(pow_sign)
	   print_int(%multiplier)
	   print_str(equal_sign)
	   .end_macro

           # scan input
	   .macro scanner (%5)
	   li $v0, %5
	   syscall
	   .end_macro
	   
	   # terminate program
	   .macro exit ()
	   li $v0, 10
	   syscall
	   .end_macro 
	   
get_multiplicand:
    	   print_str (prompt1)
           scanner (5)
           # if input number is negative, go to warning
           slt     $t0, $v0, $0                       
           bnez    $t0, warning1
           # store input number in $s0, and store a copy in $s5
           move    $s0,$v0      
           move    $s5,$s0     
   

get_multiplier:
    	   print_str (prompt2)              
           scanner (5)
           # if input number is negative, go to warning
           slt     $t0, $v0, $0
           bnez    $t0, warning2
           # store input number in $s1, and store a copy in $s6
           move    $s1,$v0   
           move    $s6,$s1     
           print_mult($s5, $s6)
    
           jal multiply
           j   print_mult_result

multiply:
           # initialize result
           move $s3, $0        
           move $s4, $0       
           # jump out if either multiplicand or multiplier equals to 0
           beq  $s1, $0, done
           beq  $s0, $0, done
           move $s2, $0       
loop:
           andi $t0, $s0, 1    
           beq  $t0, $0, next   
           add  $s3, $s3, $s1  
           slt  $t0, $s3, $s1  
           add  $s4, $s4, $t0  
           add  $s4, $s4, $s2  
next:
           srl  $t0, $s1, 31    
           sll  $s1, $s1, 1
           sll  $s2, $s2, 1
           add  $s2, $s2, $t0
           srl  $s0, $s0, 1    
           bne  $s0, $0, loop
done:
           jr   $ra
    
exponent:
           # counter
           add  $t7, $t7, 1
           bne  $t7, $s6, ex_loop
           beq  $t7, $s6, print_pow_result
ex_loop:
           jal multiply
           move $s0, $s3
           move $s1, $s5
           j exponent
    
power:
           print_pow($s5, $s6)
           move $s0, $s5
           move $s1, $s5
           jal exponent  
    
print_mult_result:
           print_int ($s3)
           j power

print_pow_result:
           print_int ($s3)
           exit ()

warning1:
           print_str(warning) 
           print_str(new_line)
	   jal get_multiplicand
          
warning2:
           print_str(warning) 
           print_str(new_line)
	   jal get_multiplier