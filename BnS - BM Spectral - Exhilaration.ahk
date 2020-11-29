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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
F1::
	MouseGetPos, mouseX, mouseY
	PixelGetColor, color, %mouseX%, %mouseY%, RGB
	StringRight color,color,10 ;
	Clipboard = %mouseX%, %OmouseY% %color%
	tooltip, Coordinate: %mouseX%`, %mouseY% `nHexColor: %color%
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

~f23 & s::
    If (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 200) {
        ; way to deal with input lags without releasing the macro
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsEvadeAvailable())
        {
            Skills.Evade()
            sleep 5
        }
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

; everything related to checking availability of skills or procs
class Availability
{
    IsStarstrikeAvailable()
    {
        ; check for color of Starstrike skill icon and cooldown color
        return Utility.GetColor(880,980) == "0x0A3EE7" && Utility.GetColor(885,960) != "0x6D3A20"
    }

    IsSwordFallAvailable()
    {
        return Utility.GetColor(1107,912) == "0x130B41"
    }

    IsSpiritVortexAvailable()
    {
        return Utility.GetColor(1036,963) == "0x2828C9"
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

    IsLmbAvailable()
    {
        lmbColor := Utility.GetColor(1103,906)
        return lmbColor == "0x9FA6B1" || lmbColor == "0x1D4DB8"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1036,895) != "0x2B1A80"
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
        return Utility.GetColor(559,635) != "0xE46B14"
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
        send y
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
    static lastLightningDrawUse := 0

    ; default rotation without any logic for max counts
    Default()
    {
        Skills.RMB()
        sleep 5

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        usedLightningDraw := false

        if (Availability.IsBraceletCloseToExpiration()) {
            ; bracelet effect close to expiring, use it before it fully expired to avoid bracelet effect bug
            Rotations.Bracelet()
        }

        if (useDpsPhase && (Availability.IsStarstrikeAvailable() && Availability.IsSoulProced())) {
            ; dps phase is ready and soul active, use it
            Rotations.DpsPhase()
        }

        if (Availability.IsWeaponResetClose()) {
            if (Availability.IsLightningDrawAvailable()) {
                Skills.LightningDraw()
                sleep 5
                usedLightningDraw = true
            }

            ; activate bracelet right before a weapon reset
            Rotations.Bracelet()
        }

        if (Availability.IsLightningDrawAvailable() && A_TickCount > this.lastLightningDrawUse + 8000) {
            Skills.LightningDraw()
            sleep 5

            usedLightningDraw = true
        }

        Rotations.Default()

        ; wait until Spirit Vortex went through without blocking (would lose FS/Slice counts) or use it if we still have bracelet uptime
        if (Availability.IsLmbAvailable() && (!(Availability.IsSwordFallAvailable() && Availability.IsSpiritVortexAvailable()) || Availability.IsBraceletActive())) {
            Skills.LMB()
            sleep 5    
        }

        if (!Availability.IsLightningDrawAvailable() && usedLightningDraw) {
            this.lastLightningDrawUse := A_TickCount
        }

        return
    }

    ; activate starstrike and talisman if it's ready
    DpsPhase()
    {
        ; use lightning draw activating dps phase for exhilaration badge (no animation so use it first)
        While (Utility.GameActive() && Availability.IsLightningDrawAvailable() && GetKeyState("F23","p"))
        {
            Skills.LightningDraw()
            sleep 5
            this.lastLightningDrawUse := A_TickCount
        }

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
        if (Availability.IsSpiritVortexAvailable()) {
            Skills.SpiritVortex()
            sleep 5
        }
    }
}

; everything utility related
class Utility
{
    ;return the color at the passed position
    GetColor(x,y)
    {
        PixelGetColor, color, x, y, RGB
        StringRight color,color,10
        Return color
    }

    ;check if BnS is the current active window
    GameActive()
    {
        Return WinActive("ahk_class LaunchUnrealUWindowsClient")
    }
}