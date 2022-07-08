; CVTQH.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
; cvtqh() - Quad to half
;
include quadmath.inc

define HFLT_MAX 0x7BFF
define HFLT_MIN 0x0001

    .code

cvtqh proc q:real16
ifdef _WIN64
    movq    rdx,xmm0
    movhlps xmm0,xmm0
    movq    rax,xmm0
    shld    rcx,rax,16
    rol     rdx,16
    shl     rax,16
    shld    rdx,rax,16
    shr     rax,32
    shr     eax,1

    .if ecx & Q_EXPMASK
        or eax,0x80000000
    .endif

    mov r9d,eax         ; duplicate it
    shl r9d,H_SIGBITS+1 ; get rounding bit
    mov r9d,0xFFE00000  ; get mask of bits to keep

    .ifc                ; if have to round
        .ifz            ; - if half way between
            .if edx == 0
                shl r9d,1
            .endif
        .endif
        add eax,0x80000000 shr (H_SIGBITS-1)

        .ifc            ; - if exponent needs adjusting
            mov eax,0x80000000
            inc cx
            ;
            ;  check for overflow
            ;
        .endif
    .endif

    mov edx,ecx         ; save exponent and sign
    and cx,Q_EXPMASK    ; if number not 0

    .repeat

        .ifnz
            .if ( cx == Q_EXPMASK )
                .if ( eax & 0x7FFFFFFF )

                    mov eax,-1
                   .break
                .endif
                mov eax,0x7C000000 shl 1
                shl dx,1
                rcr eax,1
               .break
            .endif
            add cx,H_EXPBIAS-Q_EXPBIAS
            .ifs
                ;
                ; underflow
                ;
                mov eax,0x00010000
                mov qerrno,ERANGE
               .break
            .endif

            .if ( cx >= H_EXPMASK || ( cx == H_EXPMASK-1 && eax > r9d ) )
                ;
                ; overflow
                ;
                mov eax,0x7BFF0000 shl 1
                shl dx,1
                rcr eax,1
                mov qerrno,ERANGE
               .break
            .endif

            and  eax,r9d ; mask off bottom bits
            shl  eax,1
            shrd eax,ecx,H_EXPBITS
            shl  dx,1
            rcr  eax,1
            .break .ifs ( cx || eax >= HFLT_MIN )

            mov qerrno,ERANGE
           .break
        .endif
        and eax,r9d
    .until 1
    shr  eax,16
    movd xmm0,eax
else
    int 3
endif
    ret
cvtqh endp

    end
