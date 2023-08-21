PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

ACIA_DATA   = $7000
ACIA_STATUS = $7001
ACIA_CMD    = $7002
ACIA_CTRL   = $7003

E  = %01000000
RW = %00100000
RS = %00010000

  .org $8000

reset:
  ldx #$ff
  txs
  
  lda #%00000000 ; Set all pins on port A to input
  sta DDRA
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  
  jsr lcd_init
  lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  stz ACIA_STATUS ; soft reset (value not important)

  lda #$1f        ; 8-N-1, 19200 baud
  sta ACIA_CTRL
  lda #$0b        ; No parity, no echo, no interrupts
  sta ACIA_CMD

rx_wait:
  lda ACIA_STATUS
  and #$08
  beq rx_wait

  lda ACIA_DATA
  cmp #$7f
  beq backspace
  jsr tx_data
  jsr print_char
  jmp rx_wait

tx_data:
  pha                    ; Save A.
  sta ACIA_DATA          ; Output character.
  lda #$ff               ; Initialize delay loop.
tx_delay:
  dec                    ; Decrement A.
  bne tx_delay           ; Until A gets to 0.
  pla                    ; Restore A.
  rts                    ; Return.

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
