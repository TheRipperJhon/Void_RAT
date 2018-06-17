# ![VoidRATIcon](https://i.imgur.com/Hrbv2C0.png)VoidRAT
A basic Remote Administration Tool, for educational purposes. VoidRAT has a Graphical User Interface (for executing tasks remotely), and a Client Console (for local task execution and debugging purposes). It supports custom scripts and delayed executions, advanced and classical tasks. It also has some experimental functions. This project represents the basic mechanisms of modern Remote Administration Tools (RATs, for short), and serves as material for anyone willing to learn about them.
### Feature List
| Status | Feature | Requires Admin |
| :------------: | :------------ | :------------: |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Shutdown (with Message) | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Reboot | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Sleep/Wake Up (Monitor) | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Get Network Information | Yes |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Get Available WiFi Networks | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Recover WiFi Profiles | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Get Running Processes | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Check if a Process Exists | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Attempt to Kill a Process | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Enable/Disable Task Manager | Yes |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Get Detailed System Information | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Get the List of Installed Programs | Yes |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Recover Saved Passwords | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Download a File (HTTP) | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Upload a File (HTTP) | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Run an Executable | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Run a Command | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Update Client | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Restart Client | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Uninstall Client | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Ignore Client | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Format the System Drive | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Execute a Script | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Schedule the Execution of a Script | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Execute JS | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Execute VBS | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Halt All Scripts | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | XMR Mining | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Floods | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Keylogging | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Open a Webpage | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Change System Volume | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Play a Sound (WAV) | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Beep | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Print a Document | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Open a File | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | Messagebox | No |
| ![No](https://i.imgur.com/9sVDJry.png) | Reverse Proxy | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | **Remote File Explorer** | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | **Screenshare** | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | **Webcam** | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | **Chat** | No |
| ![Yes](https://i.imgur.com/R7AgtMd.png) | **Remote Command Prompt** | No |
| ![No](https://i.imgur.com/9sVDJry.png) | **Remote PowerShell** | No |
| ![No](https://i.imgur.com/9sVDJry.png) | **System Event Viewer** | Yes |
### Bug/To-Do List
| Type | Bug/To-Do | Affects | Priority | Status |
| :------------: | :------------ | :------------: | :------------: | :------------: |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Messagebox does not appear on top | Client | Low | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Webcam module is highly unstable | Client | Medium | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Communication is single-threaded | Client | High | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Random memory leaks | Client | Medium | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | The local cursor is not accurate | Client | Low | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Remote File Explorer is generally slow | Server | Low | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | The Tasks panel is not updated regularly | Server | Low | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Single Tasks wait for background replies | Server | Medium | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Network Information is not returned | Client | Medium | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | No exception mechanism is in place | Client | High | Not Fixed |
| ![Bug](https://i.imgur.com/7Ijf4P9.png) | Admin commands are unstable | Client | Low | Not Fixed |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Some arrays are 1-indexed | Server | Low | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Some loop variables are global | Server | Medium | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Improve the Remote File Explorer | Server | Low | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Clean up the Communication unit | Server | Medium | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Fix the GetParams function | Client | Low | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Improve persistence | Client | Medium | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Add the Manifest Cloner | Server | Medium | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Implement Anti-Debugging code | Client | Medium | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | Implement Process Protection | Client | Medium | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | **Finish the Builder** | Server | High | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | **Add Settings** | Server | High | Not Done |
| ![ToDo](https://i.imgur.com/cxf35M3.png) | **Add Statistics** | Server | High | Not Done |
### Screenshots
![Control Interface](https://i.imgur.com/erv0QLD.png)
![Tasks Panel](https://i.imgur.com/admQ9mD.png)
### Environment and Dependencies
This project was created in [Lazarus-IDE](https://www.lazarus-ide.org/ "Lazarus-IDE"), a free cross-platform IDE.
Internal Dependencies: BGRAControls, Indy 10, ScrollingText.
External Dependencies: avicap32.dll, WinAPI.