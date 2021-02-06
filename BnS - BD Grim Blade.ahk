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
    IsGrimReaverAvailable() {
        return Utility.GetColor(885,959) == "0x28585D"
    }

    IsCycloneAvailable() {
        return Utility.GetColor(1035,959) == "0x358560"
    }

    IsDeathtollAvailable() {
        return Utility.GetColor(985,959) == "0x4D7046"
    }

    IsGraveyardShiftAvailable()
    {
        return Utility.GetColor(935,959) == "0x0D1111"
    }

    IsEviscerateAvailable()
    {
        return Utility.GetColor(1153,698) == "0xF3FFFE"
    }

    IsTwinSabersAvailable()
    {
        return Utility.GetColor(1145,699) == "0x369798"
    }

    IsFuneralPyreAvailable()
    {
        return Utility.GetColor(1146,706) == "0x71AEA4"
    }

    IsRaidAvailable()
    {
        return Utility.GetColor(935,892) == "0x154454"
    }

    IsLmbUnavailable()
    {
        return Utility.GetColor(1099,892) == "0xE46B14"
    }

    IsRmbUnavailable()
    {
        return Utility.GetColor(1147,892) == "0x161616"
    }

    HasRmbNoFocus()
    {
        return Utility.GetColor(1147,892) == "0x1F1F1F"
    }

    IsBraceletCloseToExpiration()
    {
        return Utility.GetColor(596,921) != "0x01C1FF"
    }

    IsBraceletActive()
    {
        return !Availability.IsBraceletCloseToExpiration()
    }

    IsWeaponResetClose()
    {
        ; check for weapon reset cooldown (slightly above and below to see if the reset is close)
        return Utility.GetColor(558,921) == "0xFFBA01" && Utility.GetColor(556,909) != "0xFFBA01"
    }

    IsSoulProced()
    {
        ; check for soul duration progress bar
        return Utility.GetColor(543,915) == "0x01C1FF"
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

    F() {
        send f
    }

    Raid() {
        send 2
    }

    Blindside() {
        send e
    }

    Strafe() {
        send q
    }

    Deflect() {
        send 1
    }

    GrimReaver() {
        send y
    }

    GraveyardShift() {
        send x
    }

    Cyclone() {
        send v
    }

    Deathtoll() {
        send c
    }

    Evade() {
        send ss
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
        Skills.RMB()
        sleep 50

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (Availability.IsCycloneAvailable()) {
            Skills.Cyclone()
            sleep 5
        }

        if (Availability.IsDeathtollAvailable()) {
            Skills.Deathtoll()
            sleep 5
        }

        While (Availability.IsTwinSabersAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
            Skills.F()
            sleep 5
        }

        if (Availability.HasRmbNoFocus() && Availability.IsRaidAvailable() && !Availability.IsTwinSabersAvailable()) {
            Skills.Raid()
            sleep 5
        }

        if (Availability.IsEviscerateAvailable() || Availability.IsFuneralPyreAvailable()) {
            Skills.F()
            sleep 5
        }

        if (Availability.IsRmbUnavailable()) {
            send c
            sleep 5
        }

        if (useDpsPhase && Availability.IsGraveyardShiftAvailable()) {
            While (Availability.IsCycloneAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.Cyclone()
                sleep 200
            }

            While (Availability.IsDeathtollAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.Deathtoll()
                sleep 200
            }

            While (Availability.IsGrimReaverAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.GrimReaver()
                sleep 5
            }

            While (Availability.IsGraveyardShiftAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.GraveyardShift()
                sleep 5
            }

            While (!Availability.IsLmbUnavailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.LMB()
                sleep 5
            }
        }

        this.Default()

        return
    }

    ; activate the bracelet
    Bracelet()
    {
    }
}