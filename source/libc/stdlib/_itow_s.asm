; _ITOW_S.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include stdlib.inc

    .code

_itow_s proc val:int_t, buffer:wstring_t, sizeInTChars:size_t, radix:int_t

ifdef _WIN64
    xor eax,eax
    .ifs ( r9d == 10 && ecx < 0 )
        inc eax
        movsxd rcx,ecx
    .endif
    .return ( _xtow_s( rcx, rdx, r8d, r9d, eax ) )
else
    xor ecx,ecx
    mov eax,val
    cdq
    .ifs ( radix == 10 && edx < 0 )
        inc ecx
    .endif
    .return ( _xtow_s( edx::eax, buffer, sizeInTChars, radix, ecx ) )
endif

_itow_s endp

    end
