; WCSNCAT.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include string.inc

    .code

    option dotname

wcsncat proc uses rdi rbx dst:LPWSTR, src:LPWSTR, max:SIZE_T

ifdef _WIN64
    mov     rax,rcx
    mov     rbx,r8
else
    mov     ecx,dst
    mov     edx,src
    mov     ebx,max
    mov     eax,ecx
endif
    xor     edi,edi
.0:
    cmp     di,[rcx]
    je      .1
    add     rcx,2
    jmp     .0
.1:
    test    ebx,ebx
    jz      .2
    dec     ebx
    mov     di,[rdx]
    mov     [rcx],di
    add     rcx,2
    add     rdx,2
    test    edi,edi
    jnz     .1
    mov     ebx,edi
    sub     rcx,2
.2:
    mov     [rcx],bx
    ret

wcsncat endp

    end
