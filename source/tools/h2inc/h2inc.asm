; H2INC.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include stdio.inc
include stdlib.inc
include string.inc
include io.inc
include malloc.inc
include winbase.inc
include signal.inc
include ctype.inc
include tchar.inc

    option dllimport:none

define __H2INC__    103

define MAXLINE      512
define MAXBUF       0x100000
define MAXARGS      20

define FL_STBUF     0x01
define FL_STRUCT    0x02
define FL_ENUM      0x04
define FL_TYPEDEF   0x08
define _LABEL       0x40 ; _UPPER + _LOWER + '_'

.enum token_type {
    T_EOF,
    T_BLANK,
    T_ID,
    T_STRUCT,
    T_UNION,
    T_TYPEDEF,
    T_ENUM,
    T_IF,
    T_ELSE,
    T_ENDIF,
    T_ENDS,
    T_INCLUDE,
    T_DEFINE,
    T_UNDEF,
    T_ERROR,
    T_PRAGMA,
    T_INTERFACE,
    T_EXTERN,
    T_INLINE,
    T_DEFINE_GUID
    }

.template jmpbuf
    _bx   dq ?
    _sp   dq ?
    _bp   dq ?
    _si   dq ?
    _di   dq ?
    _12   dq ?
    _13   dq ?
    _14   dq ?
    _15   dq ?
    _ip   dq ?
   .ends

;
; Inline functions
;

    .pragma warning(disable: 8019) ; assume byte..

setjump proto buf:ptr jmpbuf {
    xor eax,eax
    mov [rcx].jmpbuf._bp,rbp
    mov [rcx].jmpbuf._si,rsi
    mov [rcx].jmpbuf._di,rdi
    mov [rcx].jmpbuf._bx,rbx
    mov [rcx].jmpbuf._12,r12
    mov [rcx].jmpbuf._13,r13
    mov [rcx].jmpbuf._14,r14
    mov [rcx].jmpbuf._15,r15
    mov [rcx].jmpbuf._sp,rsp
    lea rdx,[rip+4]
    mov [rcx].jmpbuf._ip,rdx
    }

longjump proto buf:ptr jmpbuf, retval:int_t {

    mov rbp,[rcx].jmpbuf._bp
    mov rsi,[rcx].jmpbuf._si
    mov rdi,[rcx].jmpbuf._di
    mov rbx,[rcx].jmpbuf._bx
    mov r12,[rcx].jmpbuf._12
    mov r13,[rcx].jmpbuf._13
    mov r14,[rcx].jmpbuf._14
    mov r15,[rcx].jmpbuf._15
    mov rsp,[rcx].jmpbuf._sp
    mov rcx,[rcx].jmpbuf._ip
    mov eax,edx
    jmp rcx
    }

islalpha proto watcall c:byte {
    retm<([r15+rax+1] & (_UPPER or _LOWER))>
    }
isldigit proto watcall c:byte {
    retm<([r15+rax+1] & _DIGIT)>
    }
islalnum proto watcall c:byte {
    retm<([r15+rax+1] & (_DIGIT or _UPPER or _LOWER))>
    }
islpunct proto watcall c:byte {
    retm<([r15+rax+1] & _PUNCT)>
    }
islspace proto watcall c:byte {
    retm<([r15+rax+1] & _SPACE)>
    }
islxdigit proto watcall c:byte {
    retm<([r15+rax+1] & _HEX)>
    }
isid proto watcall c:byte {
    retm<([r15+rax+1] & (_LABEL or _DIGIT))>
    }
isidfirst proto watcall :byte {
    retm<([r15+rax+1] & _LABEL)>
    }

tokstart proto watcall string:string_t {
    movzx ecx,byte ptr [rax]
    .while ( [r15+rcx+1] & _SPACE )
        inc rax
        mov cl,[rax]
    .endw
    }

tokstartc proto watcall string:string_t {
    tokstart(string)
    xchg rax,rcx
    }

parseline proto

.data

 prgpath    string_t NULL
 jmpenv     jmpbuf <>
 ercount    dd 0

 banner     db 0
 option_q   db 0            ; -q
 option_n   db 0            ; -nologo
 option_m   db 0            ; -nomacro
 stoptions  db 0

 align 8
 option_c   string_t NULL   ; -c<calling_convention>
 option_v   string_t NULL   ; -v<calling_convention>
 option_f   string_t MAXARGS dup(NULL)
 option_w   string_t MAXARGS dup(NULL)
 option_s   string_t MAXARGS dup(NULL)
 option_r   string_t MAXARGS*2 dup(NULL)

 tokpos     string_t ?
 linebuf    string_t NULL
 filebuf    string_t NULL
 tempbuf    string_t NULL
 srcfile    ptr FILE NULL
 outfile    ptr FILE NULL
 curfile    string_t NULL
 curline    dd 1
 csize      dd ?
 cflags     db ?
 ctoken     db ?
 clevel     db ?
 cstart     db 0
 cblank     db 0
_ltype      db \
  0,
  9 dup(_CONTROL),
  5 dup(_SPACE+_CONTROL),
 18 dup(_CONTROL),
  _SPACE,
 15 dup(_PUNCT),
 10 dup(_DIGIT+_HEX),
  7 dup(_PUNCT),
  6 dup(_UPPER+_LABEL+_HEX),
 20 dup(_UPPER+_LABEL),
  4 dup(_PUNCT),
  _PUNCT+_LABEL,
  _PUNCT,
  6 dup(_LOWER+_LABEL+_HEX),
 20 dup(_LOWER+_LABEL),
  4 dup(_PUNCT),
  _CONTROL,
128 dup(0) ; and the rest are 0...

    .code

write_logo proc

    .if ( !banner )

        mov banner,1
        printf(
            "Asmc Macro Assembler C Include File Translator %d.%d\n"
            "Copyright (C) The Asmc Contributors. All Rights Reserved.\n\n",
            __H2INC__ / 100, __H2INC__ mod 100)
    .endif
    ret

write_logo endp


write_usage proc

    write_logo()
    printf("Usage: h2inc [ options ] filename\n")
    ret

write_usage endp


exit_usage proc

    write_usage()
    exit(0)

exit_usage endp


exit_options proc

    write_usage()
    printf(
        "\n"
        "-q              -- Operate quietly\n"
        "-nologo         -- Suppress copyright message\n"
        "-c<string>      -- Specify string (calling convention) for PROTO\n"
        "-v<string>      -- Specify string for PROTO using VARARG\n"
        "-m              -- Skip empty macro lines followed by a blank\n"
        "-f<functon>     -- Strip functon: -f__attribute__\n"
        "-w<word>        -- Strip word (a valid identifier)\n"
        "-s<string>      -- Strip string\n"
        "-r<old> <new>   -- Replace string\n"
        "\n"
        "Note that \"quotes\" are stripped so use -r\"\\\"old\\\"\" \"\\\"new\\\"\" to replase\n"
        "actual \"quoted strings\".\n\n"
        )

    exit(0)

exit_options endp


strtrim proc string:string_t

    .if strlen(rcx)

        lea ecx,[rax-1]
        mov edx,eax
        add rcx,string
        .while islspace([rcx])
            mov [rcx],ah
            dec rcx
            dec edx
        .endw
        mov eax,edx
    .endif
    ret

strtrim endp


strstart proc string:string_t

    .while islspace([rcx])
        inc rcx
    .endw
    xchg rcx,rax
    ret

strstart endp


prevtok proc string:string_t, start:string_t

    .while ( rcx >= rdx && !isid([rcx]) )
        dec rcx
    .endw
    .while ( rcx >= rdx && isid([rcx]) )
        dec rcx
    .endw
    inc  rcx
    xchg rcx,rax
    ret

prevtok endp


prevtokz proc string:string_t, start:string_t

    .while ( rcx >= rdx && !isid([rcx]) )
        mov [rcx],ah
        dec rcx
    .endw
    .while ( rcx >= rdx && isid([rcx]) )
        dec rcx
    .endw
    inc  rcx
    xchg rcx,rax
    ret

prevtokz endp


nexttok proc string:string_t

    .repeat
        .if ( isid([rcx]) )
            inc rcx
            .while isid([rcx])
                inc rcx
            .endw
            .break
        .endif
        .if ( islpunct([rcx]) )
            inc rcx
        .endif
    .until 1

    tokstart(rcx)
    ret

nexttok endp


toksize proc string:string_t

    mov rdx,rcx
    .if ( isidfirst([rcx]) )
        inc rcx
        .while isid([rcx])
            inc rcx
        .endw
    .endif
    xchg rax,rcx
    sub rax,rdx
    ret

toksize endp


stripval proc uses rsi string:string_t

    ; strip (0U-199U) | 0x40000000000UI64

    mov rsi,rcx
    .while [rsi]

        .while !isldigit([rsi])
            mov rsi,nexttok(rsi)
            .break(1) .if !cl
        .endw
        inc rsi
        .if ( [rsi] == 'x' )
            inc rsi
        .endif

        .for ( : islxdigit([rsi]) : rsi++ )
        .endf
        .break .if !al
        .continue .if !islalpha([rsi])

        mov rcx,rsi
        .for ( : islalnum([rsi]) : rsi++ )
        .endf
        mov rdx,rsi
        mov rsi,rcx
        strcpy(rcx, rdx)
    .endw
    .return(string)

stripval endp


; #define CN_EVENT ((UINT)(-2))

striptype proc uses rdi string:string_t

    mov rdi,rcx

    .while 1

        .break .if !strchr(rdi, '(')
        .ifd ( tokstartc(&[rax+1]) != '(' )
            mov rdi,rcx
           .continue
        .endif
        mov rdi,rcx
        mov rdx,tokstart(&[rcx+1])
        .if ( cl == '(' )
            mov rdi,rax
            mov rdx,tokstart(&[rax+1])
        .endif

        .ifd ( !isidfirst([rdx]) )
            mov rdi,rdx
           .continue
        .endif
        inc rdx
        .while isid([rdx])
            inc rdx
        .endw
        .whiled ( tokstartc(rdx) == '*' )
            inc rdx
        .endw
        .if ( al != ')' )
            mov rdi,rcx
            .continue
        .endif
        inc rdx
        .ifd ( tokstartc(rdx) != '(' )
            lea rdi,[rdx+1]
           .continue
        .endif
        mov rcx,rdi
        lea rdi,[rdx+1]
        strcpy(rcx, rdx)
    .endw
    ret

striptype endp


wordxchg proc uses rdi rsi rbx r12 r13 string:string_t, token:string_t, new:string_t

   .new retval:int_t = 0

    mov r12,rcx
    mov r13,r8
    mov rdi,tempbuf
    mov rbx,strlen(rdx)

    .while strstr(r12, token)
        mov rsi,rax
        .if !isid([rsi-1])
            .if !isid([rsi+rbx])
                inc retval
                mov [rsi],0
                strcpy(rdi, r12)
                strcat(rdi, r13)
                strcat(rdi, &[rsi+rbx])
                strcpy(r12, rdi)
            .endif
        .endif
        lea r12,[rsi+rbx]
    .endw
    .return(retval)

wordxchg endp


strxchg proc uses rdi rsi rbx string:string_t, token:string_t, new:string_t

    mov rdi,rcx
    mov rbx,strlen(rdx)

    .while strstr(rdi, token)

        mov rsi,rax
        strcpy(tempbuf, &[rsi+rbx])
        lea rdi,[rsi+strlen(strcpy(rsi, new))]
        strcat(rsi, tempbuf)
    .endw
    ret

strxchg endp


arg_option_f proc uses rsi rdi rbx r12 string:string_t

    mov rdi,rcx

    .for ( r12d = 0 : r12d < MAXARGS : r12d++ )

        lea rax,option_f
        mov rsi,[rax+r12*8]

        .break .if !rsi
        .continue .if !strstr(rdi, rsi)

        mov rbx,rax
        mov rdx,strlen(rsi)
        .if ( [rbx-1] == ' ' )
            dec rbx
            inc rdx
        .endif
        add rdx,rbx
        mov rdx,tokstart(rdx)

        mov al,[rdx]
        .if ( al == '(' )

            .for ( ecx = 0 : al : rdx++, al = [rdx] )

                .if ( al == '(' )
                    inc ecx
                .elseif ( al == ')' )
                    dec ecx
                    .ifz
                        inc rdx
                        .break
                    .endif
                .endif
            .endf
        .endif
        strcpy(rbx, rdx)
    .endf
    ret

arg_option_f endp


arg_option_s proc uses rdi rbx string:string_t

    mov rdi,rcx

    .for ( ebx = 0 : ebx < MAXARGS : ebx++ )

        lea rax,option_s
        mov rdx,[rax+rbx*8]

        .break .if !rdx

        strxchg(rdi, rdx, "")
    .endf
    ret

arg_option_s endp


arg_option_w proc uses rdi rbx string:string_t

    mov rdi,rcx

    .for ( ebx = 0 : ebx < MAXARGS : ebx++ )

        lea rax,option_w
        mov rdx,[rax+rbx*8]

        .break .if !rdx

        wordxchg(rdi, rdx, "")
    .endf
    ret

arg_option_w endp


arg_option_r proc uses rdi rbx string:string_t

    mov rdi,rcx
    .for ( ebx = 0 : ebx < MAXARGS : ebx++ )

        lea rax,option_r
        lea rcx,[rbx*8]
        mov rdx,[rax+rcx*2]

        .break .if !rdx
        mov r8,[rax+rcx*2+8]
        strxchg(rdi, rdx, r8)
    .endf
    ret

arg_option_r endp


operator proc uses rdi rsi rbx r12 string:string_t, token:string_t, new:string_t

    mov r12,rcx
    mov rdi,tempbuf
    mov rbx,strlen(rdx)

    .while strstr(r12, token)

        mov [rax],0
        lea rsi,[rax+rbx]
        mov rsi,tokstart(rsi)
        strtrim(r12)
        strcpy(rdi, r12)
        strcat(rdi, new)
        strcat(rdi, rsi)
        strcpy(r12, rdi)
    .endw
    ret

operator endp

convert proc uses rsi string:string_t

    mov rsi,rcx

    striptype(rsi)
    stripval(rsi)

    operator(rsi, "<<", " shl ")
    operator(rsi, ">>", " shr ")
    operator(rsi, "==", " eq ")
    operator(rsi, ">=", " ge ")
    operator(rsi, "<=", " le ")
    operator(rsi, "->", ".")
    operator(rsi, "||", " or ")
    operator(rsi, "&&", " and ")
    operator(rsi, ">",  " gt ")
    operator(rsi, "<",  " lt ")
    operator(rsi, "|",  " or ")
    operator(rsi, "&",  " and ")
    operator(rsi, "!=", " ne ")
    operator(rsi, "!",  " not ")
    operator(rsi, "~",  " not ")
   .return(rsi)

convert endp


oprintf proc format:string_t, args:vararg

    mov cblank,0
    .if ( cflags & FL_STBUF )

        mov rcx,strlen(filebuf)
        add rcx,filebuf
        .return vsprintf(rcx, format, &args)
    .endif

     mov cstart,1
    .return vfprintf(outfile, format, &args)

oprintf endp


error proc string:string_t

    inc ercount
    printf("%s(%d) : error : %s\n", curfile, curline, rcx)
    ret

error endp


errexit proc string:string_t

    .if ( srcfile )
        fclose(srcfile)
    .endif
    .if ( outfile )
        fclose(outfile)
    .endif
    printf("%s(%d) : fatal error : %s\n", curfile, curline, string)
    exit(1)
    ret

errexit endp


eofexit proc

    .if ( cflags & FL_STBUF )

        fprintf(outfile, filebuf)
    .endif
    longjump(&jmpenv, 1)
    ret

eofexit endp


getline proc uses rsi rdi buffer:string_t

   .new comment_section:byte = 0

    mov rsi,buffer

    .while 1

        .if !fgets(rsi, MAXLINE, srcfile)
            eofexit()
        .endif

        inc curline

        .if comment_section
            .if strstr(rsi, "*/")
                strcpy(rsi, &[rax+2])
                dec comment_section
            .else
                .continue
            .endif
        .elseif strstr(rsi, "/*")
            mov byte ptr [rax],0
            mov rdi,rax
            inc rax
            .if strstr(rax, "*/")
                add rax,2
                strcpy(rdi, rax)
               .continue .if !strtrim(rsi)
            .else
                inc comment_section
            .endif
        .endif
        .if comment_section
            .continue
        .endif
        .if strstr(rsi, "//")
            mov byte ptr [rax],0
            .continue .if !strtrim(rsi)
        .endif
        strtrim(rsi)
        .if ( eax && stoptions )
            arg_option_s(rsi)
            arg_option_w(rsi)
            arg_option_f(rsi)
            arg_option_r(rsi)
            strtrim(rsi)
        .endif
        .return rsi
    .endw
    ret

getline endp


concat proc uses rsi rdi string:string_t

    mov rdi,rcx
    lea rsi,[rdi+strtrim(rdi)+1]
    mov [rsi-1],' '
    getline(rsi)
    strcpy(rsi, tokstart(rsi))
   .return(rdi)

concat endp


concatf proc uses rdi string:string_t

    mov rdi,string
    lea rcx,[rdi+strlen(rdi)-1]

    .if ( [rcx] == '\' )

        .while 1

            mov [rcx],0
            lea rcx,[rdi+strlen(concat(rdi))-1]
            .break .if ( [rcx] != '\' )
        .endw
    .endif
    .return(rdi)

concatf endp


tokenize proc uses rsi rdi string:string_t

    mov rsi,rcx

    .while 1

        mov rdi,tokstart(rsi)
        mov tokpos,rdi

        .if ( [rdi] == 0 )
            mov csize,0
            mov ctoken,T_BLANK
           .return(T_BLANK)
        .endif

        .if ( [rdi] == '#' )

            inc rdi
            mov rdx,tokstart(rdi)
            .if ( rdx != rdi )
                strcpy(rdi, rdx)
            .endif
            dec rdi

            mov eax,[rdi+1]
            bswap eax
            .switch eax
            .case 'incl'
                mov csize,8
                mov ctoken,T_INCLUDE
                .return(T_INCLUDE)
            .case 'defi'
                mov csize,7
                mov ctoken,T_DEFINE
                .return(T_DEFINE)
            .case 'unde'
                mov csize,6
                mov ctoken,T_UNDEF
                .return(T_UNDEF)
            .case 'prag'
                mov csize,7
                mov ctoken,T_PRAGMA
                .return(T_PRAGMA)
            .case 'erro'
                mov csize,6
                mov ctoken,T_ERROR
                .return(T_ERROR)
            .case 'endi'
                mov csize,6
                mov ctoken,T_ENDIF
                .return(T_ENDIF)
            .case 'elif'
                strcpy(tempbuf, "#elseif")
                strcat(rax, &[rdi+5])
                strcpy(rdi, rax)
                mov csize,7
                mov ctoken,T_IF
                .return(T_IF)
            .case 'else'
                movzx eax,byte ptr [rdi+5]
                .if !islalpha(eax)
                    mov csize,5
                    mov ctoken,T_ELSE
                    .return(T_ELSE)
                .endif
            .default
                .for ( rdi++, ecx = 1 : islalpha([rdi]) : rdi++, ecx++ )
                .endf
                mov csize,ecx
                mov ctoken,T_IF
                .return(T_IF)
            .endsw
        .endif

        .if ( byte ptr [rdi] == '}' )
            mov csize,1
            mov ctoken,T_ENDS
            .return(T_ENDS)
        .endif

        .switch toksize(rdi)
        .case 4
            mov eax,[rdi]
            .if eax == 'mune'
                mov csize,4
                mov ctoken,T_ENUM
               .return(T_ENUM)
            .endif
            .endc
        .case 5
            .if !memcmp(rdi, "union", 5)
                mov csize,5
                mov ctoken,T_UNION
               .return(T_STRUCT)
            .endif
            .endc
        .case 6
            .if !memcmp(rdi, "struct", 6)
                mov csize,6
                mov ctoken,T_STRUCT
               .return(T_STRUCT)
            .endif
            .if !memcmp(rdi, "extern", 6)
                mov csize,6
                mov ctoken,T_EXTERN
               .return(T_EXTERN)
            .endif
            .endc
        .case 7
            .endc .if memcmp(rdi, "typedef", 7)
            mov csize,7
            mov ctoken,T_TYPEDEF
           .return(T_TYPEDEF)
        .case 8
            .if !memcmp(rdi, "EXTERN_C", 8)
                mov csize,8
                mov ctoken,T_EXTERN
                .if !memcmp(&[rdi+9], "const IID IID_", 14)
                    mov ctoken,T_INTERFACE
                    .return(T_INTERFACE)
                .endif
               .return(T_EXTERN)
            .endif
            .if !memcmp(rdi, "__inline", 8)
                mov csize,8
                mov ctoken,T_INLINE
               .return(T_INLINE)
            .endif
            .endc
        .case 11
            .if !memcmp(rdi, "DEFINE_GUID", 11)
                mov csize,11
                mov ctoken,T_DEFINE_GUID
               .return(T_DEFINE_GUID)
            .endif
        .endsw
        mov csize,eax
        mov ctoken,T_ID
       .return(T_ID)
    .endw
    ret

tokenize endp


parse_blank proc

    .if ( cstart )
        inc cblank
        .if ( cblank == 1 )

            .if ( cflags & FL_STBUF )

                strcat(filebuf, "\n")
            .else
                fprintf(outfile, "\n")
            .endif
        .endif
    .endif
    ret

parse_blank endp


; #[else]if[n]def

parse_if proc uses rdi

    mov rdi,tokpos
    .if !memcmp(rdi, "#ifdef UNICODE", 14)
        oprintf("ifdef _UNICODE\n")
       .return
    .endif
    convert(concatf(rdi))
    oprintf("%s\n", &[rdi+1])
    ret

parse_if endp


; #else/#endif/#undef

parse_else proc

    mov rdx,tokpos
    oprintf("%s\n", &[rdx+1])
    ret

parse_else endp


; #error

parse_error proc uses rdi

    mov rdi,tokpos
    .if strchr(rdi, '<')

        lea rdx,[rax+1]
        strcpy(rax, rdx)
        .if strchr(rdi, '>')
            lea rdx,[rax+1]
            strcpy(rax, rdx)
        .endif
    .endif
    oprintf(".err <%s>\n", &[rdi+7])
    ret

parse_error endp


; #pragma

parse_pragma proc uses rdi

    mov rdi,tokpos
    convert(concatf(rdi))
    oprintf(";.%s\n", &[rdi+1])
    ret

parse_pragma endp


; #include <name.h>

stripchr proc string:string_t, chr:int_t
    .if strchr(rcx, edx)
        lea rdx,[rax+1]
        strcpy(rax, rdx)
    .endif
    ret
stripchr endp


parse_include proc uses rdi

    mov rdi,tokpos
    mov rdi,tokstart(&[rdi+8])

    .if stripchr(rdi, '<')
        stripchr(rdi, '>')
    .elseif stripchr(rdi, '"')
        stripchr(rdi, '"')
    .endif
    .if strrchr(rdi, '.')
        mov [rax],0
    .endif

    strcat(rdi, ".inc")
    oprintf("include %s\n", rdi)
    ret

parse_include endp


exit_macro proc string:string_t

    .return oprintf("  exitm<%s>\n  endm\n", convert(rcx))

exit_macro endp


; gues:
; #define n (x) - value
; #define n(x)  - macro

parse_define proc uses rsi rdi rbx r12

    mov rdi,tokpos
    mov r12,tokstart(&[rdi+7])
    mov rsi,nexttok(rax)
    mov al,[rsi-1]

    .if ( cl != '(' || ( cl == '(' && ( al == ' ' || al == 9 ) ) )

        convert(concatf(rdi))
        .if ( [rsi] == '"' || ( [rsi] == 'L' && [rsi+1] == '"' ) )
            strcpy(rsi, strcat(strcat(strcpy(tempbuf, "<"), rsi), ">"))
        .endif
        oprintf("%s\n", &[rdi+1])
       .return
    .endif

    mov [rsi],0
    inc rsi
    xor ebx,ebx
    .if strchr(rsi, ')')
        mov [rax],0
        mov rbx,tokstart(&[rax+1])
    .endif

    oprintf("%s macro %s\n", r12, rsi)

    .if ( !rbx )
        .return error(rsi)
    .endif
    strcpy(rdi, rbx)

    .while ( [rdi] == '\' )
        getline(rdi)
        mov rdi,tokstart(rdi)
    .endw

    .if ( [rdi] == 0 )
        .return exit_macro(rdi)
    .endif
    ;
    ; macro(arg1, \
    ;       ..., \
    ;       argn)
    ;
    .while 1

        .break .if !strrchr(rdi, ',')

        lea rsi,[rax+1]
        .break .ifd tokstartc(rsi) != '\'
        .break .if ( [rcx+1] != 0 )

        mov [rsi],0
        concat(rdi)
    .endw
    .if ( [rdi+strlen(rdi)-1] != '\' )
        .return exit_macro(rdi)
    .endif

    .repeat

        mov [rdi+rax-1],0
        strtrim(rdi)
        convert(rdi)
        oprintf("    %s\n", tokstart(rdi))
    .until ( [rdi+strlen(getline(rdi))-1] != '\' )

    convert(rdi)
    oprintf("    %s\n", tokstart(rdi))
   .return exit_macro("")

parse_define endp


; [typedef] enum [name] {

parse_enum proc uses rdi rbx

    mov rdi,tokpos
    .if ( !strchr(rdi, '{') )
        concat(rdi)
    .endif
    mov rbx,nexttok(rdi)
    nexttok(rbx)

    or cflags,FL_ENUM
    .if ( cl == '{' || [rbx] == '{' ) ; enum { --> } name;
        mov rax,filebuf
        mov [rax],0
        or cflags,FL_STBUF
       .return
    .endif

    .if ( cl == '_' ) ; enum _name { ... } name;
        inc rbx
    .endif
    oprintf(".enum %s\n", rbx)
    ret

parse_enum endp


; }[name][, type];

parse_ends proc uses rdi rbx

    mov rdi,tokpos

    .if ( cflags & FL_STBUF )

        and cflags,not FL_STBUF
        .if ( cflags & FL_ENUM )

            and cflags,not FL_ENUM
            mov rbx,nexttok(rdi)
            .if toksize(rbx)
                mov [rbx+rax],0
            .endif
            mov byte ptr [rdi],0
            oprintf(".enum %s {\n%s%s}\n", rbx, filebuf, linebuf)
        .endif
    .elseif ( cflags & FL_ENUM )
        and cflags,not FL_ENUM
        oprintf("}\n")
    .endif
    ret

parse_ends endp


strip_unsigned proc uses rsi rdi rbx string:string_t

    mov rdi,rcx
    .while strstr(rdi, "unsigned")

        mov rbx,rax
        mov rsi,tokstart(&[rax+8])
        mov ecx,toksize(rax)
        mov eax,[rsi]
        add rsi,rcx
        lea rdx,@CStr("dword")

        .switch ecx
        .case 7
            .if eax == 'ni__'
                lea rdx,@CStr("qword")
               .endc
            .endif
            lea rsi,[rbx+8]
            .endc
        .case 4
            .if eax == 'rahc'
                lea rdx,@CStr("byte")
               .endc
            .endif
            mov eax,[rsi+1]
            .if eax == 'gnol'
                add rsi,5
                lea rdx,@CStr("qword")
               .endc
            .endif
            lea rsi,[rbx+8]
            .endc
        .case 3
            .endc .if ax == 'ni'
            lea rsi,[rax+8]
            .endc
        .case 5
            .if eax == 'rohs'
                lea rdx,@CStr("word")
               .endc
            .endif
        .default
            lea rsi,[rbx+8]
        .endsw
        strcpy(tempbuf, rdx)
        strcat(rax, rsi)
        strcpy(rbx, rax)
    .endw

    wordxchg(rdi, "long long",   "sqword")
    wordxchg(rdi, "__int64",     "sqword")
    wordxchg(rdi, "long",        "sdword")
    wordxchg(rdi, "int",         "sdword")
    wordxchg(rdi, "char",        "sbyte")
    wordxchg(rdi, "short",       "sword")
    wordxchg(rdi, "float",       "real4")
    wordxchg(rdi, "double",      "real8")
    wordxchg(rdi, "...",         "vararg")
    ret

strip_unsigned endp


; type [*] name

parse_protoarg proc uses rsi rdi rbx arg:string_t

    mov rdi,tokstart(rcx)

    .if ( strchr(rdi, '*') )

        mov bl,[rax+1]
        oprintf(" :ptr")
        .if ( bl == '*' )
            oprintf(" ptr")
        .endif
       .return( 1 )
    .endif

    lea rbx,[rdi+strtrim(rdi)]
    .if !_stricmp(rdi, "void")
        .return( 0 )
    .endif

    mov rbx,prevtok(rbx, rdi)
    .if ( rbx > rdi )
        dec rbx
        mov rbx,prevtokz(rbx, rdi)
    .endif
    oprintf(" :%s", rbx)
   .return( 1 )

parse_protoarg endp


; args );

parse_protoargs proc uses rsi rdi rbx args:string_t, comma:int_t

     mov rdi,rcx
     mov ebx,edx
     .if !strrchr(rdi, ')')
        .return error(rdi)
     .endif
     mov [rax],0

    .while strchr(rdi, '(')
        mov rsi,rax
        .for ( rcx = &[rax+1], edx = 1 : [rcx] : rcx++ )
            .if ( [rcx] == '(' )
                inc edx
            .elseif ( [rcx] == ')' )
                dec edx
                .break .ifz
            .endif
        .endf
        .if ( [rcx] == ')' )
            inc rcx
        .endif
        strcpy(rsi, rcx)
    .endw
    .while strstr(rdi, "const ")
        mov rsi,rax
        strcpy(rsi, &[rax+6])
    .endw

    .while rdi
        xor esi,esi
        .if strchr(rdi, ',')
            mov [rax],0
            lea rsi,[rax+1]
        .endif
        .if ( ebx )
            oprintf(",")
        .endif
        parse_protoarg(rdi)
        inc ebx
        mov rdi,rsi
    .endw
    ret

parse_protoargs endp


; name( args );

parse_proto proc uses rsi rdi rbx p:string_t

    mov rdi,rcx
    .if !strrchr(rdi, ')')
        .return error(rdi)
    .endif

    .for ( rax--, edx = 1 : rax > rdi : rax-- )
        .if ( [rax] == ')' )
            inc edx
        .elseif ( [rax] == '(' )
            dec edx
            .break .ifz
        .endif
    .endf
    .if ( [rax] != '(' )
        .return error(rdi)
    .endif

    mov [rax],0
    mov rbx,rax
    mov rsi,tokstart(&[rax+1])

    oprintf("%s proto", prevtokz(rbx, rdi))

    .ifd ( strip_unsigned(rsi) && option_v )
        oprintf(" %s", option_v)
    .elseif ( option_c )
        oprintf(" %s", option_c)
    .endif

    parse_protoargs(rsi, 0)
    oprintf("\n")
    ret

parse_proto endp


; (name)( args );

parse_callback proc uses rsi rdi p:string_t

    mov rdi,rcx
    oprintf("CALLBACK(")

    .if !strrchr(rdi, '(')
        .return error(rdi)
    .endif
    mov [rax],0
    mov rsi,tokstart(&[rax+1])
    strip_unsigned(rsi)

    .if !strrchr(rdi, ')')
        .return error(rdi)
    .endif
    oprintf("%s", prevtokz(rax, rdi))
    parse_protoargs(rsi, 1)
    oprintf(")\n")
    ret

parse_callback endp


concat_line proc uses rdi rbx buffer:string_t

    mov rdi,rcx
    .while !strrchr(rdi, ';')
        concat(rdi)
    .endw
    .return(rdi)

concat_line endp


parse_id proc uses rsi rdi rbx

    mov rdi,tokpos

    .if ( cflags & FL_ENUM )

        convert(rdi)
        oprintf("%s\n", linebuf)
       .return
    .endif

    mov rsi,strchr(rdi, ';')
    mov rbx,strchr(rdi, '(')
    .if ( rsi && rbx )
        .return parse_proto(rdi)
    .endif

    nexttok(rdi)

    .if ( !rsi && !rbx && !cl ) ; macro ?

        fgets(tempbuf, MAXLINE, srcfile)
        .if ( !rax || [rax] == 10 )

            inc curline
            .if ( option_m == 0 )
                oprintf("%s\n\n", linebuf)
            .endif
           .return
        .endif
        tokenize(concat_line(strcpy(linebuf, tempbuf)))
       .return parseline()
    .endif

    .if ( !rsi && rbx )

        .if strrchr(rdi, ')')
            .return .if ( [rax+1] == 0 )
        .endif
         ;nexttok(rdi)
        ;.return .if ( cl == '(' )
    .endif
    .if strchr(concat_line(rdi), '(')
        .return parse_proto(rdi)
    .endif
    .return error(rdi)

parse_id endp


parse_define_guide proc uses rdi

    mov rdi,tokpos
    .if strrchr(rdi, ';')
        mov [rax],0
    .else
        .if strrchr(concat_line(rdi), ';')
            mov [rax],0
        .endif
    .endif
    oprintf("%s\n", rdi)
    ret

parse_define_guide endp


; type name[, name2, ...];
; type (*name)(args);

parse_struct_member proc uses rsi rdi rbx r12 r13 r14

    mov rdi,tokpos
    mov r12d,strip_unsigned(rdi)

    .if strchr(rdi, '(')
        .if ( [tokstart(&[rax+1])] == '*' )
            .if strchr(rax, ')')
                lea rbx,[rax+1]
                mov rsi,prevtokz(rax, rdi)
                movzx eax,clevel
                dec eax
                lea ecx,[rax-23]
                oprintf("%*s%*s proc", eax, "", ecx, rsi)

                .ifd ( r12d && option_v )
                    oprintf(" %s", option_v)
                .elseif ( option_c )
                    oprintf(" %s", option_c)
                .endif
                mov rbx,tokstart(rbx)
                .if ( cl == '(' )
                    inc rbx
                .elseif strchr(rbx, '(')
                    lea rbx,[rax+1]
                .endif
                parse_protoargs(tokstart(rbx), 0)
                oprintf("\n")
               .return
            .endif
        .endif
    .endif

    lea r12,@CStr("ptr ")
    xor ebx,ebx
    xor r13,r13
    .if strchr(rdi, ',')
        mov [rax],0
    .endif
    mov r14,rax
    .if strchr(rdi, '[')
        mov [rax],0
        mov rbx,tokstart(&[rax+1])
        .if strchr(rbx, ']')
            mov [rax],0
            .if [rax+1] == '['
                mov word ptr [rax],' *'
                .if strchr(rax, ']')
                    mov [rax],0
                    .if [rax+1] == '['
                        mov word ptr [rax],' *'
                        .if strchr(rax, ']')
                            mov [rax],0
                        .endif
                    .endif
                .endif
            .endif
        .endif
        strtrim(rbx)
        lea rsi,[rdi+strtrim(rdi)-1]
    .elseif strrchr(rdi, ':')
        mov [rax],0
        lea rsi,[rax-1]
        mov r13,tokstart(&[rax+1])
        .if strchr(r13, ';')
            mov [rax],0
        .endif
    .elseif r14
        mov rsi,r14
    .else
        mov rsi,strrchr(rdi, ';')
    .endif
    mov rsi,prevtokz(rsi, rdi)

    movzx eax,clevel
    dec eax
    lea ecx,[rax-23]
    oprintf("%*s%*s ", eax, "", ecx, rsi)
    mov [rsi],0

    ; reduce type to 2: [unsigned] type [*]

    lea rax,[rdi+strtrim(rdi)]
    mov rsi,prevtok(rax, rdi)
    .if ( rsi > rdi )
        dec rax
        .if prevtok(rax, rdi) > rdi
            mov rdi,rax
        .endif
    .endif

    .if strchr(rsi, '*')
        mov [rax],0
        strtrim(rsi)
    .else
        add r12,4
    .endif

    .if ( rsi > rdi )
        mov rdi,rsi
    .endif

    .if rbx
        oprintf("%s%s %s dup(?)\n", r12, rdi, rbx)
    .elseif r13
        oprintf("%s%s : %2s ?\n", r12, rdi, r13)
    .else
        oprintf("%s%s ?\n", r12, rdi)
    .endif

    .while r14

        mov rsi,tokstart(&[r14+1])
        mov r14,strchr(rsi, ',')
        .if rax
            mov [rax],0
        .elseif strrchr(rsi, ';')
            mov [rax],0
        .endif

        xor ebx,ebx
        .if strrchr(rsi, '[')
            mov [rax],0
            lea rbx,[rax+1]
            .if strchr(rbx, ']')
                mov [rax],0
            .endif
        .endif
        strtrim(rsi)
        movzx eax,clevel
        dec eax
        lea ecx,[rax-24]
        oprintf("%*s%*s", eax, "", ecx, rsi)
        .if rbx
            oprintf("%s%s %s dup(?)\n", r12, rdi, rbx)
        .else
            oprintf("%s%s ?\n", r12, rdi)
        .endif
    .endw

    xor  eax,eax
    test r13,r13
    setnz al
    ret

parse_struct_member endp


; [typedef] <struct|union> [name] {

parse_struct proc uses rsi rdi rbx r12

    .new name[256]:char_t
    .new type:string_t = "struct"
    .new oldfilebuf:string_t = filebuf
    .new oldflags:dword = cflags

    .if ( ctoken == T_UNION )
        mov type,&@CStr("union")
    .endif

    mov rdi,tokpos
    mov rbx,nexttok(rdi)
    .if ( cl == 0 )
        concat(rdi)
        mov rbx,strstart(rbx)
    .endif
    .if !strchr(rdi, '{')
        .if !strchr(rdi, ';')
            concat(rdi)
        .endif
    .endif
    .if strchr(rdi, '{')
        mov byte ptr[rax], 0
    .endif

    xor esi,esi
    .if strchr(rbx, ';')
        mov rsi,prevtokz(rax, rbx)
        oprintf("%-23s typedef ", rsi)
        mov byte ptr [rsi],0
        .if strchr(rbx, '*')
            mov byte ptr [rax],0
            oprintf("ptr ")
        .endif
    .endif
    .if strtrim(rbx)
        mov rbx,prevtokz(&[rbx+rax-1], rbx)
    .endif
    .if ( rsi )
        oprintf("%s\n", rbx)
       .return
    .endif

    strcpy(&name, rbx)

    inc clevel
    or  cflags,FL_STRUCT or FL_STBUF
    mov filebuf,malloc(MAXBUF)
    mov rdi,linebuf

    .while 1

        .switch tokenize(getline(rdi))
        .case T_BLANK
            .endc
        .case T_ID
            concat_line(rdi)
            parse_struct_member()
            .endc
        .case T_STRUCT
            parse_struct()
            .endc
        .case T_ENDS

           .new enddir:byte = 0
            xor ebx,ebx
            .if !strrchr(rdi, ';')
                concat(rdi)
            .endif
            .if strchr(rdi, ',')
                mov byte ptr [rax],0
                lea rbx,[rax+1]
            .elseif strrchr(rdi, ';')
                inc enddir
                mov byte ptr [rax],0
                lea rbx,[rax+1]
            .endif
            mov rdi,nexttok(tokpos)

            dec clevel
            .if ( clevel )
                movzx ebx,clevel
                sub ebx,1
                oprintf("%*sends\n", ebx, "")
                strcpy(&name, rdi)
               .break
            .endif

            strtrim(rdi)
            lea rsi,name
            .if ( name )
                oprintf("%-23s ends\n", rsi)
                .if ( byte ptr [rdi] )
                    .if strcmp(rsi, rdi)
                        oprintf("%-23s typedef %s\n", rdi, rsi)
                    .endif
                .endif
            .else
                oprintf("%-23s ends\n", rdi)
                strcpy(&name, rdi)
            .endif

            .break .if !rbx
            mov rbx,strstart(rbx)
            .if !byte ptr [rbx]
                .break .if enddir
            .endif
            concat_line(rbx)

            .while strchr(rbx, ',')

                mov byte ptr [rax],0
                mov rdi,rbx
                lea rbx,[rax+1]
                mov rdi,strstart(rdi)
                .if ( [rdi] == '#' )
                    prevtok(rbx, rdi)
                    dec rax
                    .if ( [rax-1] == ' ' || [rax-1] == '*' )
                        mov [rax-1],0
                    .else
                        mov [rax],0
                        inc rax
                    .endif
                    mov r12,tempbuf
                    add r12,MAXBUF/2
                    strcpy(r12, rax)
                    tokenize(strcpy(linebuf, rdi))
                    parseline()
                    mov rdi,strstart(strcpy(rdi, r12))
                .endif
                .if strrchr(rdi, '*')
                    mov rdi,rax
                .endif
                .if ( byte ptr [rdi] == '*' )
                    oprintf("%-23s typedef ptr %s\n", &[rdi+1], rsi)
                .else
                    oprintf("%-23s typedef %s\n", rdi, rsi)
                .endif
            .endw
            .break .if !strchr(rbx, ';')

            mov byte ptr [rax],0
            mov rdi,rbx
            lea rbx,[rax+1]
            mov rdi,strstart(rdi)
            .if strrchr(rdi, '*')
                mov rdi,rax
            .endif
            .if byte ptr [rdi] == '*'
                oprintf("%-23s typedef ptr %s\n", addr [rdi+1], rsi)
            .else
                oprintf("%-23s typedef %s\n", rdi, rsi)
            .endif
            .break
        .default
            parseline()
        .endsw
    .endw
    mov rsi,filebuf
    mov filebuf,oldfilebuf
    .if ( !( oldflags & FL_STBUF) )
        and cflags,not FL_STBUF
    .endif
    lea rdi,name
    .if ( clevel == 0 )
        oprintf("%-23s %s\n%s", rdi, type, rsi)
    .else
        .if !memcmp(rdi, "DUMMY", 5)
            mov name,0
        .endif
        oprintf("%*s%s %s\n%s", ebx, "", type, rdi, rsi)
    .endif
    free(rsi)
    ret

parse_struct endp


; typedef type name;
; typedef type (name)(args);

parse_typedef proc uses rsi rdi rbx

   .new name[256]:char_t

    mov rdi,tokpos
    mov rbx,nexttok(rdi)
    .if ( cl == 0 )
        concat(rdi)
        mov rbx,tokstart(rbx)
    .endif

    .ifd ( toksize(rbx) == 4 )
        .if !memcmp(rbx, "enum", 4)
            mov tokpos,rbx
            .return parse_enum()
        .endif
    .elseif ( eax == 5 || eax == 6 )
        xor esi,esi
        .if !memcmp(rbx, "struct", 6)
            mov esi,T_STRUCT
            mov eax,6
        .elseif !memcmp(rbx, "union", 5)
            mov esi,T_UNION
            mov eax,5
        .endif
        .if esi
            mov tokpos,rbx
            mov ctoken,sil
            mov csize,eax
            .return parse_struct()
        .endif
    .endif

    strip_unsigned(concat_line(rdi))
    strrchr(rdi, ';')
    .if ( [rax-1] == ')' )
        .return parse_callback(rdi)
    .endif

    mov rsi,prevtokz(rax, rdi)
    strcpy(&name, rsi)
    mov [rsi],0
    xor ebx,ebx

    .if strchr(rdi, '*')
        mov [rax],0
        inc ebx
    .endif
    .if strtrim(rdi)
        mov rdi,prevtokz(&[rdi+rax-1], rdi)
    .endif

    lea rsi,name
    .if strcmp(rsi, rdi)
        oprintf("%-23s typedef ", rsi)
        .if ebx
            oprintf("ptr ")
        .endif
        oprintf("%s\n", rdi)
    .endif
    ret

parse_typedef endp


parse_interface proc uses rsi rdi rbx

    mov rdi,tokpos
    .return .if !strrchr(rdi, ';')

    mov [rax],0
    strcpy(tempbuf, &[prevtokz(rax, rdi)+4])
    getline(rdi)
    getline(rdi)
    .if memcmp(rdi, "#if defined(__cplusplus) && !defined(CINTERFACE)", 49)
        .return error(rdi)
    .endif
    getline(rdi)
    getline(rdi)
    .if !strrchr(rdi, '(')
        .return error(rdi)
    .endif

    inc rax
    oprintf("DEFINE_IIDX(%s, %s\n\n", tempbuf, rax)
    getline(rdi)
    oprintf(".comdef %s\n", tokstart(rdi))
    getline(rdi) ; {
    getline(rdi) ; public:

    .while 1

        mov rbx,tokstart(getline(rdi))
        .break .if ( cl ==  '}' )
        .continue .if ( cl ==  0 )

        .break .if !strchr(concat_line(rdi), '(')

        lea rbx,[rax+1]
        mov rsi,prevtokz(rax, rdi)
        oprintf("    %-19s proc", rsi)
        parse_protoargs(tokstart(rbx), 0)
        oprintf("\n")
    .endw
    oprintf("   .ends\n")
    .while memcmp(rdi, "#endif", 6)
        getline(rdi)
    .endw
    getline(rdi)
    getline(rdi)
    getline(rdi)
    ret

parse_interface endp


parse_extern proc uses rsi rdi rbx

    mov rdi,tokpos
    mov eax,csize
    mov rbx,tokstart(&[rdi+rax])
    .if ( ecx == 0 )
        concat(rdi)
        mov rbx,tokstart(rbx)
    .endif
    .if ( ecx == '"' )
        .return
    .endif
    .if !memcmp(rbx, "RPC_IF_HANDLE", 13)
        .return
    .endif

    concat_line(rdi)
    .if strchr(rdi, ')')
        lea rbx,[rax+1]
        tokstart(rbx)
        .if ( cl == '_' )
            mov word ptr [rbx],';'
        .endif
        add tokpos,7
        .return parse_id()
    .endif

    strip_unsigned(rdi)
    mov rsi,prevtokz(strrchr(rdi, ';'), rdi)
    oprintf("externdef %s:", rsi)

    mov [rsi],0
    .if strchr(rdi, '*')
        mov [rax],0
        oprintf("ptr ")
    .endif
    .if strtrim(rdi)
        mov rdi,prevtokz(&[rdi+rax-1], rdi)
    .endif
    oprintf("%s\n", rdi)
    ret

parse_extern endp


parse_inline proc uses rdi

    mov rdi,tokpos
    oprintf(";%s\n", rdi)

    .while 1

        .switch tokenize(getline(rdi))
        .case T_ENDS
            oprintf(";%s\n", rdi)
            .break
        .case T_IF
            parse_if()
            .endc
        .case T_ELSE
        .case T_UNDEF
        .case T_ENDIF
            parse_else()
            .endc
        .default
            oprintf(";%s\n", rdi)
            .endc
        .endsw
    .endw
    ret

parse_inline endp


parseline proc

    .switch ctoken
    .case T_BLANK
       .return parse_blank()
    .case T_STRUCT
    .case T_UNION
        mov clevel,0
       .return parse_struct()
    .case T_ENUM
       .return parse_enum()
    .case T_ENDS
        .return parse_ends()
    .case T_TYPEDEF
        .return parse_typedef()
    .case T_ID
        .return parse_id()
    .case T_IF
        .return parse_if()
    .case T_ELSE
    .case T_UNDEF
    .case T_ENDIF
        .return parse_else()
    .case T_ERROR
        .return parse_error()
    .case T_PRAGMA
        .return parse_pragma()
    .case T_INCLUDE
        .return parse_include()
    .case T_DEFINE
        .return parse_define()
    .case T_INTERFACE
        .return parse_interface()
    .case T_EXTERN
        .return parse_extern()
    .case T_DEFINE_GUID
        .return parse_define_guide()
    .case T_INLINE
        .return parse_inline()
    .endsw
    ret
parseline endp


; Command line options

setarg_option proc uses rsi rdi p:ptr string_t, arg:string_t, arg2:string_t

    mov rdi,rcx
    mov rsi,r8
    inc stoptions

    .for ( eax = 0, ecx = 0 : rax != [rdi] && ecx < MAXARGS : ecx++, rdi+=8 )
        .if rsi
            add rdi,8
        .endif
    .endf
    .if ( ecx == MAXARGS )
        .return errexit(rdx)
    .endif
    mov [rdi],_strdup(rdx)
    .if rsi
        mov [rdi+8],_strdup(rsi)
    .endif
    ret

setarg_option endp


getnextcmdstring proc uses rsi rdi cmdline:array_t

    .for ( rdi = rcx,
           rsi = &[rdi+string_t] : string_t ptr [rsi] : )
        movsq
    .endf
    movsq
   .return([rcx])

getnextcmdstring endp


get_nametoken proc uses rsi rdi rbx dst:string_t, string:string_t, size:int_t, file:int_t

    mov rsi,rdx ; string
    mov rdi,rcx ; dst
    mov ecx,r8d ; max
    mov al,[rsi]
    .if al == '"'

        inc rsi
        .for ( : ecx && [rsi] : ecx-- )

            mov eax,[rsi]
            .if al == '"'

                inc rsi
                .break
            .endif

            ; handle the \"" case

            .if al == '\' && ah == '"'

                inc rsi
            .endif
            movsb
        .endf

    .else

        .for ( : ecx : ecx -- )

            mov al,[rsi]
            .switch al
            .case ' '
            .case '-'
                .ends .if r9d
            .case 0
            .case 13
            .case 10
            .case 9
            .case '/'
                .break
            .endsw
            movsb
        .endf
    .endif
    mov [rdi],0
   .return(rsi)

get_nametoken endp


parse_param proc uses rsi rdi rbx cmdline:ptr string_t, buffer:string_t

    mov rsi,rcx
    mov rdi,rdx
    mov rbx,[rsi]
    mov eax,[rbx]

    .switch pascal al
    .case '?'
        exit_options()
    .case 'q'
        mov option_q,1
        mov banner,1
    .case 'n'
        mov banner,1
    .case 'm'
        mov option_m,1
    .case 'c'
        inc rbx
        mov [rsi],get_nametoken(rdi, rbx, 256, 0)
        mov option_c,_strdup(rdi)
    .case 'v'
        inc rbx
        mov [rsi],get_nametoken(rdi, rbx, 256, 0)
        mov option_v,_strdup(rdi)
    .case 'f'
        inc rbx
        mov [rsi],get_nametoken(rdi, rbx, 256, 0)
        setarg_option(&option_f, rdi, NULL)
    .case 'w'
        inc rbx
        mov [rsi],get_nametoken(rdi, rbx, 256, 0)
        setarg_option(&option_w, rdi, NULL)
    .case 's'
        inc rbx
        mov [rsi],get_nametoken(rdi, rbx, 256, 0)
        setarg_option(&option_s, rdi, NULL)
    .case 'r'
       .new param2[256]:char_t
        inc rbx
        mov [rsi],get_nametoken(rdi, rbx, 256, 0)
        mov rbx,tokstart(rax)
        .if ( cl == 0 )
            mov rbx,getnextcmdstring(rsi)
        .endif
        mov [rsi],get_nametoken(&param2, rbx, 256-1, 0)
        setarg_option(&option_r, rdi, &param2)
    .endsw
    ret

parse_param endp


read_paramfile proc uses rbx name:string_t

    .new path[_MAX_PATH]:char_t
    .new fp:ptr FILE = fopen(rcx, "rb")

    .if ( rax == NULL )
        mov fp,fopen(strcat(strcpy(&path, prgpath), name), "rb")
    .endif
    .if ( rax == NULL )
        errexit(name)
    .endif
    .new retval:ptr = NULL
    .if ( fseek( fp, 0, SEEK_END ) == 0 )

        .if ( ftell( fp ) )

            mov ebx,eax
            mov retval,malloc( &[rax+1] )
            mov byte ptr [rax+rbx],0
            rewind( fp )
            fread( retval, 1, ebx, fp )
        .endif
    .endif

    fclose(fp)
   .return( retval )

read_paramfile endp


parse_params proc uses rsi rdi rbx cmdline:ptr string_t, numargs:ptr int_t

   .new paramfile[_MAX_PATH]:char_t

    mov rsi,rcx
    mov rdi,rdx
    mov rbx,[rsi]

    .for ( : rbx : )

        mov eax,[rbx]
        .switch al
        .case 13
        .case 10
        .case 9
        .case ' '
            inc rbx
           .endc
        .case 0
            mov rbx,getnextcmdstring(rsi)
           .endc
        .case '-'
        .case '/'
            inc rbx
            mov [rsi],rbx
            parse_param(rsi, &paramfile)
            inc dword ptr [rdi]
            mov rbx,[rsi]
           .endc
        .case '@'
            inc rbx
            mov [rsi],get_nametoken(&paramfile, rbx, sizeof(paramfile)-1, 1)
            xor ebx,ebx
            .if paramfile[0]
                mov rbx,getenv(&paramfile)
            .endif
            .if !rbx
                mov rbx,read_paramfile(&paramfile)
            .endif
            .endc
        .default ; collect  file name
            mov rbx,get_nametoken(&paramfile, rbx, sizeof(paramfile) - 1, 1)
            mov curfile,_strdup(&paramfile)
            inc dword ptr [rdi]
            mov [rsi],rbx
           .return
        .endsw
    .endf
    mov [rsi],rbx
   .return(NULL)

parse_params endp


get_filename proc path:string_t

    .for ( rax = rcx : [rcx] : rcx++ )
        .if ( [rcx] == '\' )
            lea rax,[rcx+1]
        .endif
    .endf
    ret

get_filename endp


translate_module proc uses rsi rdi rbx source:string_t

    mov curfile,rcx
    mov rsi,rcx

    .if ( !fopen(rcx, "rt") )

        perror(rsi)
       .return( 1 )
    .endif
    mov srcfile,rax

    mov linebuf,malloc(MAXBUF)
    mov filebuf,malloc(MAXBUF)
    mov tempbuf,malloc(MAXBUF)

    mov rdi,rax
    .if ( strrchr(strcpy(rdi, rsi), '\') )
        inc rax
        strcpy(rdi, rax)
    .endif
    .if strrchr(rdi, '.')
        strcpy(rax, ".inc")
    .else
        strcat(rdi, ".inc")
    .endif
    .if !fopen(rdi, "wt")

        fclose(srcfile)
        perror(rdi)
       .return( 1 )
    .endif
    mov outfile,rax

    mov curline,1
    mov cflags,0
    mov clevel,0
    mov cstart,0
    mov cblank,0
    mov ercount,0

    .if ( !option_q )
        printf( " Translating: %s\n", source)
    .endif

    .if !setjump(&jmpenv)

        .while 1
            tokenize(getline(linebuf))
            parseline()
        .endw
    .endif

    fclose(srcfile)
    fclose(outfile)
    free(linebuf)
    free(filebuf)
    free(tempbuf)
   .return(ercount)

translate_module endp


strfcat proc buffer:string_t, path:string_t, file:string_t

    mov rax,rcx
    .if rdx
        .for ( : byte ptr [rdx] : r9b=[rdx], [rcx]=r9b, rdx++, rcx++ )
        .endf
    .else
        .for ( : byte ptr [rcx] : rcx++ )
        .endf
    .endif
    lea rdx,[rcx-1]
    .if rdx > rax

        mov dl,[rdx]
        .if !( dl == '\' || dl == '/' )

            mov dl,'\'
            mov [rcx],dl
            inc rcx
        .endif
    .endif
    .for ( dl=[r8] : dl : [rcx]=dl, r8++, rcx++, dl=[r8] )
    .endf
    mov [rcx],dl
    ret

strfcat endp


translate_subdir proc uses rsi rdi rbx directory:string_t, wild:string_t

  local rc, path[_MAX_PATH]:byte, h:HANDLE, ff:WIN32_FIND_DATA

    lea rsi,path
    lea rdi,ff
    lea rbx,ff.cFileName
    mov rc,0

    .ifd FindFirstFile(strfcat(rsi, directory, wild), rdi) != -1
        mov h,rax
        .repeat
            .if !( byte ptr ff.dwFileAttributes & _A_SUBDIR )
                mov rc,translate_module(strfcat(rsi, directory, rbx))
            .endif
        .until !FindNextFile(h, rdi)
        FindClose(h)
    .endif
    .return( rc )

translate_subdir endp


define EH_STACK_INVALID    0x08
define EH_NONCONTINUABLE   0x01
define EH_UNWINDING        0x02
define EH_EXIT_UNWIND      0x04
define EH_NESTED_CALL      0x10

GeneralFailure proc \
    ExceptionRecord   : PEXCEPTION_RECORD,
    EstablisherFrame  : ptr dword,
    ContextRecord     : PCONTEXT,
    DispatcherContext : LPDWORD

    .new signo:int_t = SIGTERM
    .new string:string_t = "Software termination signal from kill"

     mov eax,[rcx].EXCEPTION_RECORD.ExceptionFlags
    .switch
    .case eax & EH_UNWINDING
    .case eax & EH_EXIT_UNWIND
       .endc
    .case eax & EH_STACK_INVALID
    .case eax & EH_NONCONTINUABLE
        mov signo,SIGSEGV
        mov string,&@CStr("Segment violation")
       .endc
    .case eax & EH_NESTED_CALL
        exit(1)

    .default
        mov eax,[rcx].EXCEPTION_RECORD.ExceptionCode
        .switch eax
        .case EXCEPTION_ACCESS_VIOLATION
        .case EXCEPTION_ARRAY_BOUNDS_EXCEEDED
        .case EXCEPTION_DATATYPE_MISALIGNMENT
        .case EXCEPTION_STACK_OVERFLOW
        .case EXCEPTION_IN_PAGE_ERROR
        .case EXCEPTION_INVALID_DISPOSITION
        .case EXCEPTION_NONCONTINUABLE_EXCEPTION
            mov signo,SIGSEGV
            mov string,&@CStr("Segment violation")
           .endc
        .case EXCEPTION_SINGLE_STEP
        .case EXCEPTION_BREAKPOINT
            mov signo,SIGINT
            mov string,&@CStr("Interrupt")
           .endc
        .case EXCEPTION_FLT_DENORMAL_OPERAND
        .case EXCEPTION_FLT_DIVIDE_BY_ZERO
        .case EXCEPTION_FLT_INEXACT_RESULT
        .case EXCEPTION_FLT_INVALID_OPERATION
        .case EXCEPTION_FLT_OVERFLOW
        .case EXCEPTION_FLT_STACK_CHECK
        .case EXCEPTION_FLT_UNDERFLOW
            mov signo,SIGFPE
            mov string,&@CStr("Floating point exception")
           .endc
        .case EXCEPTION_ILLEGAL_INSTRUCTION
        .case EXCEPTION_INT_DIVIDE_BY_ZERO
        .case EXCEPTION_INT_OVERFLOW
        .case EXCEPTION_PRIV_INSTRUCTION
            mov signo,SIGILL
            mov string,&@CStr("Illegal instruction")
           .endc
        .endsw
    .endsw

    .if ( signo != SIGTERM )

        .new flags[17]:sbyte

        .for ( r11      = r8,
               r10      = rcx,
               r8d      = 0,
               rdx      = &flags,
               rax      = '00000000',
               [rdx]    = rax,
               [rdx+8]  = rax,
               [rdx+16] = r8b,
               eax      = [r11].CONTEXT.EFlags,
               ecx      = 16 : ecx : ecx-- )

            shr eax,1
            adc [rdx+rcx-1],r8b
        .endf

        printf(
            "This message is created due to unrecoverable error\n"
            "and may contain data necessary to locate it.\n"
            "\n"
            "\tException Code: %08X\n"
            "\tException Flags %08X\n"
            "\n"
            "\t  regs: RAX: %016lX R8:  %016lX\n"
            "\t\tRBX: %016lX R9:  %016lX\n"
            "\t\tRCX: %016lX R10: %016lX\n"
            "\t\tRDX: %016lX R11: %016lX\n"
            "\t\tRSI: %016lX R12: %016lX\n"
            "\t\tRDI: %016lX R13: %016lX\n"
            "\t\tRBP: %016lX R14: %016lX\n"
            "\t\tRSP: %016lX R15: %016lX\n"
            "\t\tRIP: %016lX\n\n"
            "\t     EFlags: %s\n"
            "\t\t     r n oditsz a p c\n\n",
            [r10].EXCEPTION_RECORD.ExceptionCode,
            [r10].EXCEPTION_RECORD.ExceptionFlags,
            [r11].CONTEXT._Rax, [r11].CONTEXT._R8,
            [r11].CONTEXT._Rbx, [r11].CONTEXT._R9,
            [r11].CONTEXT._Rcx, [r11].CONTEXT._R10,
            [r11].CONTEXT._Rdx, [r11].CONTEXT._R11,
            [r11].CONTEXT._Rsi, [r11].CONTEXT._R12,
            [r11].CONTEXT._Rdi, [r11].CONTEXT._R13,
            [r11].CONTEXT._Rbp, [r11].CONTEXT._R14,
            [r11].CONTEXT._Rsp, [r11].CONTEXT._R15,
            [r11].CONTEXT._Rip, &flags)

        errexit(string)
    .endif
    printf("error: %s\n", string)
    exit(0)

GeneralFailure endp


main proc frame:GeneralFailure argc:int_t, argv:array_t

    .new num_args:int_t = 0
    .new num_files:int_t = 0
    .new ff:WIN32_FIND_DATA

    lea r15,_ltype
    mov rsi,rdx
    mov rdi,[rdx]
    mov prgpath,rdi
    .if ( get_filename(rdi) > rdi )
        mov [rdi],0
    .else
        strcpy(rdi, ".\\")
    .endif
    add argv,8

    .while parse_params(argv, &num_args)

        write_logo()

        inc num_files
        mov rsi,curfile

        lea rdi,ff.cFileName
        .ifd FindFirstFile(rsi, &ff) == -1
            errexit(rsi)
        .endif
        FindClose(rax)

        .if !strchr(strcpy(rdi, rsi), '*')
            strchr(rdi, '?')
        .endif
        .if rax
            .if ( get_filename(rdi) > rdi )
                dec rax
            .endif
            mov [rax],0
            translate_subdir(rdi, get_filename(rsi))
        .else
            translate_module(rdi)
        .endif
    .endw

    .if !num_args
        write_usage()
    .elseif !num_files
        printf("error: missing source filename\n")
    .endif
    .return(0)

main endp

    end _tstart
