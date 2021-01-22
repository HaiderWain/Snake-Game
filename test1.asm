[org 0x0100]

jmp start
fruitno: dw 0
message: db 'GAME OVER'
message1: db 'FINAL SCORE'
message2: db 'YOU WIN!!'
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
lifeString: db 'Lives = '
lives: db 3
ScoreString: db 'Score = '
Score: db 0
Minutes: db 9
Seconds : db 60
tickCountForTime: dw 0
speed: dw 18
tickCountForSpeed: dw 0
tickCountFor4Minutes: dw 0


Wingame:
	mov ax,0xb800
	mov es,ax
    
	mov ah,0x04
	mov di,2000
	add di,-340
	mov cx,9
	mov bx,0
	complete2:
		mov al,[cs:message2+bx]
		mov word[es:di],ax
		add di,2
		inc bx
		loop complete2
	
	mov cx,11
	mov ah,0x01
	mov di,2000
	add di,-20
	mov bx,0
	complete3:
		mov al,[cs:message1+bx]
		mov word[es:di],ax
		add di,2
		inc bx
		loop complete3
	
	add di,2
	mov al,[cs:Score]
	mov ah,0
	push ax
	call printnum
	
	
	ret
	
endgame:
	mov ax,0xb800
	mov es,ax
    
	mov ah,0x04
	mov di,2000
	add di,-340
	mov cx,9
	mov bx,0
	complete:
	mov al,[cs:message+bx]
	mov word[es:di],ax
	add di,2
	inc bx
	loop complete
	
	mov cx,11
	mov ah,0x01
	mov di,2000
	add di,-20
	mov bx,0
	complete1:
	mov al,[cs:message1+bx]
	mov word[es:di],ax
	add di,2
	inc bx
	loop complete1
	
	add di,2
	mov al,[cs:Score]
	mov ah,0
	push ax
	call printnum
	
	
	ret

Beep: 
    in al, 61h  ;Save state
    push ax  

    mov bx, 6818; 1193180/175

    mov al, 6Bh  ; Select Channel 2, write LSB/BSB mode 3
    out 43h, al 

    mov ax, bx 

    out 24h, al  ; Send the LSB
    mov al, ah  
    out 42h, al  ; Send the MSB

    in al, 61h   ; Get the 8255 Port Contence
    or al, 3h  
    out 61h, al  ;End able speaker and use clock channel 2 for input

    mov cx, 03h ; High order wait value

    mov dx,0D04h; Low order wait value

    mov ax, 86h;Wait service

    int 15h        
    pop ax;restore Speaker state
    out 61h, al
    ret
printnum: 
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	
	mov ax, 0xb800
	mov es, ax 
	mov ax, [bp+4] ; load number in ax
	
	mov bx, 10 
	mov cx, 0 

nextdigit: 
	mov dx, 0 
	div bx 
	add dl, 0x30 
	push dx 
	inc cx 
	cmp ax, 0 
	jnz nextdigit 
	mov di,[bp-12]
nextpos: 
	pop dx 
	mov dh, 0x05
	mov [es:di], dx 
	add di, 2 
	loop nextpos 
	
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2

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
	
	mov di,320
	mov ah,0x04	
	mov al,0x23		
	mov cx,80
	
	cld
	rep stosw
	
	mov di,478
	mov ah,0x04	
	mov al,0x23		
	mov cx,23
	verticalPrintingRight:
		mov word[es:di],ax
		add di,160
		loop verticalPrintingRight
		
	mov di,320
	mov ah,0x04	
	mov al,0x23		
	mov cx,23
	verticalPrintingLeft:
		mov word[es:di],ax
		add di,160
		loop verticalPrintingLeft
		
		
	mov di,3680
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
    lb1:
	mov di,[cs:forrandom]
	add di,di
	mov cx,[cs:forrandom2]
	
	generate:
	add di,160
	loop generate
	
	mov ah,0x01		;L R G B I R G B
					;0 0 0 0 0 0 1 0

	mov al,'F'
	mov dx,[es:di]
	cmp dx,0x0720
	jnz lb2
	mov word[es:di],ax
	jmp lb3
	lb2:
	inc word[cs:forrandom]
	inc word[cs:forrandom2]
	mov ax,[cs:forrandom]  ;column random generator
	cmp ax,78
	jng label12
	mov word[cs:forrandom],4
 
	
    label12:
	mov ax,[cs:forrandom2]  ;row random generator
	cmp ax,22
	jng label13
	mov ax,2
	mov word[cs:forrandom2],3
	label13:
	jmp lb1
	
	
	
	lb3:
	
	
	mov ax,[cs:fruitno]
	cmp ax,1
	je dothis2
	cmp ax,0
	je dothis1
	cmp ax,2
	je dothis3
	
	
	dothis1:
	lb5:
	mov di,[cs:forrandom]
	add di,di
	mov cx,[cs:forrandom2]
	
	generate1:
	add di,160
	loop generate1
	
	mov ah,0x04		;L R G B I R G B
					;0 0 0 0 0 0 1 0

	mov al,'D'
	mov dx,[es:di]
	cmp dx,0x0720
	jnz lb6
	mov word[es:di],ax
	jmp lb7
	lb6:
	inc word[cs:forrandom]
	inc word[cs:forrandom2]
	mov ax,[cs:forrandom]  ;column random generator
	cmp ax,78
	jng label14
	mov word[cs:forrandom],4
 
	
    label14:
	mov ax,[cs:forrandom2]  ;row random generator
	cmp ax,22
	jng label15
	mov ax,2
	mov word[cs:forrandom2],3
	label15:
	jmp lb5
	
	lb7:
	
	
	dothis2:
	lb9:
	mov di,[cs:forrandom]
	add di,di
	mov cx,[cs:forrandom2]
	
	generate3:
	add di,160
	loop generate3
	
	mov ah,0x04		;L R G B I R G B
					;0 0 0 0 0 0 1 0

	mov al,'D'
	mov dx,[es:di]
	cmp dx,0x0720
	jnz lb61
	mov word[es:di],ax
	
	dothis3:
	jmp lb8
	lb61:
	inc word[cs:forrandom]
	inc word[cs:forrandom2]
	mov ax,[cs:forrandom]  ;column random generator
	cmp ax,78
	jng label144
	mov word[cs:forrandom],4
 
	
    label144:
	mov ax,[cs:forrandom2]  ;row random generator
	cmp ax,22
	jng label154
	mov ax,2
	mov word[cs:forrandom2],3
	label154:
	jmp lb9
	
	lb8:	
	mov word[cs:fruitno],2
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
printLives:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov cx,8
	mov di,3860
	mov si,0
	
	mov ah,0x07
	looping:
		mov al,[cs:lifeString+si]
		mov word[es:di],ax
		add di,2
		inc si
		loop looping
	
	;add di,2
	mov ah,0x05
	mov al,[cs:lives]
	add al,0x30
	
	mov word[es:di],ax
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
printScore:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov cx,8
	mov di,3900
	mov si,0
	
	mov ah,0x07
	loopforprintingScore:
		mov al,[cs:ScoreString+si]
		mov word[es:di],ax
		add di,2
		inc si
		loop loopforprintingScore
	
	;add di,2
	mov ah,0
	mov al,[cs:Score]	
	
	push ax
	call printnum
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
printTime:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	;Printing Minutes
	mov di,234
	mov ah,0x05
	mov al,[cs:Minutes]
	add al,0x30
	mov [es:di],ax
	
	;Printing ":"
	mov di,236
	mov ah,0x07
	mov al,':'
	mov [es:di],ax
	
	;Printing Seconds
	cmp byte[cs:Seconds],10
	jl deleteExtra0
	mov di,238
	mov ah,0
	mov al,[cs:Seconds]
	push ax
	call printnum
	jmp returnback
	
	deleteExtra0:
		mov di,238
		mov ah,0
		mov al,[cs:Seconds]
		push ax
		call printnum
		mov word[es:240],0x0720
		
	returnback
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
	
printStage1:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov ah,0x04
	mov al,'#'
	
	mov di,1160
	mov cx,40
	
	cld
	rep stosw
	
	mov di,3080
	mov cx,40
	
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
	
printStage2:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov ah,0x04
	mov al,'#'
	
	mov di,830
	mov cx,15
	
	loopforprintStage2:
		mov [es:di],ax
		add di,160
		loop loopforprintStage2
		
	mov di,930
	mov cx,15
	
	loop2forprintStage2:
		mov [es:di],ax
		add di,160
		loop loop2forprintStage2
		
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	
	ret
	
printStage3:
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax,0xb800
	mov es,ax
	
	mov ah,0x04
	mov al,'#'
	
	mov di,1330
	mov cx,30
	
	cld
	rep stosw	
	
	mov di,1330
	mov cx,8
	
	loopforprintStage3:
		mov [es:di],ax
		add di,164
		loop loopforprintStage3
		
	mov di,1390
	mov cx,8
	
	loop2forprintStage3:
		mov [es:di],ax
		add di,156
		loop loop2forprintStage3
	
	
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
	mov di,[cs:index+bx] 

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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je calltoprintStage2
		call printStage3
		jmp movingon
		calltoprintStage2:
			call printStage2
		
		movingon:
		call printingSnake
		call printLives
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call2toprintStage2
		call printStage3
		jmp movingon2
		call2toprintStage2:
			call printStage2
		
		movingon2:
		call printingSnake
		call printLives
		call printScore
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
		
		
		mov ah,0x04
		mov al,'D'
		cmp word[es:di+2],ax
		jne dont
		dec byte[cs:lives]
		dec word[cs:fruitno]
		call printLives
		
		dont:
		mov ah,0x01
		mov al,'F'
		cmp word[es:di+2],ax
		jne calltoProceed
		;else
		
		call printingFruits
		add byte[cs:Score],5
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call3toprintStage2
		call printStage3
		jmp movingon3
		call3toprintStage2:
			call printStage2
		
		movingon3:
		call printingSnake
		call printLives
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call4toprintStage2
		call printStage3
		jmp movingon4
		call4toprintStage2:
			call printStage2
		
		movingon4:
		call printingSnake
		call printLives
		call printScore
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
		
		
		mov ah,0x04
		mov al,'D'
		cmp word[es:di-160],ax
		jne dont2
		dec byte[cs:lives]
		dec word[cs:fruitno]
		call printLives
		
		
		dont2:
		mov ah,0x01
		mov al,'F'
		cmp word[es:di-160],ax
		jne calltoProceed2
		;else
		
		call printingFruits
		add byte[cs:Score],5
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call5toprintStage2
		call printStage3
		jmp movingon5
		call5toprintStage2:
			call printStage2
		
		movingon5:
		call printingSnake
		call printLives
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call6toprintStage2
		call printStage3
		jmp movingon6
		call6toprintStage2:
			call printStage2

			
		movingon6:
		call printingSnake
        call printLives
		call printScore
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
		
		
		mov ah,0x04
		mov al,'D'
		cmp word[es:di+160],ax
		jne dont3
		dec byte[cs:lives]
		dec word[cs:fruitno]
		call printLives
		
		
		dont3:
		mov ah,0x01
		mov al,'F'
		cmp word[es:di+160],ax
		jne calltoProceed3
		;else
		
		call printingFruits
		add byte[cs:Score],5
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call7toprintStage2
		call printStage3
		jmp movingon7
		call7toprintStage2:
			call printStage2
		
		movingon7:
		call printingSnake
		call printLives
		call printScore
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
		call Beep
		mov word[cs:direction],2
		dec byte[cs:lives]
		call clrscr
		call printingBorder
		cmp byte[cs:lives],2
		je call8toprintStage2
		call printStage3
		jmp movingon8
		call8toprintStage2:
			call printStage2
		
		movingon8:
		call printingSnake
		call printLives
		call printScore
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
		
		
		mov ah,0x04
		mov al,'D'
		cmp word[es:di-2],ax
		jne dont4
		dec byte[cs:lives]
		dec word[cs:fruitno]
		call printLives
		
		dont4:
		mov ah,0x01
		mov al,'F'
		cmp word[es:di-2],ax
		jne calltoProceed4
		;else
		
		call printingFruits
		add byte[cs:Score],5
		call printScore
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
	
	cmp byte[cs:lives],0
	je nomatch
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
    cmp byte[cs:lives],0
	jne dont5
	call clrscr
	call endgame
	jmp endit
	
	dont5:
	cmp byte[cs:len],60
	jne dont6
	call clrscr
	call Wingame
	jmp endit
	
	dont6:
	mov ax,0xb800
	mov es,ax
	cmp byte[cs:lives],0
	je calltolabel1
	inc word[cs:tickCountFor4Minutes]
	inc word[cs:tickCountForSpeed]
	inc word[cs:tickCountForTime]
	inc word[cs:tickcount]
	inc word[cs:forrandom]
	inc word[cs:forrandom2]
	mov ax,[cs:forrandom]  ;column random generator
	cmp ax,78
	jng label10
	mov word[cs:forrandom],4


label10:
	mov ax,[cs:forrandom2]  ;row random generator
	cmp ax,22
	jng label9
	mov ax,2
	mov word[cs:forrandom2],3

label9:
	cmp word[cs:tickCountForSpeed],364
	jne label11
	
	mov ax,[cs:speed]
	shr ax,1
	mov [cs:speed],ax
	
	mov word[cs:tickCountForSpeed],0
	mov word[cs:tickcount],0
	
label11:	
	mov ax,[cs:tickcount]
	cmp ax,[cs:speed]
	jng nextlabel
		 
	call work 
		  
	mov word[cs:tickcount],0
	jmp nextlabel
	
calltolabel1:
	jmp label11

nextlabel:
	call printTime
	
	cmp word[cs:tickCountForTime],18
	jne nextlabel2
	
	cmp byte[cs:Seconds],0
	je decreaseMinute
	
	dec byte[cs:Seconds]
	mov word[cs:tickCountForTime],0
	jmp nextlabel2
	
	decreaseMinute:
		cmp byte[cs:Minutes],0
		je label1
		dec byte[cs:Minutes]
		mov byte[cs:Seconds],59
		mov word[cs:tickCountForTime],0
				
nextlabel2:
	cmp word[cs:tickCountFor4Minutes],4368
	jne label1
	mov word[cs:tickCountFor4Minutes],0
	cmp word[cs:len],240
	jnl label1
	mov word[cs:direction],2
	dec byte[cs:lives]
	mov byte[cs:Score],0
	call clrscr
	call printingBorder
	call printingSnake
	call printLives
	call printScore
	call printingFruits
	
	endit:
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
	mov ah,0x01		
	
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
	call printStage1
	call printingSnake
	call printLives
	call printScore	
	call printTime
		
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