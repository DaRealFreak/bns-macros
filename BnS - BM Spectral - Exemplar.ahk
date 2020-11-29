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
    StringRight color,color,10
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

    IsLmbAvailable()
    {
        lmbColor := Utility.GetColor(1103,906)
        return lmbColor == "0x9FA6B1" || lmbColor == "0x1D4DB8"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1036,895) != "0x2B1A80"
    }


    IsSoulProced()
    {
        return Utility.GetColor(543,915) == "0x01C1FF"
    }

    IsTalismanAvailable()
    {
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

    SpiritVortex() {
        send v
    }

    Starstrike() {
        send y
    }

    LightningDraw() {
        send 4
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
        sleep 14

        if (Availability.IsLightningDrawAvailable()) {
            Skills.LightningDraw()
            sleep 14
        }

        if (Availability.IsSpiritVortexAvailable()) {
            Skills.SpiritVortex()
            sleep 14
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && (Availability.IsStarstrikeAvailable() && Availability.IsSoulProced())) {
            ; dps phase is ready and soul active, use it
            Rotations.DpsPhase()
        }

        Rotations.Default()

        ; wait until Spirit Vortex went through without blocking (would lose FS/Slice counts)
        if (Availability.IsLmbAvailable() && !(Availability.IsSwordFallAvailable() && Availability.IsSpiritVortexAvailable())) {
            Skills.LMB()
            sleep 14    
        }

        return
    }

    ; activate starstrike and talisman if it's ready
    DpsPhase()
    {
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
}

; everything utility related
class Utility
{
    ; return the color at the passed position
    GetColor(x,y)
    {
        PixelGetColor, color, x, y, RGB
        StringRight color,color,10
        return color
    }

    ; check if BnS is the current active window
    GameActive()
    {
        return WinActive("ahk_class LaunchUnrealUWindowsClient")
    }
}