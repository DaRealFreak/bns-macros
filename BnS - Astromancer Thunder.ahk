#NoEnv
#KeyHistory 0
#InstallMouseHook
#SingleInstance force
ListLines Off
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

; everything related to checking availability of skills or procs
class Availability
{
    WaitForSoul() {
        return true
    }

    IsLMBAvailable() {
        return Utility.GetColor(1095,887) == "0x5AAABB"
    }

    IsOrbitalStrikeAvailable() {
        ; normal and awakened orbital strike
        return Utility.GetColor(1143,700) == "0x7C979C"
    }

    IsFirstElectrifyAvailable() {
        return Utility.GetColor(940,887) == "0x16427C"
    }

    IsSecondElectrifyAvailable() {
        return Utility.GetColor(940,887) == "0x273A4B"
    }

    IsThunderballAvailable() {
        return Utility.GetColor(1035,887) == "0x8F9EB4"
    }

    IsPortentAvailable() {
        return Utility.GetColor(1035,957) == "0x36375C"
    }

    IsPolarityAvailable()
    {
        return Utility.GetColor(825,887) == "0x3589EE"
    }

    IsSupernovaAvailable() {
        return Utility.GetColor(1277,887) == "0x3D8FBD"
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
    LMB() {
        send r
    }

    RMB() {
        send t
    }

    OrbitalStrike() {
        send f
    }

    Electrify() {
        send 2
    }

    Thunderball() {
        send 4
    }

    Portent() {
        send v
    }

    Polarity() {
        send {Tab}
    }

    Supernova() {
        send g
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
        if (Availability.IsLMBAvailable()) {
            Skills.LMB()
            sleep 5
        }

        if (Availability.IsOrbitalStrikeAvailable()) {
            Skills.OrbitalStrike()
            sleep 5
        }

        if (Availability.IsFirstElectrifyAvailable() || Availability.IsSecondElectrifyAvailable()) {
            Skills.Electrify()
            sleep 5
        }

        if (Availability.IsThunderballAvailable() && !Availability.IsFirstElectrifyAvailable()) {
            Skills.Thunderball()
            sleep 5
        }

        Skills.RMB()
        sleep 5

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && (Availability.IsPolarityAvailable() && (!Availability.WaitForSoul() || Availability.IsSoulProced()))) {
            ; polarity is ready and soul active, use it
            Rotations.DpsPhase()
        }

        if (Availability.IsPortentAvailable()) {
            Skills.Portent()
            sleep 5
        }

        Rotations.Default()

        return
    }

    DpsPhase() {
        ; loop while polarity is not on cooldown or break if keys aren't pressed anymore
        While (Utility.GameActive() && Availability.IsPolarityAvailable() && GetKeyState("F23","p"))
        {    
            Skills.Talisman()
            sleep 5
            Skills.Polarity()
            sleep 5
        }

        ; loop while polarity is not on cooldown or break if keys aren't pressed anymore
        While (Utility.GameActive() && Availability.IsSupernovaAvailable() && GetKeyState("F23","p"))
        {    
            Skills.Supernova()
            sleep 5
        }
    }
}