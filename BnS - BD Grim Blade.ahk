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
    IsGrimReaverAvailable() {
        return Utility.GetColor(892,951) == "0x6C716F"
    }

    IsCycloneAvailable() {
        return Utility.GetColor(1035,951) == "0x83AD9D"
    }

    IsDeathtollAvailable() {
        return Utility.GetColor(987,951) == "0xACCBA8"
    }

    IsGraveyardShiftAvailable()
    {
        return Utility.GetColor(940,951) == "0x6B6D6D"
    }

    IsEviscerateAvailable()
    {
        return Utility.GetColor(1144,702) == "0xADC9BF"
    }

    IsTwinSabersAvailable()
    {
        return Utility.GetColor(1144,702) == "0x5C756E"
    }

    IsContagionAvailable()
    {
        return Utility.GetColor(1144,702) == "0x5B6965"
    }

    IsRaidAvailable()
    {
        return Utility.GetColor(940,887) == "0x3B8FA8"
    }

    IsLmbUnavailable()
    {
        return Utility.GetColor(1110,891) == "0x688B7C"
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
        if (useDpsPhase)
        {
            Skills.Talisman()
            sleep 5
        }

        if (Availability.IsContagionAvailable()) {
            Skills.F()
            sleep 5
        }

        if (useDpsPhase && Availability.IsGraveyardShiftAvailable()) {
            While (Availability.IsGrimReaverAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.GrimReaver()
                sleep 5
            }

            While (Availability.IsGraveyardShiftAvailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                Skills.GraveyardShift()
                sleep 5
            }

            While (!Availability.IsLmbUnavailable() && Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p"))) {
                ; in case graveyard shift didn't go through due to blinking of the off cd UI effect
                if (Availability.IsGraveyardShiftAvailable()) {
                    Skills.GraveyardShift()
                    sleep 5
                }
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