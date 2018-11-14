; STRTRIM.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include strlib.inc
include string.inc

    .code

strtrim proc string:LPSTR

    .if strlen(rcx)

        mov rcx,rax
        add rcx,string
        .repeat
            dec rcx
            .break .if byte ptr [rcx] > ' '
            mov byte ptr [rcx],0
            dec eax
        .untilz
    .endif
    ret

strtrim endp

    END
