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
    if (Availability.ScriptStrafes()) {
    	Settimer, Strafes, 15
    }

	While (Utility.GameActive() && GetKeyState("F23","p"))
	{
		Rotations.FullRotation(true)
	}

    if (Availability.ScriptStrafes()) {
        SetTimer, Strafes, Off
    }

	return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton2::
    if (Availability.ScriptStrafes()) {
    	Settimer, Strafes, 15
    }
    
    While (Utility.GameActive() && GetKeyState("XButton2","p"))
	{
		Rotations.FullRotation(false)
	}

    if (Availability.ScriptStrafes()) {
        SetTimer, Strafes, Off
    }

	return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton1::
	While (Utility.GameActive() && GetKeyState("XButton1","p"))
	{
		Rotations.Default()
	}
	return

Strafes:
    Rotations.Strafes()
    return

; everything related to checking availability of skills or procs
class Availability
{
    WaitForSoul() {
        return false
    }

    ScriptStrafes() {
        return false
    }

    IsSolarizeAvailable() {
        return Utility.GetColor(821,895) == "0x784800"
    }

    IsDynamiteOrFireworksAvailable() {
        color := Utility.GetColor(885,962)
        return color == "0x0D525D" || color == "0x69390F"
    }

    IsDawnstrikeAvailable() {
        return Utility.GetColor(935,962) == "0x8F5D19"
    }

    IsReverberationAvailable() {
        return Utility.GetColor(985,962) == "0xBD8F56"
    }

    IsStrafeLeftAvailable() {
        return Utility.GetColor(682,895) == "0x794C29"
    }

    HasStrafeLeftCooldownTimer() {
        if (Utility.GetColor(678,911) == "0xECEBEA") {
            return true
        }
        return false
    }

    IsStrafeLeftAvailableOrClose() {
        return Utility.GetColor(692,909) == "0xCC9C6E"
    }

    IsStrafeRightAvailable() {
        return Utility.GetColor(735,895) == "0xBE6F5D"
    }

    HasStrafeRightCooldownTimer() {
        if (Utility.GetColor(731,911) == "0xECEBEA") {
            return true
        }
        return false
    }

    IsStrafeRightAvailableOrClose() {
        return Utility.GetColor(745,907) == "0x674F47"
    }

    IsLMBAvailable() {
        return Utility.GetColor(1099,894) == "0x712113"
    }

    IsRMBAvailable() {
        color := Utility.GetColor(1146,895)
        return color == "0x878443" || color == "0x88733A"
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
        return Utility.GetColor(558,920) == "0xFFBA01" && Utility.GetColor(557,919) != "0xFFBA01"
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

    StrafeLeft() {
        send q
    }

    StrafeRight() {
        send e
    }

    Sunburst() {
        send 4
    }

    Reverberation() {
        send c
    }

    Dawnstrike() {
        send x
    }

    Solarize() {
        send {Tab}
    }

    Fireworks() {
        send z
    }

	Talisman() {
		send 9
	}
}

; everything rotation related
class Rotations
{
    Strafes()
    {
        static strafeCount := 0
        static strafeDirection := 1
        static lastStrafe := A_TickCount
        static firstStrafe := true

        ; switch direction after the 2nd (fast) strafe
        if (strafeCount >= 2) {
            strafeDirection := !strafeDirection
            strafeCount := 0
            lastStrafe := 0
        }

        if (Availability.IsWeaponResetClose()) {
            strafeCount := 0
            strafeDirection := 1
            lastStrafe := A_TickCount
            firstStrafe := true
            sleep 25
        }

        if (!Availability.IsWeaponResetClose()) {
            if (strafeDirection) {
                ; set count to 2 if we have the long cooldown to trigger the strafe direction toggle
                if (Availability.HasStrafeLeftCooldownTimer()) {
                    strafeCount := 2
                    firstStrafe := false
                }

                if (strafeCount == 1 && firstStrafe) {
                    if (Availability.IsStrafeRightAvailable() && A_TickCount - lastStrafe > 1500) {
                        While (Utility.GameActive() && Availability.IsStrafeRightAvailable()) {
                            Skills.StrafeRight()
                            sleep 5
                        }
                        firstStrafe := false
                        strafeCount := 1
                        strafeDirection := !strafeDirection
                    }
                }

                if (Availability.IsStrafeLeftAvailable()
                    && ((strafeCount == 0) || (strafeCount == 1 && !firstStrafe && Availability.IsStrafeRightAvailable()))) {
                    While (Utility.GameActive() && Availability.IsStrafeLeftAvailable()) {
                        Skills.StrafeLeft()
                        sleep 5
                    }
                    strafeCount := strafeCount + 1
                    lastStrafe := A_TickCount
                }
            } else {
                ; set count to 2 if we have the long cooldown to trigger the strafe direction toggle
                if (Availability.HasStrafeRightCooldownTimer()) {
                    strafeCount := 2
                    firstStrafe := false
                }
                
                if (strafeCount == 1 && firstStrafe) {
                    if (Availability.IsStrafeLeftAvailable() && A_TickCount - lastStrafe > 1500) {
                        While (Utility.GameActive() && Availability.IsStrafeLeftAvailable()) {
                            Skills.StrafeLeft()
                            sleep 5
                        }
                        firstStrafe := false
                        strafeCount := 1
                        strafeDirection := !strafeDirection
                    }
                }

                if (Availability.IsStrafeRightAvailable()
                    && ((strafeCount == 0) || (strafeCount == 1 && !firstStrafe && Availability.IsStrafeLeftAvailable()))) {
                    While (Utility.GameActive() && Availability.IsStrafeRightAvailable()) {
                        Skills.StrafeRight()
                        sleep 5
                    }
                    strafeCount := strafeCount + 1
                    lastStrafe := A_TickCount
                }
            }
        }
    }

    ; default rotation without any logic for max counts
    Default()
    {
        Skills.RMB()
        sleep 5

        Skills.Sunburst()
        sleep 5

        if (Availability.IsLMBAvailable()) {
            Skills.LMB()
            sleep 5
        }

        if (Availability.IsReverberationAvailable()) {
            Skills.Reverberation()
            sleep 5
        }

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        if (useDpsPhase && (!Availability.WaitForSoul() || Availability.IsSoulProced()) && Availability.IsSolarizeAvailable()) {
            ; dps phase is ready and soul active, use it
            Skills.Solarize()
            sleep 5
        }

        if (useDpsPhase && Availability.IsDynamiteOrFireworksAvailable()) {
            Skills.Fireworks()
            sleep 5
        }

        if (useDpsPhase && Availability.IsTalismanAvailable()) {
            Skills.Talisman()
            sleep 5
        }

        if (Availability.IsBraceletCloseToExpiration() && Availability.IsDawnstrikeAvailable()) {
            Skills.Dawnstrike()
            sleep 5
        }

        Rotations.Default()

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