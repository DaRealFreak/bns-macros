#NoEnv
#KeyHistory 0
#InstallMouseHook
#SingleInstance force
ListLines Off
Process, Priority, , A
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetBatchLines, -1

#Include %A_ScriptDir%\lib\utility.ahk

#IfWinActive ahk_class UnrealWindow
F1::
    MouseGetPos, mouseX, mouseY
    color := Utility.GetColor(mouseX, mouseY, r, g, b)
    tooltip, Coordinate: %mouseX%`, %mouseY% `nHexColor: %color%`nR:%r% G:%g% B:%b%
    Clipboard := "Utility.GetColor(" mouseX "," mouseY ") == `""" color "`"""
    SetTimer, RemoveToolTip, -5000
    return

RemoveToolTip:
    ToolTip
Return

^F10::Reload
^F11::Pause
^F12::ExitApp

#IfWinActive ahk_class UnrealWindow
$F23::
    While (Utility.GameActive() && GetKeyState("F23","p"))
    {
        Rotations.FullRotation(true)
    }
    return

#IfWinActive ahk_class UnrealWindow
$XButton2::
    While (Utility.GameActive() && GetKeyState("XButton2","p"))
    {
        Rotations.FullRotation(false)
    }
    return
    
#IfWinActive ahk_class UnrealWindow
$XButton1::
    While (Utility.GameActive() && GetKeyState("XButton1","p"))
    {
        Rotations.Default()
    }
    return

#IfWinActive ahk_class UnrealWindow
~F23 & q::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShadowDanceAvailable())
    {
        Skills.ShadowDance()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~F23 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFootworkAvailable())
    {
        Skills.Footwork()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~F23 & c::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFlurryAvailable())
    {
        Skills.Flurry()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & q::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsShadowDanceAvailable())
    {
        Skills.ShadowDance()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsFootworkAvailable())
    {
        Skills.Footwork()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & c::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsFlurryAvailable())
    {
        Skills.Flurry()
        sleep 5
    }
    return

; everything related to checking availability of skills or procs
class Availability
{
    IsShadowDanceAvailable()
    {
        return Utility.GetColor(695,887) == "0xEEAB18"
    }

    IsFootworkAvailable()
    {
        return Utility.GetColor(742,887) == "0xCBB4A3"
    }

    IsFlurryAvailable()
    {
        return Utility.GetColor(987,951) == "0x746A6A"
    }

    IsFightingSpiritAvailable()
    {
        return Utility.GetColor(825,887) == "0x3D9CB3"
    }

    IsWindGyreAvailable()
    {
        return Utility.GetColor(1035,951) == "0x7A7C94"
    }

    IsCometStrikeAvailable()
    {
        return Utility.GetColor(1035,887) == "0xB29348"
    }

    IsSearingPalmAvailable()
    {
        return Utility.GetColor(940,951) == "0x94A8A6"
    }

    IsPivotKickAvailable()
    {
        return Utility.GetColor(940,951) == "0x6983A9"
    }

    IsBraceletCloseToExpiration()
    {
        Utility.GetColor(663,819, r, g, b)
        return b < 240
    }

    IsWeaponResetClose()
    {
        ; check for weapon reset cooldown (slightly above and below to see if the reset is close)
        Utility.GetColor(620, 818, r, g)
        if (r > 200 && g > 100 && g < 200) {
            Utility.GetColor(602, 812, r2)
            return r2 < 200
        }

        return false
    }

    IsSoulProced()
    {
        ; check for soul duration progress bar
        Utility.GetColor(592,811, r, g, b)
        return b > 240 && r < 20
    }
}

; skill bindings
class Skills {
    RMB()
    {
        send t
    }

    ShadowDance()
    {
        send q
    }

    Footwork()
    {
        send e
    }

    FightingSpirit()
    {
        send {tab}
    }

    WindGyre()
    {
        send v
    }

    PivotKick()
    {
        send x
    }

    SearingPalm()
    {
        send x
    }

    CometStrike()
    {
        send 4
    }

    Flurry() {
        send c
    }

    Talisman() {
        send r
    }
}

; everything rotation related
class Rotations
{

    static lastCometStrikeUse := 0

    ; default rotation without any logic for max counts
    Default()
    {
        Skills.RMB()
        sleep 5

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && Availability.IsSoulProced()) {
            Rotations.DpsPhase()
        }

        if (Availability.IsPivotKickAvailable()) {
            While (Availability.IsPivotKickAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.PivotKick()
                sleep 5
            }
        }

        if (Availability.IsWindGyreAvailable()) {
            While (Availability.IsWindGyreAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.WindGyre()
                sleep 5
            }
        }

        ; comet strike reduces cd of wind gyre by 5 seconds so wait until we used wind gyre
        if (A_TickCount > this.lastCometStrikeUse + 10*1000 && Availability.IsCometStrikeAvailable() && !Availability.IsWindGyreAvailable()) {
            While (Availability.IsCometStrikeAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.CometStrike()
                sleep 5
            }
            this.lastCometStrikeUse := A_TickCount
        }

        ; only use searing palm on bracelet expiration which is exactly 12 seconds (same as searing palm debuff)
        if (Availability.IsBraceletCloseToExpiration() && Availability.IsSearingPalmAvailable()) {
            While (Availability.IsSearingPalmAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.SearingPalm()
                sleep 5
            }
        }

        Rotations.Default()
    }

    ; activate starstrike and talisman if it's ready
    DpsPhase()
    {
        ; our dps phase is only bb lol
        While (Utility.GameActive() && Availability.IsFightingSpiritAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 1
            Skills.FightingSpirit()
            sleep 1
        }

        return
    }
}