; _GOTOXY.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include conio.inc

    .code

_gotoxy proc x:UINT, y:UINT

ifndef _WIN64
    mov ecx,x
    mov edx,y
endif

    shl edx,16
    or  edx,ecx

    SetConsoleCursorPosition( _confh, edx )
    ret

_gotoxy endp

    end
