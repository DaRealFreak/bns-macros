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

#IfWinActive ahk_class UnrealWindow
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

; everything related to checking availability of skills or procs
class Availability
{
    IsBladeWardAvailable()
    {
        return Utility.GetColor(1035,951) == "0x6D7681"
    }

    IsDeadlockAvailable()
    {
        return Utility.GetColor(742,888) == "0x91A2C6"
    }

    IsSeismicStrikeAvailable()
    {
        return Utility.GetColor(1035,888) == "0x726969"
    }
    
    IsSoulburnAvailable()
    {
        col := Utility.GetColor(892,951)
        return col == "0x998575" || col == "0x9F727C"
    }

    IsFrenzyAvailable()
    {
        return Utility.GetColor(827,887) == "0xA82C26"
    }

    IsPrimalCallAvailable()
    {
        return Utility.GetColor(987,887) == "0xA4332E"
    }

    IsSeverStepAvailable()
    {
        return Utility.GetColor(695,887) == "0xD2B4A6"
    }

    IsOnrushAvailable()
    {
        return Utility.GetColor(695,887) == "0x903B59"
    }

    IsStrafeAvailable()
    {
        return Utility.GetColor(695,887) == "0xDDB0A3"
    }

    IsQAvailable()
    {
        return Utility.GetColor(682,892) != "0xE46B14"
    }

    IsBraceletCloseToExpiration()
    {
        Utility.GetColor(663,819, r, g, b)
        return b < 240
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
	Greatslash()
    {
		send t
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
        send r
    }
}

; everything rotation related
class Rotations
{
    ; default rotation without any logic for max counts
    Default()
    {
        Skills.Greatslash()
        sleep 5

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
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

            if (useDpsPhase && Availability.IsSoulProced() && Availability.IsSoulburnAvailable()) {
                Skills.Talisman()
                sleep 5
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
}