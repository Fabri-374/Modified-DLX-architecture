;r-type_area
jal   immediate_area ; jump in imemdiate operations 
add   r12, r2, r1    ; r12 = 3
sub   r13, r8, r11   ; 	r13 = 32768
and   r14, r9, r1    ; 	r14 = 1
or    r15, r1, r2    ; 	r15 = 3
xor   r16, r1, r3    ; 	r16 = 0
sll   r17, r6, r2    ; 	r17 = 40
srl   r18, r7, r1    ; 	r18 = 4
sra   r19, r9, r1    ;  r19 = 2
addu  r20, r18, r19  ; 	r20 = 6
subu  r21, r17, r20  ; 	r21 = 34
jr r31				 ; 	go to memory area

immediate_area:
addi  r1, r0, 1      ; r1 = 1
addui r2, r0, 2      ; r2 = 2
subi  r3, r0, -1     ; r3 = 1
andi  r4, r1, 5      ; r4 = 1
ori   r6, r2, 10     ; r6 = 10
xori  r7, r6, 2      ; r7 = 8
lhi   r8, 1          ; r8 = 65536
srli  r9, r6, 1      ; r9 = 5
slli  r10, r9, 3     ; r10 = 40
srai  r11, r8, 1     ; r11 = 32768
jalr r31			 ; go to r-type 

;memory_area
sb    0(r16), r19     ; store 2 in position 0
sh    1(r16), r18     ; store 4 in position 1
sw    2(r16), r20     ; store 6 in position 2
lb    r18, 0(r16)     ; load 2 in r18
lh    r19, 2(r16)     ; load 6 in r19
lbu   r20, 1(r1)      ; load 6 in r20
lhu   r21, 3(r1)      ; load 0 in r21
lw    r21, 1(r16)     ; load 4 in r21
comparations_area:
nop
beqz  r18, added      ; branch not taken
sge   r22, r12, r2    ; r22 = 1
sgei  r23, r3, 15     ; r23 = 0
sle   r24, r1, r3     ; r24 = 1
slei  r25, r2, 1      ; r25 = 0
sne   r26, r2, r3     ; r26 = 1
snei  r27, r1, 1      ; r27 = 0
seq   r28, r1, r14    ; r28 = 1
seqi  r29, r2, 1      ; r29 = 0
slt   r30, r16, r1    ; r30 = 1
slti  r18, r4, 1      ; r18 = 0
sgt   r2, r1, r30     ; r2 = 0
sgti  r3, r6, 0       ; r3 = 1
sltu  r4, r1, r23     ; r4 = 0
sgtu  r5, r8, r3      ; r5 = 1 
sltui r6, r8, 1       ; r6 = 0
sgtui r7, r10, 0      ; r7 = 1
sleu  r8, r8, r9      ; r8 = 0
sleui r9, r9, 16      ; r9 = 1
sgeu  r10, r10, r11   ; r10 = 0
sgeui r11, r11, 32768 ; r11 = 1
bnez  r12, comparations_area     ; branch taken

added:
mov r12, r17		  ; r12 = 40
movi r13, 65535		  ; r13 = 65535
mult r14, r15, r17	  ; r14 = 120
multi r15, r13, 2     ; r15 = 65535(signed-> -1)*2 = -2





