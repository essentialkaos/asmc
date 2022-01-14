; STRCAT.ASM--
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.

include string.inc

    .code

strcat proc __ctype uses si di s1:ptr sbyte, s2:ptr sbyte

    pushl   ds
    xor     ax,ax
    lesl    di,s1
    ldsl    si,s2
    mov     cx,-1
    repne   scasb
    dec     di
.0:
    mov     al,[si]
    mov     esl[di],al
    inc     di
    inc     si
    test    al,al
    jnz     .0
    movl    dx,es
    mov     ax,word ptr s1
    popl    ds
    ret

strcat endp

    end
