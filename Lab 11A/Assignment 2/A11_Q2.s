        .data
arrayX: .space 60
arrayY: .space 60
msg:    .asciiz "Dot Product: "
endmsg: .asciiz "\n"
invalidMsg: .asciiz "INVALID INPUT\n"

        .text
        .globl main
main:   li $v0,5
        syscall
        addi $t0,$v0,0
        addi $t2,$v0,0
        
        # Check if n is greater than 16
        li $t4, 15        # Load 16 into $t4
        bgt $t0, $t4, invalidInput   # Branch if n > 16
        
        la $t1,arrayX

loop:   li $v0,6
        syscall
        swc1 $f0,0($t1)
        addi $t1,$t1,4
        addi $t0,$t0,-1
        bne $t0,$0,loop

        la $t1,arrayY
        addi $t0,$t2,0

loop1:  li $v0,6
        syscall
        swc1 $f0,0($t1)
        addi $t1,$t1,4
        addi $t0,$t0,-1
        bne $t0,$0,loop1

        addi $t0,$t2,0
        la $t1,arrayX
        la $t3,arrayY
        mtc1 $0,$f3

loop2:  lwc1 $f1,0($t1)
        lwc1 $f2,0($t3)
        mul.s $f1,$f1,$f2
        add.s $f3,$f3,$f1
        addi $t1,$t1,4
        addi $t3,$t3,4
        addi $t0,$t0,-1
        bne $t0,$0,loop2
        mov.s $f12,$f3
        li $v0,4
        la $a0,msg
        syscall
        li $v0,2
        syscall
        li $v0,4 
        la $a0,endmsg
        syscall
        jr $ra

invalidInput:
        li $v0, 4       # Load the print string service code
        la $a0, invalidMsg   # Load the address of the string to print
        syscall         # Print the string
        jr $ra          # Return from the function

