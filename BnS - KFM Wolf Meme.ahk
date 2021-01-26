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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsShadowDanceAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShadowDanceAvailable())
        {
            Skills.ShadowDance()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFootworkAvailable())
    {
        Skills.Footwork()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & c::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsFlurryAvailable())
    {
        Skills.Flurry()
        sleep 5
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    UseWolf()
    {
        ; if the gear is not high enough wolf is actually dmg loss, so here you can decide if you even want to use wolf
        return true
    }

    IsBlueBuffAvailable()
    {
        ; check for color of BlueBuff skill icon
        return Utility.GetColor(821,892) == "0x6B2A12"
    }

    IsIncinerateAvailable()
    {
        return Utility.GetColor(1035,892) == "0x6A1410"
    }

    IsSearingStompAvailable()
    {
        return Utility.GetColor(935,959) == "0xE73C30"
    }

    IsSearingStompOnLongCooldown()
    {
        return Utility.GetColor(917,979) == "0xD86613"
    }

    IsRampageAvailable()
    {
        return Utility.GetColor(1035,959) != "0xE46B14"
    }

    IsTitanStrikeAvailable()
    {
        return Utility.GetColor(1299,892) == "0x3F0504"
    }

    IsTitanSmiteAvailable()
    {
        return Utility.GetColor(1299,959) == "0xBE5320"
    }

    IsTwinPalmAvailable()
    {
        return Utility.GetColor(1150,691) == "0x7D2013"
    }

    IsWolfVisible()
    {
        color := Utility.GetColor(1035,961)
        return color == "0x04090E" || color == "0x070F18"
    }

    IsPackFrenzyAvailable()
    {
        return Utility.GetColor(1035,892) == "0x283749"
    }

    IsClawAvailable()
    {
        ; claw and awakened claw
        color := Utility.GetColor(1099,892)
        return color == "0x1E7798" || color == "0x297DA4"
    }

    IsIronPawAvailable()
    {
        ; both iron paw skills and both awakened iron paw skills
        color := Utility.GetColor(1148,892)
        return color == "0x0D2A55" || color == "0x0B234C" || color == "0x133268" || color == "0x0B234C"
    }

    IsShadowDanceAvailable()
    {
        ; shadow dance in normal stance and wolf
        return Utility.GetColor(682,892) == "0xB7280F" || Utility.GetColor(682,892) == "0x3F0309"
    }

    IsFootworkAvailable()
    {
        ; footwork in normal stance and wolf
        return Utility.GetColor(735,892) == "0xC5A792" || Utility.GetColor(735,892) == "0x030836"
    }

    IsFlurryAvailable()
    {
        return Utility.GetColor(985,959) == "0x190C0A"
    }

    IsCounterVisible()
    {
        color := Utility.GetColor(885,892)
        return color == "0xE4A172" || color == "0xE46B14"
    }

    IsGuidingFistVisible()
    {
        color := Utility.GetColor(935,892)
        return color == "0x544A42" || color == "0xE46B14" || color == "0x1B1B1B" || color == "0xB13A10"
    }

    IsLegSweepVisible()
    {
        color := Utility.GetColor(985,892)
        return color == "0x332E33" || color == "0xE46B14"
    }

    IsPackFrenzyVisible()
    {
        color := Utility.GetColor(1035,894)
        return color == "0x050B15" || color == "0x091325"
    }

    IsFinalComboHitVisible()
    {
        return Utility.GetColor(885,892) == "0x120B0A" || Utility.GetColor(935,892) == "0x130D09" || Utility.GetColor(985,892) == "0x150D09"
    }

    IsInCombo()
    {
        ; block or approach or knockdown available or on cd
        return (!Availability.IsGuidingFistVisible() || !Availability.IsLegSweepVisible() || !Availability.IsCounterVisible()) && !Availability.IsPackFrenzyVisible()
    }

    IsSoulProced()
    {
        ; check for soul duration progress bar
        return Utility.GetColor(517,915) == "0x01C1FF"
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

    SearingStomp() {
        send x
    }

    Rampage() {
        send v
    }

    TitanStrike() {
        send g
    }

    TitanSmite() {
        send b
    }

    Wolf() {
        send v
    }

    PackFrenzy() {
        send 4
    }

    Claw() {
        send r
    }

    IronPaw() {
        send t
    }

    ShadowDance() {
        send q
    }

    Footwork() {
        send e
    }

    Flurry() {
        send c
    }

    BlueBuff() {
        send {Tab}
    }

    Incinerate() {
        send 4
    }

    Talisman() {
        send 9
    }
}

; everything rotation related
class Rotations
{
    static comboIndex := 0

    ; default rotation without any logic for max counts
    Default()
    {
        if (Availability.UseWolf()) {
            if (Availability.IsPackFrenzyAvailable()) {
                this.comboIndex := 0
                Skills.PackFrenzy()
                sleep 5
                return
            } else {
                if (Availability.IsClawAvailable()) {
                    Skills.Claw()
                    sleep 5
                    return
                } else {
                    if (Availability.IsIronPawAvailable()) {
                        Skills.IronPaw()
                        sleep 5
                        return
                    }
                }
            }
        }

        ; sleep since final combo hit is on autocast
        if (Availability.IsFinalComboHitVisible()) {
            sleep 150
            return
        }

        if (!Availability.IsInCombo()) {
            if (Availability.IsIncinerateAvailable()) {
                Skills.Incinerate()
                sleep 5
            } else {
                ; searing stomp reduces incinerate cd, so don't use searing stomp if incinerate is available
                While (Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p")) && Availability.IsSearingStompAvailable()) {
                    Skills.SearingStomp()
                    sleep 5
                }

                ; rampage doesn't improve uptime on buffs and is currently dmg loss with the titan stance XML
                ;While (Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p")) && Availability.IsRampageAvailable() && Availability.IsSearingStompOnLongCooldown()) {
                ;    Skills.Rampage()
                ;    sleep 5
                ;}

                if (Availability.IsTitanStrikeAvailable()) {
                    if (this.comboIndex >= 3) {
                        this.comboIndex := 1
                    } else {
                        this.comboIndex += 1
                    }

                    While (Utility.GameActive() && (GetKeyState("F23","p") || GetKeyState("XButton2","p")) && Availability.IsTitanStrikeAvailable()) {
                        Skills.TitanStrike()
                        sleep 5
                    }
                }
            }
        } else {
            if (!Availability.IsCounterVisible() || !Availability.IsGuidingFistVisible() || !Availability.IsLegSweepVisible()) {
                send % this.comboIndex
                sleep 50
            }
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && (Availability.IsBlueBuffAvailable() && Availability.IsSoulProced() && (!Availability.UseWolf() || !Availability.IsInCombo()))) {
            ; dps phase is ready and soul active, use it
            Rotations.DpsPhase()
        }

        Rotations.Default()

        return
    }

    ; activate bluebuff and talisman if it's ready
    DpsPhase()
    {
        ; use talisman while no cd border and keys are pressed
        While (Utility.GameActive() && Availability.IsTalismanAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 5
        }

        ; loop while BlueBuff is not on cooldown or break if keys aren't pressed anymore
        While (Utility.GameActive() && Availability.IsBlueBuffAvailable() && GetKeyState("F23","p"))
        {    
            Skills.BlueBuff()
            sleep 5
        }

        if (Availability.UseWolf()) {
            While (Utility.GameActive() && !Availability.IsWolfVisible() && GetKeyState("F23","p"))
            {
                sleep 5
            }

            While (Utility.GameActive() && Availability.IsWolfVisible() && GetKeyState("F23","p"))
            {
                Skills.Wolf()
                sleep 5
            }
        }

        return
    }
}