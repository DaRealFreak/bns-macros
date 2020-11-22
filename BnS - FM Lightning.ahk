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
	color := Utility.GetColor(mouseX, mouseY, r, g, b)
	tooltip, Coordinate: %mouseX%`, %mouseY% `nHexColor: %color%`nR:%r% G:%g% B:%b%
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
	GetStance()
	{
		electrocuteColor := Utility.GetColor(885,961)
		voltSalvoColor := Utility.GetColor(1148,693)
		; electrocute color checks: available, available on cd, unavailable, unavailable on cd, locked (overcharge mode)
		if (electrocuteColor != "0x2F1D0E" && electrocuteColor != "0x1A1008" 
			&& electrocuteColor != "0x0B0B0B" && electrocuteColor != "0x070707" 
			&& electrocuteColor != "0x242524") {
			return "godmode"
		}
		
		; volt salvo color checks: available, available on cd
		if (voltSalvoColor == "0x131A2C" || voltSalvoColor == "0x0B0F19") {
			return "overcharge"
		}

		return "default"
	}
	
	IsInStanceChange() {
		zapColor := Utility.GetColor(935,894)
		if (zapColor == "0xDAC894" || zapColor == "0x796F52" || zapColor == "0xFEFEFD" || zapColor == "0x8D8D8C" || zapColor == "0x372B0C" || zapColor == "0x1F1807") {
			return false
		}

		return true
	}

	IsMagnetizeAvailable() {
		magnetizeColor := Utility.GetColor(1035,894)
		return magnetizeColor == "0x395A9D" || magnetizeColor == "0x39849D"
	}

	IsZapAvailable() {
		zapColor := Utility.GetColor(935,894)
		return zapColor == "0xDAC894" || zapColor == "0xFEFEFD" || zapColor == "0x372B0C"
	}

	IsLightningPalmAvailable() {
		rmbColor := Utility.GetColor(1148,894)
		return rmbColor == "0x19180E" || rmbColor == "0x2B2410"
	}

	IsThunderCloudAvailable() {
		color := Utility.GetColor(985,961)
		return color == "0x7D613C" || color == "0xA68944"
	}

	IsLightningStrikeAvailable() {
		color := Utility.GetColor(935,961)
		return color == "0x0C1218" || color == "0x0B0B0C" || color == "0x0F1519"
	}

	IsElectrocuteAvailable() {
		return Utility.GetColor(885,961) == "0x2F1D0E"
	}

	IsEnemyGalvanized() {
		; start of debuff icons
		debuffIconStartPos := 763
		Loop, 10
		{
			startPos := debuffIconStartPos + (A_Index - 1) * 37
			topColor := Utility.GetColor(startPos + 4, 118)

			vblue := (topColor & 0xFF)
			vgreen := ((topColor & 0xFF00) >> 8)
			vred := ((topColor & 0xFF0000) >> 16)

			; debuff with moderate dark moderate blue found, check bottom color too
			if (vred < 50 && vgreen < 100 && vgreen > 50 && vblue > 100) {
				bottomColor := Utility.GetColor(startPos + 4, 136)
				vblue := (bottomColor & 0xFF)
				vgreen := ((bottomColor & 0xFF00) >> 8)
				vred := ((bottomColor & 0xFF0000) >> 16)

				; dark moderate violet found, return true assuming that the enemy is galvanized
				if (vred > 50 && vred < 100 && vgreen < 70 && vgreen > 20 && vblue > 100) {
					return true
				}
			}
		}
		return false
	}

	IsOverchargeEnding() {
		if (((Utility.GetColor(894, 757) & 0xFF0000) >> 16) > 150) {
			if (((Utility.GetColor(918, 749) & 0xFF0000) >> 16) < 150) {
				return true
			}
		}
		return false
	}

	IsGodmodeEnding() {
		leftColor := Utility.GetColor(894, 757)
		if (((leftColor & 0xFF00) >> 8) > 150 && ((leftColor & 0xFF0000) >> 16) > 150) {
			rightColor := Utility.GetColor(906, 751)
			if (((rightColor & 0xFF00) >> 8) < 150 && ((rightColor & 0xFF0000) >> 16) < 150) {
				return true
			}
		}
		return false
	}

	IsLightningStormAvailable() {
		color := Utility.GetColor(1035,961)
		return color == "0x4F4D40" || color == "0x505658" || color == "0x5E6A70"
	}

	IsVoltSalvoAvailable() {
		return Utility.GetColor(1148,693) == "0x131A2C"
	}

	IsGodModeAvailable() {
		return Utility.GetColor(1099,894) == "0x332E2E"
	}

	IsGodModeClose() {
		return true
	}

	IsStormWrathAvailable() {
		return Utility.GetColor(1148,693) == "0xDFC9AC"
	}

	IsChargeOnCooldown() {
		return Utility.GetColor(1099,892) == "0xE46B14"
	}

	IsOverchargeAvailable() {
		chargeColor := Utility.GetColor(1099,894)
		return chargeColor == "0x5178B4" || chargeColor == "0x2D4364"
	}

	GetGodModeCd() {
		; start of cd icons
		debuffIconStartPos := 663
		Loop, 10
		{
			startPos := debuffIconStartPos + (A_Index - 1) * 39
			Utility.GetColor(startPos + 25, 855, tr, tg, tb)
			Utility.GetColor(startPos + 25, 871, br, bg, bb)
			if (br > 120 && br < 160 && bg > 120 && bg < 160 && bb > 120 && bb < 160) {
				return "long"
			} else if (tr > 240 && tg > 220 && tb > 170 && tb < 200) {
				return "short"
			} else if (br > 230 && bg > 230 && bb > 230) {
				return "shortWaiting"
			}
		}
		return "off"
	}

	IsUltrashockAvailable() {
		return Utility.GetColor(985,961) == "0x1E8FDE"
	}

	IsUltrashockCasting() {
		return Utility.GetColor(453,962) == "0xF5B20C"
	}

	IsUltrashockOnCooldown() {
		ImageSearch, FoundX, FoundY, 600, 800, 1000, 900, Bns - FM Lightning Ultrashock.png
        return ErrorLevel = 0
	}

    IsWeaponResetClose()
    {
        ; check for weapon reset cooldown (slightly above and below to see if the reset is close)
        return Utility.GetColor(558,921) == "0xFFBA01" && Utility.GetColor(557,918) != "0xFFBA01"
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

	Zap() {
		send 2
	}

	Magnetize() {
		send 4
	}

	VoltSalvo() {
		send f
	}

	StormWrath() {
		send f
	}

	Electrocute() {
		send y
	}

	LightningStrike() {
		send x
	}

	ThunderCloud() {
		send c
	}

	LightningStorm() {
		send v
	}

	Ultrashock() {
		send c
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
		static lastStormCloud := 0
		stance := Availability.GetStance()
		stanceChange := Availability.IsInStanceChange()

		if (Availability.IsWeaponResetClose()) {
			; activate lightning storm right before a weapon reset
			While (Utility.GameActive() && Availability.IsLightningStormAvailable() && GetKeyState("F23","p"))
			{
				Skills.LightningStorm()
				sleep 5
			}
		}

		; separate if condition in case reset happened before we can check for lightning strike
		if (Availability.IsWeaponResetClose()) {
			; activate lightning strike right before a weapon reset
			While (Utility.GameActive() && Availability.IsLightningStrikeAvailable() && GetKeyState("F23","p"))
			{
				Skills.LightningStorm()
				sleep 5
			}
		}

		; can't check for availability in stance change since the skillbar moves, so just default macro here
		if (stanceChange) {
			Skills.RMB()
			sleep 5

			Skills.Zap()
			sleep 5

			Skills.Magnetize()
			sleep 5
		} else {
			if (Availability.IsZapAvailable()) {
				Skills.Zap()
				sleep 5
			}

			if (Availability.IsLightningPalmAvailable()) {
				Skills.RMB()
				sleep 5
			}

			if (Availability.IsMagnetizeAvailable()) {
				Skills.Magnetize()
				sleep 5
			}

			If (Availability.IsElectrocuteAvailable())
			{
				Skills.Electrocute()
				sleep 5
			}
		}

		switch stance
		{
			case "default":
				if (!Availability.IsOverchargeAvailable() && !Availability.IsChargeOnCooldown() && !Availability.IsGodModeAvailable()) {
					Skills.LMB()
					sleep 5
				}

				if (Availability.IsOverchargeAvailable()) {
					godModeCd := Availability.GetGodModeCd()
					; case: godmode long cd (every second overcharge)
					if (godModeCd == "long") {
						While (Utility.GameActive() && Availability.IsOverchargeAvailable() && GetKeyState("F23","p")) {
							Skills.LMB()
							sleep 5
						}
					} else {
						; case: godmode nearly ready again
						if (godModeCd == "short" || godModeCd == "off") {
							While (Utility.GameActive() && Availability.IsOverchargeAvailable() && GetKeyState("F23","p")) {
								Skills.LMB()
								sleep 5
							}
						}
					}
				}

				return

			case "overcharge":
				if (stanceChange) {
					Skills.VoltSalvo()
					sleep 5
				} else {
					if (Availability.IsOverchargeEnding() && Availability.IsGodModeAvailable()) {
						While (Utility.GameActive() && Availability.IsThunderCloudAvailable() && GetKeyState("F23","p"))
						{
							Skills.ThunderCloud()
							sleep 5
						}

						While (Utility.GameActive() && Availability.IsGodModeAvailable() && GetKeyState("F23","p"))
						{
							Skills.LMB()
							sleep 5
						}
					}

					While (Utility.GameActive() && Availability.IsVoltSalvoAvailable() && GetKeyState("F23","p"))
					{
						Skills.VoltSalvo()
						sleep 5
					}

					if (Availability.IsEnemyGalvanized() || (A_TickCount > lastStormCloud + 750 && A_TickCount - lastStormCloud < 6000)) {
						if (Availability.IsLightningStrikeAvailable()) {
							Skills.LightningStrike()
							sleep 5
						}
					} else {
						; use storm cloud if it's available while lightning strike is also available and the last cast was more than 3 seconds ago (duration of galvanize effect)
						if (Availability.IsThunderCloudAvailable() && Availability.IsLightningStrikeAvailable() && A_TickCount - lastStormCloud > 3000) {
							While (Utility.GameActive() && Availability.IsThunderCloudAvailable() && GetKeyState("F23","p"))
							{
								Skills.ThunderCloud()
								sleep 5
							}
							lastStormCloud := A_TickCount
						}
					}

					While (Utility.GameActive() && Availability.IsLightningStormAvailable() && !Availability.IsLightningStrikeAvailable() && !Availability.IsGodModeClose() && GetKeyState("F23","p"))
					{
						Skills.LightningStorm()
						sleep 5
					}
				}

				return

			case "godmode":
				if (stanceChange) {
					Skills.LightningStrike()
					sleep 5

					Skills.StormWrath()
					sleep 5
				} else {
					if (Availability.IsTalismanAvailable()) {
						While (Utility.GameActive() && Availability.IsTalismanAvailable() && GetKeyState("F23","p"))
						{
							Skills.Talisman()
							sleep 5
						}
					}

					if (Availability.IsGodmodeEnding()) {
						While (Utility.GameActive() && GetKeyState("F23","p"))
						{
							if (!Availability.IsUltrashockAvailable() || Availability.IsUltrashockCasting() || !Availability.IsGodmodeEnding() || Availability.IsUltrashockOnCooldown()) {
								break
							}

							Skills.Ultrashock()
							sleep 20
						}

						ultrashockTick := A_TickCount
						While (A_TickCount < ultrashockTick + 1200 || Availability.IsUltrashockOnCooldown()) {
							sleep 5
						}
					}

					If (Availability.IsStormWrathAvailable()) {
						Skills.StormWrath()
						sleep 5
					}

					While (Utility.GameActive() && Availability.IsLightningStrikeAvailable() && GetKeyState("F23","p"))
					{
						Skills.LightningStrike()
						sleep 5
					}

					If (Availability.IsLightningStormAvailable()) {
						Skills.LightningStorm()
						sleep 5
					}
				}

				return
		}

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
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
    GetColor(x, y, ByRef red:=0, ByRef green:=0, ByRef blue:=0)
    {
        PixelGetColor, color, x, y, RGB
        StringRight color,color,10
		red := ((color & 0xFF0000) >> 16)
		green := ((color & 0xFF00) >> 8)
		blue := (color & 0xFF)
		Return color
	}

	;check if BnS is the current active window
	GameActive()
	{
		Return WinActive("ahk_class LaunchUnrealUWindowsClient")
	}
}