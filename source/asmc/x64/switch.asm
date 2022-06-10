; SWITCH.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
include string.inc
include stdio.inc
include stdlib.inc
include malloc.inc
include limits.inc

include asmc.inc
include token.inc
include hllext.inc

    .code

    .pragma warning(disable: 6004)

     option proc: private
     assume rsi:  ptr hll_item


RenderCase proc __ccall uses rsi rdi rbx hll:ptr hll_item, case:ptr hll_item, buffer:string_t

    mov rsi,rcx
    mov rbx,rdx
    mov rdi,r8
    mov rcx,[rbx].hll_item.condlines

    .if ( rcx == NULL )

        AddLineQueueX( " jmp @C%04X", [rbx].hll_item.labels[LSTART*4] )

    .elseif ( tstrchr(rcx, '.') && byte ptr [rax+1] == '.' )

        mov byte ptr [rax],0
        lea rdi,[rax+2]
        mov ecx,GetHllLabel()

        AddLineQueueX(
            " cmp %s, %s\n"
            " jb @C%04X\n"
            " cmp %s, %s\n"
            " jbe @C%04X\n"
            "@C%04X%s",
            [rsi].condlines, [rbx].hll_item.condlines,
            ecx,
            [rsi].condlines, rdi,
            [rbx].hll_item.labels[LSTART*4],
            ecx, LABELQUAL )
    .else
        AddLineQueueX(
            " cmp %s, %s\n"
            " je @C%04X",
            [rsi].condlines, [rbx].hll_item.condlines,
            [rbx].hll_item.labels[LSTART*4] )
    .endif
    ret

RenderCase endp


RenderCCMP proc __ccall uses rsi rdi rbx hll:ptr hll_item, buffer:string_t

    mov rsi,rcx
    mov rdi,rdx
    AddLineQueueX( "%s%s", rdi, LABELQUAL )
    mov rbx,[rsi].caselist
    .while rbx
        RenderCase( rsi, rbx, rdi )
        mov rbx,[rbx].hll_item.caselist
    .endw
    ret

RenderCCMP endp


    assume rcx:ptr hll_item

GetLowCount proc __ccall hll:ptr hll_item, min:int64_t, dist:int64_t

    add rdx,r8
    xor eax,eax
    mov rcx,[rcx].caselist
    .while rcx
        .ifs [rcx].flags & HLLF_TABLE && rdx >= [rcx].value
            add eax,1
        .endif
        mov rcx,[rcx].caselist
    .endw
    ret

GetLowCount endp


GetHighCount proc __ccall hll:ptr hll_item, max:int64_t, dist:int64_t

    sub rdx,r8
    xor eax,eax
    mov rcx,[rcx].caselist
    .while rcx
        .ifs [rcx].flags & HLLF_TABLE && rdx <= [rcx].value
            add eax,1
        .endif
        mov rcx,[rcx].caselist
    .endw
    ret

GetHighCount endp


SetLowCount proc __ccall hll:ptr hll_item, count:ptr int_t, min:int64_t, dist:int64_t

    add r8,r9
    xor eax,eax
    mov rcx,[rcx].caselist
    .while rcx
        .ifs [rcx].flags & HLLF_TABLE && r8 < [rcx].value

            and [rcx].flags,NOT HLLF_TABLE
            dec int_t ptr [rdx]
            inc eax
        .endif
        mov rcx,[rcx].caselist
    .endw
    mov edx,[rdx]
    ret

SetLowCount endp


SetHighCount proc __ccall hll:ptr hll_item, count:ptr int_t, max:int64_t, dist:int64_t

    sub r8,r9
    xor eax,eax
    mov rcx,[rcx].caselist
    .while rcx
        .ifs [rcx].flags & HLLF_TABLE && r8 > [rcx].value

            and [rcx].flags,NOT HLLF_TABLE
            dec int_t ptr [rdx]
            inc eax
        .endif
        mov rcx,[rcx].caselist
    .endw
    mov edx,[rdx]
    ret

SetHighCount endp


    assume rcx:nothing

GetCaseVal proc __ccall hll:ptr hll_item, val:int64_t

    mov rax,[rcx].hll_item.caselist
    .while rax

        .if [rax].hll_item.flags & HLLF_TABLE && [rax].hll_item.value == rdx

            .break
        .endif
        mov rcx,rax
        mov rax,[rax].hll_item.caselist
    .endw
    ret

GetCaseVal endp


RemoveVal proc __ccall private hll:ptr hll_item, val:int64_t

    .if GetCaseVal()

        and [rax].hll_item.flags,NOT HLLF_TABLE
        mov eax,1
    .endif
    ret

RemoveVal endp


GetCaseValue proc __ccall uses rsi rdi rbx r12 hll:ptr hll_item, tokenarray:ptr asm_tok,
        dcount:ptr uint_t, scount:ptr uint_t

  .new i:int_t, opnd:expr, size:int_t
  .new oldtok:string_t = [rdx].asm_tok.tokpos

    xor edi,edi ; dynamic count
    xor ebx,ebx ; static count

    mov rsi,hll
    mov eax,[rsi].flags
    and eax,HLLF_ARG16 or HLLF_ARG32 or HLLF_ARG64
    mov r12b,1
    .if eax == HLLF_ARG16
        inc r12b
    .elseif eax == HLLF_ARG32
        mov r12b,4
    .elseif eax == HLLF_ARG64
        mov r12b,8
    .endif

    mov rsi,[rsi].caselist

    .while rsi

        .if [rsi].flags & HLLF_NUM

            or [rsi].flags,HLLF_TABLE
            Tokenize( [rsi].condlines, 0, tokenarray, TOK_DEFAULT )
            mov ModuleInfo.token_count,eax
            mov i,0
            EvalOperand( &i, tokenarray, eax, &opnd, EXPF_NOERRMSG )
            .break .if eax != NOT_ERROR

            mov rax,opnd.llvalue
            .if r12b == 1
                movsx rax,al
            .elseif r12b == 2
                movsx rax,ax
            .elseif r12b == 4
                movsxd rax,eax
            .endif

            .if opnd.kind == EXPR_ADDR

                mov rcx,opnd.sym
                mov edx,[rcx].asym.offs
                add rax,rdx
            .endif
            mov [rsi].value,rax
            inc ebx
        .elseif [rsi].condlines

            inc edi
        .endif
        mov rsi,[rsi].caselist
    .endw

    Tokenize( oldtok, 0, tokenarray, TOK_DEFAULT )
    mov ModuleInfo.token_count,eax

    mov rax,dcount
    mov [rax],edi
    mov rax,scount
    mov [rax],ebx
    ;
    ; error A3022 : .CASE redefinition : %s(%d) : %s(%d)
    ;
    .if ebx && Parse_Pass != PASS_1

        mov rsi,hll
        mov rsi,[rsi].caselist
        mov rdi,[rsi].caselist

        .while rdi

            .if [rsi].flags & HLLF_NUM

                .if GetCaseVal( rsi, [rsi].labels )

                    mov rcx,rax
                    asmerr( 3022, [rsi].condlines, [rsi].labels,
                        [rcx].hll_item.condlines, [rcx].hll_item.labels )
                .endif
            .endif
            mov rsi,[rsi].caselist
            mov rdi,[rsi].caselist
        .endw
    .endif
    .return ebx

GetCaseValue endp


GetMaxCaseValue proc __ccall uses rsi rdi rbx hll:ptr hll_item,
        min:ptr int64_t, max:ptr int64_t, min_table:ptr int_t, max_table:ptr int_t

    mov rsi,rcx
    xor edi,edi
    mov rax,_I64_MIN
    mov rdx,_I64_MAX

    mov rsi,[rsi].caselist
    .while rsi

        .if [rsi].flags & HLLF_TABLE

            inc   edi
            mov   rcx,[rsi].value
            cmp   rcx,rax
            cmovg rax,rcx
            cmp   rcx,rdx
            cmovl rdx,rcx
        .endif
        mov rsi,[rsi].caselist
    .endw

    .if !edi
        xor eax,eax
        xor edx,edx
    .endif
    mov rbx,max
    mov rcx,min
    mov [rbx],rax
    mov [rcx],rdx

    mov rsi,hll
    mov ecx,1
    mov eax,MIN_JTABLE
    .if ( [rsi].flags & HLLF_NOTEST )

        ; v2.30 - allow small jump tables

        mov eax,1

    .elseif !( [rsi].flags & HLLF_ARGREG )

        add eax,2
        add ecx,1
        .if !( [rsi].flags & HLLF_ARG16 or HLLF_ARG32 or HLLF_ARG64 )

            add eax,1
            .if !( ModuleInfo.xflag & OPT_REGAX )

                add eax,10
            .endif
        .endif
    .endif
    mov rsi,min_table
    mov [rsi],eax
    mov rsi,max_table
    mov eax,edi
    shl eax,cl
    mov [rsi],eax

    mov rax,[rbx]
    sub rax,rdx
    mov ecx,edi
    add rax,1
    ret

GetMaxCaseValue endp


    assume rsi:ptr asm_tok

IsCaseColon proc __ccall uses rsi rdi rbx tokenarray:ptr asm_tok

    mov rsi,rcx
    xor edi,edi
    xor edx,edx

    .while [rsi].token != T_FINAL

        mov al,[rsi].token
        mov ah,[rsi-asm_tok].token
        mov ecx,[rsi-asm_tok].tokval
        .switch

          .case al == T_OP_BRACKET : inc edx : .endc
          .case al == T_CL_BRACKET : dec edx : .endc
          .case al == T_COLON

            .endc .if edx
            .endc .if ah == T_REG && ecx >= T_ES && ecx <= T_ST

            mov [rsi].token,T_FINAL
            mov rdi,rsi
            .break
        .endsw
        add rsi,asm_tok
    .endw
    .return rdi

IsCaseColon endp


    assume rbx:ptr asm_tok

RenderMultiCase proc __ccall uses rsi rdi rbx hll:ptr hll_item, i:ptr int_t, buffer:ptr char_t,
        tokenarray:ptr asm_tok

  local result:int_t, colon:token_t

    mov rbx,tokenarray
    add rbx,asm_tok
    mov rax,rbx
    mov rsi,rbx
    xor edi,edi
    mov result,edi
    mov colon,IsCaseColon( rbx )

    .while 1
        ;
        ; Split .case 1,2,3 to
        ;
        ;   .case 1
        ;   .case 2
        ;   .case 3
        ;
        mov al,[rbx].token
        .switch al

          .case T_FINAL : .break

          .case T_OP_BRACKET : inc edi : .endc
          .case T_CL_BRACKET : dec edi : .endc

          .case T_COMMA
            .endc .if edi

            mov rdi,[rbx].tokpos
            mov BYTE PTR [rdi],0
            tstrcpy( buffer, [rsi].tokpos )
            lea rsi,[rbx+asm_tok]
            mov BYTE PTR [rdi],','
            xor edi,edi

            inc result
            AddLineQueueX( " .case %s", buffer )
            mov [rbx].token,T_FINAL
        .endsw
        add rbx,asm_tok
    .endw

    mov rbx,colon
    .if rbx

        mov [rbx].token,T_COLON
    .endif

    mov eax,result
    .if eax

        AddLineQueueX( " .case %s", [rsi].tokpos )

        mov rbx,tokenarray
        xor eax,eax
        .while [rbx].token != T_FINAL

            add eax,1
            add rbx,asm_tok
        .endw
        mov rbx,i
        mov [rbx],eax

        mov rsi,hll
        assume rsi:ptr hll_item

        .if [rsi].flags & HLLF_PASCAL

            and [rsi].flags,NOT HLLF_PASCAL

            .if ModuleInfo.list

                LstWrite( LSTTYPE_DIRECTIVE, GetCurrOffset(), 0 )
            .endif
            RunLineQueue()

            or [rsi].flags,HLLF_PASCAL
        .endif
        mov eax,1
    .endif
    ret

RenderMultiCase endp


CompareMaxMin proc __ccall reg:string_t, max:int64_t, min:int64_t, around:string_t

    AddLineQueueX(
        " cmp %s,%ld\n"
        " jl  %s\n"
        " cmp %s,%ld\n"
        " jg  %s", rcx, r8, r9, rcx, rdx, r9 )
    ret

CompareMaxMin endp

;
; Move .SWITCH <arg> to [R|E]AX
;

GetSwitchArg proc __ccall uses rbx reg:int_t, flags:int_t, arg:string_t

  local buffer[64]:sbyte

    .if !( ModuleInfo.xflag & OPT_REGAX )

        AddLineQueueX( "push %r", reg )
    .endif
    GetResWName( reg, &buffer )

    mov eax,flags
    mov edx,reg
    mov rbx,arg

    .if !( eax & HLLF_ARG16 or HLLF_ARG32 or HLLF_ARG64 )
        ;
        ; BYTE value
        ;
ifndef ASMC64
        mov ecx,ModuleInfo.curr_cpu
        and ecx,P_CPU_MASK
        .if ecx >= P_386
endif
            .if eax & HLLF_ARGMEM

                AddLineQueueX( " movsx %r, byte ptr %s", edx, rbx )
            .else
                AddLineQueueX( " movsx %r, %s", edx, rbx )
            .endif
ifndef ASMC64
        .else
            .ifd tstricmp( "al", rbx )

                AddLineQueueX( " mov al, %s", rbx )
            .endif
            AddLineQueue ( " cbw" )
        .endif
endif
    .elseif eax & HLLF_ARG16
        ;
        ; WORD value
        ;
ifndef ASMC64
        .if ModuleInfo.Ofssize == USE16

            .if eax & HLLF_ARGMEM

                AddLineQueueX( " mov %r, word ptr %s", edx, rbx )
            .elseifd tstricmp( rbx, &buffer )

                AddLineQueueX( " mov %r,%s", edx, rbx )
            .endif
        .elseif eax & HLLF_ARGMEM
else
        .if eax & HLLF_ARGMEM
endif
            AddLineQueueX( " movsx %r, word ptr %s", edx, rbx )
        .else
            AddLineQueueX( " movsx %r, %s", edx, rbx )
        .endif

    .elseif eax & HLLF_ARG32
        ;
        ; DWORD value
        ;
ifndef ASMC64
        .if ModuleInfo.Ofssize == USE32
            .if eax & HLLF_ARGMEM
                AddLineQueueX( " mov %r, dword ptr %s", edx, rbx )
            .elseifd tstricmp( rbx, &buffer )
                AddLineQueueX( " mov %r, %s", edx, rbx )
            .endif
        .elseif eax & HLLF_ARGMEM
else
        .if eax & HLLF_ARGMEM
endif
            AddLineQueueX( " movsxd %r, dword ptr %s", edx, rbx )
        .else
            AddLineQueueX( " movsxd %r, %s", edx, rbx )
        .endif
    .else
        ;
        ; QWORD value
        ;
        AddLineQueueX( " mov %r, qword ptr %s", edx, rbx )
    .endif
    ret

GetSwitchArg endp


GetJumpDist proc __ccall table_type:int_t, reg:int_t, min:int64_t, table_addr:string_t, base_addr:string_t

    mov r10d,T_MOV
    mov r11d,4
    .if ( ecx == T_BYTE )
        mov r11d,1
        mov r10d,T_MOVZX
    .elseif ( ecx == T_WORD )
        mov r11d,2
        mov r10d,T_MOVZX
    .endif
    AddLineQueueX(" %r eax, %r ptr [r11+%r*%d-(%ld*%d)+(%s-%s)]", r10d, ecx, edx, r11d, r8, r11d, r9, base_addr )
    ret

GetJumpDist endp


    assume rbx:ptr hll_item

RenderSwitch proc __ccall uses rsi rdi rbx r12 r13 hll:ptr hll_item, tokenarray:ptr asm_tok,
        buffer:string_t, exit_addr:string_t

   .new lcount:uint_t           ; number of labels in table
   .new icount:uint_t           ; number of index to labels in table
   .new l_start[16]:char_t      ; current start label
   .new l_jtab[16]:char_t       ; jump table address
   .new labelx[16]:char_t       ; case labels
   .new l_base[16]:char_t = 0   ; exit jump label
   .new use_index:uchar_t
   .new table_addr:string_t = &l_jtab
   .new start_addr:string_t = &l_start
   .new base_addr:string_t = r9

    mov rsi,rcx ; hll
    mov rdi,r8  ; buffer - switch.labels[LSTART]

    ; get static case-count

    .new dynamic:uint_t      ; number of dynmaic cases
    .new static:uint_t       ; number of static const values

    .ifd ( GetCaseValue( rsi, tokenarray, &dynamic, &static ) && [rsi].flags & HLLF_NOTEST )

        ; create a small table

        add eax,MIN_JTABLE
    .endif

    .if ( ModuleInfo.xflag & OPT_NOTABLE || eax < MIN_JTABLE )
        ;
        ; Time NOTABLE/TABLE
        ;
        ; .case *   3   4       7       8       9       10      16      60
        ; NOTABLE 1401  2130    5521    5081    7681    9481    18218   158245
        ; TABLE   1521  3361    4402    6521    7201    7881    9844    68795
        ; elseif  1402  4269    5787    7096    8481    10601   22923   212888
        ;
        RenderCCMP( rsi, rdi )
       .return
    .endif

   .new table_type:int_t = T_DWORD
ifndef ASMC64
    .if ( ModuleInfo.Ofssize == USE16 )
        mov table_type,T_WORD
    .endif
endif

    tstrcpy( start_addr, rdi )

    ; flip exit to default if exist

    .new case_default:ptr hll_item = NULL

    .if ( [rsi].flags & HLLF_ELSEOCCURED )

        .for ( rax = rsi, rbx = [rsi].caselist: rbx: rax = rbx, rbx = [rbx].caselist )

            .if ( [rbx].flags & HLLF_DEFAULT )

                mov [rax].hll_item.caselist,0
                mov case_default,rbx
                GetLabelStr( [rbx].labels[LSTART*4], exit_addr )
               .break
            .endif
        .endf
    .endif

    .if ( ModuleInfo.casealign && !( [rsi].flags & HLLF_JTDATA ) )

        mov cl,ModuleInfo.casealign
        mov eax,1
        shl eax,cl
        AddLineQueueX( " align %d", eax )

    .elseif ( [rsi].flags & HLLF_NOTEST && [rsi].flags & HLLF_JTABLE )

        .if ( ModuleInfo.Ofssize == USE64 && !( [rsi].flags & HLLF_JTDATA ) )

            AddLineQueue( " align 8" )
        .endif
    .endif
    AddLineQueueX( "%s%s", start_addr, LABELQUAL )

    .if ( dynamic )

        .for ( rax = rsi, rbx = [rsi].caselist: rbx: rax = rbx, rbx = [rbx].caselist )

            .if !( [rbx].flags & HLLF_NUM )

                mov rcx,[rbx].caselist
                mov [rax].hll_item.caselist,rcx
                RenderCase( rsi, rbx, rdi )
            .endif
        .endf
    .endif

    .while ( [rsi].condlines )

        .new min:int64_t ; minimum const value
        .new max:int64_t ; maximum const value
        .new min_table:uint_t
        .new max_table:uint_t
        .new dist:int64_t = GetMaxCaseValue( rsi, &min, &max, &min_table, &max_table )
        .new tcases:uint_t = ecx ; number of cases in table
        .new ncases:uint_t = 0   ; number of cases not in table

        .break .if ( ecx < min_table )

        .for ( ebx = ecx : ebx >= min_table && max > rdx && eax > max_table : ebx = tcases )

            GetLowCount ( rsi, min, max_table )
            mov ebx,eax
            GetHighCount( rsi, max, max_table )

            .switch
            .case ebx < min_table
                .break .if !RemoveVal( rsi, min )
                sub tcases,eax
               .endc
            .case eax < min_table
                .break .if !RemoveVal( rsi, max )
                sub tcases,eax
               .endc
            .case ebx >= eax
                mov ebx,tcases
                SetLowCount( rsi, &tcases, min, max_table )
               .endc
            .default
                mov ebx,tcases
                SetHighCount( rsi, &tcases, max, max_table )
               .endc
            .endsw
            add ncases,eax

            GetMaxCaseValue( rsi, &min, &max, &min_table, &max_table )
            mov dist,rax
           .break .if ebx == tcases
        .endf

        mov eax,tcases
        .break .if eax < min_table

        mov use_index,0
        .if ( rax < dist && ModuleInfo.Ofssize == USE64 )
            inc use_index
        .endif

        ; Create the jump table lable

        .if ( [rsi].flags & HLLF_NOTEST && [rsi].flags & HLLF_JTABLE )

            tstrcpy( table_addr, start_addr )
            AddLineQueueX( "MIN%s equ %d", rax, min )
        .else
            GetLabelStr( GetHllLabel(), table_addr )
        .endif

        mov rdi,exit_addr
        .if ncases
            mov rdi,GetLabelStr( GetHllLabel(), start_addr )
        .endif
        mov rbx,[rsi].condlines
        .if !( [rsi].flags & HLLF_NOTEST )
            CompareMaxMin(rbx, max, min, rdi)
        .endif

        mov cl,ModuleInfo.Ofssize
        .if ( [rsi].flags & HLLF_NOTEST && [rsi].flags & HLLF_JTABLE )

            .if ( [rsi].flags & HLLF_JTDATA )

                AddLineQueueX(
                    ".data\n"
                    "ALIGN 4\n"
                    "DT%s label dword", table_addr )

            .elseif cl == USE64

                mov table_type,T_QWORD
            .endif

        .else

ifndef ASMC64
            .if ( cl == USE16 )

                .if !( ModuleInfo.xflag & OPT_REGAX )
                    AddLineQueue(" push ax")
                .endif
                .if [rsi].flags & HLLF_ARGREG
                    .if ModuleInfo.xflag & OPT_REGAX
                        .ifd tstricmp("ax", rbx)
                            AddLineQueueX(" mov ax, %s", rbx)
                        .endif
                        AddLineQueue(" xchg ax, bx")
                    .else
                        AddLineQueue(
                            " push bx\n"
                            " push ax" )
                        .ifd tstricmp("bx", rbx)
                            AddLineQueueX(" mov bx, %s", rbx)
                        .endif
                    .endif
                .else
                    .if !( ModuleInfo.xflag & OPT_REGAX )
                        AddLineQueue( " push bx" )
                    .endif
                    GetSwitchArg(T_AX, [rsi].flags, rbx)
                    .if ModuleInfo.xflag & OPT_REGAX
                        AddLineQueue(" xchg ax, bx")
                    .else
                        AddLineQueue(" mov bx, ax")
                    .endif
                .endif
                .if min
                    AddLineQueueX(" sub bx, %d", min)
                .endif
                AddLineQueue(" add bx, bx")
                .if ModuleInfo.xflag & OPT_REGAX
                    AddLineQueueX(
                        " mov bx, cs:[bx+%s]\n"
                        " xchg ax, bx\n"
                        " jmp ax", table_addr )
                .else
                    AddLineQueueX(
                        " mov ax, cs:[bx+%s]\n"
                        " mov bx, sp\n"
                        " mov ss:[bx+4], ax\n"
                        " pop ax\n"
                        " pop bx\n"
                        " retn", table_addr )
                .endif

            .elseif ( cl == USE32 )

                .if !( [rsi].flags & HLLF_ARGREG )

                    GetSwitchArg(T_EAX, [rsi].flags, rbx)
                    .if ( use_index )
                        .if ( dist < 256 )
                            AddLineQueueX( " movzx eax, byte ptr [eax+IT%s-(%d)]", table_addr, min )
                        .else
                            AddLineQueueX( " movzx eax, word ptr [eax*2+IT%s-(%d*2)]", table_addr, min )
                        .endif
                        .if ( ModuleInfo.xflag & OPT_REGAX )
                            AddLineQueueX( " jmp [eax*4+%s]", table_addr )
                        .else
                            AddLineQueueX( " mov eax, [eax*4+%s]", table_addr )
                        .endif
                    .elseif ( ModuleInfo.xflag & OPT_REGAX )
                        AddLineQueueX( " jmp [eax*4+%s-(%d*4)]", table_addr, min )
                    .else
                        AddLineQueueX( " mov eax, [eax*4+%s-(%d*4)]", table_addr, min )
                    .endif
                    .if !( ModuleInfo.xflag & OPT_REGAX )
                        AddLineQueue(
                            " xchg eax, [esp]\n"
                            " retn" )
                    .endif

                .elseif ( use_index )

                    .if !( ModuleInfo.xflag & OPT_REGAX )
                        AddLineQueueX( " push %s", rbx )
                    .endif
                    .if ( dist < 256 )
                        AddLineQueueX( " movzx %s, byte ptr [%s+IT%s-(%d)]",
                            rbx, rbx, table_addr, min )
                    .else
                        AddLineQueueX( " movzx %s, word ptr [%s*2+IT%s-(%d*2)]",
                            rbx, rbx, table_addr, min )
                    .endif
                    .if ( ModuleInfo.xflag & OPT_REGAX )
                        AddLineQueueX( " jmp [%s*4+%s]", rbx, table_addr )
                    .else
                        AddLineQueueX(
                            " mov %s, [%s*4+%s]\n"
                            " xchg %s, [esp]\n"
                            " retn", rbx, rbx, table_addr, rbx )
                    .endif
                .else
                    AddLineQueueX( " jmp [%s*4+%s-(%d*4)]", rbx, table_addr, min )
                .endif

            .else
endif

            .new case_offset:uint_t = 0
            .for ( r12 = [rsi].caselist: r12: r12 = [r12].hll_item.caselist )

                .if ( [r12].hll_item.flags & HLLF_TABLE )

                    .if SymFind( GetLabelStr( [r12].hll_item.labels[LSTART*4], &labelx ) )
                        mov case_offset,[rax].asym.offs
                    .endif
                    .break
                .endif
            .endf

            ;
            ; Pack jump table in pass one.
            ;
            .if ( Parse_Pass == PASS_1 && !case_default )

                add GetCurrOffset(),34
                add eax,static

            .elseif SymFind(base_addr)

                mov eax,[rax].asym.offs
            .endif

            .if ( case_offset && eax )

                sub eax,case_offset

                .if !( eax & 0xFFFFFF00 )
                    mov table_type,T_BYTE
                .elseif !( eax & 0xFFFF0000 )
                    mov table_type,T_WORD
                .endif
            .endif

            .if ( !use_index && ( [rsi].flags & ( HLLF_ARGREG or HLLF_ARG3264 ) ) && ( ModuleInfo.xflag & OPT_REGAX ) )

                mov ebx,[rsi].tokval
                .if ( ebx == T_R11 || ebx == T_R11D )
                    asmerr( 2008, "register r11 overwritten by .SWITCH" )
                .endif
                AddLineQueue( " push rax" )

                .if ( [rsi].flags & HLLF_ARG3264 )
                    ;
                    ; Sign-extend argument if minimum case value is < 0
                    ;
                    mov rax,min
                    .ifs ( rax < 0 )

                        AddLineQueueX( " movsxd rax, %r", ebx )
                        mov ebx,T_RAX
                    .else
                        mov ecx,ebx
                        lea ebx,[rbx+T_RAX-T_EAX]
                        .if ( ecx >= T_R8D )
                            lea ebx,[rcx+T_R8-T_R8D]
                        .endif
                    .endif
                .endif

                AddLineQueueX( " lea r11, %s", base_addr )
                GetJumpDist( table_type, ebx, min, table_addr, base_addr )
                AddLineQueueX(
                    " sub r11, rax\n"
                    " pop rax\n"
                    " jmp r11" )

            .else

                .if ( ModuleInfo.xflag & OPT_REGAX )

                    AddLineQueue( " push rax" )

                    mov rcx,rbx
                    mov ebx,[rsi].tokval

                    .if !( [rsi].flags & ( HLLF_ARGREG or HLLF_ARG3264 ) )

                        GetSwitchArg( T_RAX, [rsi].flags, rcx )
                        mov ebx,T_RAX

                    .elseif ( [rsi].flags & HLLF_ARG3264 )

                        mov rax,min
                        .ifs ( rax < 0 )

                            AddLineQueueX(" movsxd rax, %r", ebx)
                            mov ebx,T_RAX
                        .else
                            mov ecx,ebx
                            lea ebx,[rbx+T_RAX-T_EAX]
                            .if ( ecx >= T_R8D )
                                lea ebx,[rcx+T_R8-T_R8D]
                            .endif
                        .endif
                    .endif

                    AddLineQueueX( " lea r11, %s", base_addr )
                    mov rcx,min
                    .if ( use_index )
                        .if ( dist < 256 )
                            AddLineQueueX( " movzx eax, byte ptr [r11+%r-(%ld)+(IT%s-%s)]",
                                ebx, rcx, table_addr, base_addr )
                        .else
                            AddLineQueueX( " movzx eax, word ptr [r11+%r*2-(%ld*2)+(IT%s-%s)]",
                                ebx, rcx, table_addr, base_addr )
                        .endif
                        xor ecx,ecx
                    .endif
                    GetJumpDist( table_type, ebx, rcx, table_addr, base_addr )
                    AddLineQueue(
                        " sub r11, rax\n"
                        " pop rax\n"
                        " jmp r11" )

                .else

                    mov rcx,rbx
                    mov ebx,[rsi].tokval

                    .if !( [rsi].flags & ( HLLF_ARGREG or HLLF_ARG3264 ) )

                        GetSwitchArg( T_RAX, [rsi].flags, rcx )
                        mov ebx,T_RAX

                    .else

                        AddLineQueue(" push rax")

                        .if ( [rsi].flags & HLLF_ARG3264 )

                            mov rax,min
                            .ifs ( rax < 0 )

                                AddLineQueueX( " movsxd rax, %r", ebx )
                                mov ebx,T_RAX
                            .else
                                mov ecx,ebx
                                lea ebx,[rbx+T_RAX-T_EAX]
                                .if ( ecx >= T_R8D )
                                    lea ebx,[rcx+T_R8-T_R8D]
                                .endif
                            .endif
                        .endif
                    .endif

                    AddLineQueueX(
                        " push r11\n"
                        " lea r11, %s", base_addr )

                    mov rcx,min
                    .if ( use_index )
                        .if ( dist < 256 )
                            AddLineQueueX( " movzx eax, byte ptr [r11+%r-(%ld)+(IT%s-%s)]",
                                ebx, rcx, table_addr, base_addr )
                        .else
                            AddLineQueueX( " movzx eax, word ptr [r11+%r*2-(%ld*2)+(IT%s-%s)]",
                                ebx, rcx, table_addr, base_addr )
                        .endif
                        xor ecx,ecx
                    .endif
                    GetJumpDist( table_type, ebx, rcx, table_addr, base_addr )
                    AddLineQueue(
                        " sub r11, rax\n"
                        " mov rax, [rsp+8]\n"
                        " mov [rsp+8], r11\n"
                        " pop r11\n"
                        " retn" )
                .endif
            .endif
ifndef ASMC64
            .endif
endif

            ;
            ; Create the jump table
            ;
            .if ( table_type != T_BYTE )
                AddLineQueueX("ALIGN %r", table_type )
            .endif
            AddLineQueueX("%s%s", table_addr, LABELQUAL )
        .endif

        .if ( use_index )

            mov r12,rdi

            .for ( ebx = -1, ; offset
                   edi = -1, ; table index
                   rsi = [rsi].caselist: rsi: rsi = [rsi].caselist )

                .if ( [rsi].flags & HLLF_TABLE )

                    .break .if !SymFind(GetLabelStr([rsi].labels[LSTART*4], &labelx))

                    .if ( ebx != [rax].asym.offs )

                        mov ebx,[rax].asym.offs
                        inc edi
                    .endif
                    ;
                    ; use case->next pointer as index...
                    ;
                    mov [rsi].next,rdi
                .endif
            .endf
            inc edi
            mov lcount,edi

            mov rdi,r12

            .for ( rsi = hll, ebx = -1,
                   rsi = [rsi].caselist: rsi: rsi = [rsi].caselist )

                .if ( [rsi].flags & HLLF_TABLE && rbx != [rsi].next )

ifndef ASMC64
                    .if ( ModuleInfo.Ofssize == USE64 )
endif
                        AddLineQueueX( " %r %s-@C%04X",
                            table_type, base_addr, [rsi].labels[LSTART*4] )
ifndef ASMC64
                    .else
                        AddLineQueueX( " %r @C%04X", table_type, [rsi].labels[LSTART*4] )
                    .endif
endif
                    mov rbx,[rsi].next
                .endif
            .endf

            mov rsi,hll
ifndef ASMC64
            .if ( ModuleInfo.Ofssize == USE64 )
endif
                AddLineQueueX( " %r 0", table_type )
ifndef ASMC64
            .else
                AddLineQueueX( " %r %s", table_type, exit_addr )
            .endif
endif
            mov rax,max
            sub rax,min
            inc eax
            mov icount,eax

            mov ecx,T_BYTE
            .ifs ( eax > 256 )

ifndef ASMC64
                .if ( ModuleInfo.Ofssize == USE16 )

                    .return( asmerr(2022, 1, 2) )
                .endif
endif
                mov ecx,T_WORD
            .endif

            .new index_type:int_t = ecx

            AddLineQueueX( "IT%s label %r", table_addr, ecx )

            .for ( ebx = 0: ebx < icount: ebx++ )
                ;
                ; loop from min value
                ;
                mov rax,min
                add rax,rbx

                .if GetCaseVal( rsi, rax )
                    ;
                    ; Unlink block
                    ;
                    mov rdx,[rax].hll_item.caselist
                    mov [rcx].hll_item.caselist,rdx
                    ;
                    ; write block to table
                    ;
                    AddLineQueueX( " %r %d", index_type, [rax].hll_item.next )

                .else
                    ;
                    ; else make a jump to exit or default label
                    ;
                    AddLineQueueX( " %r %d", index_type, lcount )
                .endif
            .endf

            .if ( table_type != T_BYTE )
                AddLineQueueX( "ALIGN %r", table_type )
            .endif

        .else

            .for ( ebx = 0: rbx < dist: ebx++ )
                ;
                ; loop from min value
                ;
                mov rax,min
                add rax,rbx

                .if GetCaseVal( rsi, rax )
                    ;
                    ; Unlink block
                    ;
                    mov rdx,[rax].hll_item.caselist
                    mov [rcx].hll_item.caselist,rdx
                    ;
                    ; write block to table
                    ;
                    mov ecx,[rax].hll_item.labels[LSTART*4]
ifndef ASMC64
                    .if ( ModuleInfo.Ofssize == USE64 )
endif
                        AddLineQueueX( " %r %s-@C%04X", table_type, base_addr, ecx )
ifndef ASMC64
                    .else

                        AddLineQueueX( " %r @C%04X", table_type, ecx )
                    .endif
endif
                .else
                    ;
                    ; else make a jump to exit or default label
                    ;
ifndef ASMC64
                    .if ( ModuleInfo.Ofssize == USE64 )
endif
                        AddLineQueueX( " %r 0", table_type )
ifndef ASMC64
                    .else
                        AddLineQueueX( " %r %s", table_type, exit_addr )
                    .endif
endif
                .endif
            .endf
        .endif

        .if ( [rsi].flags & HLLF_JTDATA )

            AddLineQueue( ".code" )
        .endif

        .if ( ncases )
            ;
            ; Create the new start label
            ;
            AddLineQueueX( "%s%s", start_addr, LABELQUAL )

            .for ( rbx = [rsi].caselist: rbx: rbx = [rbx].caselist )

                or [rbx].flags,HLLF_TABLE
            .endf
        .endif
    .endw

    .for ( rbx = [rsi].caselist : rbx : rbx = [rbx].caselist )

        RenderCase( rsi, rbx, buffer )
    .endf

    .if ( case_default && [rsi].caselist )

        AddLineQueueX( " jmp %s", exit_addr )
    .endif
    ret

RenderSwitch endp


    assume rsi: ptr hll_item

RenderJTable proc __ccall uses rsi rdi rbx hll:ptr hll_item

  local l_exit[16]:sbyte, l_jtab[16]:sbyte  ; jump table address

    mov rsi,rcx
    lea rdi,l_jtab

    .if [rsi].labels[LEXIT*4] == 0
        mov [rsi].labels[LEXIT*4],GetHllLabel()
    .endif
    .if [rsi].labels[LSTARTSW*4] == 0
        mov [rsi].labels[LSTARTSW*4],GetHllLabel()
    .endif

    AddLineQueueX( "@C%04X%s", [rsi].labels[LSTARTSW*4], LABELQUAL )

    GetLabelStr( [rsi].labels[LSTART*4], rdi )
    GetLabelStr( [rsi].labels[LEXIT*4], &l_exit )

    mov ebx,[rsi].tokval

ifndef ASMC64
    mov cl,ModuleInfo.Ofssize
    .if cl == USE16

        .if ModuleInfo.xflag & OPT_REGAX
            .ifd ( ebx != T_AX )
                AddLineQueueX( " mov ax, %r", ebx )
            .endif
            AddLineQueueX(
                " xchg ax, bx\n"
                " add bx, bx\n"
                " mov bx, cs:[bx+%s]\n"
                " xchg ax, bx\n"
                " jmp ax", rdi )
        .else
            AddLineQueue(
                " push ax\n"
                " push bx\n"
                " push ax" )
            .if ( ebx != T_BX )
                AddLineQueueX( " mov bx, %r", ebx )
            .endif
            AddLineQueueX(
                " add bx, bx\n"
                " mov ax, cs:[bx+%s]\n"
                " mov bx, sp\n"
                " mov ss:[bx+4], ax\n"
                " pop ax\n"
                " pop bx\n"
                " retn", rdi )
        .endif

    .elseif cl == USE32

        .if ( [rsi].flags & HLLF_JTDATA )
            AddLineQueueX( " jmp [%r*4+DT%s-(MIN%s*4)]", ebx, rdi, rdi )
        .else
            AddLineQueueX( " jmp [%r*4+%s-(MIN%s*4)]", ebx, rdi, rdi )
        .endif

    .else
endif
        .if ( [rsi].flags & HLLF_ARG3264 )
           ;
           ; Sign-extend argument if minimum case value is < 0
           ;
           .new minsym[32]:char_t
            tsprintf(&minsym, "MIN%s", rdi )
            .if SymFind(&minsym)
                mov rcx,rax
                xor eax,eax
                .if ( [rcx].asym.value3264 < 0 )
                    inc eax
                .endif
            .endif

            mov ecx,ebx
            lea ebx,[rbx+T_RAX-T_EAX]
            .if ( ecx >= T_R8D )
                lea ebx,[rcx+T_R8-T_R8D]
            .endif
            .if ( eax )
                AddLineQueueX(" movsxd %r, %r", ebx, ecx)
            .endif
        .endif

        .if ( ModuleInfo.xflag & OPT_REGAX ) ; defualt for 64-bit

            .ifd ( ebx == T_R11 || ebx == T_R11D )
                asmerr( 2008, "register r11 overwritten by .SWITCH" )
            .endif

            AddLineQueueX(
                " lea r11, %s\n"
                " sub r11, [%r*8+r11-(MIN%s*8)+(%s-%s)]\n"
                " jmp r11", &l_exit, ebx, rdi, rdi, &l_exit )
        .else

            mov esi,T_RAX
            .if ( ebx == esi )
                mov esi,T_RDX
            .endif
            AddLineQueueX(
                " push %r\n"
                " lea  %r, %s\n"
                " sub  %r, [%r+%r*8-(MIN%s*8)+(%s-%s)]\n"
                " xchg %r, [rsp]\n"
                " retn", esi, esi, &l_exit, esi, esi, ebx, rdi, rdi, &l_exit, esi )
        .endif
ifndef ASMC64
    .endif
endif
    ret

RenderJTable endp


    assume rbx: ptr asm_tok

SwitchStart proc __ccall uses rsi rdi rbx r12 i:int_t, tokenarray:ptr asm_tok

  local rc:int_t, cmd:uint_t, buffer[MAX_LINE_LEN]:char_t
  local opnd:expr
  local brackets:byte

    mov rc,NOT_ERROR
    mov rbx,tokenarray
    lea rdi,buffer

    imul eax,i,asm_tok
    mov eax,[rbx+rax].tokval
    mov cmd,eax
    inc i

    mov rsi,ModuleInfo.HllFree
    .if !rsi
        mov rsi,LclAlloc( hll_item )
    .endif
    ExpandCStrings(tokenarray)

    xor eax,eax
    mov [rsi].labels[LSTART*4],eax  ; set by .CASE
    mov [rsi].labels[LTEST*4],eax   ; set by .CASE
    mov [rsi].labels[LEXIT*4],eax   ; set by .BREAK
    mov [rsi].labels[LSTARTSW*4],eax; set by .GOTOSW
    mov [rsi].condlines,rax
    mov [rsi].caselist,rax
    mov [rsi].cmd,HLL_SWITCH

    imul edx,i,asm_tok  ; v2.27.38: .SWITCH [NOTEST] [C|PASCAL] ...
                        ; v2.30.07: .SWITCH [JMP] [C|PASCAL] ...
    mov eax,HLLF_WHILE

    mov brackets,0
    .while ( [rbx+rdx].token == T_OP_BRACKET )

        inc i
        inc brackets
        add rdx,asm_tok
    .endw

    .if ( [rbx+rdx].tokval == T_JMP )

        inc i
        or eax,HLLF_NOTEST
    .endif

    .if ( [rbx+rdx].token == T_ID )

        mov rcx,[rbx+rdx].string_ptr
        mov ecx,[rcx]
        or  cl,0x20
        .if ( cx == 'c' )
            mov [rbx+rdx].tokval,T_CCALL
            mov [rbx+rdx].token,T_RES_ID
            mov [rbx+rdx].bytval,1
        .endif
    .endif

    .if [rbx+rdx].tokval == T_CCALL

        inc i
        add rdx,asm_tok

    .elseif [rbx+rdx].tokval == T_PASCAL

        inc i
        add rdx,asm_tok
        or eax,HLLF_PASCAL

    .elseif ModuleInfo.xflag & OPT_PASCAL

        or eax,HLLF_PASCAL
    .endif

    mov [rsi].flags,eax

    .if [rbx+rdx].token != T_FINAL

        .return .ifd ExpandHllProc(rdi, i, rbx) == ERROR

        .if BYTE PTR [rdi]

            QueueTestLines(rdi)

            ; v2.33.38 -- the result may differ from inline RETM<al>

        .endif

        imul ecx,i,asm_tok
        mov eax,[rbx+rcx].tokval
        mov [rsi].tokval,eax

        .switch eax
        .case T_R8W .. T_R15W
        .case T_AX .. T_DI
            or  [rsi].flags,HLLF_ARG16
ifndef ASMC64
            .if ModuleInfo.Ofssize == USE16
                or [rsi].flags,HLLF_ARGREG
                .if [rsi].flags & HLLF_NOTEST
                    or [rsi].flags,HLLF_JTABLE
                .endif
            .endif
endif
        .case T_SPL .. T_R15B
        .case T_AL .. T_BH
            .endc
        .case T_R8D .. T_R15D
        .case T_EAX .. T_EDI
            or  [rsi].flags,HLLF_ARG32
ifndef ASMC64
            .if ModuleInfo.Ofssize == USE32
                or [rsi].flags,HLLF_ARGREG
                .if [rsi].flags & HLLF_NOTEST
                    or [rsi].flags,HLLF_JTABLE
                    .if !( [rsi].flags & HLLF_PASCAL )
                        or [rsi].flags,HLLF_JTDATA
                    .endif
                .endif
            .endif
            .if ModuleInfo.Ofssize == USE64
endif
                or [rsi].flags,HLLF_ARG3264
                .if [rsi].flags & HLLF_NOTEST
                    or [rsi].flags,HLLF_JTABLE or HLLF_ARGREG
                .endif
ifndef ASMC64
            .endif
endif
            .endc

        .case T_RAX .. T_R15
            or  [rsi].flags,HLLF_ARG64
            .if ModuleInfo.Ofssize == USE64
                or [rsi].flags,HLLF_ARGREG
                .if [rsi].flags & HLLF_NOTEST
                    or [rsi].flags,HLLF_JTABLE
                .endif
            .endif
            .endc

        .default
            or [rsi].flags,HLLF_ARGMEM
            mov r12d,i
            EvalOperand(&i, tokenarray, ModuleInfo.token_count, &opnd, EXPF_NOERRMSG)
            mov i,r12d

            .if ( eax != ERROR )
                mov eax,8
ifndef ASMC64
                .if ( ModuleInfo.Ofssize == USE16 )
                    mov eax,2
                .elseif ( ModuleInfo.Ofssize == USE32 )
                    mov eax,4
                .endif
endif
                .if ( opnd.kind == EXPR_ADDR && opnd.mem_type != MT_EMPTY )
                    SizeFromMemtype( opnd.mem_type, opnd.Ofssize, opnd.type )
                .endif
                .if eax == 2
                    or [rsi].flags,HLLF_ARG16
                .elseif eax == 4
                    or [rsi].flags,HLLF_ARG32
                .elseif eax == 8
                    or [rsi].flags,HLLF_ARG64
                .endif
            .endif
        .endsw

        imul ecx,Token_Count,asm_tok
        .while ( brackets && [rbx+rcx-asm_tok].token == T_CL_BRACKET )
            sub ecx,asm_tok
            dec brackets
        .endw
        mov rcx,[rbx+rcx].tokpos
        imul eax,i,asm_tok
        mov rdi,[rbx+rax].tokpos
        .while ( rcx > rdi && byte ptr [rcx-1] <= ' ' )
            dec rcx
        .endw
        sub rcx,rdi
        mov rbx,rcx
        inc rcx
        LclAlloc(ecx)
        mov [rsi].condlines,rax
        mov rdx,rsi
        mov rcx,rbx
        mov rsi,rdi
        mov rdi,rax
        rep movsb
        mov rsi,rdx
        mov byte ptr [rdi],0
        mov rbx,tokenarray
    .endif

    imul eax,i,asm_tok
    .if ![rsi].flags && ( [rbx+rax].asm_tok.token != T_FINAL && rc == NOT_ERROR )

        mov rc,asmerr( 2008, [rbx+rax].asm_tok.tokpos )
    .endif

    .if rsi == ModuleInfo.HllFree
        mov rax,[rsi].next
        mov ModuleInfo.HllFree,rax
    .endif
    mov rax,ModuleInfo.HllStack
    mov [rsi].next,rax
    mov ModuleInfo.HllStack,rsi
   .return rc

SwitchStart endp


SwitchEnd proc __ccall uses rsi rdi rbx i:int_t, tokenarray:ptr asm_tok

  local rc:int_t, cmd:int_t, buffer[MAX_LINE_LEN]:char_t,
        l_exit[16]:char_t ; exit or default label

    mov rsi,ModuleInfo.HllStack
    .return asmerr(1011) .if !rsi

    mov rax,[rsi].next
    mov rcx,ModuleInfo.HllFree
    mov ModuleInfo.HllStack,rax
    mov [rsi].next,rcx
    mov ModuleInfo.HllFree,rsi
    mov rc,NOT_ERROR
    lea rdi,buffer
    mov rbx,tokenarray

    mov ecx,[rsi].cmd
    .return asmerr(1011) .if ecx != HLL_SWITCH

    inc i
    .repeat

        .break .if [rsi].labels[LTEST*4] == 0
        .if [rsi].labels[LSTART*4] == 0
            mov [rsi].labels[LSTART*4],GetHllLabel()
        .endif
        .if [rsi].labels[LEXIT*4] == 0
            mov [rsi].labels[LEXIT*4],GetHllLabel()
        .endif

        GetLabelStr([rsi].labels[LEXIT*4], &l_exit)
        GetLabelStr([rsi].labels[LSTART*4], rdi)

        mov rax,rsi
        .while ( [rax].hll_item.caselist )
            mov rax,[rax].hll_item.caselist
        .endw
        .if ( rax != rsi && !( [rax].hll_item.flags & HLLF_ENDCOCCUR ) )
            .if !( [rsi].flags & HLLF_JTDATA )
                AddLineQueueX( " jmp @C%04X", [rsi].labels[LEXIT*4] )
            .endif
        .endif

        mov cl,ModuleInfo.casealign
        .if cl
            mov eax,1
            shl eax,cl
            AddLineQueueX( "ALIGN %d", eax )
        .endif

        .if ( ![rsi].condlines )

            mov rbx,[rsi].caselist
            assume rbx:ptr hll_item

            AddLineQueueX( "%s%s", rdi, LABELQUAL )

            .while ( rbx )

                .if ( ![rbx].condlines )

                    AddLineQueueX( " jmp @C%04X", [rbx].labels[LSTART*4] )
                .elseif ( [rbx].flags & HLLF_EXPRESSION )
                    mov i,1
                    or  [rbx].flags,HLLF_WHILE
                    ExpandHllExpression( rbx, &i, tokenarray, LSTART, 1, rdi )
                .else
                    QueueTestLines( [rbx].condlines )
                .endif
                mov rbx,[rbx].caselist
            .endw

            assume rbx:ptr asm_tok
        .else

            RenderSwitch( rsi, tokenarray, rdi, &l_exit )
        .endif
    .until 1

    mov eax,[rsi].labels[LEXIT*4]
    .if eax
        AddLineQueueX( "@C%04X%s", eax, LABELQUAL )
    .endif
    .return rc

SwitchEnd endp


SwitchExit proc __ccall uses rsi rdi rbx r12 r12 r14 i:int_t, tokenarray:ptr asm_tok

  local rc:     int_t,
        cmd:    int_t,
        buff    [16]:char_t,
        buffer  [MAX_LINE_LEN]:char_t,
        gotosw: int_t,
        hll:    ptr hll_item

    mov rsi,ModuleInfo.HllStack
    mov hll,rsi

    .return asmerr(1011) .if !rsi

    ExpandCStrings(tokenarray)

    lea rdi,buffer
    mov rc,NOT_ERROR
    imul ebx,i,asm_tok
    add rbx,tokenarray
    mov eax,[rbx].tokval
    mov cmd,eax
    xor ecx,ecx     ; exit level 0,1,2,3

    .switch eax

      .case T_DOT_DEFAULT
        .return asmerr(2142) .if ( [rsi].flags & HLLF_ELSEOCCURED )
        .return asmerr(2008, [rbx].tokpos) .if ( [rbx+asm_tok].token != T_FINAL )

        or [rsi].flags,HLLF_ELSEOCCURED

      .case T_DOT_CASE

        .while rsi && [rsi].cmd != HLL_SWITCH

            mov rsi,[rsi].next
        .endw

        .return asmerr(1010, [rbx].string_ptr) .if [rsi].cmd != HLL_SWITCH

        .if [rsi].labels[LSTART*4] == 0

            ;; First case..

            mov [rsi].labels[LSTART*4],GetHllLabel()

            .if [rsi].flags & HLLF_NOTEST && [rsi].flags & HLLF_JTABLE
                RenderJTable(rsi)
            .else
                AddLineQueueX( " jmp @C%04X", eax )
            .endif

        .elseif [rsi].flags & HLLF_PASCAL

                .if [rsi].labels[LEXIT*4] == 0
                    mov [rsi].labels[LEXIT*4],GetHllLabel()
                .endif
                mov rax,rsi
                .while [rax].hll_item.caselist
                    mov rax,[rax].hll_item.caselist
                .endw
                .if ( rax != rsi && !( [rax].hll_item.flags & HLLF_ENDCOCCUR ) )
                    AddLineQueueX( " jmp @C%04X", [rsi].labels[LEXIT*4] )
                .endif
if 0
        .elseif Parse_Pass == PASS_1
                ;
                ; error A7007: .CASE without .ENDC: assumed fall through
                ;
                mov rax,rsi
                .while [rax].hll_item.caselist
                    mov rax,[rax].hll_item.caselist
                .endw

                .if ( rax != rsi && !( [rax].hll_item.flags & HLLF_ENDCOCCUR ) )
                    asmerr( 7007 )
                .endif
endif
        .endif

        ; .case <case_a> a

        .new case_name:string_t = NULL
        .if ( [rbx+asm_tok].token == T_STRING &&
              [rbx+2*asm_tok].token == T_ID &&
              [rbx+3*asm_tok].token == T_STRING )

            mov case_name,[rbx+2*asm_tok].string_ptr
            add rbx,3*asm_tok
            add i,3
        .endif

        ; .case a, b, c, ...

        .endc .if RenderMultiCase(rsi, &i, rdi, rbx)

        mov cl,ModuleInfo.casealign
        .if cl

            mov eax,1
            shl eax,cl
            AddLineQueueX( "ALIGN %d", eax )
        .endif

        inc [rsi].labels[LTEST*4]

       .new case_label:uint_t = GetHllLabel()
        AddLineQueueX( "@C%04X%s", eax, LABELQUAL )
        .if ( case_name )
            AddLineQueueX( "%s:", case_name )
        .endif

        LclAlloc( hll_item )
        mov ecx,case_label
        mov rdx,rsi
        mov rsi,rax
        mov rax,[rdx].hll_item.condlines
        mov [rsi].labels[LSTART*4],ecx
        .while [rdx].hll_item.caselist
            mov rdx,[rdx].hll_item.caselist
        .endw
        mov [rdx].hll_item.caselist,rsi

        inc i   ; skip past the .case token
        add rbx,asm_tok

        mov r12,rax ;
        mov r13,rbx ; handle .case <expression> : ...
        mov r14,rsi ;

        .for ( esi = 0 : IsCaseColon(rbx) : rbx += asm_tok, rsi = [rbx].tokpos )

            mov rbx,rax
            .if rsi
                mov rax,[rbx].tokpos
                mov BYTE PTR [rax],0
                AddLineQueue(rsi)
                mov rax,[rbx].tokpos
                mov BYTE PTR [rax],':'
            .else
                sub rax,tokenarray
                mov ecx,asm_tok
                xor edx,edx
                div ecx
                mov ModuleInfo.token_count,eax
            .endif
        .endf

        .if rsi
            AddLineQueue(rsi)
        .endif

        mov rsi,r14

        .if r12 && cmd != T_DOT_DEFAULT

            mov rbx,r13
            mov r14,rdi
            xor edi,edi

            .while 1
                movzx eax,[rbx].token
                ;
                ; .CASE BYTE PTR [reg+-*imm]
                ; .CASE ('A'+'L') SHR (8 - H_BITS / ... )
                ;
                .switch eax

                  .case T_CL_BRACKET
                    .if edi == 1

                        .if [rbx+asm_tok].token == T_FINAL

                            or [rsi].flags,HLLF_NUM
                            .break
                        .endif
                    .endif
                    sub edi,2
                  .case T_OP_BRACKET
                    inc edi
                  .case T_PERCENT   ; %
                  .case T_INSTRUCTION   ; XOR, OR, NOT,...
                  .case '+'
                  .case '-'
                  .case '*'
                  .case '/'
                    .endc

                  .case T_NUM
                  .case T_STRING
                    .if [rbx+asm_tok].token == T_FINAL

                        or [rsi].flags,HLLF_NUM
                        .break
                    .endif
                    .endc

                  .case T_STYPE ; BYTE, WORD, ...
                    .break .if [rbx+asm_tok].tokval == T_PTR
                    .gotosw(T_STRING)

                  .case T_FLOAT ; 1..3 ?
                    .break  .if [rbx+asm_tok].token == T_DOT
                    .gotosw(T_STRING)

                  .case T_UNARY_OPERATOR    ; offset x
                    .break .if [rbx].tokval != T_OFFSET
                    .gotosw(T_STRING)

                  .case T_ID
                    .if SymFind( [rbx].string_ptr )

                        .break .if [rax].asym.state != SYM_INTERNAL
                        .break .if !([rax].asym.mem_type == MT_NEAR || \
                                      [rax].asym.mem_type == MT_EMPTY)
                    .elseif Parse_Pass != PASS_1

                        .break
                    .endif
                    .gotosw(T_STRING)

                  .default
                    ; T_REG
                    ; T_OP_SQ_BRACKET
                    ; T_DIRECTIVE
                    ; T_QUESTION_MARK
                    ; T_BAD_NUM
                    ; T_DBL_COLON
                    ; T_CL_SQ_BRACKET
                    ; T_COMMA
                    ; T_COLON
                    ; T_FINAL
                    .break
                .endsw
                add rbx,asm_tok
            .endw
            mov rdi,r14
        .endif
        mov rax,r12
        mov rbx,r13

        .if cmd == T_DOT_DEFAULT

            or [rsi].flags,HLLF_DEFAULT
        .else

            .return asmerr(2008, [rbx-asm_tok].tokpos) .if ( [rbx].token == T_FINAL )

            .if !eax

                mov ebx,i
                EvaluateHllExpression( rsi, &i, tokenarray, LSTART, 1, rdi )
                mov i,ebx
                mov rc,eax
                .endc .if eax == ERROR

            .else

                imul eax,ModuleInfo.token_count,asm_tok
                add rax,tokenarray
                mov rax,[rax].asm_tok.tokpos
                sub rax,[rbx].tokpos
                mov WORD PTR [rdi+rax],0
                tmemcpy(rdi, [rbx].tokpos, eax)
            .endif

            mov [rsi].condlines,LclDup( rdi )
        .endif

        mov eax,ModuleInfo.token_count
        mov i,eax
        .endc

      .case T_DOT_ENDC

        .for ( : rsi, [rsi].cmd != HLL_SWITCH : rsi = [rsi].next )

        .endf

        .for ( : rsi, ecx : ecx-- )
            .for ( rsi = [rsi].next: rsi, [rsi].cmd != HLL_SWITCH: rsi = [rsi].next )

            .endf
        .endf
        .return asmerr(1011) .if !rsi

        .if [rsi].labels[LEXIT*4] == 0
            mov [rsi].labels[LEXIT*4],GetHllLabel()
        .endif
        mov ecx,LEXIT
        .if cmd != T_DOT_ENDC
            mov ecx,LSTART
        .endif

        inc i
        add rbx,asm_tok
        mov gotosw,0

        .if ( ecx == LSTART && [rbx].token == T_OP_BRACKET )

            ;; .gotosw([n:]<text>)

            .if ( [rbx+asm_tok].token != T_FINAL && [rbx+2*asm_tok].token == T_COLON )

                add i,2
                add rbx,2*asm_tok
            .endif
            mov rax,[rbx+asm_tok].tokpos

            .for ( i++, rbx += asm_tok, ecx = 1 : [rbx].token != T_FINAL : i++, rbx += asm_tok )

                .if ( [rbx].token == T_OP_BRACKET )
                    inc ecx
                .elseif ( [rbx].token == T_CL_BRACKET )
                    dec ecx
                   .break .ifz
                .endif
            .endf
            .endc .if ( [rbx].token != T_CL_BRACKET )

            inc i
            add rbx,asm_tok

            .repeat

                .break .if ( [rbx-2*asm_tok].token == T_OP_BRACKET )   ; .gotosw()
                .break .if ( [rbx-2*asm_tok].token == T_COLON )        ; .gotosw(n:)

                ; get size of string

                mov rcx,[rbx-asm_tok].tokpos
                sub rcx,rax
                .break .ifz

                .endc .if ecx > MAX_LINE_LEN - 32

                ; copy string

                mov r12,rsi
                mov r13,rcx
                tmemcpy(rdi, rax, ecx)
                lea rcx,[r13+rax]
                mov byte ptr [rcx],0
                .for ( rcx-- : rcx > rax && byte ptr [rcx] <= ' ' : rcx-- )

                    mov byte ptr [rcx],0
                .endf

                ; find the string

                .for ( rsi = [rsi].caselist : rsi : rsi = [rsi].caselist )
                    .if ( [rsi].condlines )
                        .ifd !tstrcmp(rdi, [rsi].condlines)

                            mov ecx,[rsi].labels[LSTART*4]
                            .break
                        .endif
                    .endif
                .endf
                mov rax,rsi
                mov rsi,r12

                .if rax

                    mov edx,[rsi].labels[LSTART*4]
                    mov [rsi].labels[LSTART*4],ecx
                    mov gotosw,edx

                .elseif [rsi].condlines

                    ; -- this overwrites the switch argument

                    AddLineQueueX(" mov %s, %s", [rsi].condlines, rdi)

                    mov eax,[rsi].labels[LSTARTSW*4]
                    .if ( eax )

                        mov edx,[rsi].labels[LSTART*4]
                        mov [rsi].labels[LSTART*4],eax
                        mov gotosw,edx
                    .endif
                .endif

            .until 1
            mov ecx,LSTART

        .elseif ( ecx == LSTART && [rsi].labels[LSTARTSW*4] )

            mov eax,[rsi].labels[LSTARTSW*4]
            mov edx,[rsi].labels[LSTART*4]
            mov [rsi].labels[LSTART*4],eax
            mov gotosw,edx
        .endif

        HllContinueIf(rsi, &i, tokenarray, ecx, hll, 1)
        .if gotosw
            mov [rsi].labels[LSTART*4],gotosw
        .endif
        .endc

      .case T_DOT_GOTOSW

        .if ( [rbx+asm_tok].token == T_OP_BRACKET && [rbx+3*asm_tok].token == T_COLON )

            ; .gotosw(n:

            mov rax,[rbx+2*asm_tok].string_ptr
            mov al,[rax]

            .if ( al >= '0' && al <= '9' )

                sub al,'0'
                movzx ecx,al
            .endif
        .endif
        .gotosw(T_DOT_ENDC)
    .endsw

    imul ebx,i,asm_tok
    add rbx,tokenarray
    .if [rbx].token != T_FINAL && rc == NOT_ERROR

        asmerr(2008, [rbx].tokpos)
        mov rc,ERROR
    .endif
    mov eax,rc
    ret

SwitchExit endp


    option proc: public

SwitchDirective proc __ccall uses rbx i:int_t, tokenarray:ptr asm_tok

    imul eax,i,asm_tok
    add rax,tokenarray
    mov eax,[rax].asm_tok.tokval
    xor ebx,ebx

    .switch eax
      .case T_DOT_CASE
      .case T_DOT_GOTOSW
      .case T_DOT_DEFAULT
      .case T_DOT_ENDC
        mov ebx,SwitchExit(ecx, rdx)
        .endc
      .case T_DOT_ENDSW
        mov ebx,SwitchEnd(ecx, rdx)
        .endc
      .case T_DOT_SWITCH
        mov ebx,SwitchStart(ecx, rdx)
        .endc
    .endsw

    .if ModuleInfo.list
        LstWrite( LSTTYPE_DIRECTIVE, GetCurrOffset(), 0 )
    .endif
    .if ModuleInfo.line_queue.head
        RunLineQueue()
    .endif
    .return ebx

SwitchDirective endp

    END
