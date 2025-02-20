main:
    li    t0, 4          #PC = 0         # Initialize t0 with 10
    addi    t1, zero, 2  #PC = 4    # Initialize t1 with 2 (loop counter)

loop:
    addi    t1, t1, 1     #PC = 8    # Increment t1
    sll     t2, t1, 1     #PC = 12    # Shift left logical t1 by 1, store in t2
    xor     t0, t2, t1    #PC = 16   # XOR t2 and t1, store in t3
    bne     t1, t0, loop  #PC = 20    # If t1 is not equal to t0, branch to loop
    jal     x1, func      #PC = 24   # Jump to func, store return address in ra

addi t1, t1, 100          #PC = 28

func:
    addi    t4, zero, 5   #PC = 32   # Initialize t4 with 5
    jalr    zero, x1, 0   #PC = 36   # Return to the address in ra

end:
    # End of the program. Could include a halt instruction in a real scenario
