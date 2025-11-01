; Define the c_sp symbol for cc65
; c_sp is the C stack pointer in the zero page
; This is needed for compatibility with newer cc65 code
; We assign it to a fixed address that should be available

.export c_sp

.zeropage
c_sp = $9A              ; Fixed zero page address for C stack pointer (near end of available ZP)
