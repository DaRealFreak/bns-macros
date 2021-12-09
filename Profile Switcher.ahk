#NoEnv
#SingleInstance force

Profiles := []
Profiles.Insert("Light Archer", {ClassName: "ARC", ClassIcon: "Profile Switcher Icons/ARC.png", CheckBadge: false, ScriptPath: "BnS - Archer Light.ahk"})
Profiles.Insert("Astromancer Thunder", {ClassName: "AST", ClassIcon: "Profile Switcher Icons/AST.png", CheckBadge: false, ScriptPath: "BnS - Astromancer Thunder.ahk"})
Profiles.Insert("BD 3rd", {ClassName: "BD", ClassIcon: "Profile Switcher Icons/BD.png", CheckBadge: false, ScriptPath: "BnS - BD Grim Blade.ahk"})
Profiles.Insert("Burst 3rd BM", {ClassName: "BM", ClassIcon: "Profile Switcher Icons/BM.png", CheckBadge: false, ScriptPath: "BnS - BM Spectral - Exhilaration Anicancel.ahk"})
Profiles.Insert("Fire BM", {ClassName: "BM", ClassIcon: "Profile Switcher Icons/BM_Fire.png", CheckBadge: false, ScriptPath: "BnS - BM Fire.ahk"})
Profiles.Insert("Light BM", {ClassName: "BM", ClassIcon: "Profile Switcher Icons/BM_Lightning.png", CheckBadge: false, ScriptPath: "BnS - BM Lightning.ahk"})
Profiles.Insert("Wolf KFM", {ClassName: "KFM", ClassIcon: "Profile Switcher Icons/KFM.png", CheckBadge: false, ScriptPath: "BnS - KFM Wolf.ahk"})
Profiles.Insert("Wind KFM", {ClassName: "KFM", ClassIcon: "Profile Switcher Icons/KFM_Wind.png", CheckBadge: false, ScriptPath: "BnS - KFM Wind.ahk"})
Profiles.Insert("Light FM", {ClassName: "FM", ClassIcon: "Profile Switcher Icons/FM.png", CheckBadge: false, ScriptPath: "BnS - FM Lightning Rework.ahk"})
Profiles.Insert("Phantom SIN", {ClassName: "SIN", ClassIcon: "Profile Switcher Icons/SIN.png", CheckBadge: false, ScriptPath: "BnS - SIN Phantom.ahk"})
Profiles.Insert("Lightning WR", {ClassName: "WR", ClassIcon: "Profile Switcher Icons/WR.png", CheckBadge: false, ScriptPath: "BnS - WR Lightning.ahk"})
Profiles.Insert("WL 3rd", {ClassName: "WL", ClassIcon: "Profile Switcher Icons/WL_Reaver.png", CheckBadge: false, ScriptPath: "BnS - WL Reaver.ahk"})
Profiles.Insert("Shadow WL", {ClassName: "WL", ClassIcon: "Profile Switcher Icons/WL_Scourge.png", CheckBadge: false, ScriptPath: "BnS - WL Scourge.ahk"})
Profiles.Insert("Earth Summoner", {ClassName: "SUM", ClassIcon: "Profile Switcher Icons/SUM.png", CheckBadge: false, ScriptPath: "BnS - SUM Earth.ahk"})
Profiles.Insert("Earth Destroyer", {ClassName: "DES", ClassIcon: "Profile Switcher Icons/DES_Earth.png", CheckBadge: false, ScriptPath: "BnS - DES Earth.ahk"})
Profiles.Insert("Shadow Destroyer", {ClassName: "DES", ClassIcon: "Profile Switcher Icons/DES_Shadow.png", CheckBadge: false, ScriptPath: "BnS - DES Reaper.ahk"})
Profiles.Insert("Shifting DB", {ClassName: "DB", ClassIcon: "Profile Switcher Icons/DB.png", CheckBadge: false, ScriptPath: "BnS - DB Shifting.ahk"})

^F3::Reload
#IfWinActive ahk_class UnrealWindow
^F5::SwitchProfile()
^F12::ExitApp

^Numpad0::
    AHKPanic(1)
    LoadScript("BnS - BM Spectral - Exemplar Anicancel.ahk")
    return

^Numpad1::
    AHKPanic(1)
    LoadScriptFullPath("H:\OneDrive\Games\Blade and Soul\aerodrome\main.ahk")
    return
^Numpad2::
    AHKPanic(1)
    LoadScriptFullPath("H:\OneDrive\Games\Blade and Soul\aerodrome_exp\main.ahk")
    return
^Numpad3::LoadScript("../Bots/BnS - Exp Charm Bot.ahk")
^Numpad4::LoadScriptFullPath("H:\OneDrive\Games\Blade and Soul\vacation\vacation.ahk")
^Numpad5::
	AHKPanic(1)
    LoadScript("../Bots/BnS - ToI Tickets.ahk")
    return

LoadScriptFullPath(scriptPath)
{
    Run, %A_AHKPath% "%scriptPath%"
    tooltip, loaded: %scriptPath%
    SetTimer, RemoveToolTip, -2000
    return 
}

LoadScript(scriptPath)
{
    Run, %A_AHKPath% "%A_ScriptDir%\%scriptPath%"
    tooltip, loaded: %scriptPath%
    SetTimer, RemoveToolTip, -2000
    return
}

SwitchProfile()
{
    global Profiles
    for index, item in Profiles
    {
        classIcon := item.ClassIcon
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %classIcon%
        if (ErrorLevel = 0) {
            tooltip, % "found: " item.ClassName 
            SetTimer, RemoveToolTip, -2000

            if (item.CheckBadge) {
                badgeIcon := item.BadgeIcon
                ; don't check lower screen positions cause of inventory
                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight - 600, %badgeIcon%
            } else {
                ErrorLevel := 0
            }

            if (ErrorLevel = 0) {
                AHKPanic(1)

                scriptPath := item.ScriptPath
                Run, %A_AHKPath% "%A_ScriptDir%\%scriptPath%"
                tooltip, loaded: %scriptPath%
                SetTimer, RemoveToolTip, -2000
                return
            }
        }
    }
    return
}

AHKPanic(Kill=0, Pause=0, Suspend=0, SelfToo=0)
{
    DetectHiddenWindows, On
    WinGet, IDList ,List, ahk_class AutoHotkey
    Loop %IDList%
    {
        ID:=IDList%A_Index%
        WinGetTitle, ATitle, ahk_id %ID%
        IfNotInString, ATitle, %A_ScriptFullPath%
        {
            If Suspend
                PostMessage, 0x111, 65305,,, ahk_id %ID%  ; Suspend. 
            If Pause
                PostMessage, 0x111, 65306,,, ahk_id %ID%  ; Pause.
            If Kill
                WinClose, ahk_id %ID% ;kill
        }
    }
    If SelfToo
    {
        If Suspend
            Suspend, Toggle  ; Suspend. 
        If Pause
            Pause, Toggle, 1  ; Pause.
        If Kill
            ExitApp
    }
}

RemoveToolTip:
    ToolTip
    return