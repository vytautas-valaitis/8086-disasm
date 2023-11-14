.model small
.stack 15h

.data

dum db 5 dup('0')
TT dw 0000h
teata db  15, 16, 17

.code
start:
    mov ax, @data
    mov ds, ax

    ; mov1
    mov ax, cx
    mov bx, dx
    mov cl, dh
    mov bh, bl
    mov cx, [TT]
    mov cl, byte ptr [TT]
    mov bx, [TT+5]
    mov bl, byte ptr [TT-5]
    mov ss:[45], cx
    mov [TT], cx
    mov byte ptr [TT], cl
    mov [TT+5], bx
    mov byte ptr [TT-5], bl
    mov cs:[45], cx
    mov al, byte ptr [bx-1]
    mov cx, word ptr [si-4]
    mov al, byte ptr [bx+1]
    mov cx, word ptr [si+4]
    ; mov2
    mov [TT], 1234h
    mov byte ptr [TT+5], 34h
    mov es:[TT-4], 1234h
    ; mov3
    mov ax, 1234h
    mov cl, 34h
    ; mov4
    mov ax, [TT]
    mov ax, [TT+5]
    mov ax, es:[TT-4]
    mov al, byte ptr [TT]
    mov al, byte ptr [TT+5]
    mov al, byte ptr es:[TT-4]
    ; mov5
    mov [TT], ax
    mov [TT+5], ax
    mov es:[TT-4], ax
    mov byte ptr [TT], al
    mov byte ptr [TT+5], al
    mov byte ptr es:[TT-4], al
    ; mov6
    mov ds, ax
    mov es, [TT]
    mov ss, cs:[TT+5]
    mov ax, ds
    mov [TT], es
    mov cs:[TT+5], ss

    ; push1
    push [TT+5]
    push ss:[16]
    push 15h
    ; push2
    push bx
    ; push3
    push ds

    ; pop1
    pop [TT+5]
    pop ss:[16]
    ; pop2
    pop bx
    ; pop3
    pop ds

    ; xchg1
    xchg bx, [TT]
    xchg ch, al
    xchg bl, byte ptr [TT+5]
    xchg cx, cs:[16]
    ; xchg2
    xchg ax, bx
    xchg dx, ax

    ; out1
    out 12h, al
    out 15h, ax
    ; out2
    out dx, al
    out dx, ax

    ; in1
    in al, 12h
    in ax, 15h
    ; in2
    in al, dx
    in ax, dx

    ; xlat
    xlat

    ; lea
    lea bx, TT
    lea dx, TT + 5
    lea cx, cs:[TT+16]
    lea si, [bx + 4]

    ; lds
    lds ax, [bp + 16]

    ; les
    les ax, [bp + 16]

    ; lahf
    lahf
    ; sahf
    sahf

    ; pushf
    pushf
    ; popf
    popf

    ; add1
    add ax, bx
    add ch, dl
    add bx, [TT+5]
    add [TT+5], bx
    add cl, byte ptr cs:[TT+16]
    add byte ptr cs:[TT+16], dl
    ; add2
    add [TT], 1234h
    add cs:[TT+15], 12h
    ; add3
    add al, 15h
    add ax, 1234h

    ; adc1
    adc ax, bx
    adc ch, dl
    adc bx, [TT+5]
    adc [TT+5], bx
    adc cl, byte ptr cs:[TT+16]
    adc byte ptr cs:[TT+16], dl
    ; adc2
    adc [TT], 1234h
    adc cs:[TT+15], 12h
    ; adc3
    adc al, 15h
    adc ax, 1234h

    ; inc1
    inc dl
    inc [TT]
    inc cs:[TT+16]
    inc byte ptr cs:[TT+16]
    ; inc2
    inc cx
    inc ax
    
    ; sub1
    sub ax, bx
    sub ch, dl
    sub bx, [TT+5]
    sub [TT+5], bx
    sub cl, byte ptr cs:[TT+16]
    sub byte ptr cs:[TT+16], dl
    ; sub2
    sub [TT], 1234h
    sub cs:[TT+15], 12h
    ; sub3
    sub al, 15h
    sub ax, 1234h

    ; sbb1
    sbb ax, bx
    sbb ch, dl
    sbb bx, [TT+5]
    sbb [TT+5], bx
    sbb cl, byte ptr cs:[TT+16]
    sbb byte ptr cs:[TT+16], dl
    ; sbb2
    sbb [TT], 1234h
    sbb cs:[TT+15], 12h
    ; sbb3
    sbb al, 15h
    sbb ax, 1234h

    ; dec1
    dec dl
    dec [TT]
    dec cs:[TT+16]
    dec byte ptr cs:[TT+16]
    ; dec2
    dec cx
    dec ax

    ; cmp1
    cmp ax, [TT]
    cmp cl, byte ptr cs:[TT-4]
    cmp byte ptr [TT+15], cl
    cmp cs:[TT-4], si
    ; cmp2
    cmp cl, 15h
    cmp cs:[TT+4], 1234h
    cmp cs:[TT-2], 6h
    ; cmp3
    cmp al, 16h
    cmp ax, 300h

    ; mul
    mul cl
    mul dx
    mul byte ptr [TT]
    mul es:[TT+15]

    ; imul
    imul cl
    imul dx
    imul byte ptr [TT]
    imul es:[TT+15]

    ; div
    div cl
    div dx
    div byte ptr [TT]
    div es:[TT+15]
    
    ; idiv
    idiv cl
    idiv dx
    idiv byte ptr [TT]
    idiv es:[TT+15]

    ; neg
    neg cl
    neg [TT]
    neg byte ptr [TT]
    neg es:[TT+15]

    ; aaa
    aaa
    ; daa
    daa
    ; aas
    aas
    ; das
    das
    ; aam
    aam
    ; aad
    aad
    ; cbw
    cbw
    ; cwd
    cwd

    ; not
    not ax
    not [TT]
    not byte ptr es:[TT+15]

    ; shl
    shl cl, 1
    shl ax, 3
    shl ax, cl
    shl [TT], 5
    shl byte ptr es:[TT+15], 5

    ; shr
    shr cl, 1
    shr ax, 3
    shr ax, cl
    shr [TT], 5
    shr byte ptr es:[TT+15], 5

    ; sar
    sar cl, 1
    sar ax, 3
    sar ax, cl
    sar [TT], 5
    sar byte ptr es:[TT+15], 5

    ; rol
    rol cl, 1
    rol ax, 3
    rol ax, cl
    rol [TT], 5
    rol byte ptr es:[TT+15], 5

    ; ror
    ror cl, 1
    ror ax, 3
    ror ax, cl
    ror [TT], 5
    ror byte ptr es:[TT+15], 5

    ; rcl
    rcl cl, 1
    rcl ax, 3
    rcl ax, cl
    rcl [TT], 5
    rcl byte ptr es:[TT+15], 5

    ; rcr
    rcr cl, 1
    rcr ax, 3
    rcr ax, cl
    rcr [TT], 5
    rcr byte ptr es:[TT+15], 5

    ; and1
    and ax, [TT]
    and cl, byte ptr cs:[TT-4]
    and byte ptr [TT+15], cl
    and cs:[TT-4], si
    ; and2
    and cl, 15h
    and cs:[TT+4], 1234h
    and cs:[TT-2], 6h
    ; and3
    and al, 16h
    and ax, 300h

    ; or1
    or ax, [TT]
    or cl, byte ptr cs:[TT-4]
    or byte ptr [TT+15], cl
    or cs:[TT-4], si
    ; or2
    or cl, 15h
    or cs:[TT+4], 1234h
    or cs:[TT-2], 6h
    ; or3
    or al, 16h
    or ax, 300h

    ; xor1
    xor ax, [TT]
    xor cl, byte ptr cs:[TT-4]
    xor byte ptr [TT+15], cl
    xor cs:[TT-4], si
    ; xor2
    xor cl, 15h
    xor cs:[TT+4], 1234h
    xor cs:[TT-2], 6h
    ; xor3
    xor al, 16h
    xor ax, 300h

    ; test1
    test ax, [TT]
    test cl, byte ptr cs:[TT-4]
    test byte ptr [TT+15], cl
    test cs:[TT-4], si
    ; test2
    test cl, 15h
    test cs:[TT+4], 1234h
    test cs:[TT-2], 6h
    ; test3
    test al, 16h
    test ax, 300h

    ; rep
    rep
    ; repnz
    repnz
    ; movsb
    movsb
    ; movsw
    movsw
    ; cmpsb
    cmpsb
    ; cmpsw
    cmpsw
    ; scasb
    scasb
    ; scasw
    scasw
    ; lodsb
    lodsb
    ; lodsw
    lodsw
    ; stosb
    stosb
    ; stosw
    stosw

    ; call1
    call start
    ; call2
    call si
    call [TT]
    call es:[TT]
    ; call3
    db 9Ah
    dw 1234h
    dw 4321h 
    ; call4
    db 0FFh
    db 00011110b
    dw 1234h
conditional_jumps4:

    ; ret1
    retn
    ; ret2
    retn 15h
    ; ret3
    retf
    ; ret4
    retf 15h
conditional_jumps2:

    ; jmp1
    jmp conditional_jumps
    jmp conditional_jumps
    jmp conditional_jumps
    jmp conditional_jumps
    ; jmp2
    jmp start
test1:
    ; jmp3
    jmp ax
test2:
    jmp [TT]
test3:
    ; jmp4
    db 0EAh
    dw 1234h
    dw 4321h
test4:
    ; call5
    db 0FFh
    db 00101110b
    dw 1234h

    ; conditional jumps
conditional_jumps:
    ja conditional_jumps
    jae conditional_jumps2
    jb conditional_jumps3
    jbe conditional_jumps4
    je conditional_jumps
    jcxz conditional_jumps
    jg conditional_jumps
    jge conditional_jumps
    jl conditional_jumps
test5:
    jle conditional_jumps
test6:
    jne test7
test7:
    jno test1
    jnp test2
    jp test3
    jo test4
    jns test5
    js test6

    ; loops
    loop test_label
    loope conditional_jumps
    loopne conditional_jumps
    
    ; int
    int 34h
    ; iret
    iret
test_label:
    ; flag control
    clc
    stc
    cmc
    cld
    std
    cli
    sti
conditional_jumps3:
    ; hlt
    hlt
    ; wait
    wait
    ; lock
    lock

    ; esc
    esc 0h, al
    esc 1h, cl
    esc 2h, dl
    esc 3h, bl
    esc 0Fh, ah
    esc 1Fh, ch
    esc 2Fh, dh
    esc 3Fh, bh
    esc 00fh, [TT]
    esc 00fh, ds:[TT]

    ; nop
    nop

end start