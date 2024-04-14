addi r1, r1, 2
xor r2, r2, r2
addi r4, r4, 10
cycle:
addi r2,r2, 4
addi r3, r3, 1
subi r1, r1, 1
add r4, r4, r1
bnez r1, cycle
xor r8, r8, r8
addi r6,r6,56
jalr r6						
addi r8, r8, 15
addi r9, r9, 255
j end
addi r10, r10, 1
addi r11, r10, 2
jr r31						
end: 
addi r11, r11, 1
addi r12, r11, 2
movi r13, 255
