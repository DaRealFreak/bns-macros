#NoEnv
#KeyHistory 0
#InstallMouseHook
#SingleInstance force
ListLines Off
Process, Priority, , A
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
$F23::
    While (Utility.GameActive() && GetKeyState("F23","p"))
    {
        Rotations.FullRotation(true)
    }
    return

#IfWinActive ahk_class UnrealWindow
$XButton2::
    While (Utility.GameActive() && GetKeyState("XButton2","p"))
    {
        Rotations.FullRotation(false)
    }
    return
    
#IfWinActive ahk_class UnrealWindow
$XButton1::
    While (Utility.GameActive() && GetKeyState("XButton1","p"))
    {
        Rotations.Default()
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsCutOffAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsCutOffAvailable())
        {
            Skills.CutOff()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & e::
    ; way to deal with input lags without releasing the macro
    if (Availability.IsCutThroughAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsCutThroughAvailable())
        {
            Skills.CutThrough()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & x::
    ; way to deal with input lags without releasing the macro
    if (Availability.IsBladeRuseAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsBladeRuseAvailable())
        {
            Skills.BladeRuse()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & c::
    ; way to deal with input lags without releasing the macro
    if (Availability.IsEscalateAvailable()) {
        While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsEscalateAvailable())
        {
            Skills.Escalate()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & q::
    ; way to deal with input lags on iframes without releasing the macro
    if (Availability.IsCutOffAvailable()) {
        While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsCutOffAvailable())
        {
            Skills.CutOff()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & e::
    ; way to deal with input lags without releasing the macro
    if (Availability.IsCutThroughAvailable()) {
        While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsCutThroughAvailable())
        {
            Skills.CutThrough()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & x::
    ; way to deal with input lags without releasing the macro
    if (Availability.IsBladeRuseAvailable()) {
        While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsBladeRuseAvailable())
        {
            Skills.BladeRuse()
            sleep 5
        }
    }

    return

#IfWinActive ahk_class UnrealWindow
~XButton2 & c::
    ; way to deal with input lags without releasing the macro
    if (Availability.IsEscalateAvailable()) {
        While (Utility.GameActive() && GetKeyState("XButton2","p") && Availability.IsEscalateAvailable())
        {
            Skills.Escalate()
            sleep 5
        }
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    IsIncarnateAvailable()
    {
        col := Utility.GetColor(825,887)
        return col == "0x421C5E" || col == "0x1B3746" || col == "0x21225E"
    }
    
    IsOblivionAvailable()
    {
        col := Utility.GetColor(825,887)
        return col == "0xEEE9EE" || col == "0xCBEEEE" || col =="0xC3EEEE"
    }

    IsEscalateAvailable()
    {
        col := Utility.GetColor(987,951)
        return col == "0x9676CD" || col == "0x6FCCD4" || col =="0x6CBCD9"
    }

    IsEscalateVisible()
    {
        ; greyed out during use and off cd indicating we see the c skill during block
        col := Utility.GetColor(986,951)
        return col == "0x9779CD" || col == "0x72CFD4" || col == "0x6DBDD8" || col == "0x7C7C7C" || col == "0x848484" || col == "0x828282"
    }

    IsTurnStrikeAvailable()
    {
        col := Utility.GetColor(1145,887)
        return col == "0x291650" || col == "0x192D51" || col == "0x192551"
    }

    IsBladeTurnVisible()
    {
        col := Utility.GetColor(1145,887)
        return col == "0x161C1B" || col == "0x22667A" || col == "0x27347D"
    }

    IsDeepCutAvailable()
    {
        return Utility.GetColor(1035,951) == "0x6B6970"
    }

    IsDriveStrikeAvailable()
    {
        ; all 3 stances and all 3 stances in sb
        col := Utility.GetColor(1035,887)
        return col == "0x4F235B" || col == "0x2C2D58" || col == "0x2C474F" || col == "0x3F3F73" || col == "0x3F6169" || col == "0x622C6E"
    }

    IsDecimatorVisible()
    {
        ; all 3 stances and all 3 stances in sb
        col := Utility.GetColor(1143,700)
        return col == "0x9A79A5" || col == "0x757596" || col == "0x7594A4" || col == "0x9A78A6"
    }

    IsCutOffAvailable()
    {
        return Utility.GetColor(695,887) == "0x161541"
    }

    IsCutThroughAvailable()
    {
        return Utility.GetColor(742,887) == "0x4E5471"
    }

    IsBladeRuseAvailable()
    {
        col := Utility.GetColor(940,951)
        return col == "0x6C6A77" || col == "0x6A6C74" || col == "0x6D6971"
    }

    IsInStanceChange()
    {
        col := Utility.GetColor(707,889)
        return col != "0x646567" && col != "0x636366"
    }

    IsBraceletCloseToExpiration()
    {
        Utility.GetColor(663,819, r, g, b)
        return b < 240
    }

    IsWeaponResetClose()
    {
        ; check for weapon reset cooldown (slightly above and below to see if the reset is close)
        Utility.GetColor(620, 818, r, g)
        if (r > 200 && g > 100 && g < 200) {
            Utility.GetColor(602, 812, r2)
            return r2 < 200
        }

        return false
    }

    IsSoulProced()
    {
        ; check for soul duration progress bar
        Utility.GetColor(592,811, r, g, b)
        return b > 240 && r < 20
    }

    IsBraceletActive()
    {
        return !Availability.IsBraceletCloseToExpiration()
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

    Incarnate()
    {
        send {tab}
    }

    Oblivion()
    {
        send {tab}
    }

    StatisBlock()
    {
        send 1
    }

    Rescind()
    {
        send c
    }

    DriveStrike()
    {
        send 4
    }

    Decimator()
    {
        send f
    }

    DeepCut()
    {
        send v
    }

    StormBlade()
    {
        send t
    }

    CutOff()
    {
        send q
    }

    CutThrough()
    {
        send e
    }

    BladeRuse()
    {
        send x
    }

    Escalate()
    {
        send c
    }

    Talisman()
    {
        send 9
    }
}

; everything rotation related
class Rotations
{
    static lastSplinterUse := 0
    static dpsPhaseStart := 0

    ; default rotation without any logic for max counts
    Default()
    {
        ; leftover from previous or manual 4 pressing
        Skills.Decimator()
        sleep 5

        if (Availability.IsInStanceChange() || (Availability.IsDeepCutAvailable() && Availability.IsTurnStrikeAvailable())) {
            Skills.DeepCut()
            sleep 15
        }

        if (!Availability.IsInStanceChange() && !Availability.IsTurnStrikeAvailable() && !Availability.IsBladeTurnVisible()) {
            Skills.StormBlade()
            sleep 15
        }
    }

    BurstDefault()
    {
        Skills.DriveStrike()
        sleep 5
		Skills.Decimator()
		sleep 5
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        weaponResetClose := Availability.IsWeaponResetClose()

        if (useDpsPhase) {
            if (A_TickCount > this.lastSplinterUse + 60*1000 && Availability.IsSoulProced()) {
                while (Availability.IsEscalateVisible()) {
                    Skills.Talisman()
                    sleep 5
                    Skills.StatisBlock()
                    sleep 5
                }

                while (!Availability.IsEscalateVisible()) {
                    Skills.Talisman()
                    sleep 5
                    Skills.Rescind()
                    sleep 5
                }

                this.lastSplinterUse := A_TickCount
            }
        }

        if (Availability.IsOblivionAvailable()) {
            Skills.Oblivion()
            sleep 5
            this.dpsPhaseStart := A_TickCount
        }

        if ((!Availability.IsBraceletActive() || weaponResetClose) && Availability.IsIncarnateAvailable()) {
            Skills.Oblivion()
            sleep 5

            return
        }

        if (A_TickCount < this.dpsPhaseStart + 10 * 1000) {
            Rotations.BurstDefault()
            return
        }

        if (Availability.IsDriveStrikeAvailable() || Availability.IsDecimatorVisible()) {
            if (!weaponResetClose && (A_TickCount > this.lastSplinterUse + (60-16) * 1000)) {
                Rotations.Default()
            } else {
                Rotations.BurstDefault()
            }
        } else {
            Rotations.Default()
        }

       return
    }
}