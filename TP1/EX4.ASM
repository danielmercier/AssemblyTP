code segment use16

assume cs:code,ds:data,ss:pile

;Déclaration des procédures
cls proc near
	push ax bx cx dx
	MOV AH,06
	MOV	AL,00
	MOV	BH,07
	MOV	CX,0000
	MOV	DX,184FH
	INT	10H

	mov ah,00h
	mov al,03h
	int 10h
	pop ax bx cx dx
	ret
cls endp

crlf proc near
	push ax dx
	mov ah,02h
	mov dl,10
	int 21h
	mov dl,13
	int 21h
	pop ax dx
	ret
crlf endp

out_str proc near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
out_str endp

out_char proc near
	mov ah,02h
	int 21h
	ret
out_char endp

in_str proc near
	push ax
	mov ah,0ch
	mov al,0ah
	int 21h
	pop ax
	ret
in_str endp

;Offset du message a copier dans di
;Offset du resultat de la copie sans espace dans bi
efface_espace proc near
	push ax
	xor cx,cx
	mov ax,offset buffer
	add buffer,2
	NF:
		cmp [buffer],' '
		je SPACE
			mov [di],[buffer]
			inc di
			inc cx
		space:
		inc buffer
		cmp [buffer],'$'
	jne NF
	inc di
	mov [di],'$'
	mov offset buffer,ax
	sub di,cx
	pop ax
	ret
efface_espace endp

print_ax proc near
	;On divise par dix jusqu'a atteindre zero on stock tous les reste dans la pile
	push ax
	xor cx,cx
	mov dl,10
	SUP0:
		div dl
		mov bx,ax
		xor al,al
		mov al,ah
		xor ah,ah
		push ax
		mov ax,bx
		xor ah,ah
		inc cx
		cmp ax,0
	jne SUP0
	mov ah,02h
	LRESTE:
		pop dx
		xor bx,bx
		mov bl,'0'
		add dx,bx
		int 21h
	loop LRESTE
	pop ax
	ret
print_ax endp

getch proc near
	mov ah,08h
	int 21h
getch endp

;Compte le nombre de caractères
;offset du message dans dx(premier octet, nombre de caracteres)
;caractere dans al
;resultat dans bx
count_char proc near
	mov di,offset dx
	xor cx,cx
	mov cl,[di]
	xor bx,bx
	inc di
	PARCOURT:
		cmp [di],al
		jne NOTFOUND
		inc bx
		NOTFOUND:
		inc di
	loop PARCOURT
	ret
count_char endp

;Début des instructions
debut :
	mov ax,data
	mov ds,ax

	call cls
	mov dx,offset mesEnter
	call out_str
	mov dx,offset buffer
	call in_str
	call crlf
	xor bx,bx
	mov bl,[buffer + 1]
	mov [buffer + 2 + bx],'$'
	add [buffer + 1],1
	mov dx,offset buffer + 2
	call out_str
	call crlf
	mov dx,offset mesNbChar1
	call out_str
	xor ax,ax
	mov al,[buffer + 1]
	call print_ax
	mov dx,offset mesNbChar2
	call out_str
	
	COUNT:
	mov dx, offset mesCharCount
	call out_str
	call getch
	cmp al,'$'
	je FCOUNT
	mov dx,offset buffer+1
	call count_char
	mov dx,offset mesSCount1
	call out_str
	mov dl,al
	call out_char
	mov dx,offset mesSCount2
	call out_str
	mov ax,bx
	call print_ax
	mov dx,offset mesSCount3
	call out_str
	jmp COUNT
	FCOUNT:
	
	call efface_space
	call out_str
	mov ah,4ch
	int 21h
code ends

;Déclaration des données
data segment use16
	buffer   	 db 254,255 dup (?)
	mesEnter     db "Veuillez entrer un message svp(253 caracteres max) : ",10,13,'$'
	mesNbChar1	 db "Il y a ",'$'
	mesNbChar2	 db " caracteres",10,13,'$'
	mesCharCount db "Entrez un char pour compter sont nombre d'occurence, dollar pour arreter  : ",10,13,'$'
	mesSCount1   db "La lettre <",'$'
	mesSCount2   db "> a ete trouve ",'$'
	mesSCount3   db " fois",10,13,'$'
data ends

;Déclaration de la pile
pile segment stack
	remplissage db 256 dup (?)
pile ends

end debut