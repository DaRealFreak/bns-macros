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
		Rotations.Default()
	}
	return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton2::
	While (Utility.GameActive() && GetKeyState("XButton2","p"))
	{
        Rotations.DpsPhase()
	}
	return
	
#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton1::
	While (Utility.GameActive() && GetKeyState("XButton1","p"))
	{
		Rotations.Bracelet()
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

    IsLmbAvailable()
    {
        lmbColor := Utility.GetColor(1103,906)
        return lmbColor == "0x9FA6B1" || lmbColor == "0x1D4DB8"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1036,895) != "0x2B1A80"
    }

    IsSpiritVortexAvailable()
    {
        return Utility.GetColor(1036,963) == "0x2828C9"
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
        sleep 10

        if (Availability.IsLightningDrawAvailable()) {
            Skills.LightningDraw()
            sleep 10
        }
        
        if (Availability.IsLmbAvailable()) {
            Skills.LMB()
            sleep 10
        }

        return
    }

    ; activate starstrike and talisman if it's ready
    DpsPhase()
    {
        if (Availability.IsStarstrikeAvailable()) {
            Skills.Starstrike()
            sleep 5
        }

        if (Availability.IsTalismanAvailable()) {
            Skills.Talisman()
            sleep 5
        }

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