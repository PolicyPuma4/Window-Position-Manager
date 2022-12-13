; Created by https://github.com/PolicyPuma4
; Repository https://github.com/PolicyPuma4/Window-position-manager

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Persistent
#SingleInstance Force

SaveWindow()
{
    Window := SelectWindow()
    WinGet, WindowMinMax, MinMax, ahk_id %Window%
    WinGet, WindowProcessName, ProcessName, ahk_id %Window%
    if (WindowMinMax = 1)
    {
        IniWrite, 1, %IniFile%, %WindowProcessName%, WindowMinMax
        return
    }
    IniDelete, %IniFile%, %WindowProcessName%, WindowMinMax
    WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, ahk_id %Window%
    IniWrite, %WindowX%, %IniFile%, %WindowProcessName%, WindowX
    IniWrite, %WindowY%, %IniFile%, %WindowProcessName%, WindowY
    IniWrite, %WindowWidth%, %IniFile%, %WindowProcessName%, WindowWidth
    IniWrite, %WindowHeight%, %IniFile%, %WindowProcessName%, WindowHeight
    return
}


RestoreWindow()
{
    Window := SelectWindow()
    WinGet, WindowProcessName, ProcessName, ahk_id %Window%
    IniRead, WindowMinMax, %IniFile%, %WindowProcessName%, WindowMinMax
    if (WindowMinMax = 1)
    {
        WinGet, CurrentWindowMinMax, MinMax, ahk_id %Window%
        if (CurrentWindowMinMax != 1)
        {
            WinMaximize ahk_id %Window%
        }
        return
    }
    IniRead, WindowX, %IniFile%, %WindowProcessName%, WindowX
    IniRead, WindowY, %IniFile%, %WindowProcessName%, WindowY
    IniRead, WindowWidth, %IniFile%, %WindowProcessName%, WindowWidth
    IniRead, WindowHeight, %IniFile%, %WindowProcessName%, WindowHeight
    if (WindowX != "ERROR") and (WindowY != "ERROR") and (WindowWidth != "ERROR") and (WindowHeight != "ERROR")
    {
        WinGet, CurrentWindowMinMax, MinMax, ahk_id %Window%
        if (CurrentWindowMinMax = 1)
        {
            WinRestore ahk_id %Window%
        }
        WinMove, ahk_id %Window%,, %WindowX%, %WindowY%, %WindowWidth%, %WindowHeight%
    }
    return
}


SelectWindow()
{
    ih := InputHook("", all_keys)
    ih.Start()
    ih.Wait()

    if (ih.EndReason != "EndKey")
        return

    if (ih.EndKey == "Escape")
        return

    MouseGetPos,,, Window
    return Window
}

EnvGet, A_LocalAppData, LocalAppData
global A_LocalAppData := A_LocalAppData

IfNotExist, %A_LocalAppData%\Programs\Window position manager
{
    FileCreateDir, %A_LocalAppData%\Programs\Window position manager
    FileAppend,, %A_LocalAppData%\Programs\Window position manager\Saved windows.ini
}

global IniFile := A_LocalAppData "\Programs\Window position manager\Saved windows.ini"
global all_keys

Loop, 255
{
	all_keys := all_keys "{" Format("vk{:02x}", A_Index) "}"
}

Menu, Tray, Icon, shell32_3.ico
Menu, Tray, Add
Menu, Tray, Add, Save window, MenuHandler
Menu, Tray, Add, Restore window, MenuHandler
return

MenuHandler:
if (A_ThisMenuItem = "Save window")
{
    SaveWindow()
}
else if (A_ThisMenuItem = "Restore window")
{
    RestoreWindow()
}
return
