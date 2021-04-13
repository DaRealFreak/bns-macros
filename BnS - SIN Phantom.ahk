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

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & c::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsNightFuryAvailable())
    {
        Skills.NightFury()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & e::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShunpoAvailable())
    {
        Skills.Shunpo()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & q::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsShadowDanceAvailable())
    {
        Skills.ShadowDance()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
~f23 & 1::
    ; way to deal with input lags on iframes without releasing the macro
    While (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsPhantomDashAvailable())
    {
        Skills.PhantomDash()
        sleep 5
    }

    return

#IfWinActive ahk_class LaunchUnrealUWindowsClient
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
    WaitForSoul() {
        return false
    }

    UseShadowSlash() {
        ; false for exhilaration badge, true for stoic
        return false
    }

    IsBlueBuffAvailable()
    {
        return Utility.GetColor(1035,959) != "0xE46B14"
    }

    IsPhantomAvailable() {
        return Utility.GetColor(821,894) == "0x221E09"
    }

    IsNightReaverAvailable() {
        return Utility.GetColor(1036,897) == "0x8300FF"
    }

    IsNightReaverUnavailable() {
        color := Utility.GetColor(1036, 906)
        ; off cd and on cd disabled nightreaver
        return color == "0x272727" || color == "0x161616"
    }

    IsNecroStrikeAvailable()
    {
        return Utility.GetColor(1036,897) == "0x732AE6"
    }

    IsUltraVioletAvailable() {
        return Utility.GetColor() == ""
    }

    IsNightmareAvailable() {
        return Utility.GetColor(934,964) == "0x151230"
    }

    IsPhantomShurikenAvailable()
    {
        return Utility.GetColor(988,903) == "0x1B092E"
    }

    IsShadowSlashAvailable()
    {
        return Utility.GetColor(987,899) == "0x0A070B"
    }

    IsAwakenAvailable()
    {
        return Utility.GetColor(1304,902) == "0xBB7551"
    }

    IsPhantomDashAvailable()
    {
        return Utility.GetColor(885,894) == "0x1B162C"
    }

    IsUpheavalAvailable()
    {
        return Utility.GetColor(885,961) == "0x8F27F3"
    }

    IsShadowDanceAvailable()
    {
        return Utility.GetColor(682,894) == "0x0E0B0E"
    }

    IsShunpoAvailable()
    {
        return Utility.GetColor(735,894) == "0xEFBAA1"
    }

    IsNightFuryAvailable()
    {
        return Utility.GetColor(985,961) == "0x1F0033"
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

    BlueBuff() {
        send v
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

; everything rotation related
class Rotations
{
    ; default rotation without any logic for max counts
    Default()
    {
        Skills.LMB()
        sleep 5

        Skills.RMB()
        sleep 5

        ; ToDo: only use shadow slash if not full stacked already
        if (Availability.UseShadowSlash() && Availability.IsShadowSlashAvailable()) {
            Skills.ShadowSlash()
            sleep 5
        }

        ; ToDo: only use necro strike if not full stacked already or ultraviolet is available
        if (Availability.IsNecroStrikeAvailable()) {
            ; necro strike has casting time of 200 ms so we lock the script here until the skill is on cd
            While (Utility.GameActive() && Availability.IsNecroStrikeAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton1","p") || GetKeyState("XButton2","p"))) {
                Skills.NecroStrike()
                sleep 5
            }

            ; ToDo: add similar check for ultraviolet here
        }

        if (Availability.IsNightReaverAvailable()) {
            ; use up all stacks before trying to activate blue buff
            While (Utility.GameActive() && Availability.IsNightReaverAvailable() && (GetKeyState("F23","p") || GetKeyState("XButton1","p") || GetKeyState("XButton2","p")))
            {
                Skills.NightReaver()
                sleep 5
            }
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

        return
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        Rotations.Default()

        if (useDpsPhase && (Availability.IsPhantomAvailable() && (!Availability.WaitForSoul() || Availability.IsSoulProced()))) {
            ; dps phase is ready and soul active, use it
            Rotations.DpsPhase()
        }

        if (useDpsPhase && Availability.IsAwakenAvailable()) {
            Rotations.BlueBuff()
        }

        return
    }

    ; activate bluebuff and talisman if it's ready
    DpsPhase()
    {
        ; use talisman while no cd border and keys are pressed
        While (Utility.GameActive() && Availability.IsTalismanAvailable() && GetKeyState("F23","p"))
        {
            Skills.Talisman()
            sleep 5
        }

        ; use up all stacks before trying to activate blue buff
        While (Utility.GameActive() && Availability.IsPhantomAvailable() && GetKeyState("F23","p"))
        {
            Skills.Phantom()
            sleep 5
        }

        ; stance change, skill icons are just floating around
        While (Utility.GameActive() && !Availability.IsAwakenAvailable() && GetKeyState("F23","p")) {
            Rotations.Default()
        }

        ; use up all stacks before trying to activate blue buff
        While (Utility.GameActive() && !Availability.IsNightReaverUnavailable() && GetKeyState("F23","p"))
        {
            ; use up all stacks before trying to activate blue buff
            While (Utility.GameActive() && Availability.IsNightReaverAvailable() && GetKeyState("F23","p"))
            {
                Skills.NightReaver()
                sleep 5
            }

            Rotations.Default()
        }

        ; if blue buff is available after activating the stance we instantly use
        if (Availability.IsBlueBuffAvailable()) {
            Rotations.BlueBuff()
        }

        return
    }

    BlueBuff() {
        ; loop while BlueBuff is not on cooldown or break if keys aren't pressed anymore
        While (Utility.GameActive() && Availability.IsBlueBuffAvailable() && Availability.IsAwakenAvailable() && GetKeyState("F23","p"))
        {    
            Skills.BlueBuff()
            sleep 5
        }
    }
}