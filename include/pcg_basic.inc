;;
;; PCG Random Number Generation for C.
;;
;; Copyright 2014 Melissa O'Neill <oneill@pcg-random.org>
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;
;; For additional information about the PCG random number generation scheme,
;; including its license and other licensing options, visit
;;
;;     http://www.pcg-random.org
;;

;;
;; This code is derived from the full C implementation, which is in turn
;; derived from the canonical C++ PCG implementation. The C++ version
;; has many additional features and is preferable if you can use C++ in
;; your project.
;;

ifndef PCG_BASIC_H_INCLUDED
define PCG_BASIC_H_INCLUDED

include libc.inc
include stdint.inc
includelib pcg32.lib

pcg_state_setseq_64 struct
    state   uint64_t ?
    rngseq  uint64_t ?
pcg_state_setseq_64 ends

pcg32_random_t typedef pcg_state_setseq_64

PCG32_INITSTATE     equ 0x853c49e6748fea9b
PCG32_INITSEQ       equ 0xda3e39cb94b95bdb

PCG32_INITIALIZER   equ <{ PCG32_INITSTATE, PCG32_INITSEQ }>

pcg32_srandom       proto initstate:uint64_t, initseq:uint64_t
pcg32_srandom_r     proto rng:ptr pcg32_random_t, initstate:uint64_t, initseq:uint64_t
pcg32_random        proto
pcg32_random_r      proto rng:ptr pcg32_random_t
pcg32_boundedrand   proto _bound:uint32_t
pcg32_boundedrand_r proto rng:ptr pcg32_random_t, _bound:uint32_t

ifdef _WIN64

RAND_STATE  = PCG32_INITSTATE
RAND_SEQ    = PCG32_INITSEQ

__pcg32_srandom macro initstate, initseq
    RAND_STATE = initstate
    RAND_SEQ   = initseq
    exitm<>
    endm

__pcg32_random64 macro

  local r, t, x

    t = RAND_STATE
    r = ( ( ( t sar 18 ) xor t ) sar 27 )
    x = t shr 59
    t = r shr x
    r = r shl ( ( 0 - x ) and 63 )
    r = r or t

    RAND_STATE = RAND_STATE * 6364136223846793005 + RAND_SEQ

    exitm<r>
    endm

__pcg32_random macro

  local retval

    retval = __pcg32_random64() and 0xFFFFFFFF

    exitm<retval>
    endm

__pcg32_randomf macro

  local retval, rand

%   rand textequ <@CatStr(%(__pcg32_random()), <.0>)>
    ifidn <rand>,<.0>
        retval = 0.0
    elseifidn <rand>,<-.0>
        retval = -0.0
    else
        retval = rand
    endif
    exitm<retval>
    endm

__pcg32_randomf64 macro

  local retval, rand

%   rand textequ <@CatStr(%(__pcg32_random64()), <.0>)>
%   ifidn <rand>,<.0>
        retval = 0.0
%   elseifidn <rand>,<-.0>
        retval = -0.0
    else
        retval = rand
    endif
    exitm<retval>
    endm

__pcg32_boundedrand macro n

  local retval

    retval = __pcg32_random64()
    while retval lt n
        retval = __pcg32_random64()
        endm

    exitm<(retval mod n)>
    endm

__pcg32_randb macro
    exitm<__pcg32_boundedrand(256)>
    endm

__pcg32_randw macro
    exitm<__pcg32_boundedrand(256*256)>
    endm

__pcg32_randd macro
    exitm<__pcg32_random()>
    endm

__pcg32_randq macro
    exitm<__pcg32_random64()>
    endm

.template pcg32

    state   uint64_t ?
    rngseq  uint64_t ?

    .inline pcg32 :vararg {
        mov rax,0x853c49e6748fea9b + @SubStr(%@Time,7,2)
        mov this.state,rax
        mov rax,0xda3e39cb94b95bdb
        mov this.rngseq,rax
        }

    .inline random :vararg {

        mov r8,this.state
        mov rax,6364136223846793005
        mul r8
        add rax,this.rngseq
        mov this.state,rax

        mov rax,r8
        sar rax,18
        xor rax,r8
        sar rax,27

        mov rcx,r8
        shr rcx,59
        mov rdx,rax
        shr rdx,cl
        neg ecx
        and ecx,31
        shl eax,cl
        or  eax,edx
        }

    .inline boundedrand :uint32_t, :vararg {

        mov eax,edx
        neg eax
        mov r9d,edx
        xor edx,edx
        div r9d
        mov r11d,edx

        .for (::)

            this.random()

            .continue(0) .if ( eax < r11d )

            xor edx,edx
            div r9d
            mov eax,edx

            .break
        .endf
        }
    .ends

endif
endif
