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
    while (Utility.GameActive() && GetKeyState("F23","p"))
    {
        Rotations.FullRotation(true)
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & y::
    while (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsSunderingSwordAvailable())
    {
        Skills.SunderingSword()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & Tab::
    while (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsLunarSlashAvailable())
    {
        Skills.LunarSlash()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & 4::
    while (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsLightningDrawAvailable())
    {
        Skills.LightningDraw()
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & x::
    while (Utility.GameActive() && GetKeyState("F23","p") && (Utility.GetColor(940,951) == "0x6E8591" || Utility.GetColor(940,951) == "0x6A6969"))
    {
        send x
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & v::
    send 9
    sleep 5
    send v
    sleep 5
    return

#IfWinActive ahk_class UnrealWindow
~f23 & c::
    while (Utility.GameActive() && GetKeyState("F23","p") && Availability.IsBladeCallAvailable())
    {
        send 9
        sleep 5
        send c
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
~f23 & q::
    while (Utility.GameActive() && GetKeyState("F23","p") && Utility.GetColor(695,887) == "0xCBB4A3")
    {
        send q
        sleep 5
    }
    return

#IfWinActive ahk_class UnrealWindow
$XButton2::
    while (Utility.GameActive() && GetKeyState("F23","p"))
    {
        Rotations.FullRotation(false)
    }
    return
    
#IfWinActive ahk_class UnrealWindow
$XButton1::
    Camera.Spin(1587)

    return

; everything related to checking availability of skills or procs
class Availability
{
    IsBladeCallAvailable()
    {
        return Utility.GetColor(1035,951) == "0x989592" || Utility.GetColor(987,950) == "0x5A5652"
    }

    IsLunarSlashAvailable()
    {
        return Utility.GetColor(825,887) == "0xDAB63A"
    }

    IsLightningDrawOffCooldown()
    {
        col := Utility.GetColor(1035,887)
        return col == "0xEE4142" || col == "0x3D3D3D"
    }

    IsBladeStormAvailable()
    {
        return Utility.GetColor(940,951) == "0x6A6969"
    }

    IsSunderingSwordAvailable()
    {
        return Utility.GetColor(892,951) == "0xE9E7E3"
    }

    IsLightningDrawAvailable()
    {
        return Utility.GetColor(1035,887) == "0xEE4142"
    }

    IsFlashStepVisible()
    {
        col := Utility.GetColor(1035,951)
        return col == "0x718092" || col == "0x6E747B"
    }

    IsFlashStepAvailable()
    {
        return Utility.GetColor(1035,951) == "0x718092"
    }

    IsViolentBladeAvailable()
    {
        return Utility.GetColor(1143,700) == "0x83BCCD"
    }

    IsFatalBladeAvailable()
    {
        return Utility.GetColor(1143,700) == "0x897A89"
    }

    IsDragonFlashAvailable()
    {
        return Utility.GetColor(1143,714) == "0x376DCD"
    }

    IsStrafeAvailable()
    {
        return Utility.GetColor(695,887) == "0xCBB4A3"
    }

    IsInDrawStance()
    {
        col := Utility.GetColor(1146,887)
        return col  == "0x922A14" || col == "0x411C15"
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

    IsFulminationActive()
    {
        return Utility.GetColor(901,750) == "0x0094E8"
    }
}

; skill bindings
class Skills {

    RMB()
    {
        send t
    }

    FlashStep()
    {
        send v
    }

    BladeStorm()
    {
        send x
    }

    SunderingSword()
    {
        send y
    }

    DragonFlash()
    {
        send f
    }

    FatalBlade()
    {
        send f
    }

    LightningDraw()
    {
        send 4
    }

    LunarSlash()
    {
        send {tab}
    }

    Strafe()
    {
        send q
    }

    BlindSide()
    {
        send e
    }

    Evade()
    {
        send ss
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
    static lastLightningDrawUse := 0

    Default()
    {
        if (Availability.IsInDrawStance()) {
            send r
            sleep 25
            send t
            sleep 25
        }
    }

    ; full rotation with situational checks
    FullRotation(useDpsPhase)
    {
        /*
        if (!Availability.IsFulminationActive()) {
            if (Availability.IsBladeStormAvailable()) {
                Skills.BladeStorm()
                sleep 5
                return
            }

            if (Availability.IsLunarSlashAvailable()) {
                Skills.LunarSlash()
                sleep 25
            } else {
                if (Availability.IsSunderingSwordAvailable()) {
                    Skills.SunderingSword()
                    sleep 25
                }
            }
        }
        */

        if (Availability.IsWeaponResetClose()) {
            if (Availability.IsLightningDrawAvailable()) {
                Skills.LightningDraw()
                sleep 5
            }

            if (Availability.IsLunarSlashAvailable()) {
                Skills.LunarSlash()
                sleep 5
            }
        }

        Rotations.Default()
    }
}