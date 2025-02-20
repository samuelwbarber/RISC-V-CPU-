.text
.equ base_pdf, 0x100
.equ base_data, 0x10000
.equ max_count, 200
main:
    JAL     ra, init        # PC = 0    jump to init, save return address in ra
    JAL     ra, build       # PC = 4
forever:
    JAL     ra, display     # PC = 8
    J       forever         # PC = 12

init:                       # function to initialise PDF buffer memory 
    LI      a1, 0x100       # PC = 16   loop_count a1 = 256
_loop1:                     # repeat
    ADDI    a1, a1, -1      # PC = 20   decrement a1
    SB      zero, base_pdf(a1) # PC = 24 mem[base_pdf+a1] = 0
    BNE     a1, zero, _loop1 # PC = 28   until a1 = 0
    RET                      # PC = 32

build:                      # function to build prob dist func (pdf)
    LI      a1, base_data   # PC = 36   a1 = base address of data array
    LI      a2, 0           # PC = 40   a2 = offset into data array 
    LI      a3, base_pdf    # PC = 44   a3 = base address of pdf array
    LI      a4, max_count   # PC = 48   a4 = maximum count to terminate
_loop2:                     # repeat
    ADD     a5, a1, a2      # PC = 52   a5 = data base address + offset
    LBU     t0, 0(a5)       # PC = 56   t0 = data value
    ADD     a6, t0, a3      # PC = 60   a6 = index into pdf array
    LBU     t1, 0(a6)       # PC = 64   t1 = current bin count
    ADDI    t1, t1, 1       # PC = 68   increment bin count
    SB      t1, 0(a6)       # PC = 72   update bin count
    ADDI    a2, a2, 1       # PC = 76   point to next data in array
    BNE     t1, a4, _loop2  # PC = 80   until bin count reaches max
    RET                      # PC = 84

display:                    # function send PDF array value to a0 for display
    LI      a1, 0           # PC = 88   a1 = offset into pdf array
    LI      a2, 255         # PC = 92   a2 = max index of pdf array
_loop3:                     # repeat
    LBU     a0, base_pdf(a1) # PC = 96  a0 = mem[base_pdf+a1]
    addi    a1, a1, 1       # PC = 100  incr 
    BNE     a1, a2, _loop3  # PC = 104  until end of pdf array
    RET                      # PC = 108

# fix issue with load byte unsigned, i think you need to forward data from the write back stage properly
