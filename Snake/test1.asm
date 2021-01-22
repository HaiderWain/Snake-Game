[org 0x0100]

jmp start
forrandom: dw 0   ;for random column
forrandom2: dw 0   ; for random row
tickcount: dw 0
snake: times 240 db 0
index: times 240 dw 0	;To store index at Video memory of each character of snake
len: dw 20
direction:dw 0	;1 for Up, 2 for Right, 3 for Down, 4 for Left
oldsnake: times 240 db 0
oldindex: times 240 dw 0
oldlen: dw 20

clrscr: 
	push es
	push ax
	push cx
	push di

	mov ax, 0xb800
	mov es, ax 

	xor di, di 
	mov ax, 0x0720 
	mov cx, 2000 
	
	cld 
	rep stosw 

	pop di
	pop cx
	pop ax
	pop es
	
	ret
	
printingBorder:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov di,0
	mov ah,0x04	
	mov al,0x23		
	mov cx,80
	
	cld
	rep stosw
	
	mov di,318
	mov ah,0x04	
	mov al,0x23		
	mov cx,25
	verticalPrintingRight:
		mov word[es:di],ax
		add di,160
		loop verticalPrintingRight
		
	mov di,160
	mov ah,0x04	
	mov al,0x23		
	mov cx,25
	verticalPrintingLeft:
		mov word[es:di],ax
		add di,160
		loop verticalPrintingLeft
		
		
	mov di,3840
	mov ah,0x04	
	mov al,0x23		
	mov cx,80
	
	cld
	rep stosw
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
printingSnake:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov si,0
	mov bx,0
	
	mov cx,[cs:len]	
	
	mov di,1980
	mov ah,0x07	
	
	oldSnakeToNewSnake:
		mov al,[cs:oldsnake+bx]
		mov [cs:snake+bx],al
		inc bx
		loop oldSnakeToNewSnake
	
	mov cx,[cs:oldlen]
	mov word[cs:len],cx
	
	mov bx,0
	
	printingSnakeLoop:
		mov al,[cs:snake+bx]
		mov word[es:di],ax
		mov word[cs:index+si],di
		add di,2
		inc bx
		add si,2
		loop printingSnakeLoop
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret

printingFruits:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax

	mov di,[cs:forrandom]
	add di,di
	mov cx,[cs:forrandom2]
	
	generate:
	add di,160
	loop generate
	
	mov ah,0x01		;L R G B I R G B
					;0 0 0 0 0 0 1 0

	mov al,'F'
	mov word[es:di],ax
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
RightArrow:
   	mov ax,0xb800
	mov es,ax
	
	cmp word[cs:direction],4 ;If snake direction is Left, don't go right.
	je calltocallNoMatch
	
	mov cx,[cs:len]
	dec cx
	
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	sub bx,1
	
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	;di = 2020
	
	jmp forward
	calltocallNoMatch:
		jmp callNoMatch
	;-----------------------------------
	;COLLISION WITH BORDER
	forward:
		mov ah,0x04
		mov al,'#'
		cmp word[es:di+2],ax 	;If it touches the border
		jne CheckOverlapping
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch
	;-------------------------------------
	;COLLISION WITH ITSELF
	CheckOverlapping:
		mov ah,0x07
		mov al,'*'
		cmp word[es:di+2],ax
		jne CheckFruit
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch
	;COLLISION WITH FRUIT
	CheckFruit:
		push ax	
		push bx
		push cx
		push dx
		push si
		push di
		
		mov ah,0x01
		mov al,'F'
		cmp word[es:di+2],ax
		jne calltoProceed
		;else
		
		call printingFruits
		mov cx,[cs:len]
		mov bx,[cs:len]
		dec bx
		mov dx,0
		l1:
			mov dl,[cs:snake+bx]
			;mov byte[snake+bx],0
			mov byte[cs:snake+bx+4],dl
			dec bx
			loop l1
		
		mov cx,[cs:len]
		mov bx,[cs:len]
		add word[cs:len],4
		dec bx
		shl bx,1
		l2:
			mov dx,[cs:index+bx]
			mov word[cs:index+bx+8],dx
			sub bx,2
			loop l2
		jmp forward5
		
		calltoProceed:
			jmp Proceed
		
		forward5:
		mov di,[cs:index+8] ;Get index of TAIL "*"
		mov si,[cs:index+10] ;Get 2nd Last "*"
		
		sub si,di	;Get difference to Know the direction of snake
		
		mov ah,0x07
		mov al,'*'
		mov bx,6	;6,4,2,0 Index of * in Index array
		mov cx,4	;Number of characters to add
		tailisLeft:
			cmp si,2
			jne tailisUp
			addLeft:
				sub di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addLeft
			
			jmp Proceed
				
			
		tailisUp:
			cmp si,160
			jne tailisRight
			addUp:
				sub di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addUp
			
			jmp Proceed
			
		tailisRight:
			cmp si,-2
			jne tailisDown
			addRight:
				add di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addRight
			
			jmp Proceed
			
			
		tailisDown:
			cmp si,-160
			addDown:
				add di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addDown
			
			jmp Proceed
			
	
	Proceed:
		pop di	
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		
		mov cx,[cs:len]
	dec cx
	
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	sub bx,1
	
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	
		
		
		
		
		mov word[es:di+2],dx	;Head moved to the right
		add word[cs:index+bx],2	;Update index of Head
	
	RePrintingBody:
		mov si,[cs:index+bx-2]	;Store index of Current Char	
		
		mov ax,[es:si]
		mov word[es:di],ax
		
		mov word[cs:index+bx-2],di
		
		mov di,si
		sub bx,2
		loop RePrintingBody 
		
	mov dx,0x0720
	mov word[es:di],dx
	
	mov word[cs:direction],2
	
	callNoMatch:
		ret
	
UpArrow:
	mov ax,0xb800
	mov es,ax
	
	cmp word[cs:direction],3 ;If snake direction is Down, don't go Up.
	je calltocallNoMatch2
	
	mov cx,[cs:len]
	dec cx
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	
	sub bx,1
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	;di = 2020
		
	jmp forward2
	calltocallNoMatch2:
		jmp callNoMatch2
	;-----------------------------------
	;COLLISION WITH BORDER
	forward2:
		mov ah,0x04
		mov al,'#'
		cmp word[es:di-160],ax 	;If it touches the border
		jne CheckOverlapping2
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch2
	;-------------------------------------
	;COLLISION WITH ITSELF
	CheckOverlapping2:
		mov ah,0x07
		mov al,'*'
		cmp word[es:di-160],ax
		jne CheckFruit2
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch2
	;COLLISION WITH FRUIT
	CheckFruit2:
		push ax	
		push bx
		push cx
		push dx
		push si
		push di
		
		mov ah,0x01
		mov al,'F'
		cmp word[es:di-160],ax
		jne calltoProceed2
		;else
		
		call printingFruits
		mov cx,[cs:len]
		mov bx,[cs:len]
		dec bx
		mov dx,0
		l12:
			mov dl,[cs:snake+bx]
			;mov byte[snake+bx],0
			mov byte[cs:snake+bx+4],dl
			dec bx
			loop l12
		
		mov cx,[cs:len]
		mov bx,[cs:len]
		add word[cs:len],4
		dec bx
		shl bx,1
		l22:
			mov dx,[cs:index+bx]
			mov word[cs:index+bx+8],dx
			sub bx,2
			loop l22
		jmp forward52
		
		calltoProceed2:
			jmp Proceed2
		
		forward52:
		mov di,[cs:index+8] ;Get index of TAIL "*"
		mov si,[cs:index+10] ;Get 2nd Last "*"
		
		sub si,di	;Get difference to Know the direction of snake
		
		mov ah,0x07
		mov al,'*'
		mov bx,6	;6,4,2,0 Index of * in Index array
		mov cx,4	;Number of characters to add
		tailisLeft2:
			cmp si,2
			jne tailisUp2
			addLeft2:
				sub di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addLeft2
			
			jmp Proceed2
				
			
		tailisUp2:
			cmp si,160
			jne tailisRight2
			addUp2:
				sub di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addUp2
			
			jmp Proceed2
			
		tailisRight2:
			cmp si,-2
			jne tailisDown2
			addRight2:
				add di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addRight2
			
			jmp Proceed2
			
			
		tailisDown2:
			cmp si,-160
			addDown2:
				add di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addDown2
			
			jmp Proceed2
			
	
	Proceed2:
		pop di	
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		
		mov cx,[cs:len]
	dec cx
	
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	sub bx,1
	
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	
		
	
		mov word[es:di-160],dx	    ;Head moved to the right
		add word[cs:index+bx],-160	;Update index of Head
	
	RePrintingBody3:
		mov si,[cs:index+bx-2]	;Store index of Current Char	
		
		mov ax,[es:si]
		mov word[es:di],ax
		
		mov word[cs:index+bx-2],di
		
		mov di,si
		sub bx,2
		loop RePrintingBody3
		
	mov dx,0x0720
	mov word[es:di],dx
		
	mov word[cs:direction],1
	
	callNoMatch2:
		ret
			
	
DownArrow:
	mov ax,0xb800
	mov es,ax
	
	cmp word[cs:direction],1 ;If snake direction is Up, don't go Down.
	je calltocallNoMatch3
	
	mov cx,[cs:len]
	dec cx
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	
	sub bx,1
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	;di = 2020
	
	jmp forward3
	calltocallNoMatch3:
		jmp callNoMatch3
	;-----------------------------------
	;COLLISION WITH BORDER
	forward3:
		mov ah,0x04
		mov al,'#'
		cmp word[es:di+160],ax 	;If it touches the border
		jne CheckOverlapping3
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch3
	;-------------------------------------
	;COLLISION WITH ITSELF
	CheckOverlapping3:
		mov ah,0x07
		mov al,'*'
		cmp word[es:di+160],ax
		jne CheckFruit3
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch3
	;COLLISION WITH FRUIT
	CheckFruit3:
		push ax	
		push bx
		push cx
		push dx
		push si
		push di
		
		mov ah,0x01
		mov al,'F'
		cmp word[es:di+160],ax
		jne calltoProceed3
		;else
		
		call printingFruits
		mov cx,[cs:len]
		mov bx,[cs:len]
		dec bx
		mov dx,0
		l13:
			mov dl,[cs:snake+bx]
			;mov byte[snake+bx],0
			mov byte[cs:snake+bx+4],dl
			dec bx
			loop l13
		
		mov cx,[cs:len]
		mov bx,[cs:len]
		add word[cs:len],4
		dec bx
		shl bx,1
		l23:
			mov dx,[cs:index+bx]
			mov word[cs:index+bx+8],dx
			sub bx,2
			loop l23
		jmp forward53
		
		calltoProceed3:
			jmp Proceed3
		
		forward53:
		mov di,[cs:index+8] ;Get index of TAIL "*"
		mov si,[cs:index+10] ;Get 2nd Last "*"
		
		sub si,di	;Get difference to Know the direction of snake
		
		mov ah,0x07
		mov al,'*'
		mov bx,6	;6,4,2,0 Index of * in Index array
		mov cx,4	;Number of characters to add
		tailisLeft3:
			cmp si,2
			jne tailisUp3
			addLeft3:
				sub di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addLeft3
			
			jmp Proceed3
				
			
		tailisUp3:
			cmp si,160
			jne tailisRight3
			addUp3:
				sub di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addUp3
			
			jmp Proceed3
			
		tailisRight3:
			cmp si,-2
			jne tailisDown3
			addRight3:
				add di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addRight3
			
			jmp Proceed3
			
			
		tailisDown3:
			cmp si,-160
			addDown3:
				add di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addDown3
			
			jmp Proceed3
			
	
	Proceed3:
		pop di	
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		
		mov cx,[cs:len]
	dec cx
	
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	sub bx,1
	
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	
	
		mov word[es:di+160],dx	    ;Head moved to the right
		add word[cs:index+bx],160	;Update index of Head
	
	RePrintingBody2:
		mov si,[cs:index+bx-2]	;Store index of Current Char	
		
		mov ax,[es:si]
		mov word[es:di],ax
		
		mov word[cs:index+bx-2],di
		
		mov di,si
		sub bx,2
		loop RePrintingBody2
		
	mov dx,0x0720
	mov word[es:di],dx
			
	mov word[cs:direction],3
	
	callNoMatch3:
		ret

LeftArrow:
	mov ax,0xb800
	mov es,ax
	
	cmp word[cs:direction],2 ;If snake direction is Right, don't go Left.
	je calltocallNoMatch4
	
	mov cx,[cs:len]
	dec cx
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	
	sub bx,1
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	;di = 2020
	
	jmp forward4
	calltocallNoMatch4:
		jmp callNoMatch4
	;-----------------------------------
	;COLLISION WITH BORDER
	forward4:
		mov ah,0x04
		mov al,'#'
		cmp word[es:di-2],ax 	;If it touches the border
		jne CheckOverlapping4
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch4
	;-------------------------------------
	;COLLISION WITH ITSELF
	CheckOverlapping4:
		mov ah,0x07
		mov al,'*'
		cmp word[es:di-2],ax
		jne CheckFruit4
		;else
		
		mov word[cs:direction],2
		call clrscr
		call printingBorder
		call printingSnake
		call printingFruits
		jmp callNoMatch4
	;COLLISION WITH FRUIT
	CheckFruit4:
		push ax	
		push bx
		push cx
		push dx
		push si
		push di
		
		mov ah,0x01
		mov al,'F'
		cmp word[es:di-2],ax
		jne calltoProceed4
		;else
		
		call printingFruits
		mov cx,[cs:len]
		mov bx,[cs:len]
		dec bx
		mov dx,0
		l14:
			mov dl,[cs:snake+bx]
			;mov byte[snake+bx],0
			mov byte[cs:snake+bx+4],dl
			dec bx
			loop l14
		
		mov cx,[cs:len]
		mov bx,[cs:len]
		add word[cs:len],4
		dec bx
		shl bx,1
		l24:
			mov dx,[cs:index+bx]
			mov word[cs:index+bx+8],dx
			sub bx,2
			loop l24
		jmp forward54
		
		calltoProceed4:
			jmp Proceed4
		
		forward54:
		mov di,[cs:index+8] ;Get index of TAIL "*"
		mov si,[cs:index+10] ;Get 2nd Last "*"
		
		sub si,di	;Get difference to Know the direction of snake
		
		mov ah,0x07
		mov al,'*'
		mov bx,6	;6,4,2,0 Index of * in Index array
		mov cx,4	;Number of characters to add
		tailisLeft4:
			cmp si,2
			jne tailisUp4
			addLeft4:
				sub di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addLeft4
			
			jmp Proceed4
				
			
		tailisUp4:
			cmp si,160
			jne tailisRight4
			addUp4:
				sub di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addUp4
			
			jmp Proceed4
			
		tailisRight4:
			cmp si,-2
			jne tailisDown4
			addRight4:
				add di,2
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addRight4
			
			jmp Proceed4
			
			
		tailisDown4:
			cmp si,-160
			addDown4:
				add di,160
				mov word[es:di],ax
				mov [cs:index+bx],di
				sub bx,2
				loop addDown4
			
			jmp Proceed4
			
	
	Proceed4:
		pop di	
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		
		mov cx,[cs:len]
	dec cx
	
	mov bx,[cs:len]	;bx is used as offset for Index/Snake Array	
	sub bx,1
	
	mov dh,0x07
	mov dl,[cs:snake+bx] ;Get Value of Head "@" 

	shl bx,1	;Multiplying by 2 because index is in "dw"
	mov di,[cs:index+bx] ;Get index of Head "@"
	
		
		
		mov word[es:di-2],dx	;Head moved to the right
		add word[cs:index+bx],-2	;Update index of Head
	
	RePrintingBody4:
		mov si,[cs:index+bx-2]	;Store index of Current Char	
		
		mov ax,[es:si]
		mov word[es:di],ax
		
		mov word[cs:index+bx-2],di
		
		mov di,si
		sub bx,2
		loop RePrintingBody4 

		
	mov dx,0x0720
	mov word[es:di],dx
		
	mov word[cs:direction],4
	
	callNoMatch4:
		ret	
		

kbisr:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	in al,0x60
	cmp al,0x4D 
	jne nextcmp
	call RightArrow
	jmp nomatch
	
nextcmp:
	cmp al,0x48 ;UpArrow
	;if
	jne nextcmp2
	call UpArrow
	jmp nomatch
	;else	
nextcmp2:
	cmp al,0x50 ;DownArrow
	;if
	jne nextcmp3
	call DownArrow
	jmp nomatch
	;else	
nextcmp3:
	cmp al,0x4B ;LeftArrow
	jne nomatch
	;if
	call LeftArrow
	;else
	;exit 
nomatch: 
	mov al, 0x20
	out 0x20, al 
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	iret
	

	
work :
	cmp word[cs:direction],2  ;1 for Up, 2 for Right, 3 for Down, 4 for Left
	jne nextcmp10
	call RightArrow
	
nextcmp10:
	cmp word[cs:direction],1  ;1 for Up, 2 for Right, 3 for Down, 4 for Left
	jne nextcmp11
	call UpArrow
	
nextcmp11:
	cmp word[cs:direction],3  ;1 for Up, 2 for Right, 3 for Down, 4 for Left
	jne nextcmp12
	call DownArrow
	
nextcmp12:
	cmp word[cs:direction],4  ;1 for Up, 2 for Right, 3 for Down, 4 for Left
	jne nextcmp13
	call LeftArrow
	
nextcmp13:
	ret
	
	
	
timer: 
	push ax
	inc word[cs:tickcount]
	inc word[cs:forrandom]
	inc word[cs:forrandom2]
	mov ax,[cs:forrandom]  ;column random generator
	cmp ax,78
	jng label10
	mov word[cs:forrandom],4
 
	
label10:
	mov ax,[cs:forrandom2]  ;row random generator
	cmp ax,23
	jng label11
	mov ax,2
	mov word[cs:forrandom2],2
 
	
label11:	
	mov ax,[cs:tickcount]
	cmp ax,3
	jng label1
		 
	call work 
		  
	mov word[cs:tickcount],0
 
label1:
	mov al, 0x20
	out 0x20, al ; end of interrupt
	pop ax
	iret ; return from interrupt
	
	
start:
    mov ax,0xb800
	mov es,ax

	
    mov word[cs:direction],2
	call clrscr
	
	mov di,1620
	mov ah,0x01		;L R G B I R G B
					;0 0 0 0 0 0 1 0
	mov al,'F'
	mov word[es:di],ax
	
	;initiating snake
	mov cx,19
	mov bx,0
	
	FormingSnakeLoop:
		mov byte[cs:snake+bx],'*'
		inc bx
		loop FormingSnakeLoop
	mov byte[cs:snake+bx],'@'
	
	mov cx,19
	mov bx,0
	
	FormingOldSnake:
		mov byte[cs:oldsnake+bx],'*'
		inc bx
		loop FormingOldSnake
	
	mov byte[cs:oldsnake+bx],'@'
	
	call printingBorder
	call printingSnake
	
		
	xor ax, ax
	mov es, ax ; point es to IVT base
	cli ; disable interrupts
	mov word [es:8*4], timer; store offset at n*4
	mov [es:8*4+2], cs ; store segment at n*4+2
	sti ; enable interrupts
		
	xor ax,ax
	mov es,ax
		
	cli
	mov word[es:9*4],kbisr
	mov word[es:9*4+2],cs
	sti
	
	mov ax, 0x3100 ; terminate and stay resident
	int 0x21