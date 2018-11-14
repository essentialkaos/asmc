; ATAN2QF.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include quadmath.inc

    .code

atan2qf proc vectorcall Y:XQFLOAT, X:XQFLOAT

  local y:REAL10
  local x:REAL10

    XQFLOATTOLD(y)
    XQFLOATTOLD(x, xmm1)

    fld     y
    fld     x
    fpatan
    fstp    x

    LDTOXQFLOAT(x)
    ret

atan2qf endp

    end
