;Declare data
data segment use16
	mesError  db  10,13,"Not hexa!",10,13,'$'
	MesEnterA db  "Entrez A : ",'$'
	MesEnterB db  "Entrez B : ",'$'
	mesA      db  "A = $"
	mesB      db  "          B = ",'$'
	mesAplB   db  "A + B = $"
	mesAmoiB   db  "A - B = $"
	mesAfoiB   db  "A * B = $"
	mesAdivB   db  "A / B = $"
	mesReste1   db  " Reste= $"
	mesReste2   db  " Reste= $"
	mesBmoiA   db  "			        B - A = $"
	mesBdivA   db  "B / A = $"
	data ends
;
;declare pile
pile segment stack
	remplissage dw 400 dup(?)
pile ends
;
;Declare code
code segment use16

assume cs:code,ds:data,ss:pile,es:data
;Procedure
;
;Applique le complement a 2 à ax
complement_ax proc near
	rol ax,1
	jnc sortir
	ror ax,1
	sub ax,1
	not ax
	stc
	jmp fincom
	sortir:
	ror ax,1
	fincom:
	ret
complement_ax endp
complement_al proc near
	rol al,1
	jnc sortiral
	ror al,1
	sub al,1
	not al
	stc
	jmp fincomal
	sortiral:
	ror ax,1
	fincomal:
	ret
complement_al endp
hex_digit proc near
	push dx ax
	add dl,'0'
	cmp dl,'9'
	jbe showdigit
	add dl,7
	showdigit:
	mov ah,02h
	int 21h
	pop ax dx
	ret
hex_digit endp
;
print_al proc near
	push dx
	mov dl,al
	shr dl,4
	call hex_digit
	mov dl,al
	and dl,0fh
	call hex_digit
	pop dx
	ret
print_al endp

print_ax proc near
	push ax
	call complement_ax
	jnc passigne
	push ax
	mov al,'-'
	call co
	pop ax
	passigne:
	ror ax,8
	call print_al
	ror ax,8
	call print_al
	pop ax
	ret
print_ax endp

conv_hex proc near
	sub al,'0'
	jb hret
	cmp al,10
	cmc
	jnb hret
	sub al,7
	cmp al,10
	jb hret
	cmp al,10h
	cmc
	hret:
	ret
conv_hex endp
ci proc near
	mov ah,01h
	int 21h
	ret
ci endp
co proc near
	push ax dx
	mov dl,al
	mov ah,02h
	int 21h
	pop dx ax
	ret
co endp
crlf proc near
	push ax dx
	mov ah,02h
	mov dl,10
	int 21h
	mov dl,13
	int 21h
	pop dx ax
	ret
crlf endp
ci_wordhex proc near
	push bx
	call ci
	call conv_hex
	jc fault
	shl al,4
	mov bl,al
	call ci
	call conv_hex
	jc fault
	or al,bl
	mov bh,al
	call ci
	call conv_hex
	jc fault
	shl al,4
	mov bl,al
	call ci
	call conv_hex
	jc fault
	or al,bl
	mov ah,bh
	jmp ishexa
	fault:
	lea dx,mesError
	mov ah,09h
	int 21h
	ishexa:
	pop bx
	ret
ci_wordhex endp
so proc near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
so endp
;
;Fin procedure
debut:
	mov ax, data
	mov ds,ax
	
	;wchar:
	;	call ci
	;	cmp al,'$'
	;	je break
	;	call conv_hex ;convertit al en hexa si le code ascii correspond
	;	call crlf
	;	jc notprint
	;	shl al,4
	;	call print_al
	;	call crlf
	;	notprint:
	;jmp wchar
	;break:
	lea dx,mesentera
	call so
	call ci_wordhex
	call crlf
	mov bx,ax
	lea dx,mesenterb
	call so
	call ci_wordhex
	call crlf
	push ax bx
	pop ax bx
	lea dx,mesA
	call so
	call print_ax
	lea dx,mesB
	call so
	push ax
	mov ax,bx
	call print_ax
	pop ax
	call crlf
	lea dx,mesAplB
	call so
	push ax
	add ax,bx
	call print_ax
	pop ax
	call crlf
	;
	lea dx,mesAmoiB
	call so
	push ax
	sub ax,bx
	call print_ax
	pop ax
	;
	lea dx,mesBmoiA
	call so
	push ax bx
	sub bx,ax
	mov ax,bx
	call print_ax
	pop bx ax
	call crlf
	;
	lea dx,mesAfoiB
	call so
	push ax
	mul bx
	push ax
	mov ax,dx
	call print_ax
	pop ax
	call print_ax
	pop ax
	call crlf
	;
	lea dx,mesAdivB
	call so
	push ax
	xor dx,dx
	div bx
	call print_ax
	push dx
	call crlf
	lea dx,mesReste1
	call so
	pop dx
	mov ax,dx
	call print_ax
	pop ax
	call crlf
	;Positionnement du curseur
	push ax bx cx dx
	mov ah,03h
	mov bh,0
	int 10h
	mov ah,02h
	sub dh,2
	add dl,40
	int 10h
	pop dx cx bx ax
	;
	lea dx,mesBdivA
	call so
	push ax bx
	xor dx,dx
	push ax bx
	pop ax bx
	div bx
	call print_ax
	push dx
	;Positionnement du curseur
	push ax bx cx dx
	mov ah,03h
	mov bh,0
	int 10h
	mov ah,02h
	add dh,1
	sub dl,12
	int 10h
	pop dx cx bx ax
	;
	lea dx,mesReste2
	call so
	pop dx
	mov ax,dx
	call print_ax
	pop bx ax
	call crlf
	
	;Quitter
	mov ah,4ch
	int 21h

code ends
	 end debut