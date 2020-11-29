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
#Include %A_ScriptDir%\lib\hsv.ahk

+::
    color := Utility.GetColor(663 + (2*39) + 16, 857)
    HSL_FromRGB(color, h)
    tooltip % color "," h
    return

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
    IsLunarSlashAvailable()
    {
        return Utility.GetColor(821,894) == "0xFFE683"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1035,894) == "0xFF4D2F"
    }

    IsHonedSlashAvailable()
    {
        return Utility.GetColor(1148,894) == "0x8A1201"
    }

    IsSunderingSwordAvailable()
    {
        return Utility.GetColor(885,961) == "0x97928C"
    }

    IsOneStrikeTenCutsAvailable()
    {
        return Utility.GetColor(985,961) == "0x4A0040"
    }

    IsBladeCallAvailable()
    {
        ; start of cd icons
        cdIconStartPos := 663
        Loop, 10
        {
            startPos := cdIconStartPos + (A_Index - 1) * 39
            if (A_Index > 6) {
                startPos += 1
            }

            Utility.GetColor(startPos+15, 858, r, g, b)
            if(r > 80 && r < 120 && g > 160 && g < 200 && b > 180 && b < 220) {
                return false
            }
        }
        return true
    }

    ShouldReduceLunarSlashCooldown()
    {
        return Utility.GetColor(594,911) != "0x01C1FF"
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
        return Utility.GetColor(558,921) == "0xFFBA01" && Utility.GetColor(557,918) != "0xFFBA01"
    }

    IsSoulProced()
    {
        ; check for soul duration progress bar
        return Utility.GetColor(543,915) == "0x01C1FF"
    }

    IsTalismanAvailable()
    {
        ; check for talisman cooldown border
        return Utility.GetColor(559,635) != "0xE46B14"
    }
}

; skill bindings
class Skills {
    HonedSlash() {
        send r
    }

    BleedingEdge() {
        send t
    }

    LunarSlash() {
        send {tab}
    }

    LightningDraw() {
        send 4
    }

    SunderingSword() {
        send z
    }

    OneStrikeTenCuts() {
        send c
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
        Skills.HonedSlash()
        sleep 5

        Skills.BleedingEdge()
        sleep 5

        if (Availability.IsLightningDrawAvailable()) {
            Skills.LightningDraw()
            sleep 5
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (Availability.ShouldReduceLunarSlashCooldown()) {
            if (!Availability.IsLunarSlashAvailable()) {
                if (Availability.IsSunderingSwordAvailable()) {
                    Skills.SunderingSword()
                    sleep 5
                } else {
                    if (Availability.IsOneStrikeTenCutsAvailable()) {
                        Skills.OneStrikeTenCuts()
                        sleep 5
                    }
                }
            }
        }

        tooltip % Availability.IsBladeCallAvailable()

        if (Availability.IsBraceletCloseToExpiration()) {
            ; bracelet effect close to expiring, use it before it fully expired to avoid bracelet effect bug
            Rotations.Bracelet()
        }

        if (Availability.IsWeaponResetClose()) {
            ; activate bracelet right before a weapon reset
            Rotations.Bracelet()
        }

        Rotations.Default()

        return
    }

    ; activate starstrike and talisman if it's ready
    DpsPhase()
    {
        ; use spirit vortex before activating dps phase for exhilaration badge
        While (Utility.GameActive() && Availability.IsSpiritVortexAvailable() && GetKeyState("F23","p"))
        {
            Skills.SpiritVortex()
            sleep 5
        }

        ; use talisman while no cd border and keys are pressed
        While (Utility.GameActive() && Availability.IsTalismanAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 5
        }

        ; check skill border for cooldown, check for skill icon for stance and break if keys aren't pressed anymore
        ; while in stance and stance off cooldown send stance key
        While (Utility.GameActive() && Availability.IsStarstrikeAvailable() && GetKeyState("F23","p"))
        {
            ; use LMB if not used before activating the DPS phase to avoid LMB as first action after FS are available which caused some weird animation delays in my tests
            if (Availability.IsLmbAvailable() && !Availability.IsSwordFallAvailable()) {
                Skills.LMB()
                sleep 5    
            }
        
            Skills.Starstrike()
            sleep 5
        }
        
        ; try to use FS as the very first action
        Skills.RMB()
        sleep 5

        return
    }

    ; activate the bracelet
    Bracelet()
    {
        if (Availability.IsLunarSlashAvailable()) {
            Skills.LunarSlash()
            sleep 5
        }
    }
}