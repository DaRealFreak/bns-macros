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
    Camera.Spin(1587)

    return

#IfWinActive ahk_class UnrealWindow
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsNightFuryAvailable())
    {
        Skills.NightFury()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & e::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShunpoAvailable())
    {
        Skills.Shunpo()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShadowDanceAvailable())
    {
        Skills.ShadowDance()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & 1::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsPhantomDashAvailable())
    {
        Skills.PhantomDash()
        sleep 5
    }

    return

#IfWinActive ahk_class UnrealWindow
~f23 & z::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsUpheavalAvailable())
    {
        Skills.Upheaval()
        sleep 5
    }

    return

; everything related to checking availability of skills or procs
class Availability
{
    UseShadowSlash() {
        ; false for exhilaration badge, true for stoic
        return true
    }

    IsPhantomAvailable()
    {
        return Utility.GetColor(825,887) == "0x5B31B7"
    }

    IsNightReaverAvailable()
    {
        return Utility.GetColor(1035,887) == "0x7326D7"
    }

    IsInStanceChange()
    {
        col := Utility.GetColor(828,888)
        return col != "0x756B92" && col != "0x8769D2" && col != "0xD6B1A0"
    }

    IsNecroStrikeAvailable()
    {
        return Utility.GetColor(1035,887) == "0x471C54"
    }

    IsUltraVioletAvailable() {
        return Utility.GetColor(1035,887) == "0x1F1324"
    }

    IsNightmareAvailable() {
        return Utility.GetColor(940,951) == "0x8C6CD4"
    }

    IsPhantomShurikenAvailable()
    {
        return Utility.GetColor(987,887) == "0x311735"
    }

    IsShadowSlashAvailable()
    {
        return Utility.GetColor(987,887) == "0x311C3D"
    }

    IsPhantomDashAvailable()
    {
        return Utility.GetColor(892,887) == "0x8A63E4"
    }

    IsUpheavalAvailable()
    {
        return Utility.GetColor(892,951) == "0x916FD4"
    }

    IsShadowDanceAvailable()
    {
        return Utility.GetColor(695,887) == "0x131414"
    }

    IsShunpoAvailable()
    {
        return Utility.GetColor(742,887) == "0x164F3F"
    }

    IsNightFuryAvailable()
    {
        return Utility.GetColor(987,951) == "0x7F6A88"
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

    PhantomShuriken() {
        send 3
    }

    ShadowSlash() {
        send 3
    }

    NightReaver() {
        send 4
    }

    NecroStrike() {
        send 4
    }

    Nightmare() {
        send x
    }

    Upheaval() {
        send z
    }

    PhantomDash() {
        send 1
    }

    ShadowDance() {
        send q
    }

    Shunpo() {
        send e
    }

    NightFury() {
        send c
    }

    Phantom() {
        send {Tab}
    }

    Talisman() {
        send 9
    }
}

class Camera
{
    Spin(pxls)
    {
        ; you have to experiment a little with your settings here due to your DPI, ingame sensitivity etc
        MouseGetPos, xp, yp
        if (xp >= pxls) {
            DllCall("mouse_event", "UInt", 0x0001, "UInt", -1 * pxls, "UInt", 0)
        } else {
            DllCall("mouse_event", "UInt", 0x0001, "UInt", pxls, "UInt", 0)
        }
    }
}

; everything rotation related
class Rotations
{
    Default()
    {
        Skills.LMB()
        sleep 5

        Skills.RMB()
        sleep 5
    }

    FullRotation(useDpsPhase)
    {
        if (Availability.IsInStanceChange()) {
            Skills.NightReaver()
            return
        }

        if (useDpsPhase && Availability.IsPhantomAvailable()) {
            Rotations.DpsPhase()
        }

        if (Availability.IsNightReaverAvailable()) {
            Skills.NightReaver()
            sleep 5
        }

        ; always use phantom shuriken to trigger exhilaration badge effect
        if (Availability.IsPhantomShurikenAvailable()) {
            Skills.PhantomShuriken()
            sleep 5
        }

        ; only use nightmare if we don't have enough stacks for night reaver anymore to avoid overstacking
        if (Availability.IsNightmareAvailable()) {
            Skills.Nightmare()
            sleep 5
        }

        Rotations.Default()

        return
    }

    ; activate bluebuff and talisman if it's ready
    DpsPhase()
    {
        ; properly prestack at least 2 stacks before entering stance
        if (Availability.IsNecroStrikeAvailable()) {
            ; necro strike has casting time of 200 ms so we lock the script here until the skill is on cd
            While (Utility.GameActive() && Availability.IsNecroStrikeAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton1","p") || GetKeyState("XButton2","p"))) {
                Skills.NecroStrike()
                sleep 50
            }

            While (Utility.GameActive() && Availability.IsUltraVioletAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton1","p") || GetKeyState("XButton2","p"))) {
                Skills.NecroStrike()
                sleep 5
            }
        }

        if (Availability.UseShadowSlash() && Availability.IsShadowSlashAvailable()) {
            Skills.ShadowSlash()
            sleep 5
        }

        ; use up all stacks before trying to activate blue buff
        While (Utility.GameActive() && Availability.IsPhantomAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 5
            Skills.Phantom()
            sleep 5
        }

        return
    }
}