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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
$F23::
    While (Utility.GameActive() && GetKeyState("F23","p"))
    {
        Rotations.FullRotation(true)
    }
    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton2::
    While (Utility.GameActive() && GetKeyState("XButton2","p"))
    {
        Rotations.FullRotation(false)
    }
    return
    
#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton1::
    While (Utility.GameActive() && GetKeyState("XButton1","p"))
    {
        Rotations.Default()
    }
    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsSearingStrikeAvailable())
    {
        Skills.SearingStrike()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsTyphoonAvailable())
    {
        Skills.Typhoon()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & 1::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsBlitzAvailable())
    {
        Skills.Blitz()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
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
    IsWrath2Available()
    {
        return Utility.GetColor(1299,892) == "0x0C162F"
    }

    IsWrath3Available()
    {
        return Utility.GetColor(1180,683) == "0x201308"
    }

    IsCleaveAvailable()
    {
        color := Utility.GetColor(1148,894)
        return color == "0xAE6736" || color == "0xC17340"
    }

    IsMightyCleaveAvailable()
    {
        return Utility.GetColor(1180,683) == "0x120E05"
    }

    IsNoFuryCleaveAvailable()
    {
        return Utility.GetColor(1299,892) == "0x080808"
    }

    IsFuryAvailable()
    {
        return Utility.GetColor(735,894) == "0x5F0E2B"
    }

    IsEmberstompAvailable()
    {
        return Utility.GetColor(985,894) == "0x250B09"
    }

    IsSmashAvailable()
    {
        return Utility.GetColor(935,961) == "0xA36346"
    }

    IsSearingStrikeAvailable()
    {
        return Utility.GetColor(985,961) == "0x897141"
    }

    IsTyphoonAvailable()
    {
        return Utility.GetColor(682,894) == "0xEB7A8C"
    }

    IsBraceletCloseToExpiration()
    {
        return Utility.GetColor(596,921) != "0x01C1FF"
    }

    IsWeaponResetClose()
    {
        ; check for weapon reset cooldown (slightly above and below to see if the reset is close)
        return Utility.GetColor(558,921) == "0xFFBA01" && Utility.GetColor(556,909) != "0xFFBA01"
    }

    IsTalismanAvailable()
    {
        ; check for talisman cooldown border
        return Utility.GetColor(557,635) != "0xE46B14"
    }
}

; skill bindings
class Skills {
    Wrath() {
        send r
    }

    Wrath2() {
        send g
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
    Default()
    {
        if (Availability.IsWeaponResetClose()) {
            if (Availability.IsEmberstompAvailable()) {
                Skills.EmberStomp()
                sleep 5
            }

            if (Availability.IsSmashAvailable()) {
                Skills.Smash()
                sleep 5
            }
        }

        if (Availability.IsTalismanAvailable()) {
            Skills.Talisman()
            sleep 5
        }

        if (Availability.IsNoFuryCleaveAvailable()) {
            if (Availability.IsFuryAvailable()) {
                ; emberstomp will get instantly anicanceled by fury, annoying gcd group though
                Skills.EmberStomp()
                sleep 20
                Skills.Fury()
                sleep 20
            } else {
                if (Availability.IsEmberstompAvailable()) {
                    Skills.EmberStomp()
                    sleep 5
                }

                Skills.MightyCleave()
                sleep 5
                Skills.Cleave()
                sleep 5
            }
        } else {
            if (Availability.IsMightyCleaveAvailable() && Availability.IsBraceletCloseToExpiration()) {
                While (Availability.IsMightyCleaveAvailable()) {
                    Skills.MightyCleave()
                    sleep 20
                }

                While (Availability.IsSmashAvailable()) {
                    Skills.Smash()
                    sleep 10
                }
            }

            if (Availability.IsWrath2Available()) {
                ; if wrath 2 is available we want to use it before mighty cleave since the hit of the 2nd wrath is near instant
                ; so we anicancel the 2nd wrath with mighty cleave
                While (Availability.IsWrath2Available()) {
                    Skills.Wrath2()
                    sleep 10
                } 

                sleep 40
            } else {
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
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        Rotations.Default()

        return
    }

    ; activate bluebuff and talisman if it's ready
    DpsPhase()
    {
        return
    }
}