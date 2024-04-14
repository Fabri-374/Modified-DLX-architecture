addi r1, r1, 2		; $r1 = 2
xor r3, r3, r3		; $r3 = 0
cycle:
addi r3, r3, 1		; $r3 = 1		$r3 = 2
subi r1, r1, 1		; $r1 = 1		$r1 = 0
bnez r1, cycle		; branch T		branch NT
xor r8, r8, r8		
sge r4, r3, r1		;				$r4 = 1
jal final			;				jump
addi r8, r8, 15		;							$r8 = 15
addi r9, r9, 255	;							$r9	= 255
j end				;							jump
addi r10, r10, 1	; should remain at zero value
addi r11, r10, 2	; should remain at zero value
final:
jr r31				;				return
end: 				;
addi r11, r11, 1	;							$r11 = 1
addi r12, r11, 2	;							$r12 = 3
movi r13, 255		;							$r13 = 255
