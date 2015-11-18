\ ����:       Autostrings.spf
\ �����:      VoidVolker
\ ����:       20/03/2012 18:03
\ ������:     3.8
\ ��������:
\  ������ � ���������������������� ����������� � ������-��������������������.
\ 1. ������ ����  
\     " �����: %12345 N>S% ��������� ����������: %ACTIVE-WINDOW% |n������� ������|n |q�������|q"
\   ��������������� � ��������� ���:
\     S" �����: " 12345 N>S S+  S" ��������� ����������: " S+ ACTIVE-WINDOW S+
\     S"  |n������� ������|n |q�������|q" S+
\   � ������ ���������� ���������� ����� % � % ����� �� �������� EVALUATE (�.�. ��� �������������)
\   � ����� ������������� ������������� S+
\   � ������ ������������� ��� � ���������� ������ ����������������, � S+ �����������
\   ����� ����� ����� ���� ����� 255 ��������.
\ 2. �������������� �.�. "������-������������������" - �.�. ������������ ������������������
\   �������� ����� ����� �� ���������� �� �������������� �� �������.
\     \   ->  
\     \\  ->  \
\     \p  ->  %
\     \q  ->  "
\     \t  ->  <���������> 9
\     \v  ->  <������������ ���������> 0xB
\     \r  ->  <������� �������>  0xD
\     \n  ->  <������� ������> crlf  0x0D0A
\ ��� �� ��������� ����� s" z" c" c ���������� ������-�������������������
\ ������� �� ����������� �����:
\   �� ����� ���������� ���� � ���������� �� ����� ����� ���������� ������;
\   ��� ����� ���������� ������������� ������ N>S - �������� ������� ����� �����������, 
\    �.�. ��� ������ ���������� ������, ����� ����� ����������.
\ �������������� ������ ������: ����� �������� ���� ����� ������������ ����� ����� ������, � �����
\    ���������� �������� �����, ����� ���������� ������ �������������. ��� ������������ ������,
\    ���������� � �����, ������� ������������ ����� LAS-FREE
\ LAS-FREE   \ ( -- ) \ ���������� ������, ������� ������ S+ ��� �������� �����.
\ ������� ������ ��� ����� S+
\  TRASH(   \ ( -- ) \ ������ ���� ������. ��� ������, ��������� ������ S+ ����� �������� � �������. 
\ ��� ������� ���������� ��� ���������� ������� ����������� ����� TRASH! � TRASH@ (������ ������,
\ ���������� ������ ALLOCATE)
\  )TRASH   \ ( -- ) \ ��������� ���� ������. ��� ������, ����������� � ������� ����� �����������. ����� S+ ������ �� ����� ��������� ������ � �������.
\  TRASH!   \ ( addr -- ) \ ��������� ����� �� ����� � �������. ������ ����� ���� TRASH( � )TRASH
\  TRASH@   \ ( -- addr ) \ �������� ����� �� �������.  ������ ����� ���� TRASH( � )TRASH

REQUIRE CASE lib/ext/case.f
REQUIRE {       ~ac\lib\locals.f
: XCOUNT DUP CELL+ SWAP @ ;

MODULE: AUTOSTRINGS_MODULE
  \ ### ��������� ������-������������������� ###

  USER esc-u1
  USER esc-a1

  : esc-c,
    esc-a1 @ C!
    esc-a1 1+!
  ;

EXPORT

  : resolve-escape   \ ( a u a1 -- a1 u1 )
    esc-a1 !        \ a u
    2DUP +          \ a u ae
    SWAP esc-u1 !   \ a ae
    SWAP            \ ae a
    BEGIN           \ ae a
      DUP C@ DUP [CHAR] \ =
        IF  \ ae a char
          DROP DUP 1+ C@ CASE
            [CHAR] \ OF [CHAR] \ esc-c, 1+ -1 esc-u1 +! ENDOF
            [CHAR] p OF [CHAR] % esc-c, 1+ -1 esc-u1 +! ENDOF
            [CHAR] q OF [CHAR] " esc-c, 1+ -1 esc-u1 +! ENDOF
            [CHAR] t OF   9 esc-c, 1+ -1 esc-u1 +! ENDOF
            [CHAR] v OF 0xB esc-c, 1+ -1 esc-u1 +! ENDOF
            [CHAR] r OF 0xD esc-c, 1+ -1 esc-u1 +! ENDOF
            [CHAR] n OF 0xD esc-c, 0xA esc-c, 1+ ENDOF
            DUP OF ENDOF
          ENDCASE
        ELSE
          esc-c,
        THEN
        1+
      2DUP =
    UNTIL
    2DROP
    esc-a1 @ esc-u1 @ - esc-u1 @
    0 esc-c,
  ;

  : _sliteral-code
    R>      \ acnt
    XCOUNT  \ astr u
    2DUP    \ astr u astr u
    +       \ astr u astr+u
    1+      \ astr u astr+u+1
    >R      \ astr u
  ;
  
  : _zliteral-code
    R> XCOUNT
    OVER + 1+
    >R
  ;
  
  : sliteral  \ ( a u -- ) \ ���������� ������� � 4 �����, ��� ��������� �������� �� �������� �� 4 ��.
    STATE @
      IF
        ['] _sliteral-code COMPILE,
        HERE >R 0 ,      \ a u R: a1 \ �������� ����� �������� � ����������� ��� ���� �����
        HERE resolve-escape \ a1 u1 \ ��������� ������-������������������
        DUP ALLOT        \ a1 u1 \ ����������� ������, ������� ����� �������
        0 C,
        R> !                \ a1    \ ��������� �������
        DROP                \ ������� �����
      ELSE
        2DUP + 0 SWAP C!
        OVER resolve-escape
      THEN
  ; IMMEDIATE

DEFINITIONS

  \ ### ������� ������ ��� ����� S+ ###
  1024 CONSTANT /TRASH                \ ����� �������, 1-�� ������ - ������� �����, -1-�� - ���������� �������
  USER-VALUE TRASH                    \ �������, ���������� - ����������, �� ���� - ����
  USER-VALUE las-addr
  
EXPORT

  : TRASH!   \ ( addr -- ) \ ��������� ����� �� ����� � �������. ������ ����� ���� TRASH( � )TRASH
    TRASH @ /TRASH <
    IF
      TRASH 1+!
      TRASH  TRASH @ CELLS  +  !
    ELSE
      DROP ABORT" ������������ �������! ��������� ����� ������� ��� ������ ������. ��������� /TRASH"
    THEN
  ;
  
  : TRASH@   \ ( -- addr ) \ �������� ����� �� �������.  ������ ����� ���� TRASH( � )TRASH
    TRASH @
    IF
      TRASH  TRASH @ CELLS  + @
      -1 TRASH +!
    ELSE
      ABORT" ������� ������! ������ ������� ��, ���� ���."
    THEN
  ;

  : STR+ { a1 u1 a2 u2 -- a3 u3 } \ ������� ��� ������, �������� ����� ����� ������ � �������
    u1 u2 + DUP 1+ ALLOCATE THROW
    a1 OVER u1 CMOVE
    a2 OVER u1 + u2 CMOVE
    TRASH IF DUP TRASH! THEN
    DUP TO las-addr
    SWAP
  ;
  
  : TRASH-FREE   \ ( -- ) \ �������� �������
    TRASH @ IF
      TRASH CELL+ TRASH @ CELLS + TRASH CELL+ DO
        I @ FREE THROW
      CELL +LOOP
    THEN
  ;

  : LAS-FREE   \ ( -- ) \ ���������� ������, ������� ������ S+ ��� �������� �����.
    las-addr IF las-addr FREE THROW THEN
  ;
  
  : TRASH(   \ ( -- ) \ ������ ���� ������. ��� ������, ��������� ������ S+ ����� �������� � �������. ��� ������� ���������� ��� ���������� ������� ����������� ����� TRASH! � TRASH@ (������ ������, ���������� ������ ALLOCATE)
    /TRASH CELLS ALLOCATE THROW
    TRASH OVER ! CELL+ TO TRASH
  ;
  
  : )TRASH   \ ( -- ) \ ��������� ���� ������. ��� ������, ����������� � ������� ����� �����������. ����� S+ ������ �� ����� ��������� ������ � �������.
    TRASH-FREE
    TRASH CELL - DUP @ TO TRASH 
    FREE THROW
  ;

  
DEFINITIONS
  
  \ ### ���������� ###
  USER-VECT <astr-literal>
  
  USER astra      \ ��������� ����� ������ ��� �������
  USER astru      \ ����� ������ ��� �������
  USER astrea     \ �������� ����� ������ ��� �������
  USER astrla     \ ����� ��������� ������������ ������
  USER astrings   \ ������� �������� - ��������� ����������� �� ������ ��������

EXPORT

  : (s+)1  \ ������������� S+ ������ ���� �� ����� 2 ������
    astrings @ 2 =
      IF
        STATE @
          IF
            POSTPONE STR+
          ELSE
            STR+
          THEN
        1 astrings !
      THEN
  ;
  
  VECT (s+)
  ' (s+)1 TO (s+)
  
DEFINITIONS

  : interpret-code   \ ( a u -- )
    EVALUATE
    astrings 1+! (s+)
  ;

  : interpret-str   \ ( a u -- ) \ ���������������� ������ � ����� S+
    DUP
      IF
        astrings 1+!
        [COMPILE] sliteral
        (s+)
      ELSE
        2DROP
      THEN
  ;

  USER-VECT <subst-resolve>
  0 VALUE (code-resolve)'
  0 VALUE (str-resolve)'

  : (code-resolve)   \ ( i -- )  \ ���������� ���(���������)
    (str-resolve)' TO <subst-resolve>
    >R
    astrla @ 1+ R@ OVER - \ �������� ������
    interpret-code        \ �������������� ���
    R> 1+ astrla !        \ ��������� ������� �����
  ;
  ' (code-resolve) TO (code-resolve)'

  : (str-resolve)   \ ( i -- )  \ ���������� ������
    (code-resolve)' TO <subst-resolve>
    >R
    astrla @ R@ OVER -    \ �������� ������
    interpret-str         \ �������������� ������
    R> astrla !           \ ��������� ������� �����
  ;
  ' (str-resolve) TO (str-resolve)'

EXPORT

  : )ATRASH
    \ �������������� ������ ������� �� �������
    TRASH @ IF TRASH@ TO las-addr THEN
    )TRASH
  ;
  
  : "" S" " ;   \ ������ ������ - ����� ������ �� �����

  : ASTR   \ ( a1 u1 -- a2 u2 )
    DUP
      IF
        \ �������������� ���������� � �������
        0 astrings !
        (str-resolve)' TO <subst-resolve>
        2DUP + astrea !
        astru ! DUP astra ! astrla !
        \ ��������� �������
        STATE @
          IF
            POSTPONE TRASH(
          ELSE
            TRASH(
          THEN
          
        \ ������������ ������ � �����
        astrea @ astra @ DO
          I C@ [CHAR] % =             \ ���������?
            IF
              I <subst-resolve>
            THEN
        LOOP
        
        \ � �������������� ��������� ������� ������
        astrla @ astrea @ OVER - interpret-str
        \ ��������� �������
        STATE @
          IF
            POSTPONE )ATRASH
          ELSE
            )ATRASH
          THEN
      ELSE
        [COMPILE] SLITERAL
      THEN
  ;
  
  \ USER-CREATE StringBuf 10240 USER-ALLOT
  \ USER StringBuf#
  \ StringBuf# 0!
  \ StringBuf 10240 ERASE
  
  \ : JRECURSE   \ �������� ��� ������� - �.�. �������. ��� ������� �������� � �������� - �.�. 
    \ ?COMP
    \ LATEST NAME> 
    \ 0xE9 C,
    \ HERE CELL+ - ,
  \ ; IMMEDIATE
  
  : "   \ ( -- a u ) ( " ������" -> )
    \ ������ ������
    [CHAR] " PARSE    \ a u
    \ 2DUP +
    \ 1- DUP C@ DUP EMIT [CHAR] \ =
    \ SWAP 1- C@ DUP EMIT [CHAR] \ <> AND CR
    \ IF
      \ ." >" CR
      \ 1- StringBuf StringBuf# @ + SWAP 
      \ DUP StringBuf# +!
      \ CMOVE
      \ REFILL IF JRECURSE THEN
      \ StringBuf StringBuf# @
    \ ELSE
      \ StringBuf# @
      \ IF
        \ ."  *** " StringBuf StringBuf# @ . . CR
        \ StringBuf StringBuf# @ + SWAP 
        \ DUP StringBuf# +!
        \ CMOVE
        \ StringBuf StringBuf# @
      \ THEN
    \ THEN
    
    ASTR
    
    \ StringBuf# 0!
    \ StringBuf 10240 ERASE
  ; IMMEDIATE

  WINAPI: MultiByteToWideChar   KERNEL32.DLL
  WINAPI: WideCharToMultiByte   KERNEL32.DLL
  65001 CONSTANT CP_UTF8
  USER UnicodeBuf

  : >UNICODE ( addr u -- addr2 u2 )
    DUP 2* CELL+ ALLOCATE DROP UnicodeBuf !
    SWAP >R
    DUP 2* CELL+ UnicodeBuf @ ROT R> 0 ( flags) 0 ( CP_ACP)
    MultiByteToWideChar
    UnicodeBuf @ 
    SWAP 2* 
    2DUP + 0 SWAP W!
  ;
  : UNICODE> ( addr u -- addr2 u2 )
  \ �� ����� - ����� � ������, � WideCharToMultiByte ����� �-�� ��������
    2 /
    1+ \ 0 � ����� ���� �������, �.�. �� ���� � �������.������
    >R >R 0 0 R> R>
    DUP CELL+ ALLOCATE DROP UnicodeBuf ! \ 0 0 addr len
    SWAP >R                        \ 0 0 len
    DUP CELL+ UnicodeBuf @         \ 0 0 len len+4 mem
    ROT ( ����� �������� DROP -1 ��� ����������� �����) 
    R>                             \ 0 0 len+4 mem len addr
    0 ( flags) 0 ( CP_ACP)
    WideCharToMultiByte
    UnicodeBuf @ 
    SWAP 1-
  ;
  : UTF8>UNICODE ( addr u -- addr2 u2 )
    DUP 2* CELL+ ALLOCATE DROP UnicodeBuf !
    SWAP >R
    DUP 2* CELL+ UnicodeBuf @ ROT R> 0 ( flags) CP_UTF8
    MultiByteToWideChar
    UnicodeBuf @ 
    SWAP 2* 
    2DUP + 0 SWAP W!
  ;
  : UNICODE>UTF8 ( addr u -- addr2 u2 )
  \ �� ����� - ����� � ������, � WideCharToMultiByte ����� �-�� ��������
    2 /
    1+ \ 0 � ����� ���� �������, �.�. �� ���� � �������.������
    >R >R 0 0 R> R>
    2* DUP CELL+ ALLOCATE DROP UnicodeBuf ! \ 0 0 addr len
    SWAP >R                        \ 0 0 len
    DUP CELL+ UnicodeBuf @         \ 0 0 len len+4 mem
    ROT 2 / ( ����� �������� DROP -1 ��� ����������� �����) 
    R>                             \ 0 0 len+4 mem len addr
    0 ( flags) CP_UTF8
    WideCharToMultiByte
    UnicodeBuf @ 
    SWAP 1-
  ;
  : >UTF8  ( addr u -- addr2 u2 )
    >UNICODE OVER >R UNICODE>UTF8 R> FREE THROW
  ;
  : UTF8> ( addr u -- addr2 u2 )
    UTF8>UNICODE UNICODE>
  ;

  : autostrings.init ;
  : autostrings.exit ;
  
  : U"
    [CHAR] " PARSE >UTF8
    [COMPILE] SLITERAL
  ; IMMEDIATE
  
  \ : [S:]
    \ BEGIN WHILE
    
    \ REPEAT
  \ ;
  
  \ : [:S]
  
  \ ;
  
;MODULE

\ ����� ��������
\ WINAPI: GetTickCount kernel32.dll

\ : t1
  \ GetTickCount
  \ 10000 0 DO
    \ S" �����:%12345% %QUOTE%�������%QUOTE%%CRLF%������� ������%CRLF%������� %PERCENT%" EVAL-SUBST
    \ 2DROP
  \ LOOP
  \ GetTickCount - ABS .
\ ;

\ : t2
  \ GetTickCount
  \ 1000000 0 DO
    \ " �����:%12345 N>S% |q�������|q|n������� ������|n������� |p\
    \ 12345"
    \ 2DROP
  \ LOOP
  \ GetTickCount - ABS . CR
\ ;