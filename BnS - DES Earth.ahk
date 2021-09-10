#NoEnv
#KeyHistory 0
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
    return

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
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsSearingStrikeAvailable())
    {
        Skills.SearingStrike()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsTyphoonAvailable())
    {
        Skills.Typhoon()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & 1::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsBlitzAvailable())
    {
        Skills.Blitz()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & 2::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsRamAvailable())
    {
        Skills.Ram()
        sleep 5
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    IsAwkCleaveAvailable()
    {
        color := Utility.GetColor(1148,894)
        ; awk cleave off gcd and on gcd
        return color == "0xC17340" || color == "0x964915"
    }

    IsWrath3Available()
    {
        return Utility.GetColor(1143,700) == "0x7E7169"
    }

    IsCleaveAvailable()
    {
        color := Utility.GetColor(1146,887)
        ; ToDo: awk cleave
        return color == "0xB7602F" || color == "0xC17340"
    }

    IsMightyCleaveAvailable()
    {
        return Utility.GetColor(1143,700) == "0x6F6C69"
    }

    IsNoFuryCleaveAvailable()
    {
        return Utility.GetColor(1276,888) == "0x7C6E69"
    }

    IsFuryAvailable()
    {
        return Utility.GetColor(742,887) == "0x5E1842"
    }

    IsEmberstompAvailable()
    {
        return Utility.GetColor(987,887) == "0x281616"
    }

    IsSmashAvailable()
    {
        return Utility.GetColor(940,950) == "0x301B13"
    }

    IsSearingStrikeAvailable()
    {
        return Utility.GetColor(987,950) == "0x6D5532"
    }

    IsTyphoonAvailable()
    {
        return Utility.GetColor(695,887) == "0xBC4859"
    }

    IsBraceletCloseToExpiration()
    {
        Utility.GetColor(663,819, r, g, b)
        return b < 240
    }

    IsBraceletActive()
    {
        return !Availability.IsBraceletCloseToExpiration()
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
}

; skill bindings
class Skills {
    Wrath() {
        send r
    }

    Wrath3() {
        send f
    }

    Cleave() {
        send t
    }

    MightyCleave() {
        send f
    }

    SearingStrike()
    {
        send c
    }

    EmberStomp() {
        send 3
    }

    Smash() {
        send x
    }

    Fury() {
        send e
    }

    Typhoon()
    {
        send q
    }

    Talisman() {
        send 9
    }
}

; everything rotation related
class Rotations
{
    ; default rotation without any logic for max counts
    Default(useDpsPhase)
    {
        if (Availability.IsWeaponResetClose()) {
            Skills.Talisman()
            sleep 5

            if (Availability.IsEmberstompAvailable()) {
                Skills.EmberStomp()
                sleep 50
            }

            if (Availability.IsSmashAvailable()) {
                Skills.Smash()
                sleep 50
            }
        }

        ; wrath is usable during sb but we still need the fury buff
        if (useDpsPhase && Availability.IsFuryAvailable() && Availability.IsAwkCleaveAvailable()) {
            if (useDpsPhase && Availability.IsFuryAvailable()) {
                ; emberstomp will get instantly anicanceled by fury, annoying gcd group though
                Skills.EmberStomp()
                sleep 5
                Skills.Fury()
            }
        }

        if (Availability.IsNoFuryCleaveAvailable()) {
            if (useDpsPhase && Availability.IsFuryAvailable()) {
                ; emberstomp will get instantly anicanceled by fury, annoying gcd group though
                Skills.EmberStomp()
                sleep 5
                Skills.Fury()
            } else {
                if (useDpsPhase && Availability.IsEmberstompAvailable()) {
                    Skills.EmberStomp()
                    sleep 5
                }

                Skills.MightyCleave()
                sleep 5
                Skills.Cleave()
                sleep 5
            }
        } else {
            if ((Availability.IsMightyCleaveAvailable() || !Availability.IsBraceletActive()) && Availability.IsSmashAvailable()) {
                While (Availability.IsMightyCleaveAvailable()) {
                    Skills.MightyCleave()
                    sleep 10
                }

                While (Availability.IsSmashAvailable() && (!Availability.IsMightyCleaveAvailable())) {
                    Skills.Smash()
                    sleep 10
                }
            }

            if (Availability.IsWrath3Available()) {
                ; wrath 3 actually has a higher duration until hit, so we cancel it with cleave after 70 ms
                While (Availability.IsWrath3Available()) {
                    Skills.Wrath3()
                    sleep 10
                }

                sleep 70

                While (Availability.IsCleaveAvailable()) {
                    Skills.Cleave()
                    sleep 10
                }
            } else {
                ; spam wrath
                Skills.Wrath()
                sleep 10
            }
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        Rotations.Default(useDpsPhase)

        return
    }

    ; activate bluebuff and talisman if it's ready
    DpsPhase()
    {
        return
    }
}