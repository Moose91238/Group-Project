s_prompt: DC "Enter unsigned integer:\0"
s_nl:     DC "\n\0"

STACK:    EQU 0x100000

lui sp, STACK>>12           ; initialize stack pointer to STACK top

; read unsigned integer into x5
addi x10, x0, s_prompt
ecall x5, x10, 5            ; in: integer -> x5 (with prompt)

; working registers:
; x6 = current n
; x7 = remainder bit
; x8 = temp for output
; x9 = count of pushed bits

addi x6, x5, 0              ; n = input
addi x9, x0, 0              ; count = 0

; handle n == 0 separately (binary 0)
bne  x6, x0, div_loop
addi x7, x0, 0
sd   x7, 0(sp)              ; push 0
addi sp, sp, -8
addi x9, x9, 1
jal  x0, print_loop_entry

; push remainders (LSB first)
div_loop:
andi x7, x6, 1              ; bit = n % 2
sd   x7, 0(sp)              ; push bit
addi sp, sp, -8
addi x9, x9, 1              ; count++
srli x6, x6, 1              ; n /= 2
bne  x6, x0, div_loop

print_loop_entry:
beq  x9, x0, done           ; nothing to print

; pop and print bits (MSB first now)
print_loop:
addi sp, sp, 8              ; pop
ld   x8, 0(sp)
ecall x0, x8, 0             ; out integer (no newline)
addi x9, x9, -1
bne  x9, x0, print_loop

; optional newline
done:
addi x10, x0, s_nl
ecall x0, x10, 3            ; out string (no newline added by service)

; finish
ebreak x0, x0, 0
