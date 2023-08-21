PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

T1CL = $6004
T1CH = $6005
ACR = $600B
IFR = $600D
IER = $600E

E  = %01000000
RW = %00100000
RS = %00010000

char_addr = $00 ; 2 bytes LOW, HIGH
last_addr = $02 ; 1 byte
counter = $03 ; 1 byte
guystatus = $04 ; 1 byte
jump = $05 ; 1 byte


  .org $8000

reset:
  ldx #$ff
  txs

  sei
  
  lda #%11111110 ; Set one pin on port A to input
  sta DDRA
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  jsr lcd_init
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001100 ; Display on; cursor off; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  stz last_addr
  stz last_addr + 1
  
  stz guystatus
  stz jump
  stz counter

  lda #(guy1 & $ff)
  sta char_addr
  lda #(guy1 >> 8)
  sta char_addr + 1
  ldy #0
  jsr make_char

  lda #(guy2 & $ff)
  sta char_addr
  lda #(guy2 >> 8)
  sta char_addr + 1
  ldy #1
  jsr make_char

  lda #(guyjump & $ff)
  sta char_addr
  lda #(guyjump >> 8)
  sta char_addr + 1
  ldy #2
  jsr make_char
  
  lda #%01000000
  sta ACR

  lda #%11000000
  sta IER

  lda #$0e
  sta T1CL
  lda #$27
  sta T1CH

  lda #%11000000
  jsr lcd_instruction

  lda #0
  jsr print_char

  cli

loop:
  lda PORTA
  beq cont
  lda guystatus
  ora #2
  sta guystatus
  jmp loop
cont:
  lda guystatus
  and #1
  sta guystatus
  jmp loop
  


; ////////////////
; LCD INSTRUCTIONS
; ////////////////

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

lcd_init:
  lda #%00000010 ; Set 4-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  rts

lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  rts

read_address:
  jsr lcd_wait
  lda #%11110000 ; LCD data is input
  sta DDRB

  lda #RW        ; Read busy flag and addresses
  sta PORTB
  lda #(RW|E)
  sta PORTB
  lda PORTB      ; Read high nibble
  and #%00000111 ; Only read addresses
  asl
  asl
  asl
  asl
  sta last_addr  ; Shifted to the left 4 times and stored
  lda #RW        ; Read busy flag and addresses
  sta PORTB
  lda #(RW|E)
  sta PORTB
  lda PORTB      ; Read low nibble
  and #%00001111 ; Only read addresses
  ora last_addr  ; OR with high nibble
  sta last_addr

  lda #RW
  sta PORTB
  lda #%11111111 ; LCD data is output
  sta DDRB
  rts

make_char:
  jsr read_address

  tya
  asl
  asl
  asl
  and #%00111000
  ora #%01000000
  pha
  ldx #8
mchar_loop:
  jsr lcd_instruction
  lda (char_addr)
  jsr print_char
  inc char_addr
  pla
  inc
  pha
  dex
  bne mchar_loop
mchar_exit:
  pla
  lda last_addr
  ora #%10000000
  jsr lcd_instruction
  rts

print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts

; ////////////////
;       END
; ////////////////


irq:
  pha
  lda counter
  cmp #100
  beq frame
exit:
  inc counter
  lda T1CL
  pla
  rti
frame:
  stz counter

  lda #%00000001 ; Clear display
  jsr lcd_instruction

  lda guystatus
  and #2
  cmp #2
  beq jumpR
toggle:
  lda #%11000000
  jsr lcd_instruction
  lda guystatus
  jsr print_char
  lda guystatus
  eor #1
  sta guystatus
  jmp exit
jumpR:
  lda jump
  cmp #4
  beq resetj
  
  inc jump
  
  lda #%00000010
  jsr lcd_instruction

  lda #2
  jsr print_char
  jmp exit
resetj
  lda guystatus
  and #1
  sta guystatus
  stz jump
  jmp toggle


;stz counter
;lda #%11000000
;jsr lcd_instruction
;lda guystatus
;jsr print_char
;lda guystatus
;eor #1
;sta guystatus
  

; ////////////////
;     CHAR MAP
; ////////////////

  .org $fd00
guy1:
  .byte %00001110
  .byte %00010100
  .byte %00011110
  .byte %00011110
  .byte %00010010
  .byte %00010010
  .byte %00010011
  .byte %00011000
guy2:
  .byte %00001110
  .byte %00010100
  .byte %00011110
  .byte %00011110
  .byte %00010010
  .byte %00010010
  .byte %00011010
  .byte %00000011
guyjump:
  .byte %00001110
  .byte %00010100
  .byte %00011110
  .byte %00011110
  .byte %00010010
  .byte %00010010
  .byte %00010010
  .byte %00011011

  
; ////////////////
;       END
; ////////////////

  .org $fffc
  .word reset
  .word irq
