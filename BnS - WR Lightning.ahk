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
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsSeverStepAvailable() || Availability.IsOnrushAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && (Availability.IsSeverStepAvailable() || Availability.IsOnrushAvailable()))
        {
            Skills.SeverStep()
            sleep 5
        }
    } else {
        if (Availability.IsStrafeAvailable()) {
            While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsStrafeAvailable())
            {
                Skills.Strafe()
                sleep 5
            }
        }
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShearStormAvailable())
    {
        Skills.ShearStorm()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~XButton2 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsSeverStepAvailable() || Availability.IsOnrushAvailable()) {
        While (Utility.GameActive() && GetKeyState("XButton2","p") && (Availability.IsSeverStepAvailable() || Availability.IsOnrushAvailable()))
        {
            Skills.SeverStep()
            sleep 5
        }
    } else {
        if (Availability.IsStrafeAvailable()) {
            While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsStrafeAvailable())
            {
                Skills.Strafe()
                sleep 5
            }
        }
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~XButton2 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsShearStormAvailable())
    {
        Skills.ShearStorm()
        sleep 5
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    IsBladeWardAvailable()
    {
        return Utility.GetColor(1035,959) == "0x111E2C"
    }

    IsDeadlockAvailable()
    {
        return Utility.GetColor(735,892) == "0x2A325B"
    }

    IsSeismicStrikeAvailable()
    {
        return Utility.GetColor(1035,892) == "0x1A0B0B"
    }
    
    IsSoulburnAvailable()
    {
        return Utility.GetColor(885,959) == "0x4E301A" || Utility.GetColor(885,959) == "0x551622"
    }

    IsFrenzyAvailable()
    {
        return Utility.GetColor(823,892) == "0x791914"
    }

    IsPrimalCallAvailable()
    {
        return Utility.GetColor(985,894) == "0xF8BBA6"
    }

    IsFellstrikeAvailable()
    {
        return Utility.GetColor(1182,684) == "0x112649"
    }

    IsRazeAvailable()
    {
        return Utility.GetColor(1182,684) == "0x15164C"
    }

    IsBloodstormAvailable()
    {
        return Utility.GetColor(1182,684) == "0x1F060E"
    }

    IsShearStormAvailable()
    {
        return Utility.GetColor(985,959) == "0x5C0502"
    }

    IsSeverStepAvailable()
    {
        return Utility.GetColor(682,892) == "0xC3A798"
    }

    IsOnrushAvailable()
    {
        return Utility.GetColor(682,892) == "0x541E38"
    }

    IsStrafeAvailable()
    {
        return Utility.GetColor(682,892) == "0xD1A395"
    }

    IsQAvailable()
    {
        return Utility.GetColor(682,892) != "0xE46B14"
    }

    IsBraceletCloseToExpiration()
    {
        return Utility.GetColor(596,921) != "0x01C1FF"
    }

    IsTalismanAvailable()
    {
        ; check for talisman cooldown border
        return Utility.GetColor(557,635) != "0xE46B14"
    }
}

; skill bindings
class Skills {
	Greatslash()
    {
		send t
	}

    F()
    {
        send f
    }

    BladeWard()
    {
        send v
    }

    PrimalCall()
    {
        send 3
    }

    SeismicStrike()
    {
        send 4
    }

    Deadlock() 
    {
        send e
    }

    SeverStep()
    {
        send q
    }

    Strafe()
    {
        send q
    }

    ShearStorm()
    {
        send c
    }

    Soulburn()
    {
        send z
    }

    Frenzy()
    {
        send {tab}
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
        if (Availability.IsFellstrikeAvailable() || Availability.IsRazeAvailable() || Availability.IsBloodstormAvailable()) {
            Skills.F()
            sleep 5
        } else {
            Skills.Greatslash()
            sleep 5
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (Availability.IsTalismanAvailable())
        {
            Skills.Talisman()
            sleep 5
        }

        if (!Availability.IsFrenzyAvailable()) {
            if (Availability.IsBladeWardAvailable()) {
                Skills.BladeWard()
                sleep 5
                return
            }

            if (Availability.IsDeadlockAvailable()) {
                Skills.Deadlock()
                sleep 5
                return
            }

            if (Availability.IsSeismicStrikeAvailable()) {
                Skills.SeismicStrike()
                sleep 5
                return
            }

            if (useDpsPhase && Availability.IsSoulburnAvailable()) {
                Skills.Soulburn()
                sleep 5
                return
            }

            if (Availability.IsPrimalCallAvailable() && Availability.IsBraceletCloseToExpiration()) {
                Skills.PrimalCall()
                sleep 5
            }
        } else {
            while (Availability.IsSeismicStrikeAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton2","p")) && Utility.GameActive()) {
                Skills.SeismicStrike()
                sleep 5
            }

            while (Availability.IsFrenzyAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton2","p")) && Utility.GameActive()) {
                Skills.Frenzy()
                sleep 5
            }
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