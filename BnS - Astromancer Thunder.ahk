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
    WaitForSoul() {
        return true
    }

    IsLMBAvailable() {
        return Utility.GetColor(1099,892) != "0xE46B14"
    }

    IsOrbitalStrikeAvailable() {
        color := Utility.GetColor(1149,698)
        ; normal and awakened orbital strike
        return color == "0x264A80" || color == "0x264A80"
    }

    IsFirstElectrifyAvailable() {
        return Utility.GetColor(935,894) == "0x5F8FCA"
    }

    IsSecondElectrifyAvailable() {
        return Utility.GetColor(935,894) == "0x2F7098"
    }

    IsThunderballAvailable() {
        return Utility.GetColor(1035,894) == "0x122AB0"
    }

    IsPortentAvailable() {
        return Utility.GetColor(1035,964) == "0x1C1C43"
    }

    IsPolarityAvailable()
    {
        return Utility.GetColor(821,894) == "0x44BBFF"
    }

    IsSupernovaAvailable() {
        return Utility.GetColor(1301,892) == "0x174278"
    }

    IsScourgeEffectActive() {
        ; raid badge effect scourge effect is only active for 10 seconds, so check for 5 second mark here
        return Utility.GetColor(598,902) == "0x01C1FF"
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

    OrbitalStrike() {
        send f
    }

    Electrify() {
        send 2
    }

    Thunderball() {
        send 4
    }

    Portent() {
        send v
    }

    Polarity() {
        send {Tab}
    }

    Supernova() {
        send g
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
        if (Availability.IsLMBAvailable()) {
            Skills.LMB()
            sleep 5
        }

        if (Availability.IsOrbitalStrikeAvailable()) {
            Skills.OrbitalStrike()
            sleep 5
        }

        if (Availability.IsFirstElectrifyAvailable() || Availability.IsSecondElectrifyAvailable()) {
            Skills.Electrify()
            sleep 5
        }

        if (Availability.IsThunderballAvailable() && !Availability.IsFirstElectrifyAvailable()) {
            Skills.Thunderball()
            sleep 5
        }

		Skills.RMB()
        sleep 5

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && (Availability.IsPolarityAvailable() && (!Availability.WaitForSoul() || Availability.IsSoulProced()))) {
            ; polarity is ready and soul active, use it
            Rotations.DpsPhase()
        }

        if (Availability.IsPortentAvailable()) {
            Skills.Portent()
            sleep 5
        }

        Rotations.Default()

        return
    }

    DpsPhase() {
        ; use talisman while no cd border and keys are pressed
        While (Utility.GameActive() && Availability.IsTalismanAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 5
        }

        ; loop while polarity is not on cooldown or break if keys aren't pressed anymore
        While (Utility.GameActive() && Availability.IsPolarityAvailable() && GetKeyState("F23","p"))
        {	
            Skills.Polarity()
            sleep 5
        }

        ; loop while polarity is not on cooldown or break if keys aren't pressed anymore
        While (Utility.GameActive() && Availability.IsSupernovaAvailable() && GetKeyState("F23","p"))
        {	
            Skills.Supernova()
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