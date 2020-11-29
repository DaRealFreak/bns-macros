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

; everything related to checking availability of skills or procs
class Availability
{
    IsBlueBuffAvailable()
    {
        ; check for color of BlueBuff skill icon
        return Utility.GetColor(824,910) == "0xEA6E60"
    }

    IsCometStrikeAvailable()
    {
        ; check for color of Comet Strike skill icon
        return Utility.GetColor(1037,899) == "0x8B4F24"
    }

    IsSearingPalmAvailable() {
        ; check for color of Comet Strike skill icon
        return Utility.GetColor(1040,911) == "0x12110C"
    }

    IsTremorAvailable()
    {
        ; check for color of Tremor skill icon
        return Utility.GetColor(1039,962) == "0xC67E5C"
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
    SearingDragon() {
        send x
    }

    Tremor() {
        send v
    }

    BlueBuff() {
        send {Tab}
    }

    CometStrike() {
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
        Skills.SearingDragon()
        sleep 5

        if (Availability.IsCometStrikeAvailable() || Availability.IsSearingPalmAvailable()) {
            Skills.CometStrike()
            sleep 5
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && (Availability.IsBlueBuffAvailable() && Availability.IsSoulProced())) {
            ; dps phase is ready and soul active, use it
            Rotations.DpsPhase()
        }

        Rotations.Default()

        ; use tremor in full rotation only to have a macro option where you don't want to use the tremor stun
        if (Availability.IsTremorAvailable()) {
            Skills.Tremor()
            sleep 5
        }

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

        return
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