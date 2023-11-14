locals @@
.model small
.stack 200h

; globals
g_input_buffer_max_size  = 128d
g_output_buffer_max_size = 512d
g_output_subbuffer_max_size = 128d
g_ins_byte_buffer_max_size = 8d
g_label_buffer_max_size  = 64d
g_file_name_buffer_size = ((9d*3d)+8d+3d+1d) ; 9d*x-folder*depth, 8-name, 3-extension, 1-dot

; macros
m_print_string macro string_addr ; prints string at address that ends with $
    push ax
    push dx
    lea dx, string_addr
    mov ah, 09h
    int 21h
    pop dx
    pop ax
endm
m_skip_bytes macro byte_count ; reads 'byte_count' bytes
    local sloop
    push cx
    mov cx, byte_count
    sloop:
        call get_byte
    loop sloop
    pop cx
endm
m_write_char_unsafe macro char ; outputs single character to file
    mov al, char
    call write_char
endm
m_write_char macro char ; outputs single character to file
    push ax
    m_write_char_unsafe char
    pop ax
endm
m_print_char_unsafe macro char ; outputs single character to console
    mov ah, 02h
    mov dl, char
    int 21h
endm
m_print_char macro char ; outputs single character to console
    push ax dx
    m_print_char_unsafe char
    pop dx ax
endm
m_struct_filler macro count ; data filler
    db (count*8d) dup(?)
endm

.data
; registers
reg_AX db "AX$"
reg_CX db "CX$"
reg_DX db "DX$"
reg_BX db "BX$"
reg_SP db "SP$"
reg_BP db "BP$"
reg_SI db "SI$"
reg_DI db "DI$"
reg_16 dw reg_AX, reg_CX, reg_DX, reg_BX, reg_SP, reg_BP, reg_SI, reg_DI
reg_AL db "AL$"
reg_CL db "CL$"
reg_DL db "DL$"
reg_BL db "BL$"
reg_AH db "AH$"
reg_CH db "CH$"
reg_DH db "DH$"
reg_BH db "BH$"
reg_8  dw reg_AL, reg_CL, reg_DL, reg_BL, reg_AH, reg_CH, reg_DH, reg_BH
reg_ES db "ES$"
reg_CS db "CS$"
reg_SS db "SS$"
reg_DS db "DS$"
reg_s  dw reg_ES, reg_CS, reg_SS, reg_DS
rm_000 db "BX+SI$"
rm_001 db "BX+DI$"
rm_010 db "BP+SI$"
rm_011 db "BP+DI$"
rm_100 db "SI$"
rm_101 db "DI$"
rm_110 db "BP$"
rm_111 db "BX$"
rm_mod dw rm_000, rm_001, rm_010, rm_011, rm_100, rm_101, rm_110, rm_111
; strings
str_model_point    db ".model small$"
str_stack_point    db ".stack$"
str_data_point     db ".data$"
str_code_point     db ".code$"
str_entry_point    db "start$"
str_code_end_point db "end start$"
str_imm_data_point db "@data$"
str_byte_ptr       db "byte ptr $"
str_word_ptr       db "word ptr $"
str_label          db "label$"
str_ds_start       db "ds_start $"
; mnemonics
ins_invalid db "$"
ins_mov     db "mov$"
ins_push    db "push$"
ins_pop     db "pop$"
ins_xchg    db "xchg$"
ins_out     db "out$"
ins_in      db "in$"
ins_xlat    db "xlat$"
ins_lea     db "lea$"
ins_lds     db "lds$"
ins_les     db "les$"
ins_lahf    db "lahf$"
ins_sahf    db "sahf$"
ins_pushf   db "pushf$"
ins_popf    db "popf$"
ins_add     db "add$"
ins_adc     db "adc$"
ins_inc     db "inc$"
ins_sub     db "sub$"
ins_sbb     db "sbb$"
ins_dec     db "dec$"
ins_cmp     db "cmp$"
ins_mul     db "mul$"
ins_imul    db "imul$"
ins_div     db "div$"
ins_idiv    db "idiv$"
ins_neg     db "neg$"
ins_aaa     db "aaa$"
ins_daa     db "daa$"
ins_aas     db "aas$"
ins_das     db "das$"
ins_aam     db "aam$"
ins_aad     db "aad$"
ins_cbw     db "cbw$"
ins_cwd     db "cwd$"
ins_not     db "not$"
ins_shl     db "shl$"
ins_shr     db "shr$"
ins_sar     db "sar$"
ins_rol     db "rol$"
ins_ror     db "ror$"
ins_rcl     db "rcl$"
ins_rcr     db "rcr$"
ins_and     db "and$"
ins_or      db "or$"
ins_xor     db "xor$"
ins_test    db "test$"
ins_rep     db "rep$"
ins_repnz   db "repnz$"
ins_movsb   db "movsb$"
ins_movsw   db "movsw$"
ins_cmpsb   db "cmpsb$"
ins_cmpsw   db "cmpsw$"
ins_scasb   db "scasb$"
ins_scasw   db "scasw$"
ins_lodsb   db "lodsb$"
ins_lodsw   db "lodsw$"
ins_stosb   db "stosb$"
ins_stosw   db "stosw$"
ins_call    db "call$"
ins_ret     db "ret$"
ins_jmp     db "jmp$"
ins_ja      db "ja$"
ins_jae     db "jae$"
ins_jb      db "jb$"
ins_jbe     db "jbe$"
ins_je      db "je$"
ins_jcxz    db "jcxz$"
ins_jg      db "jg$"
ins_jge     db "jge$"
ins_jl      db "jl$"
ins_jle     db "jle$"
ins_jne     db "jne$"
ins_jno     db "jno$"
ins_jnp     db "jnp$"
ins_jp      db "jp$"
ins_jo      db "jo$"
ins_jns     db "jns$"
ins_js      db "js$"
ins_loop    db "loop$"
ins_loope   db "loope$"
ins_loopne  db "loopne$"
ins_int     db "int$"
ins_iret    db "iret$"
ins_clc     db "clc$"
ins_stc     db "stc$"
ins_cmc     db "cmc$"
ins_cld     db "cld$"
ins_std     db "std$"
ins_cli     db "cli$"
ins_sti     db "sti$"
ins_hlt     db "hlt$"
ins_wait    db "wait$"
ins_lock    db "lock$"
ins_esc     db "esc$"
ins_nop     db "nop$"

ins_dup_80_83 dw ins_add, ins_or, ins_adc, ins_sbb, ins_and, ins_sub, ins_xor, ins_cmp
ins_dup_d0_d3 dw ins_rol, ins_ror, ins_rcl, ins_rcr, ins_shl, ins_shr, 0, ins_sar
ins_dup_f6_f7 dw ins_test, 0, ins_not, ins_neg, ins_mul, ins_imul, ins_div, ins_idiv
ins_dup_fe_ff dw ins_inc, ins_dec, ins_call, ins_call, ins_jmp, ins_jmp, ins_push

; lookup table for opcodes
enum_format enum {
    f_none,
    f_modregrm,
    f_dup
}
enum_types enum {
    t_none,
    t_AL, t_CL, t_DL, t_BL, t_AH, t_CH, t_DH, t_BH,
    t_AX, t_CX, t_DX, t_BX, t_SP, t_BP, t_SI, t_DI,
    t_ES, t_CS, t_SS, t_DS,
    t_reg8, t_reg16,
    t_mem8, t_mem16,
    t_imm8, t_imm16,
    t_modrm8, t_modrm16,
    t_addr8, t_addr16,
    t_label_int, t_label_int_close, t_label_ext,
    t_sreg16,
    t_one,
    t_esc,
    t_exp8
}
s_instr struc ; everything is dw to keep struct aligned to a power of 2 for faster mul
    s_mnemonic dw 0
    s_format   dw 0
    s_op_1     dw 0
    s_op_2     dw 0
ends

label ltable
s_instr<ins_add, f_modregrm, t_modrm8, t_reg8> ; add1 00h
s_instr<ins_add, f_modregrm, t_modrm16, t_reg16> ; add1 01h
s_instr<ins_add, f_modregrm, t_reg8, t_modrm8> ; add1 02h
s_instr<ins_add, f_modregrm, t_reg16, t_modrm16> ; add1 03h
s_instr<ins_add, f_none, t_AL, t_imm8> ; add3 04h
s_instr<ins_add, f_none, t_AX, t_imm16> ; add3 05h
s_instr<ins_push, f_none, t_ES, t_none> ; push3 06h
s_instr<ins_pop, f_none, t_ES, t_none> ; pop3 07h
s_instr<ins_or, f_modregrm, t_modrm8, t_reg8> ; or1 08h
s_instr<ins_or, f_modregrm, t_modrm16, t_reg16> ; or1 09h
s_instr<ins_or, f_modregrm, t_reg8, t_modrm8> ; or1 0Ah
s_instr<ins_or, f_modregrm, t_reg16, t_modrm16> ; or1 0Bh
s_instr<ins_or, f_none, t_AL, t_imm8> ; or3 0Ch
s_instr<ins_or, f_none, t_AX, t_imm16> ; or3 0Dh
s_instr<ins_push, f_none, t_CS, t_none> ; push3 0Eh
s_instr<ins_pop, f_none, t_CS, t_none> ; pop3 0Fh
s_instr<ins_adc, f_modregrm, t_modrm8, t_reg8> ; adc1 10h
s_instr<ins_adc, f_modregrm, t_modrm16, t_reg16> ; adc1 11h
s_instr<ins_adc, f_modregrm, t_reg8, t_modrm8> ; adc1 12h
s_instr<ins_adc, f_modregrm, t_reg16, t_modrm16> ; adc1 13h
s_instr<ins_adc, f_none, t_AL, t_imm8> ; adc3 14h
s_instr<ins_adc, f_none, t_AX, t_imm16> ; adc3 15h
s_instr<ins_push, f_none, t_SS, t_none> ; push3 16h
s_instr<ins_pop, f_none, t_SS, t_none> ; pop3 17h
s_instr<ins_sbb, f_modregrm, t_modrm8, t_reg8> ; sbb1 18h
s_instr<ins_sbb, f_modregrm, t_modrm16, t_reg16> ; sbb1 19h
s_instr<ins_sbb, f_modregrm, t_reg8, t_modrm8> ; sbb1 1Ah
s_instr<ins_sbb, f_modregrm, t_reg16, t_modrm16> ; sbb1 1Bh
s_instr<ins_sbb, f_none, t_AL, t_imm8> ; sbb3 1Ch
s_instr<ins_sbb, f_none, t_AX, t_imm16> ; sbb3 1Dh
s_instr<ins_push, f_none, t_DS, t_none> ; push3 1Eh
s_instr<ins_pop, f_none, t_DS, t_none> ; pop3 1Fh
s_instr<ins_and, f_modregrm, t_modrm8, t_reg8> ; and1 20h
s_instr<ins_and, f_modregrm, t_modrm16, t_reg16> ; and1 21h
s_instr<ins_and, f_modregrm, t_reg8, t_modrm8> ; and1 22h
s_instr<ins_and, f_modregrm, t_reg16, t_modrm16> ; and1 23h
s_instr<ins_and, f_none, t_AL, t_imm8> ; and3 24h
s_instr<ins_and, f_none, t_AX, t_imm16> ; and3 25h
m_struct_filler (27h-25h-1d)
s_instr<ins_daa, f_none, f_none, f_none> ; daa 27h
s_instr<ins_sub, f_modregrm, t_modrm8, t_reg8> ; sub1 28h
s_instr<ins_sub, f_modregrm, t_modrm16, t_reg16> ; sub1 29h
s_instr<ins_sub, f_modregrm, t_reg8, t_modrm8> ; sub1 2Ah
s_instr<ins_sub, f_modregrm, t_reg16, t_modrm16> ; sub1 2Bh
s_instr<ins_sub, f_none, t_AL, t_imm8> ; sub3 2Ch
s_instr<ins_sub, f_none, t_AX, t_imm16> ; sub3 2Dh
m_struct_filler (2Fh-2Dh-1d)
s_instr<ins_das, f_none, f_none, f_none> ; das 2Fh
s_instr<ins_xor, f_modregrm, t_modrm8, t_reg8> ; xor1 30h
s_instr<ins_xor, f_modregrm, t_modrm16, t_reg16> ; xor1 31h
s_instr<ins_xor, f_modregrm, t_reg8, t_modrm8> ; xor1 32h
s_instr<ins_xor, f_modregrm, t_reg16, t_modrm16> ; xor1 33h
s_instr<ins_xor, f_none, t_AL, t_imm8> ; xor3 34h
s_instr<ins_xor, f_none, t_AX, t_imm16> ; xor3 35h
m_struct_filler (37h-35h-1d)
s_instr<ins_aaa, f_none, f_none, f_none> ; aaa 37h
s_instr<ins_cmp, f_modregrm, t_modrm8, t_reg8> ; cmp1 38h
s_instr<ins_cmp, f_modregrm, t_modrm16, t_reg16> ; cmp1 39h
s_instr<ins_cmp, f_modregrm, t_reg8, t_modrm8> ; cmp1 3Ah
s_instr<ins_cmp, f_modregrm, t_reg16, t_modrm16> ; cmp1 3Bh
s_instr<ins_cmp, f_none, t_AL, t_imm8> ; cmp1 3Ch
s_instr<ins_cmp, f_none, t_AX, t_imm16> ; cmp1 3Dh
m_struct_filler (3Fh-3Dh-1d)
s_instr<ins_aas, f_none, f_none, f_none> ; aas 3Fh
s_instr<ins_inc, f_none, t_AX, t_none> ; inc2 40h
s_instr<ins_inc, f_none, t_CX, t_none> ; inc2 41h
s_instr<ins_inc, f_none, t_DX, t_none> ; inc2 42h
s_instr<ins_inc, f_none, t_BX, t_none> ; inc2 43h
s_instr<ins_inc, f_none, t_SP, t_none> ; inc2 44h
s_instr<ins_inc, f_none, t_BP, t_none> ; inc2 45h
s_instr<ins_inc, f_none, t_SI, t_none> ; inc2 46h
s_instr<ins_inc, f_none, t_DI, t_none> ; inc2 47h
s_instr<ins_dec, f_none, t_AX, t_none> ; inc2 48h
s_instr<ins_dec, f_none, t_CX, t_none> ; inc2 49h
s_instr<ins_dec, f_none, t_DX, t_none> ; inc2 4Ah
s_instr<ins_dec, f_none, t_BX, t_none> ; inc2 4Bh
s_instr<ins_dec, f_none, t_SP, t_none> ; inc2 4Ch
s_instr<ins_dec, f_none, t_BP, t_none> ; inc2 4Dh
s_instr<ins_dec, f_none, t_SI, t_none> ; inc2 4Eh
s_instr<ins_dec, f_none, t_DI, t_none> ; inc2 4Fh
s_instr<ins_push, f_none, t_AX, t_none> ; push2 50h
s_instr<ins_push, f_none, t_CX, t_none> ; push2 51h
s_instr<ins_push, f_none, t_DX, t_none> ; push2 52h
s_instr<ins_push, f_none, t_BX, t_none> ; push2 53h
s_instr<ins_push, f_none, t_SP, t_none> ; push2 54h
s_instr<ins_push, f_none, t_BP, t_none> ; push2 55h
s_instr<ins_push, f_none, t_SI, t_none> ; push2 56h
s_instr<ins_push, f_none, t_DI, t_none> ; push2 57h
s_instr<ins_pop, f_none, t_AX, t_none> ; pop2 58h
s_instr<ins_pop, f_none, t_CX, t_none> ; pop2 59h
s_instr<ins_pop, f_none, t_DX, t_none> ; pop2 5Ah
s_instr<ins_pop, f_none, t_BX, t_none> ; pop2 5Bh
s_instr<ins_pop, f_none, t_SP, t_none> ; pop2 5Ch
s_instr<ins_pop, f_none, t_BP, t_none> ; pop2 5Dh
s_instr<ins_pop, f_none, t_SI, t_none> ; pop2 5Eh
s_instr<ins_pop, f_none, t_DI, t_none> ; pop2 5Fh
m_struct_filler (70h-5Fh-1d)
s_instr<ins_jo, f_none, t_label_int_close, t_none> ; jo 70h
s_instr<ins_jno, f_none, t_label_int_close, t_none> ; jno 71h
s_instr<ins_jb, f_none, t_label_int_close, t_none> ; jb 72h
s_instr<ins_jae, f_none, t_label_int_close, t_none> ; jae 73h
s_instr<ins_je, f_none, t_label_int_close, t_none> ; je 74h
s_instr<ins_jne, f_none, t_label_int_close, t_none> ; jne 75h
s_instr<ins_jbe, f_none, t_label_int_close, t_none> ; jbe 76h
s_instr<ins_ja, f_none, t_label_int_close, t_none> ; ja 77h
s_instr<ins_js, f_none, t_label_int_close, t_none> ; js 78h
s_instr<ins_jns, f_none, t_label_int_close, t_none> ; jns 79h
s_instr<ins_jp, f_none, t_label_int_close, t_none> ; jp 7Ah
s_instr<ins_jnp, f_none, t_label_int_close, t_none> ; jnp 7Bh
s_instr<ins_jl, f_none, t_label_int_close, t_none> ; jl 7Ch
s_instr<ins_jge, f_none, t_label_int_close, t_none> ; jge 7Dh
s_instr<ins_jle, f_none, t_label_int_close, t_none> ; jle 7Eh
s_instr<ins_jg, f_none, t_label_int_close, t_none> ; jg 7Fh
s_instr<ins_dup_80_83, f_dup, t_modrm8, t_imm8> ; dup_80_83 80h
s_instr<ins_dup_80_83, f_dup, t_modrm16, t_imm16> ; dup_80_83 81h
s_instr<ins_dup_80_83, f_dup, t_modrm8, t_imm8> ; dup_80_83 82h
s_instr<ins_dup_80_83, f_dup, t_modrm16, t_exp8> ; dup_80_83 83h
s_instr<ins_test, f_modregrm, t_reg8, t_modrm8> ; test1 84h
s_instr<ins_test, f_modregrm, t_reg16, t_modrm16> ; test1 85h
s_instr<ins_xchg, f_modregrm, t_reg8, t_modrm8> ; xchg1 86h
s_instr<ins_xchg, f_modregrm, t_reg16, t_modrm16> ; xchg1 87h
s_instr<ins_mov, f_modregrm, t_modrm8, t_reg8> ; mov1 88h
s_instr<ins_mov, f_modregrm, t_modrm16, t_reg16> ; mov1 89h
s_instr<ins_mov, f_modregrm, t_reg8, t_modrm8> ; mov1 8Ah
s_instr<ins_mov, f_modregrm, t_reg16, t_modrm16> ; mov1 8Bh
s_instr<ins_mov, f_modregrm, t_modrm16, t_sreg16> ; mov6 8Ch
s_instr<ins_lea, f_modregrm, t_reg16, t_modrm16> ; lea 8Dh
s_instr<ins_mov, f_modregrm, t_sreg16, t_modrm16> ; mov6 8Eh
s_instr<ins_pop, f_modregrm, t_modrm16, t_none> ; pop1 8Fh
s_instr<ins_nop, f_none, t_none, t_none> ; nop 90h
s_instr<ins_xchg, f_none, t_AX, t_CX> ; xchg2 91h
s_instr<ins_xchg, f_none, t_AX, t_DX> ; xchg2 92h
s_instr<ins_xchg, f_none, t_AX, t_BX> ; xchg2 93h
s_instr<ins_xchg, f_none, t_AX, t_SP> ; xchg2 94h
s_instr<ins_xchg, f_none, t_AX, t_BP> ; xchg2 95h
s_instr<ins_xchg, f_none, t_AX, t_SI> ; xchg2 96h
s_instr<ins_xchg, f_none, t_AX, t_DI> ; xchg2 97h
s_instr<ins_cbw, f_none, t_none, t_none> ; cbw 98h
s_instr<ins_cwd, f_none, t_none, t_none> ; cwd 99h
s_instr<ins_call, f_none, t_label_ext, t_none> ; call3 9Ah
s_instr<ins_wait, f_none, t_none, t_none> ; wait 9Bh
s_instr<ins_pushf, f_none, t_none, t_none> ; pushf 9Ch
s_instr<ins_popf, f_none, t_none, t_none> ; popf 9Dh
s_instr<ins_sahf, f_none, t_none, t_none> ; sahf 9Eh
s_instr<ins_lahf, f_none, t_none, t_none> ; lahf 9Fh
s_instr<ins_mov, f_none, t_AL, t_addr8> ; mov4 A0h
s_instr<ins_mov, f_none, t_AX, t_addr16> ; mov4 A1h
s_instr<ins_mov, f_none, t_addr8, t_AL> ; mov5 A2h
s_instr<ins_mov, f_none, t_addr16, t_AX> ; mov5 A3h
s_instr<ins_movsb, f_none, t_none, t_none> ; movsb A4h
s_instr<ins_movsw, f_none, t_none, t_none> ; movsw A5h
s_instr<ins_cmpsb, f_none, t_none, t_none> ; cmpsb A6h
s_instr<ins_cmpsw, f_none, t_none, t_none> ; cmpsw A7h
s_instr<ins_test, f_none, t_AL, t_imm8> ; test3 A8h
s_instr<ins_test, f_none, t_AX, t_imm16> ; test3 A9h
s_instr<ins_stosb, f_none, t_none, t_none> ; stosb AAh
s_instr<ins_stosw, f_none, t_none, t_none> ; stosw ABh
s_instr<ins_lodsb, f_none, t_none, t_none> ; lodsb ACh
s_instr<ins_lodsw, f_none, t_none, t_none> ; lodsw ADh
s_instr<ins_scasb, f_none, t_none, t_none> ; scasb AEh
s_instr<ins_scasw, f_none, t_none, t_none> ; scasw AFh
s_instr<ins_mov, f_none, t_AL, t_imm8> ; mov3 B0h
s_instr<ins_mov, f_none, t_CL, t_imm8> ; mov3 B1h
s_instr<ins_mov, f_none, t_DL, t_imm8> ; mov3 B2h
s_instr<ins_mov, f_none, t_BL, t_imm8> ; mov3 B3h
s_instr<ins_mov, f_none, t_AH, t_imm8> ; mov3 B4h
s_instr<ins_mov, f_none, t_CH, t_imm8> ; mov3 B5h
s_instr<ins_mov, f_none, t_DH, t_imm8> ; mov3 B6h
s_instr<ins_mov, f_none, t_BH, t_imm8> ; mov3 B7h
s_instr<ins_mov, f_none, t_AX, t_imm16> ; mov3 B8h
s_instr<ins_mov, f_none, t_CX, t_imm16> ; mov3 B9h
s_instr<ins_mov, f_none, t_DX, t_imm16> ; mov3 BAh
s_instr<ins_mov, f_none, t_BX, t_imm16> ; mov3 BBh
s_instr<ins_mov, f_none, t_SP, t_imm16> ; mov3 BCh
s_instr<ins_mov, f_none, t_BP, t_imm16> ; mov3 BDh
s_instr<ins_mov, f_none, t_SI, t_imm16> ; mov3 BEh
s_instr<ins_mov, f_none, t_DI, t_imm16> ; mov3 BFh
m_struct_filler (0C2h-0BFh-1d)
s_instr<ins_ret, f_none, t_imm16, t_none> ; ret2 C2h
s_instr<ins_ret, f_none, t_none, t_none> ; ret1 C3h
s_instr<ins_les, f_modregrm, t_reg16, t_modrm16> ; les C4h
s_instr<ins_lds, f_modregrm, t_reg16, t_modrm16> ; lds C5h
s_instr<ins_mov, f_modregrm, t_modrm8, t_imm8> ; mov2 C6h
s_instr<ins_mov, f_modregrm, t_modrm16, t_imm16> ; mov2 C7h
m_struct_filler (0CAh-0C7h-1d)
s_instr<ins_ret, f_none, t_imm16, t_none> ; ret4 CAh
s_instr<ins_ret, f_none, t_none, t_none> ; ret3 CBh
m_struct_filler (0CDh-0CBh-1d)
s_instr<ins_int, f_none, t_imm8, t_none> ; int CDh
m_struct_filler (0CFh-0CDh-1d)
s_instr<ins_iret, f_none, t_none, t_none> ; iret CFh
s_instr<ins_dup_d0_d3, f_dup, t_modrm8, t_one> ; dup_d0_d3 D0h
s_instr<ins_dup_d0_d3, f_dup, t_modrm16, t_one> ; dup_d0_d3 D1h
s_instr<ins_dup_d0_d3, f_dup, t_modrm8, t_CL> ; dup_d0_d3 D2h
s_instr<ins_dup_d0_d3, f_dup, t_modrm16, t_CL> ; dup_d0_d3 D3h
s_instr<ins_aam, f_modregrm, t_none, t_none> ; aam D4h
s_instr<ins_aad, f_modregrm, t_none, t_none> ; aad D5h
m_struct_filler (0D7h-0D5h-1d)
s_instr<ins_xlat, f_none, t_none, t_none> ; xlat D7h
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc D8h
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc D9h
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc DAh
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc DBh
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc DCh
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc DDh
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc DEh
s_instr<ins_esc, f_modregrm, t_esc, t_modrm8> ; esc DFh
s_instr<ins_loopne, f_none, t_label_int_close, t_none> ; loopne E0h
s_instr<ins_loope, f_none, t_label_int_close, t_none> ; loope E1h
s_instr<ins_loop, f_none, t_label_int_close, t_none> ; loop E2h
s_instr<ins_jcxz, f_none, t_label_int_close, t_none> ; jcxz E3h
s_instr<ins_in, f_none, t_AL, t_imm8> ; in1 E4h
s_instr<ins_in, f_none, t_AX, t_imm8> ; in1 E5h
s_instr<ins_out, f_none, t_imm8, t_AL> ; out1 E6h
s_instr<ins_out, f_none, t_imm8, t_AX> ; out1 E7h
s_instr<ins_call, f_none, t_label_int, t_none> ; call1 E8h
s_instr<ins_jmp, f_none, t_label_int, t_none> ; jmp2 E9h
s_instr<ins_jmp, f_none, t_label_ext, t_none> ; jmp4 EAh
s_instr<ins_jmp, f_none, t_label_int_close, t_none> ; jmp1 EBh
s_instr<ins_in, f_none, t_AL, t_DX> ; in2 ECh
s_instr<ins_in, f_none, t_AX, t_DX> ; in2 EDh
s_instr<ins_out, f_none, t_DX, t_AL> ; out2 EEh
s_instr<ins_out, f_none, t_DX, t_AX> ; out2 EFh
s_instr<ins_lock, f_none, t_none, t_none> ; lock F0h
m_struct_filler (0F2h-0F0h-1d)
s_instr<ins_repnz, f_none, t_none, t_none> ; repnz F2h
s_instr<ins_rep, f_none, t_none, t_none> ; rep F3h
s_instr<ins_hlt, f_none, t_none, t_none> ; hlt F4h
s_instr<ins_cmc, f_none, t_none, t_none> ; cmc F5h
s_instr<ins_dup_f6_f7, f_dup, t_modrm8, t_none> ; dup_f6_f7 F6h    !!! for ins_test set op_2 to imm8
s_instr<ins_dup_f6_f7, f_dup, t_modrm16, t_none> ; dup_f6_f7 F7h   !!! for ins_test set op_2 to imm16
s_instr<ins_clc, f_none, t_none, t_none> ; clc F8h
s_instr<ins_stc, f_none, t_none, t_none> ; stc F9h
s_instr<ins_cli, f_none, t_none, t_none> ; cli FAh
s_instr<ins_sti, f_none, t_none, t_none> ; sti FBh
s_instr<ins_cld, f_none, t_none, t_none> ; cld FCh
s_instr<ins_std, f_none, t_none, t_none> ; std FDh
s_instr<ins_dup_fe_ff, f_dup, t_modrm8, t_none> ; dup_fe_ff FEh
s_instr<ins_dup_fe_ff, f_dup, t_modrm16, t_none> ; dup_fe_ff FFh

; files
input_file_name      db (g_file_name_buffer_size + 1) dup(?)
input_file_handle    dw 0000h
output_file_name     db "ASMOUT.ASM$", (g_output_buffer_max_size - 11d + 1) dup(?)
output_file_handle   dw 0000h
; file errors
error_file_unknown          db "ERROR: Could not open file: $"
error_file_not_found        db "ERROR: File not found: $"
error_file_no_permissions   db "ERROR: No permissions for file: $"
error_file_read             db "ERROR: Could not read from file: $"
error_file_write            db "ERROR: Could not write to file: $"
error_file_ended            db "ERROR: File ended unexpectedly: $"
error_file_not_valid        db "ERROR: File is not valid MZ EXE: $"
; args
arg_buffer db 256 dup (?)
string_help db "Syntax: disasm [options] input_file_name", 0Ah
db "Options:", 0Ah
db "-h,-?      Display this help screen.", 0Ah
db "-o [name]  Output file name. Defaults to 'ASMOUT.ASM'.", 0Ah
db "-a         Output addresses.", 0Ah
db "-c         Output code segment only.", 0Ah
db "-l         Output generated labels.", 0Ah
db "-p         Output instruction bytes.", 0Ah
db "-n         Remove NOP that is generated after JMP. Use if JMP is out of range for this reason.", 0Ah
db "-d         Output numbers in decimal.", 0Ah
string_endl_dollar db 0Dh, 0Ah, 24h
arg_addresses db 0
arg_code_only db 0
arg_labels    db 0
arg_use_dec   db 0
arg_jmp_nop   db 0
arg_ins_bytes db 0
error_opc_invalid db "ERROR: Invalid instruction.$"
error_args_no_input_file   db "ERROR: No input file passed.$"
error_args_no_output_file  db "ERROR: No output file passed.$"
error_args_file_size       db "ERROR: File name is too long: $"
error_args_after_input     db "ERROR: Args after input file name.$"
error_args_unknown         db "ERROR: Unknown argument: $"

; buffers
input_buffer          db g_input_buffer_max_size dup(?)
input_buffer_size     dw 0000h
input_current_index   dw 0000h
output_buffer         db g_output_buffer_max_size dup(?)
output_buffer_size    dw 0000h
output_subbuffer      db g_output_subbuffer_max_size dup(?)
output_subbuffer_size dw 0000h
ins_byte_buffer       db g_ins_byte_buffer_max_size dup(?)
ins_byte_buffer_size  dw 0000h
label_buffer          dw g_label_buffer_max_size dup(?)
label_buffer_size     dw 0000h

; vars
var_byte db 00h
var_word dw 0000h
var_prefix   dw 0FFFFh
var_opc_byte db 00h
var_global_index dw 0000h
var_stack_size   dw 0000h
var_cs_start     dw 0000h
var_cs_end       dw 0000h
var_ds_start     dw 0000h
var_entry_point  dw 0000h
var_ds_address   dw 0000h
var_label_curr_addr dw 0000h ; stores treshold where any addr below does not get added to label
var_no_more_labels  db 00h
var_use_subbuffer   db 00h

.code
start:
    mov ax, @data
    mov ds, ax

    call get_arguments
    call open_input_file
    call input_decode_header
    call open_output_file
    call dissasemble

    jmp exit

args_skip_spaces proc
    @@l:
        cmp si, bx
        jae @@exit

        mov al, byte ptr es:[si]
        inc si
        ; if space, continue
        cmp al, ' '
        je @@l
        dec si
    @@exit:
    ret
args_skip_spaces endp

decode_arg proc
    push ax
    @@read_next_arg:
    cmp si, bx
    jae @@unknown_option

    mov al, byte ptr es:[si]
    inc si

    ; check args
    cmp al, 'h'
    jne @@arg_help_skip1
    jmp @@arg_help
    @@arg_help_skip1:
    cmp al, '?'
    jne @@arg_help_skip2
    jmp @@arg_help
    @@arg_help_skip2:
    cmp al, 'o'
    jne @@arg_output_file_skip
    jmp @@arg_output_file
    @@arg_output_file_skip:
    cmp al, 'a'
    jne @@arg_output_addr_skip
    jmp @@arg_output_addr
    @@arg_output_addr_skip:
    cmp al, 'c'
    jne @@arg_code_only_skip
    jmp @@arg_code_only
    @@arg_code_only_skip:
    cmp al, 'l'
    jne @@arg_labels_skip
    jmp @@arg_labels
    @@arg_labels_skip:
    cmp al, 'p'
    jne @@arg_ins_bytes_skip
    jmp @@arg_ins_bytes
    @@arg_ins_bytes_skip:
    cmp al, 'n'
    jne @@arg_jmp_nop_skip
    jmp @@arg_jmp_nop
    @@arg_jmp_nop_skip:
    cmp al, 'd'
    jne @@arg_use_dec_skip
    jmp @@arg_use_dec
    @@arg_use_dec_skip:

    @@unknown_option:
    m_print_string error_args_unknown
    m_print_char_unsafe al
    m_print_string string_endl_dollar
    m_print_string string_help
    jmp exit

    @@arg_help:
        m_print_string string_help
        jmp exit
    @@arg_output_file:
        lea di, output_file_name
        call arg_read_filename
        cmp cx, 1
        jae @@exit
        m_print_string error_args_no_output_file
        m_print_string string_endl_dollar
        jmp exit
    @@arg_output_addr:
        mov [arg_addresses], 1
        jmp @@check_next_arg
    @@arg_code_only:
        mov [arg_code_only], 1
        jmp @@check_next_arg
    @@arg_labels:
        mov [arg_labels], 1
        jmp @@check_next_arg
    @@arg_ins_bytes:
        mov [arg_ins_bytes], 1
        jmp @@check_next_arg
    @@arg_jmp_nop:
        mov [arg_jmp_nop], 1
        jmp @@check_next_arg
    @@arg_use_dec:
        mov [arg_use_dec], 1
        jmp @@check_next_arg
        
    @@check_next_arg: ; allow combining args to a single expression
        cmp si, bx
        jae @@exit
        mov al, byte ptr es:[si]
        cmp al, ' '
        je @@exit
        jmp @@read_next_arg

    @@exit:
    pop ax
    ret
decode_arg endp

arg_read_filename proc ; INPUT: si=buffer,bx=max_buffer,di=filename
    push ax
    call args_skip_spaces
    xor cx, cx
    @@l:
        cmp si, bx
        jae @@exit

        mov al, byte ptr es:[si]
        inc si

        ; if space, exit
        cmp al, ' '
        je @@exit
        
        ; check if filename is too big
        cmp cx, g_file_name_buffer_size
        jb @@filesize_good
        m_print_string error_args_file_size
        mov dx, di
        mov ah, 09h
        int 21h
        m_print_string string_endl_dollar
        jmp exit
        @@filesize_good:

        ; input filename
        push di
        add di, cx
        mov byte ptr ds:[di], al
        pop di
        inc cx
        jmp @@l
    @@exit:
    add di, cx
    mov byte ptr ds:[di], '$'
    pop ax
    ret
arg_read_filename endp

get_arguments proc
    xor bx, bx
    mov bl, byte ptr es:[80h] ; get arg len
    mov si, 81h
    cld
    xor dx, dx ; stores how many arguments were extracted

    ; if no arguments are provided, print help screen
    cmp bl, 0
    je @@exit

    xor ah, ah ; if ah == 1, input filename was read already, throw error
    add bx, 81h ; loop until SI reaches BX
    ; loop through args
    @@l:
        call args_skip_spaces
        cmp si, bx
        jae @@exit

        mov al, byte ptr es:[si]
        inc si
        
        ; if -, option
        cmp al, '-'
        jne @@not_an_option
        call decode_arg
        inc dx
        jmp @@l

        @@not_an_option:
        cmp ah, 0
        je @@read_input_file
        ; throw error
        m_print_string error_args_after_input
        m_print_string string_endl_dollar
        jmp exit
        @@read_input_file:
        lea di, input_file_name
        dec si
        call arg_read_filename
        inc dx
        mov ah, 1
        cmp cx, 1
        jae @@l
        m_print_string error_args_no_input_file
        m_print_string string_endl_dollar
        jmp exit
    @@exit:
    ; if no arguments are provided, print help screen
    cmp dx, 0
    je @@args_empty
    cmp ah, 0
    je @@args_empty
    jmp @@args_not_empty
    @@args_empty:
    m_print_string error_args_no_input_file
    m_print_string string_endl_dollar
    m_print_string string_help
    jmp exit
    @@args_not_empty:

    ret
get_arguments endp

open_input_file proc
    push ax dx
    ; open file
    mov ah, 3Dh ; open file by filename
    mov al, 00h ; read
    lea dx, input_file_name
    int 21h
    jnc @@no_errors

    ; file not found
    cmp ax, 02h
    je @@file_not_found
    ; no permissions
    cmp ax, 05h
    je @@file_no_permissions
    ; unknown
    m_print_string error_file_unknown
    m_print_string input_file_name
    m_print_string string_endl_dollar
    jmp exit
    
    @@file_not_found:
    m_print_string error_file_not_found
    m_print_string input_file_name
    m_print_string string_endl_dollar
    jmp exit

    @@file_no_permissions:
    m_print_string error_file_no_permissions
    m_print_string input_file_name
    m_print_string string_endl_dollar
    jmp exit

    ; no errors, save handle and return
    @@no_errors:
    mov [input_file_handle], ax
    pop dx ax
    ret
open_input_file endp

open_output_file proc
    push ax dx cx
    mov ah, 3Ch ; create file
    lea dx, output_file_name
    xor cx, cx
    int 21h
    jnc @@no_errors

    ; no permissions
    cmp ax, 05h
    je @@file_no_permissions
    ; unknown
    m_print_string error_file_unknown
    m_print_string output_file_name
    m_print_string string_endl_dollar
    jmp exit
    
    @@file_no_permissions:
    m_print_string error_file_no_permissions
    m_print_string output_file_name
    m_print_string string_endl_dollar
    jmp exit

    ; no errors, save handle and return
    @@no_errors:
    mov [output_file_handle], ax
    pop cx dx ax
    ret
open_output_file endp

close_file proc ; INPUT: BX=filehandle
    push ax
    mov ax, 3e00h
    int 21h
    pop ax
    ret
close_file endp

get_input_buffer proc
    push ax bx cx dx
    mov ah, 3Fh ; read from file with handle
    mov bx, [input_file_handle]
    mov cx, g_input_buffer_max_size
    lea dx, input_buffer
    int 21h
    jnc @@buffer_read

    ; error, exit
    m_print_string error_file_read
    m_print_string input_file_name
    m_print_string string_endl_dollar
    jmp exit

    @@buffer_read:
    mov [input_buffer_size], ax
    mov word ptr [input_current_index], 0d

    pop dx cx bx ax
    ret
get_input_buffer endp

get_byte proc
    push ax si
    ; check for out of bounds
    @@check_bounds:
    mov ax, [input_current_index]
    cmp ax, [input_buffer_size]
    jb @@in_bounds
    ; request another buffer
    call get_input_buffer
    cmp word ptr [input_buffer_size], 0
    je @@exit
    jmp @@check_bounds

    @@in_bounds:
    ; read byte and increment counters
    mov si, word ptr [input_current_index]
    mov al, [input_buffer + si]
    mov [var_byte], al
    inc word ptr [input_current_index]
    inc word ptr [var_global_index]
    ; move byte to ins bytes
    cmp word ptr [ins_byte_buffer_size], g_ins_byte_buffer_max_size
    jae @@exit
    mov si, word ptr [ins_byte_buffer_size]
    mov byte ptr [ins_byte_buffer + si], al
    inc word ptr [ins_byte_buffer_size]
    @@exit:
    pop si ax
    ret
get_byte endp

get_word proc
    push ax dx
    mov dl, [var_byte]

    ; get word byte by byte to avoid reading out of buffer bounds
    call get_byte
    mov al, [var_byte]
    call get_byte
    mov ah, [var_byte]
    mov [var_word], ax

    mov [var_byte], dl
    pop dx ax
    ret
get_word endp

move_input_file_cursor proc ; INPUT: DX=offset
    push ax bx cx
    mov ax, 4200h
    mov bx, [input_file_handle]
    xor cx, cx
    int 21h
    jnc @@no_cursor_error
    m_print_string error_file_ended
    m_print_string input_file_name
    m_print_string string_endl_dollar
    jmp exit
    @@no_cursor_error:
    pop cx bx ax
    ret
move_input_file_cursor endp

input_decode_header proc
    push ax bx cx dx
    ; check if file is MZ(ZM) EXE
    call get_word
    cmp word ptr [var_word], 4D5Ah
    je @@valid_exe
    cmp word ptr [var_word], 5A4Dh
    je @@valid_exe
    ; not valid file
    m_print_string error_file_not_valid
    m_print_string input_file_name
    m_print_string string_endl_dollar
    jmp exit

    ; get required header info
    @@valid_exe:

    ; code segment end
    call get_word ; e_cblp
    mov cx, [var_word]
    call get_word ; e_cp
    mov ax, [var_word]
    cmp cx, 0
    je @@cs_end_other
    dec ax
    shl ax, 9d
    add ax, cx
    mov [var_cs_end], ax    
    jmp @@cs_end_finish
    @@cs_end_other:
    shl ax, 9d
    mov [var_cs_end], ax
    @@cs_end_finish:

    ; code segment start
    m_skip_bytes 2d
    call get_word ; e_cparhdr
    mov ax, [var_word]
    shl ax, 4 ; ax * 16
    mov [var_cs_start], ax

    ; stack size
    m_skip_bytes 6d
    call get_word ; e_sp
    mov ax, [var_word]
    mov [var_stack_size], ax

    ; entry point
    m_skip_bytes 2d
    call get_word ; e_ip
    mov bx, [var_word]
    call get_word ; e_cs
    mov ax, [var_word]
    xor dx, dx
    mov cx, 16d
    imul cx
    add ax, bx
    add ax, word ptr [var_cs_start]
    mov [var_entry_point], ax

    ; DS start address location ('@data' location)
    call get_word ; e_lfarlc
    mov ax, [var_word]
    ; read buffer at specific location
    mov dx, ax
    call move_input_file_cursor
    mov word ptr [input_current_index], 0d ; relocation table offset
    call get_input_buffer
    call get_word
    mov cx, [var_word] ; offset
    call get_word
    mov ax, [var_word] ; segment
    shl ax, 4 ; ax * 16
    add ax, cx
    add ax, word ptr [var_cs_start]
    mov [var_ds_address], ax

    ; DS start
    ; read buffer at specific location
    mov dx, ax
    call move_input_file_cursor
    mov word ptr [input_current_index], 0d ; DS address
    call get_input_buffer
    call get_word
    mov ax, [var_word]
    shl ax, 4 ; ax * 16
    add ax, [var_cs_start]
    mov [var_ds_start], ax

    ; if data segment is present, cs_end is at ds_start
    cmp [var_cs_end], ax
    jb @@no_data
    mov [var_cs_end], ax
    @@no_data:
    pop dx cx bx ax
    ret
input_decode_header endp

file_print proc
    push bx ax cx dx
    mov bx, [output_file_handle]
    mov cx, [output_buffer_size]
    lea dx, output_buffer
    mov ah, 40h
    int 21h
    jnc @@no_error
    ; no permissions
    cmp ax, 05h
    je @@file_no_permissions
    ; unknown
    m_print_string error_file_write
    m_print_string output_file_name
    m_print_string string_endl_dollar
    jmp exit
    
    @@file_no_permissions:
    m_print_string error_file_no_permissions
    m_print_string output_file_name
    m_print_string string_endl_dollar
    jmp exit

    @@no_error:
    mov word ptr [output_buffer_size], 0d
    pop dx cx ax bx
    ret
file_print endp

dissasemble proc
    ; file start
    cmp [arg_code_only], 0
    jne @@skip_file_start
    ; print '.model small'
    lea si, str_model_point
    call write_dollar_string
    m_write_char_unsafe 10d ; new-line
    ; print '.stack'
    lea si, str_stack_point
    call write_dollar_string
    m_write_char_unsafe ' '
    mov ax, [var_stack_size]
    call write_number_word
    m_write_char_unsafe 10d ; new-line
    @@skip_file_start:

    ; data segment
    cmp [arg_code_only], 0
    je @@skip_data_sg_jump
    jmp @@skip_data_sg
    @@skip_data_sg_jump:
    ; move file cursor to data segment
    mov dx, [var_ds_start]
    mov word ptr [var_global_index], dx
    call move_input_file_cursor
    call get_input_buffer
    ; print '.data'
    lea si, str_data_point
    call write_dollar_string
    m_write_char_unsafe 10d ; new-line
    ; print str_ds_start
    lea si, str_label
    call write_dollar_string
    m_write_char_unsafe ' '
    lea si, str_ds_start
    call write_dollar_string
    m_write_char_unsafe 10d ; new-line

    ; loop while buffer_size == max_buffer_size || buffer_index < buffer_size
    xor cx, cx
    @@datawhileloop:
        cmp [input_buffer_size], g_input_buffer_max_size
        je @@valid_loop
        mov ax, [input_buffer_size]
        cmp [input_current_index], ax
        jb @@valid_loop
        jmp @@datawhileloop_end
        @@valid_loop:

        call get_byte
        cmp [input_buffer_size], 0
        je @@datawhileloop_end

        ; if first iteration, print extra stuff
        cmp cx, 0
        jne @@not_first_iter

        ; print current addr
        cmp [arg_addresses], 0
        je @@skip_data_addr_write
        mov ax, [var_global_index]
        call write_number_word
        m_write_char_unsafe ':'
        m_write_char_unsafe ' '
        @@skip_data_addr_write:

        m_write_char_unsafe 'd'
        m_write_char_unsafe 'b'
        m_write_char_unsafe ' '
        mov al, [var_byte]
        call write_number_byte
        inc cx
        jmp @@datawhileloop

        @@not_first_iter:
        m_write_char_unsafe ','
        mov al, [var_byte]
        call write_number_byte
        inc cx
        cmp cx, 10d
        jb @@dont_create_nl
        xor cx, cx
        m_write_char_unsafe 10d
        @@dont_create_nl:
        call file_print
        jmp @@datawhileloop
    @@datawhileloop_end:
    m_write_char_unsafe 10d ; new-line
    @@skip_data_sg:
    ; code segment
    ; move file cursor to code segment
    mov dx, [var_cs_start]
    mov word ptr [var_global_index], dx
    call move_input_file_cursor
    call get_input_buffer
    ; print '.code'
    cmp [arg_code_only], 0
    jne @@skip_code_start
    lea si, str_code_point
    call write_dollar_string
    m_write_char_unsafe 10d ; new-line
    @@skip_code_start:

    ; loop while global index < code end
    mov [ins_byte_buffer_size], 0
    mov di, [var_cs_end]
    @@whileloop:
        cmp word ptr [var_global_index], di
        jb @@no_break
        jmp @@break
        @@no_break:

        mov [var_use_subbuffer], 0
        ; check for entry point
        cmp [arg_code_only], 0
        jne @@not_entry_point
        mov ax, [var_global_index]
        cmp ax, [var_entry_point]
        jne @@not_entry_point
        lea si, str_entry_point
        call write_dollar_string
        m_write_char_unsafe ':'
        m_write_char_unsafe 10d ; new-line
        @@not_entry_point:

        ; labels
        cmp [arg_labels], 0
        je @@skip_label
        cmp [var_no_more_labels], 1
        je @@skip_label
        call check_for_label
        @@skip_label:

        ; print current addr if no prefix
        cmp [arg_addresses], 0
        je @@skip_addr_write
        cmp [var_prefix], 0FFFFh
        jne @@skip_addr_write
        mov ax, [var_global_index]
        call write_number_word
        m_write_char_unsafe ':'
        m_write_char_unsafe ' '
        @@skip_addr_write:

        mov [var_use_subbuffer], 1
        call get_byte

        ; remove NOP after close JMP
        cmp byte ptr [arg_jmp_nop], 0
        je @@skip_jmp_nop
        cmp byte ptr [var_opc_byte], 0EBh ; opc_byte from previous iteration
        jne @@skip_jmp_nop
        cmp byte ptr [var_byte], 90h
        jne @@skip_jmp_nop
        mov byte ptr [var_opc_byte], 0 ; reset so this does not remove any more NOPs
        jmp @@whileloop
        @@skip_jmp_nop:

        ; check for prefix
        xor ax, ax
        mov al, [var_byte]
        mov [var_opc_byte], al ; save it for ins_esc
        and al, 11100111b
        cmp al, 00100110b
        jne @@not_a_prefix
        mov al, [var_byte]
        shr al, 2 ; shift by 3, but then shift left to align to word
        and al, 110b
        mov [var_prefix], ax

        jmp @@whileloop
        @@not_a_prefix:

        ; check if valid opcode
        xor bx, bx
        mov bl, [var_byte]
        shl bx, 3 ; multiply by struct size to access correct instr in lookup table
        add bx, offset ltable
        cmp [bx].s_mnemonic, offset ins_invalid
        ja @@opcode_valid
        m_print_string error_opc_invalid
        jmp exit

        @@opcode_valid:
        ; print tab
        m_write_char_unsafe ' '
        m_write_char_unsafe ' '
        m_write_char_unsafe ' '
        m_write_char_unsafe ' '

        ; decode
        cmp [bx].s_format, f_none
        je @@format_none
        cmp [bx].s_format, f_modregrm
        je @@format_modregrm
        cmp [bx].s_format, f_dup
        je @@format_modregrm
        ; unknown format, exit
        m_print_string error_opc_invalid
        jmp exit

        @@format_none:
            ; print the mnemonic
            mov si, [bx].s_mnemonic      
            call write_dollar_string
            cmp byte ptr [bx].s_op_1, t_none
            je @@continue_out_of_range
            m_write_char_unsafe ' '
            
            ; print op1
            mov ah, byte ptr [bx].s_op_1
            call decode_f_none
            cmp byte ptr [bx].s_op_2, t_none
            je @@continue_out_of_range
            m_write_char ','
            m_write_char ' '
            ; print op2
            mov ah, byte ptr [bx].s_op_2
            call decode_f_none
            jmp @@continue_out_of_range

        @@format_modregrm:
            call get_byte

            mov cl, byte ptr [bx].s_op_1 ; save op_1 to CL
            mov ch, byte ptr [bx].s_op_2 ; save op_2 to CH

            ; print the mnemonic
            mov si, [bx].s_mnemonic
            cmp [bx].s_format, f_dup
            jne @@not_duplicate_format
            xor ax, ax
            mov al, [var_byte] ; addr byte
            shr al, 2
            and al, 1110b
            add si, ax
            mov si, [si]

            ; make adjustments to edge-case opcodes
            call adjust_dup_opc_edge_cases

            ; check if valid opcode
            cmp si, offset ins_invalid
            ja @@not_duplicate_format
            m_print_string error_opc_invalid
            jmp exit

            @@continue_out_of_range: ; fix for out of range
            jmp @@continue

            @@not_duplicate_format:      
            call write_dollar_string
            cmp cl, t_none ; op_1
            je @@continue
            m_write_char_unsafe ' '

            ; print op1
            mov al, [var_byte] ; addr byte
            mov ah, cl
            call decode_f_modregrm
            cmp byte ptr ch, t_none ;op_2
            je @@continue
            m_write_char ','
            m_write_char ' '
            ; print op2
            mov ah, ch
            call decode_f_modregrm

        @@continue:
            m_write_char 10d ; new line
            mov [var_use_subbuffer], 0
            cmp [arg_ins_bytes], 1
            jne @@no_ins_bytes
            call write_ins_bytes
            @@no_ins_bytes:
            call write_subbuffer
            mov [var_prefix], 0FFFFh ; clear prefix
        jmp @@whileloop

    @@break:

    ; print 'end start'
    cmp [arg_code_only], 0
    jne @@skip_end_start
    lea si, str_code_end_point
    call write_dollar_string
    @@skip_end_start:
    call file_print
    ret
dissasemble endp

check_for_label proc
    cmp [label_buffer_size], 0
    jne @@skip_extract
    call extract_labels
    @@skip_extract:

    push bx ax
    xor bx, bx
    @@l:
        cmp bx, [label_buffer_size]
        jae @@exit

        ; check if label exists here
        shl bx, 1
        mov ax, [label_buffer + bx]
        shr bx, 1
        inc bx
        cmp ax, [var_global_index]
        jne @@l

        ; print label
        push si
        lea si, str_label
        call write_dollar_string
        call write_number_word
        m_write_char_unsafe ':'
        m_write_char_unsafe 10d ; new-line
        ; remove label to speed up other searches
        dec [label_buffer_size]
        mov si, [label_buffer_size]
        shl si, 1
        mov ax, [label_buffer + si]
        dec bx
        shl bx, 1
        mov [label_buffer + bx], ax
        pop si

    @@exit:
    pop ax bx
    ret
check_for_label endp

extract_labels proc ; at least doubles dissasemble time, because needs to find jumps by dissasembling all over again.
    push ax bx cx dx di si
    push [ins_byte_buffer_size]
    push [var_global_index]

    mov [label_buffer_size], 0
    mov dx, [var_global_index]
    mov [var_label_curr_addr], dx
    mov dx, [var_cs_start]
    mov [var_global_index], dx
    call move_input_file_cursor
    call get_input_buffer

    ; loop while global index < code end
    mov di, [var_cs_end]
    @@whileloop:
        cmp word ptr [var_global_index], di
        jb @@skip_exit1
        jmp @@exit
        @@skip_exit1:
 
        call get_byte
        
        ; check for prefix
        xor ax, ax
        mov al, [var_byte]
        and al, 11100111b
        cmp al, 00100110b
        jne @@not_a_prefix
        jmp @@whileloop
        @@not_a_prefix:

        ; check if valid opcode
        xor bx, bx
        mov bl, [var_byte]
        shl bx, 3 ; multiply by struct size to access correct instr in lookup table
        add bx, offset ltable
        cmp [bx].s_mnemonic, offset ins_invalid
        ja @@opcode_valid
        m_print_string error_opc_invalid
        jmp exit
        @@opcode_valid:

        ; decode
        cmp [bx].s_format, f_none
        je @@format_none
        cmp [bx].s_format, f_modregrm
        je @@format_modregrm
        cmp [bx].s_format, f_dup
        je @@format_modregrm
        ; unknown format, exit
        m_print_string error_opc_invalid
        jmp exit

       @@format_none:
            ; op1
            mov ah, byte ptr [bx].s_op_1
            call labelextr_decode_f_none
            cmp byte ptr [bx].s_op_2, t_none
            jne @@skip_wl_jump1
            jmp @@whileloop
            @@skip_wl_jump1:
            ; op2
            mov ah, byte ptr [bx].s_op_2
            call labelextr_decode_f_none
            jmp @@whileloop

        @@format_modregrm:
            call get_byte

            mov cl, byte ptr [bx].s_op_1 ; save op_1 to CL
            mov ch, byte ptr [bx].s_op_2 ; save op_2 to CH

            ; get the mnemonic
            mov si, [bx].s_mnemonic
            cmp [bx].s_format, f_dup
            jne @@not_duplicate_format
            xor ax, ax
            mov al, [var_byte] ; addr byte
            shr al, 2
            and al, 1110b
            add si, ax
            mov si, [si]

            ; make adjustments to edge-case opcodes
            call adjust_dup_opc_edge_cases

            ; check if valid opcode
            cmp si, offset ins_invalid
            ja @@not_duplicate_format
            m_print_string error_opc_invalid
            jmp exit

            @@not_duplicate_format:      
            cmp cl, t_none ; op_1
            je @@continue

            ; op1
            mov al, [var_byte] ; addr byte
            mov ah, cl
            call labelextr_decode_f_modregrm
            cmp byte ptr ch, t_none ;op_2
            je @@continue
            ; op2
            mov ah, ch
            call labelextr_decode_f_modregrm
        @@continue:
            jmp @@whileloop

    @@exit:
    cmp [label_buffer_size], 0
    jne @@skip_flag
    mov [var_no_more_labels], 1
    @@skip_flag:
    pop [var_global_index]
    pop [ins_byte_buffer_size]
    mov dx, [var_global_index]
    call move_input_file_cursor
    call get_input_buffer
    pop si di dx cx bx ax
    ret
extract_labels endp

adjust_dup_opc_edge_cases proc ; INPUT: CL=op1, CH=op2, SI=instr
    push ax
    ; ins_test
    cmp si, offset ins_test
    jne @@exit
        cmp cl, t_modrm8
        jne @@test_modrm16
            mov ch, t_imm8
            jmp @@exit
        @@test_modrm16:
            mov ch, t_imm16
            jmp @@exit

    @@exit:
    pop ax
    ret
adjust_dup_opc_edge_cases endp

get_prefix proc
    push bx si
    cmp [var_prefix], 0FFFFh
    je @@exit
    lea bx, reg_s
    add bx, [var_prefix]
    mov si, [bx]
    call write_dollar_string
    m_write_char ':'
    @@exit:
    pop si bx
    ret
get_prefix endp

print_dummy_addr_label proc ; prints str_ds_start to compile as address instead of constant
    cmp [var_prefix], 0FFFFh
    jne @@exit
    push ax si
    lea si, str_ds_start
    call write_dollar_string
    m_write_char_unsafe '+'
    m_write_char_unsafe ' '
    pop si ax
    @@exit:
    ret
print_dummy_addr_label endp

decode_ins_esc proc ; INPUT: al=addr_byte
    mov ah, [var_opc_byte]
    and ah, 111b ; xxx
    shl ah, 3
    shr al, 3
    and al, 111b ; yyy
    or al, ah ; 00xxxyyy
    call write_number_byte
    ret
decode_ins_esc endp

decode_labels proc ; INPUT: ah=instr_operand. OUTPUT: dl=0 if nothing found, else dl=1
    push si
    cmp ah, t_label_int
    je @@type_label_int
    cmp ah, t_label_ext
    je @@type_label_ext
    cmp ah, t_label_int_close
    je @@type_label_int_close
    jmp @@exit_none

    @@type_label_int:
        call get_word
        mov ax, [var_word]
        add ax, [var_global_index]
        cmp [arg_labels], 0
        je @@no_label1
        ; if label is start, print differently
        cmp ax, [var_entry_point]
        jne @@print_label1
        lea si, str_entry_point
        call write_dollar_string
        jmp @@exit
        @@print_label1:
        lea si, str_label
        call write_dollar_string
        @@no_label1:
        call write_number_word
        jmp @@exit
    @@type_label_ext:
        call get_word
        push cx
        mov cx, [var_word]
        call get_word
        mov ax, [var_word]
        call write_number_word
        m_write_char_unsafe ':'
        mov ax, cx
        call write_number_word
        pop cx
        jmp @@exit
    @@type_label_int_close:
        call get_byte
        mov al, byte ptr [var_byte]
        cbw
        add ax, [var_global_index]
        cmp [arg_labels], 0
        je @@no_label2
        ; if label is start, print differently
        cmp ax, [var_entry_point]
        jne @@print_label2
        lea si, str_entry_point
        call write_dollar_string
        jmp @@exit
        @@print_label2:
        lea si, str_label
        call write_dollar_string
        @@no_label2:
        call write_number_word
        jmp @@exit        

    @@exit_none:
    xor dl, dl
    pop si
    ret
    @@exit:
    mov dl, 1
    pop si
    ret
decode_labels endp

decode_repeating_types proc ; INPUT: ah=instr_operand. OUTPUT: dl=0 if nothing found, else dl=1
    call decode_labels
    cmp dl, 1
    je @@type_none ; @@exit is out of range

    cmp ah, t_none
    je @@type_none
    cmp ah, t_one
    je @@type_one
    cmp ah, t_imm8
    je @@type_imm8
    cmp ah, t_imm16
    je @@type_imm16
    ; range checks
    cmp ah, t_AL
    jb @@not_al
    cmp ah, t_BH
    ja @@not_al
    jmp @@type_AL
    @@not_al:
    cmp ah, t_AX
    jb @@not_ax
    cmp ah, t_DI
    ja @@not_ax
    jmp @@type_AX
    @@not_ax:
    cmp ah, t_ES
    jb @@not_es
    cmp ah, t_DS
    ja @@not_es
    jmp @@type_ES
    @@not_es:
    xor dl, dl
    ret

    @@type_none:
        jmp @@exit
    @@type_one:
        m_write_char_unsafe '1'
        jmp @@exit
    @@type_imm8:
        call get_byte
        mov al, byte ptr [var_byte]
        mov dx, 1
        call check_data_addr
        cmp dl, 0
        jne @@exit
        call write_number_byte
        jmp @@exit
    @@type_imm16:
        call get_word
        mov ax, [var_word]
        mov dx, 2
        call check_data_addr
        cmp dl, 0
        jne @@exit
        call write_number_word
        jmp @@exit
   @@type_AL:
        sub ah, t_AL
        shl ah, 1
        lea bx, reg_8
        add bl, ah
        mov si, [bx]
        call write_dollar_string
        jmp @@exit
    @@type_AX:
        sub ah, t_AX
        shl ah, 1
        lea bx, reg_16
        add bl, ah
        mov si, [bx]
        call write_dollar_string
        jmp @@exit
    @@type_ES:
        sub ah, t_ES
        shl ah, 1
        lea bx, reg_s
        add bl, ah
        mov si, [bx]
        call write_dollar_string
        jmp @@exit

    @@exit:
    mov dl, 1
    ret
decode_repeating_types endp

decode_f_none proc ; INPUT: ah=instr_operand
    push ax si bx dx

    call decode_repeating_types
    cmp dl, 1
    je @@exit

    cmp ah, t_addr8
    je @@type_addr8
    cmp ah, t_addr16
    je @@type_addr16
    ; unknown, exit
    m_print_string error_opc_invalid
    jmp exit

    @@type_addr8:
        lea si, str_byte_ptr
        call write_dollar_string
        call get_prefix
        m_write_char_unsafe '['
        call print_dummy_addr_label
        call get_word
        mov ax, [var_word]
        call write_number_word
        m_write_char_unsafe ']'
        jmp @@exit
    @@type_addr16:
        lea si, str_word_ptr
        call write_dollar_string
        call get_prefix
        m_write_char_unsafe '['
        call print_dummy_addr_label
        call get_word
        mov ax, [var_word]
        call write_number_word
        m_write_char_unsafe ']'
        jmp @@exit

    @@exit:
    pop dx bx si ax
    ret
decode_f_none endp

decode_f_modregrm proc ; INPUT: ah=instr_operand, al=addr_byte
    push ax si bx dx

    call decode_repeating_types
    cmp dl, 1
    je @@exit_out_of_range

    cmp ah, t_esc
    jne @@not_type_esc
    call decode_ins_esc
    jmp @@exit_out_of_range
    @@not_type_esc:

    cmp ah, t_reg8
    je @@type_reg8
    cmp ah, t_reg16
    je @@type_reg16
    cmp ah, t_modrm8
    je @@type_modrm8
    cmp ah, t_modrm16
    je @@type_modrm16
    cmp ah, t_sreg16
    je @@type_sreg16
    cmp ah, t_exp8
    jne @@not_type_exp8
    jmp @@type_exp8
    @@not_type_exp8:
    ; unknown, exit
    call file_print
    m_print_string error_opc_invalid
    jmp exit

    @@exit_out_of_range:
    jmp @@exit

    @@type_reg8:
        shr al, 3
        and al, 111b
        shl al, 1
        lea bx, reg_8
        add bl, al
        mov si, [bx] 
        call write_dollar_string
        jmp @@exit
    @@type_reg16:
        shr al, 3
        and al, 111b
        shl al, 1
        lea bx, reg_16
        add bl, al
        mov si, [bx] 
        call write_dollar_string
        jmp @@exit
    @@type_modrm8:
        mov ah, al
        and ah, 111b ; rm
        shr al, 6 ; mod
        lea bx, reg_8
        call decode_modrm
        jmp @@exit
    @@type_modrm16:
        mov ah, al
        and ah, 111b ; rm
        shr al, 6 ; mod
        lea bx, reg_16
        call decode_modrm
        jmp @@exit
    @@type_sreg16:
        shr al, 3
        and al, 11b
        shl al, 1
        lea bx, reg_s
        add bl, al
        mov si, [bx] 
        call write_dollar_string
        jmp @@exit
    @@type_exp8:
        call get_byte
        mov al, byte ptr [var_byte]
        cbw
        call write_number_word

    @@exit:
    pop dx bx si ax
    ret
decode_f_modregrm endp

decode_modrm proc ; INPUT: bx=reg_array, ah=rm, al=mod
    push ax bx si

    cmp al, 11b
    je @@get_from_regarr

        cmp bx, offset reg_8
        je @@size_byte
        ; else size_word
            lea si, str_word_ptr
            call write_dollar_string
            jmp @@skip_size_byte
        @@size_byte:
            lea si, str_byte_ptr
            call write_dollar_string
        @@skip_size_byte:
        call get_prefix

    cmp al, 00b
    je @@get_from_00
    ; else
        push ax ; keep for mod check later
        m_write_char_unsafe '['
        lea bx, rm_mod
        shl ah, 1
        add bl, ah
        mov si, [bx]
        call write_dollar_string
        pop ax
        cmp al, 10b
        je @@get_word
        ; else get_byte
            call get_byte
            mov al, [var_byte]
            cbw
            cmp ah, 0
            je @@no_minus
            not al
            inc al
            mov ah, 2
            @@no_minus:
            add ah, 43d
            m_write_char ah
            call write_number_byte
            jmp @@finish
        @@get_word:
            call get_word
            mov ax, [var_word]
            m_write_char '+'
            call write_number_word
        @@finish:
        m_write_char_unsafe ']'
        jmp @@exit

    @@get_from_regarr:
        shl ah, 1
        add bl, ah
        mov si, [bx]
        call write_dollar_string
        jmp @@exit

    @@get_from_00:
        cmp ah, 110b
        je @@direct_addr
            m_write_char_unsafe '['
            lea bx, rm_mod
            shl ah, 1
            add bl, ah
            mov si, [bx]
            call write_dollar_string
            m_write_char_unsafe ']'
            jmp @@exit
        @@direct_addr:
            m_write_char_unsafe '['
            call print_dummy_addr_label
            call get_word
            mov ax, [var_word]
            call write_number_word
            m_write_char_unsafe ']'
            jmp @@exit

    @@exit:
    pop si bx ax
    ret
decode_modrm endp

labelextr_add_label proc ; INPUT: ax=addr
    push cx dx bx si

    ; if bellow threshold skip
    cmp ax, [var_label_curr_addr]
    jb @@exit

    ; if entry point, skip
    cmp ax, [var_entry_point]
    je @@exit

    ; if already exists, exit
    xor si, si
    @@l1:
        cmp si, [label_buffer_size]
        jae @@break1
        shl si, 1
        cmp ax, [label_buffer + si]
        je @@exit
        shr si, 1
        inc si
        jmp @@l1
    @@break1:

    ; if theres space, add it
    cmp [label_buffer_size], g_label_buffer_max_size
    jae @@try_to_add
    mov bx, [label_buffer_size]
    shl bx, 1
    mov [label_buffer + bx], ax
    inc [label_buffer_size]
    jmp @@exit
    @@try_to_add:
    ; if no space, find biggest one and overwrite if bigger than currently found
    xor bx, bx ; stores max index
    mov dx, [label_buffer] ; stores max value
    xor si, si
    xor cx, cx ; if 1, replace label
    @@l2:
        cmp si, [label_buffer_size]
        jae @@break2
        shl si, 1
        cmp ax, [label_buffer + si]
        jae @@continue
        ; if found bigger check for max
        cmp [label_buffer + si], dx
        jb @@continue
        ; save max
        mov dx, [label_buffer + si]
        mov bx, si
        mov cx, 1

        @@continue:
        shr si, 1
        inc si
        jmp @@l2
    @@break2:
    cmp cx, 0
    je @@exit
    mov [label_buffer + bx], ax

    @@exit:
    pop si bx dx cx
    ret
labelextr_add_label endp

labelextr_decode_labels proc ; INPUT: ah=instr_operand. OUTPUT: dl=0 if nothing found, else dl=1
    cmp ah, t_label_int
    je @@type_label_int
    cmp ah, t_label_ext
    je @@type_label_ext
    cmp ah, t_label_int_close
    je @@type_label_int_close
    xor dl, dl
    ret

    @@type_label_int:
        call get_word
        mov ax, [var_word]
        add ax, [var_global_index]
        call labelextr_add_label
        jmp @@exit
    @@type_label_ext:
        call get_word
        call get_word
        jmp @@exit
    @@type_label_int_close:
        call get_byte
        mov al, byte ptr [var_byte]
        cbw
        add ax, [var_global_index]
        call labelextr_add_label

    @@exit:
    mov dl, 1
    ret
labelextr_decode_labels endp

labelextr_decode_repeating_types proc ; INPUT: ah=instr_operand. OUTPUT: dl=0 if nothing found, else dl=1
    call labelextr_decode_labels
    cmp dl, 1
    je @@exit

    cmp ah, t_imm8
    je @@type_imm8
    cmp ah, t_imm16
    je @@type_imm16
    xor dl, dl
    ret

    @@type_imm8:
        call get_byte
        jmp @@exit
    @@type_imm16:
        call get_word

    @@exit:
    mov dl, 1
    ret
labelextr_decode_repeating_types endp

labelextr_decode_f_none proc ; INPUT: ah=instr_operand
    push ax dx

    call labelextr_decode_repeating_types
    cmp dl, 1
    je @@exit

    cmp ah, t_addr8
    je @@read_word
    cmp ah, t_addr16
    jne @@exit
    @@read_word:
        call get_word

    @@exit:
    pop dx ax
    ret
labelextr_decode_f_none endp

labelextr_decode_f_modregrm proc ; INPUT: ah=instr_operand, al=addr_byte
    push ax dx

    call labelextr_decode_repeating_types
    cmp dl, 1
    je @@exit

    cmp ah, t_modrm8
    je @@decode
    cmp ah, t_modrm16
    je @@decode
    cmp ah, t_exp8
    jne @@exit
    call get_byte
    jmp @@exit
    @@decode:
        mov ah, al
        and ah, 111b ; rm
        shr al, 6 ; mod
        call labelextr_decode_modrm

    @@exit:
    pop dx ax
    ret
labelextr_decode_f_modregrm endp

labelextr_decode_modrm proc ; ah=rm, al=mod
    push ax

    cmp al, 11b
    je @@exit
    cmp al, 00b
    je @@get_from_00
    ; else
        cmp al, 10b
        je @@get_word
        ; else get_byte
            call get_byte
            jmp @@exit
        @@get_word:
            call get_word
            jmp @@exit

    @@get_from_00:
        cmp ah, 110b
        jne @@exit
        call get_word
        jmp @@exit

    @@exit:
    pop ax
    ret
labelextr_decode_modrm endp

check_data_addr proc ; INPUT: dx=bytes_offset. OUTPUT: dl=0 if is not data, dl=1 if is data
    push ax si
    cmp [arg_code_only], 0
    je @@not_code_only
    mov dl, 0
    jmp @@exit
    @@not_code_only:
    mov ax, [var_global_index]
    sub ax, dx
    mov dl, 0
    cmp ax, [var_ds_address]
    jne @@exit
    lea si, str_imm_data_point
    call write_dollar_string
    mov dl, 1
    @@exit:
    pop si ax
    ret
check_data_addr endp

write_ins_bytes proc
    push ax bx
    xor bx, bx
    @@l:
        cmp bx, word ptr [ins_byte_buffer_size]
        jae @@skip_numbers
        ; don't use 'write_number_byte' to skip added stuff
        mov al, byte ptr [ins_byte_buffer + bx]
        shr al, 4
        call write_single_hex_digit
        mov al, byte ptr [ins_byte_buffer + bx]
        and al, 1111b
        call write_single_hex_digit
        m_write_char_unsafe ' '
        inc bx
        jmp @@l
        @@skip_numbers:
        cmp bx, g_ins_byte_buffer_max_size
        jae @@l_break
        m_write_char_unsafe ' '
        m_write_char_unsafe ' '
        m_write_char_unsafe ' '
        inc bx
        jmp @@l
    @@l_break:
    mov [ins_byte_buffer_size], 0
    pop bx ax
    ret
write_ins_bytes endp

write_subbuffer proc
    push ax bx
    xor bx, bx
    @@l:
        cmp bx, word ptr [output_subbuffer_size]
        jae @@l_break
        mov al, byte ptr [output_subbuffer + bx]
        call write_char
        inc bx
        jmp @@l
    @@l_break:
    mov [output_subbuffer_size], 0
    pop bx ax
    ret
write_subbuffer endp

write_char proc ; writes char to output buffer. INPUT: al=byte_to_write
    push bx
    ; check which buffer
    cmp [var_use_subbuffer], 1
    jne @@not_subbuffer
        cmp [output_subbuffer_size], g_output_subbuffer_max_size
        jb @@continue_writing_sub
        mov [output_subbuffer_size], 0
        @@continue_writing_sub:
        mov bx, [output_subbuffer_size]
        mov byte ptr [output_subbuffer + bx], al
        inc word ptr [output_subbuffer_size]
        jmp @@exit

    @@not_subbuffer:
        cmp [output_buffer_size], g_output_buffer_max_size
        jb @@continue_writing
        call file_print
        @@continue_writing:
        mov bx, [output_buffer_size]
        mov byte ptr [output_buffer + bx], al
        inc word ptr [output_buffer_size]
        
    @@exit:
    pop bx
    ret
write_char endp

write_dollar_string proc ; writes string terminated by $ to output buffer. INPUT: SI=input_string
    push ax
    cld
    @@l:
        lodsb
        cmp al, 24h
        je @@exit
        call write_char
        jmp @@l
    @@exit:
    pop ax
    ret
write_dollar_string endp

write_single_hex_digit proc ; input AL=half-byte
    push ax
    add al, '0'
    cmp al, '9'
    jbe @@in_hex
    add al, 7
    @@in_hex:
    call write_char
    pop ax
    ret
write_single_hex_digit endp

write_number_internal proc ; INPUT: AL=half-byte. CH=1 if there were no chars before. CL=1 to prepend zeros.
    ; if CL=1, skip skipping
    cmp cl, 1
    je @@make_hex
    ; if number is 0 and no numbers before it, skip
    cmp al, 0
    jne @@make_hex
    cmp ch, 1
    jne @@make_hex
    jmp @@exit

    ; make to hex
    @@make_hex:
    ; if it is first char, print 0 behind it
    cmp ch, 1
    jne @@dont_print
    m_write_char '0'
    @@dont_print:
    xor ch, ch
    call write_single_hex_digit

    @@exit:
    ret
write_number_internal endp

write_number_byte proc ; INPUT: AL=number
    cmp [arg_use_dec], 0
    je @@no_dec
    push ax
    xor ah, ah
    call write_number_decimal
    m_write_char_unsafe 'd'
    pop ax
    ret
    @@no_dec:

    push bx cx ax
    mov bx, sp

    mov cx, 0101h

    ; upper-half
    mov al, byte ptr ss:[bx]
    shr al, 4
    call write_number_internal
    ; lower-half
    mov al, byte ptr ss:[bx]
    and al, 1111b
    call write_number_internal

    m_write_char_unsafe 'h'
    pop ax cx bx
    ret
write_number_byte endp

write_number_word proc ; INPUT: AX=number
    cmp [arg_use_dec], 0
    je @@no_dec
    push ax
    call write_number_decimal
    m_write_char_unsafe 'd'
    pop ax
    ret
    @@no_dec:

    push bx cx ax
    mov bx, sp

    mov cx, 0101h
    ; high-byte
    inc bx
    ; upper-half
    mov al, byte ptr ss:[bx]
    shr al, 4
    call write_number_internal
    ; lower-half
    mov al, byte ptr ss:[bx]
    and al, 1111b
    call write_number_internal

    ; low-byte
    dec bx
    ; upper-half
    mov al, byte ptr ss:[bx]
    shr al, 4
    call write_number_internal
    ; lower-half
    mov al, byte ptr ss:[bx]
    and al, 1111b
    call write_number_internal

    m_write_char_unsafe 'h'
    pop ax cx bx
    ret
write_number_word endp

write_number_decimal proc ; INPUT: AX=number
    push ax bx cx dx

    mov cx, 10d
    xor bl, bl ; stores number of digits
    @@division_loop:
        ; divide number by 10 and print remainder in a loop
        xor dx, dx
        div cx
        push dx ; store digits on the stack in reverse order
        inc bl
        cmp ax, 0
        jne @@division_loop

    @@print_loop:
        pop ax
        add ax, '0'
        m_write_char_unsafe al
        dec bl
        cmp bl, 0
        jne @@print_loop

    pop dx cx bx ax
    ret
write_number_decimal endp

exit:
    call file_print
    mov bx, [input_file_handle]
    call close_file
    mov bx, [output_file_handle]
    call close_file
    mov ah, 4Ch
    mov al, 0h
    int 21h

end start