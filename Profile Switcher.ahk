#NoEnv
#SingleInstance force

Profiles := []
Profiles.Insert("Meme KFM", {ClassName: "KFM", ClassIcon: "Profile Switcher Icons/KFM.png", CheckBadge: true, BadgeIcon: "Profile Switcher Icons/KFM - Courage Soul Badge.png", ScriptPath: "BnS - KFM Fire Meme.ahk"})
Profiles.Insert("Burst 3rd BM", {ClassName: "BM", ClassIcon: "Profile Switcher Icons/BM.png", CheckBadge: true, BadgeIcon: "Profile Switcher Icons/BM - Exhilaration Soul Badge.png", ScriptPath: "BnS - BM Spectral - Exhilaration.ahk"})
Profiles.Insert("Raid 3rd BM", {ClassName: "BM", ClassIcon: "Profile Switcher Icons/BM.png", CheckBadge: true, BadgeIcon: "Profile Switcher Icons/BM - Exemplar Soul Badge.png", ScriptPath: "BnS - BM Spectral - Exemplar.ahk"})
Profiles.Insert("Phantom SIN", {ClassName: "SIN", ClassIcon: "Profile Switcher Icons/SIN.png", CheckBadge: false, ScriptPath: "BnS - SIN Phantom.ahk"})
Profiles.Insert("Light Archer", {ClassName: "ARC", ClassIcon: "Profile Switcher Icons/ARC.png", CheckBadge: false, ScriptPath: "BnS - Archer Light.ahk"})

^F3::Reload
#IfWinActive ahk_class LaunchUnrealUWindowsClient
^F5::SwitchProfile()
^F12::ExitApp

SwitchProfile() {
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

AHKPanic(Kill=0, Pause=0, Suspend=0, SelfToo=0) {
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
Return