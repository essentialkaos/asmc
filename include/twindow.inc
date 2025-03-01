.pragma list(push, 0)

ifndef __TWINDOW_INC
define __TWINDOW_INC

include wincon.inc
include winuser.inc

ifndef WM_MOUSEWHEEL
define WM_MOUSEWHEEL 0x020A
endif

ifndef _UNICODE

define CFTEXT   CF_TEXT

define _tlodsb  <lodsb>
define _tscasb  <scasb>
define _tstosb  <stosb>
define _tal     <al>

_tshr macro reg
    endm
_tshl macro reg
    endm

.pragma comment(lib, TWinA)

.enum BoxDrawing { ; ASCII code page 850

    U_LIGHT_HORIZONTAL          = '�',
    U_LIGHT_VERTICAL            = '�',
    U_LIGHT_DOWN_AND_RIGHT      = '�',
    U_LIGHT_DOWN_AND_LEFT       = '�',
    U_LIGHT_UP_AND_RIGHT        = '�',
    U_LIGHT_UP_AND_LEFT         = '�',
    U_LIGHT_VERTICAL_AND_RIGHT  = '�',
    U_LIGHT_VERTICAL_AND_LEFT   = '�',
    U_LIGHT_DOWN_AND_HORIZONTAL = '�',
    U_LIGHT_UP_AND_HORIZONTAL   = '�',

    U_DOUBLE_HORIZONTAL         = '�',
    U_DOUBLE_VERTICAL           = '�',
    U_DOUBLE_DOWN_AND_RIGHT     = '�',
    U_DOUBLE_DOWN_AND_LEFT      = '�',
    U_DOUBLE_UP_AND_RIGHT       = '�',
    U_DOUBLE_UP_AND_LEFT        = '�',

    U_UPPER_HALF_BLOCK          = '�', ; Block elements
    U_LOWER_HALF_BLOCK          = '�',
    U_FULL_BLOCK                = '�',
    U_LIGHT_SHADE               = '�',
    U_MEDIUM_SHADE              = '�',
    U_DARK_SHADE                = '�',

    U_BLACK_RIGHT_POINTER       = 0x10,
    U_BLACK_LEFT_POINTER        = 0x11,
    U_BLACK_UP_TRIANGLE         = 0x1E,
    U_BLACK_DOWN_TRIANGLE       = 0x1F,
    U_BULLET_OPERATOR           = 0x07,
    U_MIDDLE_DOT                = '�',

    }

else

define CFTEXT   CF_UNICODETEXT

define _tlodsb  <lodsw>
define _tscasb  <scasw>
define _tstosb  <stosw>
define _tal     <ax>

_tshr macro reg
    shr reg,1
    endm
_tshl macro reg
    shl reg,1
    endm

.pragma comment(lib, TWinW)

.enum BoxDrawing { ; Unicode

    U_LIGHT_HORIZONTAL          = 0x2500,
    U_LIGHT_VERTICAL            = 0x2502,
    U_LIGHT_DOWN_AND_RIGHT      = 0x250C,
    U_LIGHT_DOWN_AND_LEFT       = 0x2510,
    U_LIGHT_UP_AND_RIGHT        = 0x2514,
    U_LIGHT_UP_AND_LEFT         = 0x2518,
    U_LIGHT_VERTICAL_AND_RIGHT  = 0x251C,
    U_LIGHT_VERTICAL_AND_LEFT   = 0x2524,
    U_LIGHT_DOWN_AND_HORIZONTAL = 0x252C,
    U_LIGHT_UP_AND_HORIZONTAL   = 0x2534,

    U_DOUBLE_HORIZONTAL         = 0x2550,
    U_DOUBLE_VERTICAL           = 0x2551,
    U_DOUBLE_DOWN_AND_RIGHT     = 0x2554,
    U_DOUBLE_DOWN_AND_LEFT      = 0x2557,
    U_DOUBLE_UP_AND_RIGHT       = 0x255A,
    U_DOUBLE_UP_AND_LEFT        = 0x255D,

    U_LIGHT_ARC_DOWN_AND_RIGHT  = 0x256D,
    U_LIGHT_ARC_DOWN_AND_LEFT   = 0x256E,
    U_LIGHT_ARC_UP_AND_LEFT     = 0x256F,
    U_LIGHT_ARC_UP_AND_RIGHT    = 0x2570,

    U_UPPER_HALF_BLOCK          = 0x2580, ; Block elements
    U_LOWER_HALF_BLOCK          = 0x2584,
    U_FULL_BLOCK                = 0x2588,
    U_LIGHT_SHADE               = 0x2591,
    U_MEDIUM_SHADE              = 0x2592,
    U_DARK_SHADE                = 0x2593,

    U_BLACK_RIGHT_POINTER       = 0x25BA,
    U_BLACK_LEFT_POINTER        = 0x25C4,
    U_BLACK_UP_TRIANGLE         = 0x25B2,
    U_BLACK_DOWN_TRIANGLE       = 0x25BC,

    U_BULLET_OPERATOR           = 0x2219,
    U_MIDDLE_DOT                = 0x00B7,

    }

endif


.enum ColorAttrib : byte {

    FG_TITLE,     ; 0x00
    FG_FRAME,     ; 0x01
    FG_FILES,     ; 0x02
    FG_SYSTEM,    ; 0x03
    FG_HIDDEN,    ; 0x04
    FG_PBSHADE,   ; 0x05
    FG_KEYBAR,    ; 0x06
    FG_DESKTOP,   ; 0x07
    FG_INACTIVE,  ; 0x08
    FG_DIALOG,    ; 0x09
    FG_PANEL,     ; 0x0A
    FG_SUBDIR,    ; 0x0B
    FG_MENUS,     ; 0x0C
    FG_TITLEKEY,  ; 0x0D
    FG_DIALOGKEY, ; 0x0E
    FG_MENUSKEY,  ; 0x0F

    BG_DESKTOP,   ; 0x10
    BG_PANEL,     ; 0x11
    BG_DIALOG,    ; 0x12
    BG_MENUS,     ; 0x13
    BG_ERROR,     ; 0x14
    BG_TITLE,     ; 0x15
    BG_INVERSE,   ; 0x16
    BG_GRAY,      ; 0x17
    BG_PUSHBUTTON,; 0x18
    BG_INVPANEL,  ; 0x19
    BG_INVMENUS,  ; 0x1A
    BG_UNUSED1,   ; 0x1B
    BG_TEXTVIEW,  ; 0x1C
    BG_TEXTEDIT,  ; 0x1D
    FG_TEXTVIEW,  ; 0x1E
    FG_TEXTEDIT,  ; 0x1F

    COLOR_COUNT   ; 0x20
    }

.enum WindowType {

    T_NORMAL,
    T_PUSHBUTTON,
    T_RADIOBUTTON,
    T_CHECKBOX,
    T_XCELL,
    T_EDIT,
    T_MENU,
    T_XHTML,
    T_MOUSE,
    T_SCROLLUP,
    T_SCROLLDOWN,
    T_TEXTBUTTON
    }

.enum WindowFlags {

    W_ISOPEN        = 0x01,
    W_VISIBLE       = 0x02,
    W_MOVEABLE      = 0x04,
    W_SHADE         = 0x08,
    W_WNDPROC       = 0x10,
    W_CHILD         = 0x20,
    W_COLOR         = 0x40,
    W_TRANSPARENT   = 0x80,

    O_RADIO      = 0x00100, ; Active (*)
    O_CHECK      = 0x00200, ; Active [x]
    O_LIST       = 0x00400, ; Linked list item
    O_SELECT     = 0x00800, ; Select text on activation
    O_CONTROL    = 0x01000, ; Allow _CONTROL chars
    O_DEXIT      = 0x02000, ; Close dialog and return 0: Cancel
    O_PBKEY      = 0x04000, ; Return result if short key used
    O_DLGED      = 0x08000, ; dialog text -- return Left/Right
    O_GLOBAL     = 0x10000, ; Item contain global short-key table
    O_EVENT      = 0x20000, ; Item have local event handler
    O_CHILD      = 0x40000, ; Item have a child
    O_STATE      = 0x80000, ; State

    O_MODIFIED  = 0x100000, ; dialog text
    O_OVERWRITE = 0x200000, ; selected text on paste
    O_USEBEEP   = 0x400000
    }

CURSOR_NORMAL   equ 16

WM_RETURNCMD    equ WM_USER+1
WM_CHILDMSG     equ WM_USER+2
MAXSCRLINE      equ 256 ; max screen size

.pragma pack(push, 1)


.template TColor
    at          db COLOR_COUNT dup(?)
   .ends
    color_t     typedef ptr TColor

    externdef   TAttributesDefault:TColor
    externdef   TAttributesTransparent:TColor


.template TRect
    x           db ?
    y           db ?
    col         db ?
    row         db ?

    .inline Size {
        movzx   eax,[this].TRect.row
        mul     [this].TRect.col
        imul    eax,eax,CHAR_INFO
        }
    .inline Coord {
        movzx   eax,[this].TRect.row
        shl     eax,16
        mov     al,[this].TRect.col
        }
    .inline SmallRect {
        movzx   eax,[this].TRect.row
        movzx   edx,[this].TRect.y
        lea     rax,[rax+rdx-1]
        shl     edx,16
        shl     eax,16
        mov     dl,[this].TRect.x
        mov     al,[this].TRect.col
        add     al,dl
        dec     al
        shl     rax,32
        or      rax,rdx
        }
   .ends
    trect_t     typedef ptr TRect


MTRECT macro x, y, col, row
    exitm<(x or (y shl 8) or (col shl 16) or (row shl 24 ))>
    endm


TRect::Read     proto :HANDLE, :PCHAR_INFO
TRect::Write    proto :HANDLE, :PCHAR_INFO
TRect::Exchange proto :HANDLE, :PCHAR_INFO


.template TRObject
    flags       dw ? ; (WindowType-1) + WindowFlags (O_)
    count       db ?
    index       db ?
    rc          TRect <>
   .ends
    robject_t   typedef ptr TRObject


.template TResource
    MemSize     dw ?
    dialog      TRObject <>
   .ends
    resource_t  typedef ptr TResource


.template TMessage
    Next        ptr_t ?
    Message     uint_t ?
    wParam      size_t ?
    lParam      ptr_t ?
   .ends
    message_t   typedef ptr TMessage


.class TCursor

    CursorInfo  CONSOLE_CURSOR_INFO <>
    Position    COORD <>
    Handle      HANDLE ?

    TCursor     proc
    Hide        proc
    Show        proc
    Move        proc :int_t, :int_t
    Release     proc
   .ends
    cursor_t    typedef ptr TCursor


.class TEdit

    base        LPTSTR ?        ; base pointer
    flags       uint_t ?        ; config
    xpos        uint_t ?        ; window x
    ypos        uint_t ?        ; window y
    scols       uint_t ?        ; size of screen-line
    bcols       uint_t ?        ; size of buffer-line
    xoffs       uint_t ?        ; x offset on screen
    boffs       uint_t ?        ; base offset - start of screen-line
    bcount      uint_t ?        ; byte count in line (expanded)
    clrattrib   CHAR_INFO <>    ; clear attrib/char
    clip_so     uint_t ?        ; Clipboard start offset
    clip_eo     uint_t ?        ; Clipboard end offset

    TEdit       proc :ptr TWindow, :uint_t
    Release     proc
    OnSetFocus  proc :ptr TWindow
    OnLBDown    proc :ptr TWindow
    OnChar      proc :ptr TWindow, :WPARAM
   .ends
    tedit_t     typedef ptr TEdit


.template TContext
    union
     struct
      State     db ?
      Flags     db ?
      x         db ?
      y         db ?
      rc        TRect <>
     ends
     object     tedit_t ?
    ends
   .ends
    context_t   typedef ptr TContext

.pragma pack(pop)

window_t        typedef ptr TWindow

.template TClass
    Instance    window_t ?
    StdIn       HANDLE ?
    StdOut      HANDLE ?
    Message     message_t ?
    Buttons     uint_t ?
    Focus       uint_t ?
    Console     window_t ?
    ConMode     uint_t ?
    ErrMode     uint_t ?
    KeyState    uint_t ?
   .ends
    class_t     typedef ptr TClass

CALLBACK(tproc_t, :window_t, :uint_t, :size_t, :ptr_t)

.class TWindow

    rc              TRect <>
    Flags           uint_t ?
    Window          PCHAR_INFO ?
    Color           color_t ?
    Class           class_t ?
    Type            uint_t ?
    Index           uint_t ?
    WndProc         tproc_t ?
    Child           window_t ?
    Prev            window_t ?
    Cursor          cursor_t ?
    SysKey          uint_t ?
    Context         TContext <>

    TWindow         proc
    Open            proc :TRect, :uint_t
    Load            proc :resource_t
    Resource        proc :resource_t
    Release         proc

    Show            proc
    Hide            proc
    Move            proc :int_t, :int_t

    Read            proc :trect_t, :PCHAR_INFO
    Write           proc :trect_t, :PCHAR_INFO
    Exchange        proc :trect_t, :PCHAR_INFO

    SetShade        proc
    ClrShade        proc

    Clear           proc :CHAR_INFO
    GetChar         proc :int_t, :int_t
    PutFrame        proc :TRect, :int_t, :uchar_t
    PutChar         proc :int_t, :int_t, :int_t, :CHAR_INFO
    PutString       proc :int_t, :int_t, :ushort_t, :int_t, :LPTSTR, :vararg
    PutPath         proc :int_t, :int_t, :int_t, :LPTSTR
    PutCenter       proc :int_t, :int_t, :int_t, :LPTSTR
    PutTitle        proc :LPTSTR
    MessageBox      proc :int_t, :LPTSTR, :LPTSTR, :vararg

    CursorGet       proc
    CursorSet       proc
    CursorOn        proc
    CursorOff       proc
    CursorMove      proc :int_t, :int_t

    Register        proc :tproc_t
    Send            proc :uint_t, :size_t, :ptr
    Post            proc :uint_t, :size_t, :ptr
    PostQuit        proc :int_t
    DefWindowProc   proc :uint_t, :size_t, :ptr

    Child           proc :TRect, :uint_t, :uint_t
    Window          proc
    PushButton      proc :TRect, :uint_t, :LPTSTR
    GetFocus        proc
    SetFocus        proc :uint_t
    GetItem         proc :uint_t

    MoveConsole     proc :int_t, :int_t
    SetConsole      proc :int_t, :int_t
    SetMaxConsole   proc
    ConsoleSize     proc

    CGetChar        proc :int_t, :int_t
    CPutChar        proc :int_t, :int_t, :int_t, :CHAR_INFO
    CPutString      proc :int_t, :int_t, :ushort_t, :int_t, :LPTSTR, :vararg
    CPutPath        proc :int_t, :int_t, :int_t, :LPTSTR
    CPutCenter      proc :int_t, :int_t, :int_t, :LPTSTR
    CPutBackground  proc :int_t, :int_t, :int_t, :uchar_t
   .ends

endif
.pragma list(pop)
