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
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShadowDanceAvailable())
    {
        Skills.ShadowDance()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFootworkAvailable())
    {
        Skills.Footwork()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & c::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFlurryAvailable())
    {
        Skills.Flurry()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & 3::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsHowlAvailable())
    {
        Skills.Howl()
        sleep 5
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    IsIncinerateAvailable()
    {
        return Utility.GetColor(1035,887) == "0xB53E30"
    }

    IsDireWolfAvailable()
    {
        return Utility.GetColor(1035,951) == "0x696B6D"
    }

    IsWolfFangAvailable()
    {
        return Utility.GetColor(825,887) == "0x242729"
    }

    IsShadowDanceAvailable()
    {
        ; q iframe in normal and wolf form
        col := Utility.GetColor(695,887)
        return col == "0xE07A5D" || col == "0x541313"
    }

    IsFootworkAvailable()
    {
        ; e iframe in normal and wolf form
        col := Utility.GetColor(742,887)
        return col == "0xD2B4A6" || col  == "0x13154D"
    }

    IsFlurryAvailable()
    {
        return Utility.GetColor(987,951) == "0x746B6A"
    }

    IsHowlAvailable()
    {
        return Utility.GetColor(987,887) == "0x2B8F9B"
    }

    IsInWolf()
    {
        ; v return
        return Utility.GetColor(1034,951) == "0x779AA8"
    }
}

; skill bindings
class Skills {
    LMB()
    {
        send r
    }

	RMB()
    {
		send t
	}

    DireWolf()
    {
        send v
    }

    SearingStomp()
    {
        send x
    }

    ShadowDance()
    {
        send q
    }

    Footwork()
    {
        send e
    }

    Flurry()
    {
        send c
    }

    Howl()
    {
        send 3
    }

    Incinerate()
    {
        send 4
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
        Skills.RMB()
        sleep 25

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (Availability.IsInWolf()) {
            Skills.LMB()
            return
        }

        if (useDpsPhase && Availability.IsDireWolfAvailable()) {
            while (Availability.IsIncinerateAvailable()) {
                Skills.Incinerate()
                sleep 5
            }

            loop, 5 {
                Skills.Talisman()
                sleep 5
                Skills.DireWolf()
                sleep 5
            }
            return
        }

        if (Availability.IsWolfFangAvailable())
        {
            send {tab}
            sleep 5
            return
        }

        if (Availability.IsIncinerateAvailable()) {
            Skills.Incinerate()
            sleep 5
            return
        } else {
            loop, 2 {
                Skills.SearingStomp()
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