;Declare data
data segment public 'data' use16
	mes db "C'est le message du segement data utilise dans le programme principal$"
	mes_fin db "C'EST FINI VOUS DEVEZ VOIR CE MESSAGE ET LES 4 PRECEDENTS$"
data ends
data1 segment public 'data' use16
	mes1 db "C'est le message de DATA1$"
data1 ends

data2 segment public 'data' use16
	mes2 db "C'est le message de DATA2$"
data2 ends

data3 segment public 'data' use16
	mes3 db "C'est le message de DATA3$"
data3 ends
;
;declare pile
pile segment stack
	remplissage dw 400 dup(?)
pile ends
;
;Declare code
code segment use16

assume cs:code,ds:data1,ss:pile
;Procédures
;
;dans es le segment du data et dans dx le message
afficher_message proc near
	push ds
	mov ax,es
	mov ds,ax
	call so
	pop ds
	ret
afficher_message endp
so proc near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
so endp
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
;
;Fin procedure
debut:
	mov ax, data
	mov ds,ax
	
	lea dx,mes
	call so
	call crlf
	mov ax, data1
	mov es,ax
	lea dx,mes1
	call afficher_message
	call crlf
	mov ax,data2
	mov es,ax
	lea dx,mes2
	call afficher_message
	call crlf
	mov ax,data3
	mov es,ax
	lea dx,mes3
	call afficher_message
	call crlf
	lea dx,mes_fin
	call so
	call crlf
	
	;Quitter
	mov ah,4ch
	int 21h

code ends
	 end debut