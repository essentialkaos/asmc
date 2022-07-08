; ISINF_NSQ.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include quadmath.inc

    .code

isinf_nsq proc q:real16
ifdef _WIN64
    movq    rax,xmm0
    shufpd  xmm0,xmm0,1
    movq    rdx,xmm0
    shufpd  xmm0,xmm0,1
    mov     rcx,0x7fffffffffffffff
    and     rdx,rcx
    mov     rcx,0x7fff000000000000
    xor     rdx,rcx
    or      rax,rdx
    setz    al
    movzx   eax,al
endif
    ret
isinf_nsq endp

    end
