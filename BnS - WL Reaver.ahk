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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & Tab::
    ; way to deal with input lags without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsTimeGyreAvailable())
    {
        send {tab}
        sleep 5
    }

    return

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
        Rotations.Default()
    }
    return

; everything related to checking availability of skills or procs
class Availability {
    IsTimeGyreAvailable()
    {
        return Utility.GetColor(822,893) == "0x884544"
    }

    IsBloodCurseAvailable()
    {
        return Utility.GetColor(985,894) == "0xFF2425"
    }

    IsUndercutAvailable()
    {
        return Utility.GetColor(1035,961) == "0x680904"
    }

    IsPossessionAvailable()
    {
        return Utility.GetColor(1035,894) == "0x4A0100"
    }

    IsSoulReaveAvailable()
    {
        color := Utility.GetColor(1035,894)
        return color == "0x000000" || color == "0x512112" || color == "0xEB2425"
    }

    IsPlagueAvailable()
    {
        return Utility.GetColor(1181,685) == "0x130901"
    }

    IsDoomAvailable() {
	    return Utility.GetColor(935,894) == "0x250000"
    }

    IsUndercutClose()
    {
        return Utility.GetColor(1050,959) != "0xE46B14"
    }

    IsWeaponResetClose()
    {
        return Utility.GetColor(581,907) == "0xFFBA01"
    }
}

; skill bindings
class Skills {
    LMB()
    {
        send r
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

        if (doomAvailable && !Availability.IsUndercutClose() && !Availability.IsWeaponResetClose()) {
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
        }

        if (Availability.IsPossessionAvailable()) {
            Skills.Possession()
            sleep 5
        }

        Skills.RMB()
        sleep 5

        Skills.LMB()
        sleep 5

        return
    }
}