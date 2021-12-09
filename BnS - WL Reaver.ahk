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
~f23 & Tab::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && (Availability.IsTimeGyreAvailable() || Availability.IsSoulBurnAvailable()))
    {
        Skills.SbOrTd()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & c::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsReapAvailable())
    {
        Skills.Reap()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & y::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsDeathVeilAvailable())
    {
        Skills.DeathVeil()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
$F23::
    While (Utility.GameActive() && GetKeyState("F23","p"))
    {
        Rotations.Default()
    }
    return

#IfWinActive ahk_class UnrealWindow
$XButton2::
    While (Utility.GameActive() && GetKeyState("XButton2","p"))
    {
        Rotations.Default()
    }
    return

; everything related to checking availability of skills or procs
class Availability {
    IsTimeGyreAvailable()
    {
        return Utility.GetColor(825,887) == "0x6C403D"
    }

    IsSoulBurnAvailable()
    {
        return Utility.GetColor(825,887) == "0x141414"
    }

    IsReaverAvailable()
    {
        col := Utility.GetColor(825,887)
        return col == "0x8B2952" || col == "0x131313"
    }

    IsPossessionAvailable()
    {
        return Utility.GetColor(1035,887) == "0x841313"
    }

    IsBloodCurseAvailable()
    {
        return Utility.GetColor(987,887) == "0xEE2223"
    }

    IsUndercutAvailable()
    {
        return Utility.GetColor(1035,950) == "0xA35744"
    }

    IsUndercutClose()
    {
        col := Utility.GetColor(1051,962)
        return col != "0x291819" && col != "0x18172C"
    }

    IsSoulReaveAvailable()
    {
        ; also check for sb colors
        color := Utility.GetColor(1035,890)
        return color == "0x595959" || color == "0xAD9073" || color == "0xF6CDCF"
    }

    IsPlagueAvailable()
    {
        return Utility.GetColor(1144,703) == "0x585150"
    }

    IsDoomAvailable() {
	    return Utility.GetColor(940,887) == "0x2D1313"
    }

    IsReapAvailable()
    {
        return Utility.GetColor(987,950) == "0x46130C"
    }

    IsDeathVeilAvailable()
    {
        return Utility.GetColor(892,950) == "0x4B0C0C"
    }

    IsMistWalkerVisible()
    {
        return Utility.GetColor(694,887) == "0x631413"
    }
}

; skill bindings
class Skills {
    LMB()
    {
        send 0
    }

    RMB()
    {
        send t
    }

    BloodCurse()
    {
        send 3
    }

    Undercut()
    {
        send v
    }

    Plague()
    {
        send f
    }

    Doom()
    {
    	send 2
    }

    Possession()
    {
        send 4
    }

    SoulReave()
    {
    	send 4
    }

    SbOrTd()
    {
        send {tab}
    }

    Reaver()
    {
        send {tab}
    }

    Reap()
    {
        send c
    }

    DeathVeil()
    {
        send z
    }
}

/*
**	Make sure to use the autocast Plague XML otherwise your Plague won't cast.
**	
**	GCD Settings:
**	Skill Id	Value	Mode
** 	0		-0.16	0
**	173320		0	1
**	173330		0	1
*/

; everything rotation related
class Rotations {
    ; default rotation without any logic for max counts
    Default() {
        ; check reused availabilities
        bloodCurseAvailable := Availability.IsBloodCurseAvailable()
        doomAvailable := Availability.IsDoomAvailable()

        if (!Availability.IsBraceletActive() && bloodCurseAvailable) {
            Skills.BloodCurse()
            sleep 5
            return
        }

        if (bloodCurseAvailable) {
            Skills.BloodCurse()
            sleep 5
        }

        if (Availability.IsUndercutAvailable()) {
            Skills.Undercut()
            sleep 5
        }

        if (doomAvailable && !Availability.IsUndercutClose()) {
            Skills.Doom()
            sleep 5
        }

        if (!doomAvailable && Availability.IsSoulReaveAvailable()) {
            Skills.SoulReave()
            sleep 5
        }

        if (Availability.IsPlagueAvailable()) {
            Skills.Plague()
            sleep 5
        } else {
            Skills.RMB()
            sleep 5

            Skills.LMB()
            sleep 5
        }

        if (!Availability.IsMistWalkerVisible()) {
            if (Availability.IsPossessionAvailable()) {
                Skills.Possession()
                sleep 5
            }

            if (Availability.IsReaverAvailable()) {
                Skills.Reaver()
                sleep 5
            }
        }


        return
    }
}