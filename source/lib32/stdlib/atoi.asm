; ATOI.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include stdlib.inc

    .code

atoi proc string:LPSTR

    atol(string)
    ret

atoi endp

    END
