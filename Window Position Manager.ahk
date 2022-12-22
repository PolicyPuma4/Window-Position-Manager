; Created by https://github.com/PolicyPuma4
; Repository https://github.com/PolicyPuma4/Window-Position-Manager

#Requires AutoHotkey v2.0-beta

;@Ahk2Exe-Obey U_bits, = %A_PtrSize% * 8
;@Ahk2Exe-Obey U_type, = "%A_IsUnicode%" ? "Unicode" : "ANSI"
;@Ahk2Exe-ExeName %A_ScriptName~\.[^\.]+$%_%U_type%_%U_bits%

;@Ahk2Exe-SetMainIcon shell32_3.ico
if not A_IsCompiled
    TraySetIcon("shell32_3.ico")

Persistent()

A_LocalAppData := EnvGet("LOCALAPPDATA")

app_dir_path := A_LocalAppData "\Programs\Window Position Manager"
if not DirExist(app_dir_path)
    DirCreate(app_dir_path)

saved_windows_path := app_dir_path "\Saved Windows.ini"
if not FileExist(saved_windows_path)
    FileAppend("", saved_windows_path)

all_keys := ""
Loop 255
{
    all_keys := all_keys "{" Format("vk{:02x}", A_Index) "}"
}

exceptions := Map(
    "chrome.exe", "Picture-in-picture",
    "firefox.exe", "Picture-in-Picture"
)

A_IconTip := "Select an option, hover your cursor over any window and then press any button on your keyboard`nPress escape to cancel"
A_TrayMenu.Add()
A_TrayMenu.Add("Edit saved windows", EditSavedWindows)
A_TrayMenu.Add("Save window", SaveWindow)
A_TrayMenu.Add("Restore window", RestoreWindow)

EditSavedWindows(*)
{
    Run("notepad.exe " saved_windows_path, app_dir_path)
}

SelectWindow()
{
    ih := InputHook("", all_keys)
    ih.Start()
    ih.Wait()

    if not ih.EndReason = "EndKey"
        return

    if ih.EndKey = "Escape"
        return

    MouseGetPos(,, &window)
    return window
}

GetProcessName(window)
{
    process_name := WinGetProcessName(window)
    has_exception := exceptions.Get(process_name, "")
    if not has_exception
        return process_name

    window_title := WinGetTitle(window)
    if not has_exception = window_title
        return process_name

    return process_name " " window_title
}

SaveWindow(*)
{
    window := SelectWindow()
    if not window
        return

    window_state := WinGetMinMax(window)
    process_name := GetProcessName(window)
    if window_state
    {
        IniWrite(true, saved_windows_path, process_name, "max")
        return
    }

    IniWrite(false, saved_windows_path, process_name, "max")
    WinGetPos(&x, &y, &width, &height, window)
    IniWrite(x, saved_windows_path, process_name, "x")
    IniWrite(y, saved_windows_path, process_name, "y")
    IniWrite(width, saved_windows_path, process_name, "width")
    IniWrite(height, saved_windows_path, process_name, "height")
}

RestoreWindow(*)
{
    window := SelectWindow()
    if not window
        return

    process_name := GetProcessName(window)
    saved_window_state := IniRead(saved_windows_path, process_name, "max", "")
    if saved_window_state
    {
        window_state := WinGetMinMax(window)
        if not window_state
            WinMaximize(window)

        return
    }

    saved_x := IniRead(saved_windows_path, process_name, "x", "")
    saved_y := IniRead(saved_windows_path, process_name, "y", "")
    saved_width := IniRead(saved_windows_path, process_name, "width", "")
    saved_height := IniRead(saved_windows_path, process_name, "height", "")
    if saved_x = "" or saved_y = "" or saved_width = "" or saved_height = ""
        return

    window_state := WinGetMinMax(window)
    if window_state
        WinRestore(window)

    WinMove(saved_x, saved_y, saved_width, saved_height, window)
}
