.text
.globl main
main:
    addi    t1, zero, 0x0f      # pc = 0 load t1 with 255
    addi    a0, zero, 0x0       # pc = 4 a0 is used for output
mloop:     
    addi    a1, zero, 0x0       # pc = 8 a1 is the counter, init to 0
iloop:
    sw      a1, 0(a1)
    lh      a0, 0(a1)           # pc = 12 load a0 dmem[a1] pc = 12
    addi    a1, a1, 1           # pc = 16 increment a1
    bne     a1, t1, iloop       # pc = 20 if a1 = 255, branch to iploop
    bne     t1, zero, mloop     # pc = 24 ... else always brand to mloop
    
