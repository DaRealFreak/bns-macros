#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; everything utility related
class Utility
{
    ;return the color at the passed position
    GetColor(x, y, ByRef red:=0, ByRef green:=0, ByRef blue:=0)
    {
        PixelGetColor, color, x, y, RGB
        StringRight color,color,10
        ; only bitshift if the refs actually got passed to the function
        if (red != 0) {
            red := ((color & 0xFF0000) >> 16)
        }
        if (green != 0) {
            green := ((color & 0xFF00) >> 8)
        }
        if (blue != 0) {
            blue := (color & 0xFF)
        }
        Return color
    }

    ;check if BnS is the current active window
    GameActive()
    {
        Return WinActive("ahk_class LaunchUnrealUWindowsClient")
    }
}