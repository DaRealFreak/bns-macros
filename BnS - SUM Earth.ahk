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
    IsStranglingRootsAvailable()
    {
        return Utility.GetColor(885,894) == "0x3E1821"
    }

    Is2Available()
    {
        return Utility.GetColor(935,892) != "0xE46B14"
    }

    IsPetalStormTossAvailable()
    {
        return Utility.GetColor(985,894) == "0x385DDD"
    }

    IsRumbleQueenAvailable()
    {
        return Utility.GetColor(1300,895) == "0x713201"
    }

    IsEnhancedSunflowerAvailable()
    {
        return Utility.GetColor(1148,894) == "0xE1BC44"
    }

    IsSunflowerOnGcd()
    {
        ; either orange cd border or no focus
        return Utility.GetColor(1148,892) == "0xE46B14" || Utility.GetColor(1148,892) == "0x323232"
    }

    IsTalismanAvailable()
    {
        ; check for talisman cooldown border
        return Utility.GetColor(557,635) != "0xE46B14"
    }
}

; skill bindings
class Skills {
    LMB() {
        send r
    }

	RMB() {
		send t
	}

    StranglingRoots() {
        send 1
    }

    2() {
        send 2
    }

    PetalStormToss() {
        send 3
    }

    RumbleQueen() {
        send g
    }

    Talisman() {
        send 9
    }
}

; everything rotation related
class Rotations
{
    static rotation := 0

    Default()
    {
        if (!Availability.IsSunflowerOnGcd()) {
            Skills.RMB()
            sleep 5
        } else {
            Skills.LMB()
            sleep 5
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase) {
            Rotations.DpsPhase()
        }

        if (!Availability.IsEnhancedSunflowerAvailable()) {
            if (Availability.IsPetalStormTossAvailable()) {
                Skills.PetalStormToss()
                sleep 5
            }

            if (Availability.IsStranglingRootsAvailable()) {
                Skills.StranglingRoots()
                sleep 5
            }
        } else {
            if (useDpsPhase && Availability.IsTalismanAvailable()) {
                Skills.Talisman()
                sleep 5
            }
        }

        if (Availability.Is2Available()) {
            Skills.2()
            sleep 5
        }

        Rotations.Default()

        return
    }

    DpsPhase()
    {
        if (Availability.IsRumbleQueenAvailable()) {
            Skills.RumbleQueen()
            sleep 5
        }

        return
    }
}