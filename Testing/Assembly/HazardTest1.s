main:
    # Setup initial values
    addi    t0, zero, 5          # PC = 0    Initialize t0 with 5
    addi    t1, zero, 10         # PC = 4    Initialize t1 with 10
    addi    t2, zero, 15         # PC = 8    Initialize t2 with 15

    # Data Hazard: Read-After-Write (RAW) with Load Instruction
    sw      t1, 0(t0)            # PC = 12   Store t1 at address in t0
    lw      t3, 0(t0)            # PC = 16   Load into t3 from address in t0, RAW hazard

    # Control Hazard with Branch Instruction
    beq     t3, t1, branch_target # PC = 20   Branch if t3 equals t1

    # Control Hazard with Jump Instruction
    jal     x1, jump_target       # PC = 24   Jump to jump_target, store return address in x1

    # Data Hazard: Write-After-Read (WAR)
    addi    t4, t2, 20           # PC = 28   Initialize t4 with t2 + 20
    addi    t2, zero, 25         # PC = 32   Updating t2 after reading it, WAR hazard

    # Data Hazard: Write-After-Write (WAW)
    addi    t5, zero, 30         # PC = 36   Initialize t5 with 30
    addi    t5, zero, 35         # PC = 40   Update t5 again, WAW hazard

    # Additional Load for RAW Hazard
    sw      t4, 4(t0)            # PC = 44   Store t4 at address in t0 + 4
    lw      t6, 4(t0)            # PC = 48   Load into t6 from address in t0 + 4, RAW hazard

    # Infinite loop to end program
end:
    j       end                  # PC = 52   Jump to end

branch_target:
    addi    x27, t3, 1            # PC = 56   Increment t7, target of the branch

jump_target:
    addi    x28, x1, 1            # PC = 60   Increment t8, target of the jump
    jalr    zero, x1, 0          # PC = 64   Return to the address in x1
