PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %01000000
RW = %00100000
RS = %00010000

old = $00
message = $01

  .org $8000

reset:
  ldx #$ff
  txs
  
  lda #%11110000 ; Set some pins on port A to input
  sta DDRA
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  
  jsr lcd_init
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001100 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction

  lda #0
  jmp display

loop:
  lda PORTA
  and #$0f
  cmp old     ; Compare with old
  bne display
  jmp loop
display:
  pha
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  pla
  jsr clear_msg
  sta old
  ldx #0
  tay
loadmsg:
  cpy #$01
  bne next1
  lda msg1,x
  jmp load
next1:
  cpy #$02
  bne default
  lda msg2,x
  jmp load
default:
  lda msg1,x
load:
  beq printing
  sta message,x
  inx
  jmp loadmsg
printing:
  stz message,x
  jsr print
  jmp loop

clear_msg:
  pha
  ldx #0
clearing:
  lda message,x
  beq clear_exit
  stz message,x
  inx
  jmp clearing
clear_exit:
  pla
  rts

print:
  pha
  phx
  ldx #0
print_msg:
  lda message,x
  beq print_exit
  jsr print_char
  inx
  jmp print_msg
print_exit:
  plx
  pla
  rts

msg1: .asciiz "Hello, World!"
msg2: .asciiz "mamah aku takut"

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

  .org $fffc
  .word reset
  .word $0000
