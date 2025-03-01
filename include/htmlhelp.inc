ifndef __HTMLHELP_H__
define __HTMLHELP_H__

include winapifamily.inc

if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)

if _MSC_VER LT 1200
ifndef _WIN64
define DWORD_PTR DWORD
endif
endif

define HH_DISPLAY_TOPIC	       0x0000
define HH_HELP_FINDER	       0x0000
define HH_DISPLAY_TOC	       0x0001
define HH_DISPLAY_INDEX	       0x0002
define HH_DISPLAY_SEARCH       0x0003
define HH_SET_WIN_TYPE	       0x0004
define HH_GET_WIN_TYPE	       0x0005
define HH_GET_WIN_HANDLE       0x0006
define HH_ENUM_INFO_TYPE       0x0007
define HH_SET_INFO_TYPE	       0x0008
define HH_SYNC		       0x0009
define HH_RESERVED1	       0x000A
define HH_RESERVED2	       0x000B
define HH_RESERVED3	       0x000C
define HH_KEYWORD_LOOKUP       0x000D
define HH_DISPLAY_TEXT_POPUP   0x000E
define HH_HELP_CONTEXT	       0x000F
define HH_TP_HELP_CONTEXTMENU  0x0010
define HH_TP_HELP_WM_HELP      0x0011
define HH_CLOSE_ALL	       0x0012
define HH_ALINK_LOOKUP	       0x0013
define HH_GET_LAST_ERROR       0x0014
define HH_ENUM_CATEGORY	       0x0015
define HH_ENUM_CATEGORY_IT     0x0016
define HH_RESET_IT_FILTER      0x0017
define HH_SET_INCLUSIVE_FILTER 0x0018
define HH_SET_EXCLUSIVE_FILTER 0x0019
define HH_INITIALIZE	       0x001C
define HH_UNINITIALIZE	       0x001D
define HH_SET_QUERYSERVICE     0x001E
define HH_PRETRANSLATEMESSAGE  0x00fd
define HH_SET_GLOBAL_PROPERTY  0x00fc
define HH_SAFE_DISPLAY_TOPIC   0x0020

HHWIN_PROP_TAB_AUTOHIDESHOW equ (1 SHL 0)
HHWIN_PROP_ONTOP	equ (1 SHL 1)
HHWIN_PROP_NOTITLEBAR	equ (1 SHL 2)
HHWIN_PROP_NODEF_STYLES equ (1 SHL 3)
HHWIN_PROP_NODEF_EXSTYLES equ (1 SHL 4)
HHWIN_PROP_TRI_PANE	equ (1 SHL 5)
HHWIN_PROP_NOTB_TEXT	equ (1 SHL 6)
HHWIN_PROP_POST_QUIT	equ (1 SHL 7)
HHWIN_PROP_AUTO_SYNC	equ (1 SHL 8)
HHWIN_PROP_TRACKING	equ (1 SHL 9)
HHWIN_PROP_TAB_SEARCH	equ (1 SHL 10)
HHWIN_PROP_TAB_HISTORY	equ (1 SHL 11)
HHWIN_PROP_TAB_FAVORITES equ (1 SHL 12)
HHWIN_PROP_CHANGE_TITLE equ (1 SHL 13)
HHWIN_PROP_NAV_ONLY_WIN equ (1 SHL 14)
HHWIN_PROP_NO_TOOLBAR	equ (1 SHL 15)
HHWIN_PROP_MENU		equ (1 SHL 16)
HHWIN_PROP_TAB_ADVSEARCH equ (1 SHL 17)
HHWIN_PROP_USER_POS	equ (1 SHL 18)
HHWIN_PROP_TAB_CUSTOM1	equ (1 SHL 19)
HHWIN_PROP_TAB_CUSTOM2	equ (1 SHL 20)
HHWIN_PROP_TAB_CUSTOM3	equ (1 SHL 21)
HHWIN_PROP_TAB_CUSTOM4	equ (1 SHL 22)
HHWIN_PROP_TAB_CUSTOM5	equ (1 SHL 23)
HHWIN_PROP_TAB_CUSTOM6	equ (1 SHL 24)
HHWIN_PROP_TAB_CUSTOM7	equ (1 SHL 25)
HHWIN_PROP_TAB_CUSTOM8	equ (1 SHL 26)
HHWIN_PROP_TAB_CUSTOM9	equ (1 SHL 27)
HHWIN_TB_MARGIN		equ (1 SHL 28)

HHWIN_PARAM_PROPERTIES	equ (1 SHL 1)
HHWIN_PARAM_STYLES	equ (1 SHL 2)
HHWIN_PARAM_EXSTYLES	equ (1 SHL 3)
HHWIN_PARAM_RECT	equ (1 SHL 4)
HHWIN_PARAM_NAV_WIDTH	equ (1 SHL 5)
HHWIN_PARAM_SHOWSTATE	equ (1 SHL 6)
HHWIN_PARAM_INFOTYPES	equ (1 SHL 7)
HHWIN_PARAM_TB_FLAGS	equ (1 SHL 8)
HHWIN_PARAM_EXPANSION	equ (1 SHL 9)
HHWIN_PARAM_TABPOS	equ (1 SHL 10)
HHWIN_PARAM_TABORDER	equ (1 SHL 11)
HHWIN_PARAM_HISTORY_COUNT equ (1 SHL 12)
HHWIN_PARAM_CUR_TAB	equ (1 SHL 13)

HHWIN_BUTTON_EXPAND	equ (1 SHL 1)
HHWIN_BUTTON_BACK	equ (1 SHL 2)
HHWIN_BUTTON_FORWARD	equ (1 SHL 3)
HHWIN_BUTTON_STOP	equ (1 SHL 4)
HHWIN_BUTTON_REFRESH	equ (1 SHL 5)
HHWIN_BUTTON_HOME	equ (1 SHL 6)
HHWIN_BUTTON_BROWSE_FWD equ (1 SHL 7)
HHWIN_BUTTON_BROWSE_BCK equ (1 SHL 8)
HHWIN_BUTTON_NOTES	equ (1 SHL 9)
HHWIN_BUTTON_CONTENTS	equ (1 SHL 10)
HHWIN_BUTTON_SYNC	equ (1 SHL 11)
HHWIN_BUTTON_OPTIONS	equ (1 SHL 12)
HHWIN_BUTTON_PRINT	equ (1 SHL 13)
HHWIN_BUTTON_INDEX	equ (1 SHL 14)
HHWIN_BUTTON_SEARCH	equ (1 SHL 15)
HHWIN_BUTTON_HISTORY	equ (1 SHL 16)
HHWIN_BUTTON_FAVORITES	equ (1 SHL 17)
HHWIN_BUTTON_JUMP1	equ (1 SHL 18)
HHWIN_BUTTON_JUMP2	equ (1 SHL 19)
HHWIN_BUTTON_ZOOM	equ (1 SHL 20)
HHWIN_BUTTON_TOC_NEXT	equ (1 SHL 21)
HHWIN_BUTTON_TOC_PREV	equ (1 SHL 22)

define HHWIN_DEF_BUTTONS ( HHWIN_BUTTON_EXPAND or HHWIN_BUTTON_BACK or HHWIN_BUTTON_OPTIONS or HHWIN_BUTTON_PRINT )

define IDTB_EXPAND	       200
define IDTB_CONTRACT	       201
define IDTB_STOP	       202
define IDTB_REFRESH	       203
define IDTB_BACK	       204
define IDTB_HOME	       205
define IDTB_SYNC	       206
define IDTB_PRINT	       207
define IDTB_OPTIONS	       208
define IDTB_FORWARD	       209
define IDTB_NOTES	       210
define IDTB_BROWSE_FWD	       211
define IDTB_BROWSE_BACK	       212
define IDTB_CONTENTS	       213
define IDTB_INDEX	       214
define IDTB_SEARCH	       215
define IDTB_HISTORY	       216
define IDTB_FAVORITES	       217
define IDTB_JUMP1	       218
define IDTB_JUMP2	       219
define IDTB_CUSTOMIZE	       221
define IDTB_ZOOM	       222
define IDTB_TOC_NEXT	       223
define IDTB_TOC_PREV	       224


HHN_FIRST		equ (0-860)
HHN_LAST		equ (0-879)

HHN_NAVCOMPLETE		equ (HHN_FIRST-0)
HHN_TRACK		equ (HHN_FIRST-1)
HHN_WINDOW_CREATE	equ (HHN_FIRST-2)

HHN_NOTIFY		STRUC
hdr			NMHDR <>
pszUrl			PCSTR ?
HHN_NOTIFY		ENDS

HH_POPUP		STRUC
cbStruct		SINT ?
hinst			HINSTANCE ?
idString		UINT ?
pszText			LPCTSTR ?
pt			POINT <>
clrForeground		COLORREF ?
clrBackground		COLORREF ?
rcMargins		RECT <>
pszFont			LPCTSTR ?
HH_POPUP		ENDS

HH_AKLINK		STRUC
cbStruct		SINT ?
fReserved		BOOL ?
pszKeywords		LPCTSTR ?
pszUrl			LPCTSTR ?
pszMsgText		LPCTSTR ?
pszMsgTitle		LPCTSTR ?
pszWindow		LPCTSTR ?
fIndexOnFail		BOOL ?
HH_AKLINK		ENDS

.enum {
    HHWIN_NAVTYPE_TOC,
    HHWIN_NAVTYPE_INDEX,
    HHWIN_NAVTYPE_SEARCH,
    HHWIN_NAVTYPE_FAVORITES,
    HHWIN_NAVTYPE_HISTORY,
    HHWIN_NAVTYPE_AUTHOR,
    HHWIN_NAVTYPE_CUSTOM_FIRST = 11
    }

.enum {
    IT_INCLUSIVE,
    IT_EXCLUSIVE,
    IT_HIDDEN,
    }

HH_ENUM_IT		STRUC
cbStruct		SINT ?
iType			SINT ?
pszCatName		LPCSTR ?
pszITName		LPCSTR ?
pszITDescription	LPCSTR ?
HH_ENUM_IT		ENDS
PHH_ENUM_IT		typedef ptr HH_ENUM_IT

HH_ENUM_CAT		STRUC
cbStruct		SINT ?
pszCatName		LPCSTR ?
pszCatDescription	LPCSTR ?
HH_ENUM_CAT		ENDS
PHH_ENUM_CAT		typedef ptr HH_ENUM_CAT

HH_SET_INFOTYPE		STRUC
cbStruct		SINT ?
pszCatName		LPCSTR ?
pszInfoTypeName		LPCSTR ?
HH_SET_INFOTYPE		ENDS
PHH_SET_INFOTYPE	typedef ptr HH_SET_INFOTYPE

HH_INFOTYPE		typedef DWORD
PHH_INFOTYPE		typedef ptr HH_INFOTYPE

.enum {
    HHWIN_NAVTAB_TOP,
    HHWIN_NAVTAB_LEFT,
    HHWIN_NAVTAB_BOTTOM,
    }

define HH_MAX_TABS 19

.enum {
    HH_TAB_CONTENTS,
    HH_TAB_INDEX,
    HH_TAB_SEARCH,
    HH_TAB_FAVORITES,
    HH_TAB_HISTORY,
    HH_TAB_AUTHOR,
    HH_TAB_CUSTOM_FIRST = 11,
    HH_TAB_CUSTOM_LAST = HH_MAX_TABS
    }

HH_MAX_TABS_CUSTOM	equ (HH_TAB_CUSTOM_LAST - HH_TAB_CUSTOM_FIRST + 1)


HH_FTS_DEFAULT_PROXIMITY equ (-1)

HH_FTS_QUERY		STRUC
cbStruct		SINT ?
fUniCodeStrings		BOOL ?
pszSearchQuery		LPCTSTR ?
iProximity		LONG ?
fStemmedSearch		BOOL ?
fTitleOnly		BOOL ?
fExecute		BOOL ?
pszWindow		LPCTSTR ?
HH_FTS_QUERY		ENDS


HH_WINTYPE		STRUC
cbStruct		SINT ?
fUniCodeStrings		BOOL ?
pszType			LPCTSTR ?
fsValidMembers		dd ?
fsWinProperties		dd ?
pszCaption		LPCTSTR ?
dwStyles		dd ?
dwExStyles		dd ?
rcWindowPos		RECT <>
nShowState		SINT ?
hwndHelp		HWND ?
hwndCaller		HWND ?
paInfoTypes		ptr HH_INFOTYPE ?
hwndToolBar		HWND ?
hwndNavigation		HWND ?
hwndHTML		HWND ?
iNavWidth		SINT ?
rcHTML			RECT <>
pszToc			LPCTSTR ?
pszIndex		LPCTSTR ?
pszFile			LPCTSTR ?
pszHome			LPCTSTR ?
fsToolBarFlags		dd ?
fNotExpanded		BOOL ?
curNavType		SINT ?
tabpos			SINT ?
idNotify		SINT ?
tabOrder		db HH_MAX_TABS + 1 dup(?)
cHistory		SINT ?
pszJump1		LPCTSTR ?
pszJump2		LPCTSTR ?
pszUrlJump1		LPCTSTR ?
pszUrlJump2		LPCTSTR ?
rcMinSize		RECT <>
cbInfoTypes		SINT ?
pszCustomTabs		LPCTSTR ?
HH_WINTYPE		ENDS
PHH_WINTYPE		typedef ptr HH_WINTYPE

.enum {
    HHACT_TAB_CONTENTS,
    HHACT_TAB_INDEX,
    HHACT_TAB_SEARCH,
    HHACT_TAB_HISTORY,
    HHACT_TAB_FAVORITES,
    HHACT_EXPAND,
    HHACT_CONTRACT,
    HHACT_BACK,
    HHACT_FORWARD,
    HHACT_STOP,
    HHACT_REFRESH,
    HHACT_HOME,
    HHACT_SYNC,
    HHACT_OPTIONS,
    HHACT_PRINT,
    HHACT_HIGHLIGHT,
    HHACT_CUSTOMIZE,
    HHACT_JUMP1,
    HHACT_JUMP2,
    HHACT_ZOOM,
    HHACT_TOC_NEXT,
    HHACT_TOC_PREV,
    HHACT_NOTES,
    HHACT_LAST_ENUM,
    }

HHNTRACK		STRUC
hdr			NMHDR <>
pszCurUrl		PCSTR ?
idAction		SINT ?
phhWinType		ptr HH_WINTYPE ?
HHNTRACK		ENDS

;HWND
HtmlHelpA proto WINAPI \
	    hwndCaller: HWND,
	       pszFile: LPCSTR,
	      uCommand: UINT,
		dwData: DWORD_PTR


;HWND
HtmlHelpW proto WINAPI \
	    hwndCaller: HWND,
	       pszFile: LPCWSTR,
	      uCommand: UINT,
		dwData: DWORD_PTR

ifdef _UNICODE
define HtmlHelp	 <HtmlHelpW>
else
define HtmlHelp	 <HtmlHelpA>
endif


ATOM_HTMLHELP_API_ANSI	equ 14
ATOM_HTMLHELP_API_UNICODE equ 15

.enum HH_GPROPID {
    HH_GPROPID_SINGLETHREAD=1,
    HH_GPROPID_TOOLBAR_MARGIN=2,
    HH_GPROPID_UI_LANGUAGE=3,
    HH_GPROPID_CURRENT_SUBSET=4,
    HH_GPROPID_CONTENT_LANGUAGE=5
    }

ifdef __oaidl_h__

.pragma pack(push, 8)

HH_GLOBAL_PROPERTY	STRUC
id			HH_GPROPID ?
var			VARIANT <>
HH_GLOBAL_PROPERTY	ENDS

.pragma pack(pop)

endif

endif
endif
