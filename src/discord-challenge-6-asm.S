/* ============================================================================
 * Name        : discord-challenge-6-asm.S
 * Author      : Perry Harrington
 * Version     :
 * Copyright   : Your copyright notice
 * Description : Discord challenge 6 in assembly, for Linux x86_64
 * ============================================================================
 */

.equ SYS_read, 0
.equ SYS_write, 1
.equ nl, 10

.data
string:	.zero 12
a:		.ascii " \xff\xf9\xf1\xfe'r\xe9#\x9b%\x14\x1fI\xfd'\xff\xf1\x86\x17"
newline: .byte nl

.text
.global main
main:
	mov		$SYS_read, %rax
	mov		$0, %rdi
	mov		$string, %rsi
	mov		$12, %rdx
	syscall

	sub		$1, %rax
	mov		%rax, %r12		# bytes read

	xor		%r9, %r9		# i
eachline:
	xor		%r8, %r8		# j

	mov		$newline, %rsi	# newline
	call	writechar

foreachs:
	mov		$string, %rdi

	movzxb	(%r8,%rdi), %rcx	#j=s[i]
	mov		$5, %rdx
	imul	%r9, %rdx

	sub		$48, %rcx		# j-48
	mov		%rcx, %rbx		# original ascii->num j in rcx
	shr		%rbx

	mov		$a, %rdi

	add		%rdx, %rdi		# f=i*5
	add		%rbx, %rdi		# f=f+(j/2)

	movzxb	(%rdi), %rsi	# rsi = a[f] overwrite j/2

	and		$1, %rcx		# j&1
	shl		$2, %rcx		# j*4

	shr		%cl, %rsi		# a[f]>>(j&1)*4

	xor		%r10, %r10		# for(k=0...)
eachchar:
	push	%rsi			# save a[f], our bit pattern

	mov		%r10, %rcx
	shl		%cl, %rsi		# rsi=(f<<k)&8
	and		$8, %rsi

	add		$a, %rsi		# rsi demolished
							# load ' ' or '#'
	call	writechar

	pop		%rsi			# restore j
	inc		%r10
	cmp		$4, %r10
	jle		eachchar		# for(...k<4;k++)

	inc		%r8				# for (j:string)
	cmp		%r12, %r8
	jne		foreachs		# string len 1+string

	inc		%r9
	cmp		$3, %r9
	jle		eachline		# for (...i<4;i++)

	xor		%rax, %rax
	ret

writechar:
	mov		$1, %rdi		# stdout
	mov		$SYS_write, %rax
	mov		$1, %rdx		# 1 byte to write
	syscall
	ret
