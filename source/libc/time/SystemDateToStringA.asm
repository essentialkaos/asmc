; SYSTEMDATETOSTRINGA.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
; DMY:dd.mm.yyyy, MDY:mm/dd/yyyy, YMD:yyyy/mm/dd
;
include time.inc
include winnls.inc

    .code

SystemDateToStringA proc string:ptr char_t, date:ptr SYSTEMTIME

   .new dateString[64]:wchar_t

    GetDateFormatEx(NULL, DATE_SHORTDATE, date, NULL, &dateString, lengthof(dateString), NULL)

    .for ( rdx = string, ecx = 0 : ecx < 10 : ecx++ )

        mov al,byte ptr dateString[rcx*2]
        mov [rdx+rcx],al
    .endf

    mov byte ptr [rdx+rcx],0
   .return( string )

SystemDateToStringA endp

    END
