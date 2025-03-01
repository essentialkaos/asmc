; MALLOC.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include malloc.inc
include errno.inc

public  _crtheap

    .data

    _crtheap label HANDLE
    _heap_base heap_t 0     ; address of main memory block
    _heap_free heap_t 0     ; address of free memory block

    .code

CreateHeap proto private :size_t

; Allocates memory blocks.
;
; void *malloc( size_t size );
;
malloc proc byte_count:size_t

ifndef _WIN64
    mov rcx,byte_count
endif
    mov rdx,_heap_free
    add rcx,HEAP+_GRANULARITY-1
    and cl,-(_GRANULARITY)

    .repeat

        .if ( rdx )

            .if ( [rdx].HEAP.type == _HEAP_FREE )
                ;
                ; Use a free block.
                ;
                mov rax,[rdx].HEAP.size
                .if ( rax >= rcx )

                    mov [rdx].HEAP.type,_HEAP_LOCAL

                    .ifnz

                        mov [rdx].HEAP.size,rcx
                        sub rax,rcx
                        mov [rdx+rcx].HEAP.size,rax
                        mov [rdx+rcx].HEAP.type,_HEAP_FREE
                    .endif

                    lea rax,[rdx+HEAP]
                    add rdx,[rdx].HEAP.size
                    mov _heap_free,rdx
                   .return
                .endif
            .endif

            mov eax,_amblksiz
            .if ( rcx <= rax )
                ;
                ; Find a free block.
                ;
                mov rdx,_heap_base
                xor eax,eax

                .while 1

                    add rdx,rax
                    mov rax,[rdx].HEAP.size
                    .if !rax
                        ;
                        ; Last block is zero and points to first block.
                        ;
                        mov rdx,[rdx].HEAP.prev
                        mov rdx,[rdx].HEAP.prev
                       .continue(0) .if rdx
                       .break
                    .endif

                    .continue(0)  .if ( [rdx].HEAP.type != _HEAP_FREE )
                    .continue(01) .if ( rax >= rcx )
                    .continue(0)  .if ( [rdx+rax].HEAP.type != _HEAP_FREE )
                    .repeat
                        add rax,[rdx+rax].HEAP.size
                        mov [rdx].HEAP.size,rax
                    .until ( [rdx+rax].HEAP.type != _HEAP_FREE )
                    .continue(01) .if ( rax >= rcx )
                .endw
            .endif
        .endif

        .if ( CreateHeap( rcx ) )

            .continue(0)
        .endif
    .until 1
    ret

malloc endp

; Deallocates or frees a memory block.
;
; void free( void *memblock );
;
free proc memblock:ptr

ifndef _WIN64
    mov rcx,memblock
endif
    sub rcx,HEAP
    .ifns
        ;
        ; If memblock is NULL, the pointer is ignored. Attempting to free an
        ; invalid pointer not allocated by malloc() may cause errors.
        ;
        .if ( [rcx].HEAP.type == _HEAP_ALIGNED )

            mov rcx,[rcx].HEAP.prev
        .endif

        .if ( [rcx].HEAP.type == _HEAP_LOCAL )

            xor edx,edx
            mov [rcx].HEAP.type,_HEAP_FREE ; Delete this block.

            .for ( rax = [rcx].HEAP.size : dl == [rcx+rax].HEAP.type,
                   : rax += [rcx+rax].HEAP.size, [rcx].HEAP.size = rax )
                 ;
                 ; Extend size of block if next block is free.
                 ;
            .endf
            mov _heap_free,rcx

            .if ( rdx == [rcx+rax].HEAP.size )
                ;
                ; This is the last bloc in this chain.
                ;
                mov rcx,[rcx+rax].HEAP.prev ; <= first bloc
                .if ( dl == [rcx].HEAP.type )

                    .for ( rax = [rcx].HEAP.size : dl == [rcx+rax].HEAP.type,
                           : rax += [rcx+rax].HEAP.size, [rcx].HEAP.size = rax )
                    .endf

                    .if ( rdx == [rcx+rax].HEAP.size )

                        ;
                        ; unlink the node
                        ;
                        mov rdx,[rcx].HEAP.prev
                        mov rax,[rcx].HEAP.next
                        .if rdx
                            mov [rdx].HEAP.next,rax
                        .endif
                        .if rax
                            mov [rax].HEAP.prev,rdx
                        .endif
                        mov rax,_heap_base
                        .if ( rax == rcx )
                            xor eax,eax
                            mov _heap_base,rax
                        .endif
                        mov _heap_free,rax
                        mov memblock,rcx

                        HeapFree( GetProcessHeap(), 0, memblock )
                    .endif
                .endif
            .endif
        .endif
    .endif
    ret

free endp


CreateHeap proc private uses rbx size:size_t

ifndef _WIN64
    mov ecx,size
endif
    mov ebx,_amblksiz
    sub ebx,HEAP
    .if ( rbx < rcx )
        mov rbx,rcx
    .endif
    add rbx,HEAP

    .if ( HeapAlloc( GetProcessHeap(), 0, rbx ) == NULL )

        _set_errno( ENOMEM )
       .return
    .endif

    lea rdx,[rbx-HEAP]
    xor ecx,ecx

    mov [rax].HEAP.size,rdx
    mov [rax].HEAP.type,_HEAP_FREE
    mov [rax].HEAP.next,rcx
    mov [rax].HEAP.prev,rcx
    mov [rax+rdx].HEAP.size,rcx
    mov [rax+rdx].HEAP.type,_HEAP_LOCAL
    mov [rax+rdx].HEAP.prev,rax

    mov rdx,_heap_base
    .if ( rdx )
        .while ( [rdx].HEAP.next != rcx )
            mov rdx,[rdx].HEAP.next
        .endw
        mov [rdx].HEAP.next,rax
        mov [rax].HEAP.prev,rdx
    .else
        mov _heap_base,rax
    .endif
    mov _heap_free,rax

    mov rcx,size
    mov rdx,rax
    mov rax,[rdx].HEAP.size
    .if ( rax >= rcx )
        .return
    .endif
    _set_errno( ENOMEM )
    .return( 0 )

CreateHeap endp

    end
