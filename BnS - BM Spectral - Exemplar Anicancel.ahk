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
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsGuardianBladesAvailable())
    {
        Skills.GuardianBlades()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsBlindsideAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsBlindsideAvailable())
        {
            Skills.Blindside()
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
~f23 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsCometStepAvailable())
    {
        Skills.CometStep()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & 1::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsDeflectAvailable())
    {
        Skills.Deflect()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & v::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsSpiritVortexAvailable())
    {
        Skills.SpiritVortex()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~XButton2 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsGuardianBladesAvailable())
    {
        Skills.GuardianBlades()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~XButton2 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsBlindsideAvailable()) {
        While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsBlindsideAvailable())
        {
            Skills.Blindside()
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
~XButton2 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsCometStepAvailable())
    {
        Skills.CometStep()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~XButton2 & 1::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsDeflectAvailable())
    {
        Skills.Deflect()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~XButton2 & v::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsSpiritVortexAvailable())
    {
        Skills.SpiritVortex()
        sleep 5
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    KeepBadgeEffectUp()
    {
        return true
    }

    IsStarstrikeAvailable()
    {
        ;return Utility.GetColor(885,961) == "0x080F46"
        return Utility.GetColor(821,894) == "0x060C42"
    }

    IsSpiritVortexAvailable()
    {
        return Utility.GetColor(1035,961) == "0x241AA2"
    }
    
    IsGuardianBladesAvailable()
    {
        return Utility.GetColor(985,961) == "0x081A30"
    }

    IsBlindsideAvailable()
    {
        return Utility.GetColor(682,894) == "0xEBB0BA"
    }

    IsStrafeAvailable()
    {
        return Utility.GetColor(682,894) == "0xEDCEB5"
    }

    IsCometStepAvailable()
    {
        return Utility.GetColor(735,894) == "0x332769"
    }

    IsEvadeAvailable()
    {
        return Utility.GetColor(682,961) == "0x875049"
    }

    IsDeflectAvailable()
    {
        return Utility.GetColor(885,894) == "0x001A2A"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1036,895) != "0x2B1A80"
    }

    IsBraceletCloseToExpiration()
    {
        return Utility.GetColor(596,921) != "0x01C1FF"
    }

    IsInDpsPhase()
    {
        ; check falling stars for off cd and on cd
        return Utility.GetColor(1148,894) == "0x26267D" || Utility.GetColor(1148,894) == "0x151546"
    }

    IsBraceletActive()
    {
        return !Availability.IsBraceletCloseToExpiration()
    }

    IsBadgeEffectActive()
    {
        ; bracelet at break to 6 seconds
        return Utility.GetColor(601,900) == "0x01C1FF"
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

    Blindside() {
        send q
    }

    Strafe() {
        send q
    }

    CometStep() {
        send e
    }

    Deflect() {
        send 1
    }

    SpiritVortex() {
        send v
    }

    Starstrike() {
        send {tab}
    }

    LightningDraw() {
        send 4
    }

    GuardianBlades() {
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
    static usedLightningDraw := false
    static lastLightningDrawUse := 0

    ; default rotation without any logic for max counts
    Default()
    {
        Skills.RMB()
        Skills.LMB()
        sleep 5

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        lightningDrawAvailable := Availability.IsLightningDrawAvailable()
        spiritVortexAvailable := Availability.IsSpiritVortexAvailable()
        weaponResetClose := Availability.IsWeaponResetClose()

        if (this.usedLightningDraw && !lightningDrawAvailable) {
            this.usedLightningDraw := false
            this.lastLightningDrawUse := A_TickCount
        }

        if (A_TickCount > this.lastLightningDrawUse + 7500) {
            shouldRefreshLightningDraw := true
        } else {
            shouldRefreshLightningDraw := false
        }

        if (Availability.IsInDpsPhase()) {
            ; FS not visible on LMB so we're on the 3rd or 4th hit
            if (!(Utility.GetColor(1099,894) == "0x1A0461" || Utility.GetColor(1099,894) == "0x0F0336")) {
                if (spiritVortexAvailable && (!Availability.IsBadgeEffectActive() || weaponResetClose)) {
                    ; bracelet effect close to expiring, use it before it fully expired to avoid bracelet effect bug
                    Rotations.Bracelet()
                } else if (lightningDrawAvailable && (shouldRefreshLightningDraw || weaponResetClose)) {
                    Skills.LightningDraw()
                    this.usedLightningDraw := true
                } else {
                    Skills.LMB()
                }

                Skills.RMB()
                sleep 1
            } else {
                Skills.RMB()
                sleep 1
            }

            return
        } else {
            if (useDpsPhase && (Availability.IsStarstrikeAvailable() && Availability.IsSoulProced())) {
                ; dps phase is ready and soul active, use it
                Rotations.DpsPhase()
                return
            }

            ; Slice not visible on LMB so we're on the 3rd or 4th hit
            if (!(Utility.GetColor(1099,894) == "0x07388C" || Utility.GetColor(1099,894) == "0x041F4E")) {
                if (spiritVortexAvailable && ((Availability.KeepBadgeEffectUp() && !Availability.IsBadgeEffectActive()) || (!Availability.KeepBadgeEffectUp() && Availability.IsBraceletCloseToExpiration()) || weaponResetClose)) {
                    ; bracelet/badge effect close to expiring, use it before it fully expired to avoid bracelet effect bug
                    Rotations.Bracelet()
                } else if (lightningDrawAvailable && (shouldRefreshLightningDraw || weaponResetClose)) {
                    Skills.LightningDraw()
                    this.usedLightningDraw := true
                } else {
                    Skills.LMB()
                }

                Skills.RMB()
                sleep 1
            } else {
                Skills.RMB()
                sleep 1
            }

            return
        }
    }

    ; activate starstrike and talisman if it's ready
    DpsPhase()
    {
        ; use spirit vortex before activating dps phase for exhilaration badge
        While (Utility.GameActive() && Availability.IsSpiritVortexAvailable() && GetKeyState("F23","p"))
        {
            Skills.SpiritVortex()
            sleep 1
        }

        ; use lightning draw for additional crit dmg
        While (Utility.GameActive() && Availability.IsLightningDrawAvailable() && GetKeyState("F23","p"))
        {
            Skills.LightningDraw()
            sleep 1
            this.lastLightningDrawUse := A_TickCount
        }

        ; use talisman while no cd border and keys are pressed
        While (Utility.GameActive() && Availability.IsTalismanAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 1
        }

        ; check skill border for cooldown, check for skill icon for stance and break if keys aren't pressed anymore
        ; while in stance and stance off cooldown send stance key
        While (Utility.GameActive() && Availability.IsStarstrikeAvailable() && GetKeyState("F23","p"))
        {
            Skills.Starstrike()
            sleep 1
        }
        
        ; try to use FS as the very first action
        Skills.RMB()

        return
    }

    ; activate the bracelet
    Bracelet()
    {
        if (Availability.IsSpiritVortexAvailable()) {
            Skills.SpiritVortex()
        }
    }
}