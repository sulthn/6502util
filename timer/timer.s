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

counter = $00

  .org $8000

reset:
  ldx #$ff
  txs
  
  lda #%11111111 ; Set all pins on port A to output
  sta DDRA
  lda #%00000000 ; Set all pins on port B to input
  sta DDRB

  stz PORTA
  
  lda #%01000000
  sta ACR

  lda #%11000000
  sta IER

  lda #$0e
  sta T1CL

  lda #$27
  sta T1CH
  
  cli

loop:
  jmp loop


irq:
  lda counter
  cmp #100
  bne auh
  stz counter
  lda PORTA
  eor #1
  sta PORTA
exit:
  lda T1CL
  rti
auh:
  inc counter
  jmp exit

  .org $fffc
  .word reset
  .word irq
