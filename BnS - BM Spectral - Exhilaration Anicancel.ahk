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
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsGuardianBladesAvailable())
    {
        Skills.GuardianBlades()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
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

#IfWinActive ahk_class UnrealWindow
~f23 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsCometStepAvailable())
    {
        Skills.CometStep()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & 1::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsDeflectAvailable())
    {
        Skills.Deflect()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & v::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsSpiritVortexAvailable())
    {
        Skills.SpiritVortex()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsGuardianBladesAvailable())
    {
        Skills.GuardianBlades()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
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

#IfWinActive ahk_class UnrealWindow
~XButton2 & e::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsCometStepAvailable())
    {
        Skills.CometStep()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & 1::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsDeflectAvailable())
    {
        Skills.Deflect()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
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
        return false
    }

    IsStarstrikeAvailable()
    {
        return Utility.GetColor(825,887) == "0x192C47"
    }

    IsSpiritVortexAvailable()
    {
        return Utility.GetColor(1035,951) == "0x726DA1"
    }
    
    IsGuardianBladesAvailable()
    {
        return Utility.GetColor(987,951) == "0x697785"
    }

    IsBlindsideAvailable()
    {
        return Utility.GetColor(695,887) == "0xD2A6A8"
    }

    IsStrafeAvailable()
    {
        return Utility.GetColor(695,887) == "0xD2B8A6"
    }

    IsCometStepAvailable()
    {
        return Utility.GetColor(742,887) == "0x40436D"
    }

    IsEvadeAvailable()
    {
        return Utility.GetColor(695,950) == "0x73464A"
    }

    IsDeflectAvailable()
    {
        return Utility.GetColor(892,887) == "0x13181D"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1035,887) == "0x51388F"
    }

    IsSliceOnLmb()
    {
        col := Utility.GetColor(1095,887)
        return col == "0x090A2C" || col == "0x0B0B19"
    }

    IsFallingStarOnLmb()
    {
        col := Utility.GetColor(1095,887)
        return col == "0x11092A" || col == "0x0D0B18"
    }

    IsBraceletCloseToExpiration()
    {
        Utility.GetColor(663,819, r, g, b)
        return b < 240
    }

    IsInDpsPhase()
    {
        ; check falling stars for off cd and on cd
        col := Utility.GetColor(1147,897)
        return col == "0x150CA1" || col == "0x0D0B43"
    }

    IsBraceletActive()
    {
        return !Availability.IsBraceletCloseToExpiration()
    }

    IsBadgeEffectActive()
    {
        ; bracelet at break to 6 seconds
        Utility.GetColor(663,797, r, g, b)
        return b > 250
        ;return Utility.GetColor(682,798) == "0x04B1FE"
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
            if (!Availability.IsFallingStarOnLmb()) {
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
            if (!Availability.IsSliceOnLmb()) {
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

        ; check skill border for cooldown, check for skill icon for stance and break if keys aren't pressed anymore
        ; while in stance and stance off cooldown send stance key
        While (Utility.GameActive() && Availability.IsStarstrikeAvailable() && GetKeyState("F23","p"))
        {
            ; make sure talisman is activated together with starstrike
            loop, 2 {
                Skills.Talisman()
                sleep 5
            }

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