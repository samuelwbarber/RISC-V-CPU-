main:
    addi    a0, zero, 0x0                       # load a0 with 0 (a0 is vbd_value, the output)
    addi    t1, zero, 0x0FF
    addi    a2, zero, 0x000 
    addi    a3, zero, 0x001
    addi    a4, zero, 0x000
    addi    a5, zero, 0x001
    jal     x0, loop                            # Jump to loop

constant_time:
    addi    t0, t0, -1                          # Decrement t0
    beq     t0, zero, loop                      # If t0 is equal to zero, return to loop
    jal     x0, constant_time                   # Else continue looping

loop:
    addi    t0, zero, 0x00F                     # load t0 with a large number to be counted down
    sll     a0, a0, 1                           # shift a0 by 1 so it goes up sequentially in decimal
    addi    a0, a0, 1                           # increment a0 by 1
    beq     a0, t1, random_time                 # If a0 is 255, turn off after a random time
    jal     x0, constant_time                   # Jump to constant_time

random_time:
    jal     ra, random_logic                    # Calculate the random value to be decremented
    addi    s1, s1, -1
    beq     s1, zero, end                       # If s1 is equal to zero, end the program
    jalr    x0, ra, 0                           # Else continue looping from the adding statement

end:
    addi    a0, zero, 0x0 
    jal     x0, loop

random_logic:
    addi    s1, zero, 0x0
    add     s1, s1, a2
    sll     a3, a3, 0x001
    add     s1, s1, a3
    sll     a4, a4, 0x001
    add     s1, s1, a4
    sll     a5, a5, 0x001
    add     s1, s1, a5
    xor     a2, a4, a5
    jalr    x0, ra, 0                           # Return to random_time, 1 instruction later
