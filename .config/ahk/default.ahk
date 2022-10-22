#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; :: ; control j
; Send, My First Script  ; command is Send
; return

; ; hotstring: convert ftw to free the whales
; ::ftw::Free the whales
; return

; ^u::
; MsgBox, Escape!!!
; return

; Hotkey, RControl & e, Up
; Hotkey, RControl & d, Down
; Hotkey, RControl & s, Left
; Hotkey, RControl & f, Right

FN1 := false

; $LAlt::Send {LControl}
; CapsLock::LWin
; LWin::LAlt

$*RAlt::
FN1 := true
return

$RAlt UP::
FN1 := false
return

LAlt & BackSpace::
Send ^{BackSpace}
return

#If FN1 = true
  $e::Up
  $d::Down
  $s::Left
  $f::Right

  $j::Home
  $l::End
  $i::PgUp
  $k::PgDn

  $Esc::`
  $1::F1
  $2::F2
  $3::F3
  $4::F4
  $5::F5
  $6::F6
  $7::F7
  $8::F8
  $9::F9
  $0::F10
  $-::F11
  $=::F12
#If ; end

; ^i::
; MsgBox, Wow!
; MsgBox, There are
; Run, notepad.exe  ; run notepad on computer
; WinActivate, Untitled - Notepad
; WinWaitActive, Untitled - Notepad
; Send, 7 lines{!}{Enter}  ; escape that symbol
; SendInput, inside the CTRL{+}J hotkey.
; return

; RControl & e::Up  ; W
; RControl & d::Down
; RControl & s::Left
; RControl & f::Right

; RControl & j::Home
; RControl & l::End
; RControl & i::PgUp
; RControl & k::PgDn

; ^j:: ; control j
; Send, My First Script  ; command is Send
; return

; ^j:: ; control j
; Send, My First Script  ; command is Send
; return

; RAlt::
; SendInput, {RControl}
; return

; RAlt::RControl

; RControl & e::
; SendInput, {Up}
; return

; *j::
; {
;   if GetKeyState("Ctrl") or GetKeyState("LShift")
;     Send {f}
;   else
;     Send {F1}
;   return
; }

; SendInput, {Up}
; return

; RControl & d::
; SendInput, {Down}
; return

; RControl & s::
; SendInput, {Left}
; return

; RControl & f::
; SendInput, {Right}
; return

; RControl & i::
; SendInput, {PgUp}
; return

; RControl & k::
; SendInput, {PgDn}
; return

; RControl & j::
; SendInput, {Home}
; return

; RControl & l::
; SendInput, {End}
; return

; RControl & w::
; SendInput, {Delete}
; return

; *f::
; {
;   if GetKeyState("LCtrl") or GetKeyState("LShift")
;     Send {f}
;   else
;     Send {F1}
;   return
; }