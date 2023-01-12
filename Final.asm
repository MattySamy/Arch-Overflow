include "emu8086.inc" 
org 100h  

.data  
    countA db 0  ; size of cols    
    countB db 0
    countC db 0 
    countD db 0
    countE db 0 
    countF db 0  
    countG db 0
    
    largeList db 42 dup(?)           
    done db ?        ; status of winner ( V , H , D , DR )  
    win db 0          ; counter to check winner 
    count dw 0       ; cuurent index in checkH
    countCol db 0   ; break point 
    countRow db 0   ; break point 

.code                   
; FOLLOW
; 1- Draw 
; 2- take input (col name)
; 3- check if col full or not  => 
;        if full => take new input
;        if not => push input & inc size
; 4- check winner ( V , H , D , DR ) 
; 5- check if all complete  => end game
; 6- go to step 2

;**** fream ****  
MOV AX , 0B800H  ; display video mode
MOV DS , AX 
MOV AL , 38 ; COLOR       
 
MOV CL , 0          
MOV BH , 0
;LEA DI , colA 
;MOV BL , countA 

         
GOTOXY 20 , 0 
PRINT 'WELLCOME TO OUR GAME'
GOTOXY 25 , 2
PRINT 'CONNECT 4 '
GOTOXY 20 , 3
PRINT '___________________'
  
MOV [964] , 'A'
MOV [970] , 'B'
MOV [976] , 'C'
MOV [982] , 'D'
MOV [988] , 'E'
MOV [994] , 'F'
MOV [1000] , 'G'
 
MOV CX , 12 
MOV BL , 7 
MOV DL , 8
L1:
 
GOTOXY 1 , BL
PRINT '_____________________'      

GOTOXY 3 , DL
PRINT '|'    
GOTOXY 6 , DL
PRINT '|'  
GOTOXY 9 , DL
PRINT '|'    
GOTOXY 12 , DL
PRINT '|' 
GOTOXY 15 , DL
PRINT '|'    
GOTOXY 18 , DL
PRINT '|'  
GOTOXY 21 , DL
PRINT '|'     
  
ADD BL , 2 
ADD DL , 2
DEC CX  
LOOP L1 

GOTOXY 1 , 19                   
PRINT '_____________________' 
PRINT 0AH

; **** TACK DATA ****
MOV AX , @DATA
MOV DS , AX 
;MOV SI , OFFSET input   

GOTOXY 0 20   ; TO START FROM BEGINING 
PRINT 10 ,13  ; PRINT NEW LINE
PRINT 'chose col from (A,B,C,D,E,F,G)'

MOV CL , 0  
mov dl , 1  ; first player is X (1)
mov dh, 1  ; first player is X (1)  

choise: 
 GOTOXY 10 , 22     
mov win , 0 
 cmp dl, 1
 JE player1   
 
  cmp dl, 2
 JE player2
 
  
 player1:  
    print "Player 1 :" 
    mov dl, 2 
    mov dh, 1
    JMP readInput  
 player2:
    mov dl, 1  
    mov dh, 2
    print "Player 2 :"     
 
 readInput:  
 GOTOXY 20 ,23
 print '                                              '
 GOTOXY 20 ,23  ; 
print "choise : "   
 
 MOV AH , 01      ; read form player 
 INT 21H
 
 cmp al , 41H    
 JE A  
 cmp al , 42H  
 JE B         
  cmp al , 43H  
 JE C  
  cmp al , 44H  
 JE D  
  cmp al , 45H  
 JE E           
   cmp al , 46H  
 JE F  
   cmp al , 47H  
 JE G 

; IF player enter any character except (A,B,C,D,E,F,G) then => go to take input again and print message
 GOTOXY 20 ,23   
PRINT "Invalid Please chose only (A,B,C,D,E,F,G)"
 JMP back  
  
 A: 
    ; check if countA >=6
    ; if full => check the capacity of all cols
    ;     if there at least one col avail => jump to choise 
    ;     if all full => print game complate
    mov al, countA   
    ; check if col available or not 
    cmp al , 6      ; count >= 6 go for check  
    ; if not available check other cols 
    jae checkAll
    ; determine the position to draw       
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 2 , bl          
    mov al, countA
    CBW 
    mov count , ax 
    ; deal with large array 
    mov si, offset largeList 
    MOV di, si 
    ADD SI , AX    
    mov [si], DH 
    ; incremant size of array
    inc countA 
    ; determin the draw (x|o)   
    cmp dh, 1  
    je ap1       
    cmp dh, 2  
    je ap2  
    ; draw point
    ap1:  
    putc 'X' 
    JMP checkA
    
    ap2: 
    putc 'O' 
    
    checkA:  
    cmp ax, 3 
    jae checkV
     
    jmp checkDiagonal 
    ;jmp checkH 
 B:     
    mov al, countB        
    cmp al , 6      ; count >= 6 go for check   
    jae checkAll
        
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 5 , bl 
    MOV AL , countB
    CBW
    mov count , ax 
    ; deal with large array 
    mov si, offset largeList 
    ADD SI , 6  
    mov di, si 
    add si, AX     
    mov [si], DH
     
    inc countB    
    
    cmp dh, 1
    je bp1       
    cmp dh, 2  
    je bp2  
    
    bp1:
    putc 'X'
    JMP checkB    
    
    bp2: 
    putc 'O' 

    checkB:  
    cmp ax, 3 
    jae checkV
                    
    jmp checkDiagonal 
    
 C:     
 
    mov al, countC   
        
    cmp al , 6      ; count >= 6 go for check   
    jae checkAll
 
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 8 , bl  
    mov al, countC 
    CBW
    ; deal with large array 
    mov si, offset largeList 
    ADD SI , 12  
    mov di, si 
    add si, AX
    mov [si], DH 
    mov count , ax
    inc countC  
    je cp1       
    cmp dh, 2  
    je cp2  
    
    cp1:
    putc 'X'
    JMP checkC      
    
    cp2: 
    putc 'O' 
    
    checkC:   
    cmp ax, 3 
    jae checkV         
    jmp checkDiagonal    
D:     
 
    mov al, countD  
        
    cmp al , 6      ; count >= 6 go for check   
    jae checkAll
           
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 11 , bl        
    mov al, countD
    CBW
    mov count , ax
    ; deal with large array 
    
    mov si, offset largeList 
    ADD SI , 18    
    mov di, si 
    add si, AX
    mov [si], DH 

    inc countD    
    
    cmp dh, 1
    je dp1       
    cmp dh, 2  
    je dp2  
    
    dp1:
    putc 'X'
    JMP checkD      
    
    dp2: 
    putc 'O' 
    
    checkD:                        
    cmp ax, 3 
    jae checkV  
    jmp checkDiagonal
 E:     
 
    mov al, countE            
    cmp al , 6      ; count >= 6 go for check   
    jae checkAll
    
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 14 , bl   
    mov al, countE         
    CBW  
    mov count , ax    
    
    ; deal with large array 
    mov si, offset largeList 
    ADD SI , 24  
    mov di, si 
    add si, AX
    mov [si], DH 
    
    mov count , ax
    inc countE   
    
    cmp dh, 1  
    je ep1       
    cmp dh, 2  
    je ep2  
    
    ep1:
    putc 'X'
    JMP checkE      
    
    ep2: 
    putc 'O' 
    
    checkE:  
    cmp ax, 3 
    jae checkV  
    jmp checkDiagonal    
 F:     
    mov al, countF 
    cmp al , 6     ; count >= 6 go for check   
    jae checkAll
            
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 17 , bl  
    mov al, countF
    CBW         
    mov count , ax
    ; deal with large array 
    mov si, offset largeList 
    ADD SI , 30     
    mov di, si 
    add si, AX
    mov [si], DH
    inc countF 
    
    cmp dh, 1  
    je fp1       
    cmp dh, 2  
    je fp2  
    
    fp1:
    putc 'X'
    JMP checkF      
    
    fp2: 
    putc 'O'  
    
    checkF:  
    cmp ax, 3 
    jae checkV       
    
    jmp checkDiagonal

 G:     
 
    mov al, countG       
    cmp al , 6      ; count >= 6 go for check   
    jae checkAll
        
    mov bl, 18 
    add al, al 
    sub bl, al 
    
    GOTOXY 20 , bl
     mov al, countG   
     CBW
     mov count, ax  
        
    ; deal with large array 
    mov si, offset largeList 
    ADD SI , 36
    mov di, si 
    add si, AX
    mov [si], DH 
    
    inc countG  
     
    cmp dh, 1  
    je gp1       
    cmp dh, 2  
    je gp2  
    
    gp1:
    putc 'X'
    JMP checkG      
    
    gp2: 
    putc 'O'    
    
    checkG:  
        
    cmp ax, 3 
    jae checkV
    
    jmp checkDiagonal      
    
checkAll:  
mov al , countA 
cmp al, 6      ; count < 6 
jb back  

mov al , countB 
cmp al, 6      ; count < 6 
jb back    

mov al , countC 
cmp al, 6      ; count < 6 
jb back  

mov al , countD 
cmp al, 6      ; count < 6 
jb back  

mov al , countE 
cmp al, 6      ; count < 6 
jb back  

mov al , countF 
cmp al, 6      ; count < 6 
jb back  

mov al , countG 
cmp al, 6      ; count < 6 
jb back  

GOTOXY 10 , 22
PRINT "Game Complete"    
JMP exit                 

;//////////////////////////////////////////    
; => inputs :  
; 1) index of last element in current col 
; => output : 
;       if winner => print win && end game
;       else => go to check diagonal
; Start to check vertical
; loopV1 => ( store current value && compare if index = 3 then go to next check ) 
; loopV2 => ( if current = previous then increment previous an check ) if not win go to loopV1 => repeate 4 times 
; incV => increment win and check ( if win = 4 then print win && end game ) ( if win < 4 then go to loopV2)     
;//////////////////////////////////////////
checkV:       
mov done, 'V'
mov countRow , 0
mov si, di   ; (di) is the index of last element in col   

loopV1:                    
; REST VALUES 
mov countCol , 0           
mov win, 0   

cmp  countRow, 3
jae checkDiagonal
inc countRow   

mov di, si

mov bh, [di]
inc di
cmp bh, [di]
je incV     

inc si
jmp loopV1    

    loopV2:
    inc countCol
    cmp countCol, 4
    jae loopV1 
     
    inc di
    cmp bh, [di]
    je incV
    
    inc si
    jmp loopV1
  
incV:
inc win
cmp win,3
je playerWinner 
jmp loopV2 

; //////////////////////////////////////////// 
; => inputs :   
; 1) index of current col => count (0,1,2,3,4,5)
; => output : 
;       if winner => print win && end game
;       else => go to next choise
; Start to check horizental
; loopH1 => ( store current value && compare => if countRow = 4 then go to next check ) 
; loopH2 => ( if current = previous then add 6 to the previous to check next col ) if not win go to loopH1 => repeate 4 times 
; incV => increment win and check ( if win = 4 then print win && end game ) ( if win < 4 then go to loopH2) 
;//////////////////////////////////////////////
checkH:   
mov done, 'H'
mov countRow , 0  
mov win, 0 
mov si, offset largeList
mov ax , count  

add si, ax
mov di, si
  
loopH1:                  
; REST VALUES 
mov countCol , 0           
mov win, 0   

cmp  countRow, 4
jae choise
inc countRow   

mov di, si

mov bh, [di]     
CMP bh, 0 
je nextRow  

add di, 6
cmp bh, [di]
je incH     

jmp nextRow   

    loopH2:
    inc countCol
    cmp countCol, 4
    jae loopH1 
     
    add di, 6
    cmp bh, [di]
    je incH    
    
    jmp nextRow
     
incH:
inc win
cmp win,3
je playerWinner 
jmp loopH2 

nextRow:
add si, 6
jmp loopH1
;//////////////////////////////////////////////  
; inputs :
; 1)  offset of first index in array
; => output : 
;       if winner => print win && end game
;       else => go to next choise
; Start to check horizental
; loop1 => ( start from first row && increment by 1 => if countRow = 3 then go to checkDiagonalReverse ) else =>  go to loop1D
; loop2 => ( take next row and make all checks )
; loop1D => ( add 7 to current && compare if current = next then add 7 to the next ) if not win => repeate 4 times 
; incD => increment win and check ( if win = 4 then print win && end game ) ( if win < 4 then go to loop2)   
;//////////////////////////////////////////////
checkDiagonal:   
mov done, 'D'       

mov cx,-1        
mov countRow , 0

loop1:                  
; REST VALUES 
mov si, offset largeList  
mov countCol , 0           
mov win, 0 

cmp countRow, 3
jae  checkDiagonalReverse 

inc countRow 
inc cx    
add si, cx
mov bh, [si] ; 0 

cmp bh, 0
je nextCol   

loop1D:  
cmp bh, 0
je nextCol  
          
mov di, si
add di, 7         

cmp bh, [di]
je incD     

cmp bh, [di]
jne nextCol

    loop2:       
    add di, 7
    cmp bh, [di]
    je incD
    
    ; if cmp is false   
    nextCol:  ; next row ( char B,C,D)       
    inc countCol 
    cmp countCol, 4
    jae loop1      
    
    mov win, 0
    add si, 6    
    mov bh, [si] ; 0      
    jmp  loop1D
    
;jbe loop1  

incD:
inc win 
cmp win, 3 
je playerWinner  

jmp loop2

; End checkDiagonal:   
;///////////////////////////////////        
checkDiagonalReverse:
mov done, 'R'       

mov cx,6        
;mov ax, 0

mov countRow , 0   

loopR1:                  
; REST VALUES 
mov si, offset largeList  
mov countCol , 0           
mov win, 0 
 

cmp countRow, 3
jae  checkH 
inc countRow 

dec cx    
add si, cx
mov bh, [si] ; 0 

cmp bh, 0
je nextColR        


loop1DR:  
cmp bh, 0
je nextColR  
          
mov di, si
add di, 5         

cmp bh, [di]
je incDR     

cmp bh, [di]
jne nextColR     

    loopR2:       
    add di, 5
    cmp bh, [di]
    je incDR
    
    ; if cmp is false   
    nextColR:  ; next row ( char B,C,D)       
    inc countCol 
    cmp countCol, 4
    jae loopR1      
    
    mov win, 0
    add si, 6    
    mov bh, [si] ; 0      
    jmp  loop1DR
               
incDR:
inc win 
cmp win, 3 
je playerWinner  

jmp loopR2                              
    
;///////////////////////////////////

back:
mov dl, dh   ; to keep the value of next player   
jmp choise        

                                          
playerWinner:   
GOTOXY 20 ,23  ;    

cmp dh, 1 
je player1Win             

print "Player Two is win"    
jmp exit 

player1Win:
print "Player One is win"        
jmp  exit

exit:          
GOTOXY 30 ,6
print '* ARCH OVERFLOW *'
GOTOXY 30 ,8            
print 'Mohamed Salah Rajab'
GOTOXY 30 , 10   
print 'Mustafa Abdel Hamid'   
GOTOXY 30 , 12   
print 'Aya Elsayed Hussein'
GOTOXY 30 , 14   
print 'Samaa Abdel Mohsen Mohamed'
GOTOXY 30 , 16   
print 'Radwa Ayman Hassan'   

ret                              