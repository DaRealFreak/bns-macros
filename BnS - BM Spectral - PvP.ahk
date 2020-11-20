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

aircombo := 0
#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton2::
    global aircombo
    aircombo := !aircombo
    if (aircombo) {
        tooltip "activating automatic double air combo"
    	SetTimer, RemoveToolTip, 1000
        SetTimer, DoubleAirCombo, 0
    } else {
        tooltip "deactivating automatic double air combo"
    	SetTimer, RemoveToolTip, 1000
        SetTimer, DoubleAirCombo, off
    }
	return

DoubleAirCombo:
    Rotations.DoubleAirCombo()
    return

autoEscape := 0
#IfWinActive ahk_class LaunchUnrealUWindowsClient
$XButton1::
    global autoEscape
    autoEscape := !autoEscape
    if (autoEscape) {
        tooltip "activating automatic escape"
    	SetTimer, RemoveToolTip, 1000
        SetTimer, AutoEscape, 0
    } else {
        tooltip "deactivating automatic escape"
    	SetTimer, RemoveToolTip, 1000
        SetTimer, AutoEscape, off
    }
	return

AutoEscape:
    Rotations.Escape()
    return

; everything related to checking availability of skills or procs
class Availability
{
    UsingExhilarationBadge()
    {
        ; if we use exhilaration badge we can reset spirit vortex for triple air combo
        return true
    }

    IsCCed()
    {
        return Utility.GetColor(1035,894) == "0x222322"
    }

    IsStunned()
    {
        return Utility.GetColor(885,894) == "0x242524"
    }

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

    IsTakeFlightAvailable()
    {
        return Utility.GetColor(1150,697) == "0x6188EB"
    }

    IsRisingEagleAvailable()
    {
        return Utility.GetColor(1099,894) == "0x043F55"
    }

    IsAscendAvailable()
    {
        return Utility.GetColor(1099,894) == "0x747674"
    }

    IsRollAvailable()
    {
        return Utility.GetColor(1150,697) == "0xB48284"
    }

    IsCounterStrikeAvailable()
    {
        return Utility.GetColor(985,894) == "0x000000"
    }

    IsWhirlAvailable()
    {
        return Utility.GetColor(885,894) == "0x24211E"
    }

    IsSecondWindAvailable()
    {
        return Utility.GetColor(821,894) == "0x747E8C"
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

    RisingEagle() {
        send r
    }

    Ascend() {
        send r
    }

    TakeFlight() {
        send f
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

    DoubleAirCombo() 
    {
        static ascend := 0
        static doubleAir := 0

        ; take flight condition (knock up)
        if (Availability.IsTakeFlightAvailable()) {
            While (Utility.GameActive() && Availability.IsTakeFlightAvailable()) {
                Skills.TakeFlight()
                sleep 5
            }
        }

        ; rising eagle conditions (first extension)
        if (Availability.IsRisingEagleAvailable()) {
            While (Utility.GameActive() && Availability.IsRisingEagleAvailable()) {
                Skills.RisingEagle()
                sleep 5
            }
        }

        ; ascend conditions (second extension)
        if (Availability.IsAscendAvailable() && ascend == 0) {
            ascend := A_TickCount+1350
        }

        if (A_TickCount >= ascend && ascend != 0) {
            ascend := 0
            ; not ready, probably after double air combo already
            if (!Availability.IsAscendAvailable()) {
                return
            }

            While (Utility.GameActive() && Availability.IsAscendAvailable()) {
                Skills.Ascend()
                sleep 5
            }

            doubleAir := A_TickCount+1950
        }

        ; spirit vortex conditions
        if (A_TickCount >= doubleAir && doubleAir != 0) {
            Rotations.Aircombo()
            doubleAir := 0
        }
    }

    Escape()
    {
        ; priorities kd'ed: tab
        ; priorities stunned: F -> TAB -> 3 -> 1
        if (Availability.IsCCed()) {
            if (Availability.IsStunned()) {
                send {tab}
                sleep 5
            } else {
                if (Availability.IsRollAvailable()) {
                    While (Utility.GameActive() && Availability.IsRollAvailable()) {
                        send f
                        sleep 5
                    }
                } else {
                    send {tab}
                }

                if (Availability.IsSecondWindAvailable()) {
                    While (Utility.GameActive() && Availability.IsSecondWindAvailable()) {
                        send {tab}
                        sleep 5
                    }
                }

                if (Availability.IsCounterStrikeAvailable()) {
                    While (Utility.GameActive() && Availability.IsCounterStrikeAvailable()) {
                        send 3
                        sleep 5
                    }
                }

                if (Availability.IsWhirlAvailable()) {
                    While (Utility.GameActive() && Availability.IsWhirlAvailable()) {
                        send 1
                        sleep 5
                    }
                }
            }
        }
    }

    Aircombo()
    {
        If (Availability.UsingExhilarationBadge()) {
            While (Utility.GameActive() && !Availability.IsSpiritVortexAvailable() && Availability.IsStarstrikeAvailable()) {
                Skills.Starstrike()
                sleep 5
            }
        }

        While (Utility.GameActive() && Availability.IsSpiritVortexAvailable()) {
            Skills.SpiritVortex()
            sleep 5
        }

        While (Utility.GameActive() && Availability.IsTalismanAvailable())
        {
            Skills.Talisman()
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