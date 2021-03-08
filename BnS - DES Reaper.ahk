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
    IsEmberstompAvailable()
    {
        return Utility.GetColor(985,892) == "0x1B0C0C"
    }

    IsExecuteAvailable()
    {
        return Utility.GetColor(935,959) == "0x290C0A"
    }

    IsFuryAvailable()
    {
        return Utility.GetColor(735,892) == "0x420D2E"
    }

    IsTalismanAvailable()
    {
        ; check for talisman cooldown border
        return Utility.GetColor(557,635) != "0xE46B14"
    }
}

; skill bindings
class Skills {
	RMB() {
		send t
	}

    F() {
        send f
    }

    EmberStomp() {
        send 3
    }

    Execute() {
        send x
    }

    Fury() {
        send e
    }

    Talisman() {
        send 9
    }
}

; everything rotation related
class Rotations
{
    static rotation := 0

    ; default rotation without any logic for max counts
    Default()
    {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsEmberstompAvailable()) {
            Skills.Emberstomp()
            sleep 5
        }

        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsTalismanAvailable()) {
            Skills.Talisman()
            sleep 5
        }

        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFuryAvailable()) {
            Skills.Fury()
            sleep 150
        }

        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsExecuteAvailable()) {
            Skills.Execute()
            sleep 5
        }

        Skills.RMB()
        sleep 5

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