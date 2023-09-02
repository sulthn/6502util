PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

  .org $8000

reset:
  ldx #$ff
  txs

  lda #$ff
  sta DDRA
  sta DDRB
  
  lda #$aa
  sta PORTA
loop:
  jmp loop

  .org $fffc
  .word reset
  .word $0000
