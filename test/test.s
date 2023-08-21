  .org $8000

reset:
  ldx #$ff
  txs
  
  lda #12
  sta $00
loop:
  jmp loop

  .org $fffc
  .word reset
  .word $0000
