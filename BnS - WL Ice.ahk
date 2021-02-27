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
Return

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

; everything related to checking availability of skills or procs
class Availability
{
    IsTemporalFieldAvailable()
    {
        return Utility.GetColor(985,959) == "0x441953"
    }

    IsSoulShackleAvailable()
    {
        return Utility.GetColor(935,892) == "0x171141"
    }

    IsImprisonAvailable()
    {
        return Utility.GetColor(985,892) == "0x270E3E"
    }

    IsWingstormAvailable()
    {
        return Utility.GetColor(1035,959) == "0x0C1B2D"
    }

    IsDragoncallAvailable()
    {
        return Utility.GetColor(1035,892) == "0x131135" || Utility.GetColor(1035,892) == "0x131542"
    }

    IsLeechAvailable()
    {
        return Utility.GetColor(1147,691) == "0x071223"
    }

    IsInSoulburn()
    {
        ; bombardment available, bombardment on gcd, and bombardment not available due to focus during sb
        return Utility.GetColor(1161,908) == "0x012E68" || Utility.GetColor(1161,908) == "0x011A3A" || Utility.GetColor(1161,908) == "0x161616"
    }

    IsWeaponResetClose()
    {
        ; check for weapon reset cooldown (slightly above and below to see if the reset is close)
        return Utility.GetColor(558,921) == "0xFFBA01" && Utility.GetColor(556,909) != "0xFFBA01"
    }

    IsBraceletCloseToExpiration()
    {
        return Utility.GetColor(596,921) != "0x01C1FF"
    }

    IsBraceletActive()
    {
        return !Availability.IsBraceletCloseToExpiration()
    }

    HasRmbNoFocus()
    {
        return Utility.GetColor(1147,892) == "0x080808"
    }

    IsTalismanAvailable()
    {
        ; check for talisman cooldown border
        return Utility.GetColor(557,635) != "0xE46B14"
    }
}

; skill bindings
class Skills {
	TemporalField()
    {
        send c
    }

    SoulShackle()
    {
        send 2
    }

    Imprison()
    {
        send 3
    }

    Wingstorm()
    {
        send v
    }

    Dragoncall()
    {
        send 4
    }
    
    Leech()
    {
        send f
    }

    RMB()
    {
        send t
    }

    Talisman()
    {
        send 9
    }
}

; everything rotation related
class Rotations
{
    ; default rotation without any logic for max counts
    Default()
    {
        if (Availability.IsDragoncallAvailable()) {
            While (Utility.GameActive() && Availability.IsDragoncallAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.Dragoncall()
                sleep 5
            }
        } else {
            ; additional dragoncall call for UI effects while it's still available
            Skills.Dragoncall()
            sleep 5

            Skills.RMB()
            sleep 5
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        ; try to always use leech outside of soulburn stance
        if (!Availability.IsInSoulburn() && Availability.IsLeechAvailable()) {
            While (Utility.GameActive() && Availability.IsLeechAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.Leech()
                sleep 5
            }
        }

        ; if we don't have focus use soul shackle -> leech during sb or only soul shackle outside of sb since we try to have leech up anyways
        if (Availability.HasRmbNoFocus()) {
            if (Availability.IsInSoulburn()) {
                if (Availability.IsSoulShackleAvailable()) {
                    Skills.SoulShackle()
                    sleep 5
                } else {
                    if (Availability.IsLeechAvailable()) {
                        Skills.Leech()
                        sleep 5
                    }
                }
            }
            else {
                if (Availability.IsSoulShackleAvailable()) {
                    Skills.SoulShackle()
                    sleep 5
                }
            }
        }

        ; use soul shackle if bracelet is not active or a weapon reset is close
        if ((!Availability.IsBraceletActive() || Availability.IsWeaponResetClose()) && Availability.IsSoulShackleAvailable()) {
            Skills.SoulShackle()
            sleep 5
        }

        if (Availability.IsTemporalFieldAvailable()) {
            Skills.TemporalField()
            sleep 5
        }

        if (Availability.IsWingstormAvailable()) {
            Skills.Wingstorm()
            sleep 5
        }

        if (Availability.IsImprisonAvailable()) {
            Skills.Imprison()
            sleep 5
        }

        if (Availability.IsTalismanAvailable()) {
            Skills.Talisman()
            sleep 5
        }

        Rotations.Default()

        return
    }

    ; activate bluebuff and talisman if it's ready
    DpsPhase()
    {
        return
    }
}