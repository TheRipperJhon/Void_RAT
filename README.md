# ![VoidRATIcon](https://i.imgur.com/Hrbv2C0.png)VoidRAT
A basic Remote Administration Tool, for educational purposes. VoidRAT has a Graphical User Interface (for executing tasks remotely), and a Client Console (for local task execution and debugging purposes). It supports custom scripts and delayed executions, advanced and classical tasks. It also has some experimental functions. This project represents the basic mechanisms of modern Remote Administration Tools (RATs, for short), and serves as material for anyone willing to learn about them.
### Feature List
| Status | Feature | Requires Admin |
| :------------: | :------------ | :------------: |
| :tw-2705: | Shutdown (with Message) | No |
| :tw-2705: | Reboot | No |
| :tw-2705: | Sleep/Wake Up (Monitor) | No |
| :tw-2705: | Get Network Information | Yes |
| :tw-2705: | Get Available WiFi Networks | No |
| :tw-2705: | Recover WiFi Profiles | No |
| :tw-2705: | Get Running Processes | No |
| :tw-2705: | Check if a Process Exists | No |
| :tw-2705: | Attempt to Kill a Process | No |
| :tw-2705: | Enable/Disable Task Manager | Yes |
| :tw-2705: | Get Detailed System Information | No |
| :tw-2705: | Get the List of Installed Programs | Yes |
| :tw-2705: | Recover Saved Passwords | No |
| :tw-2705: | Download a File (HTTP) | No |
| :tw-2705: | Upload a File (HTTP) | No |
| :tw-2705: | Run an Executable | No |
| :tw-2705: | Run a Command | No |
| :tw-2705: | Update Client | No |
| :tw-2705: | Restart Client | No |
| :tw-2705: | Uninstall Client | No |
| :tw-2705: | Ignore Client | No |
| :tw-2705: | Format the System Drive | No |
| :tw-2705: | Execute a Script | No |
| :tw-2705: | Schedule the Execution of a Script | No |
| :tw-2705: | Execute JS | No |
| :tw-2705: | Execute VBS | No |
| :tw-2705: | Halt All Scripts | No |
| :tw-2705: | XMR Mining | No |
| :tw-2705: | Floods | No |
| :tw-2705: | Keylogging | No |
| :tw-2705: | Open a Webpage | No |
| :tw-2705: | Change System Volume | No |
| :tw-2705: | Play a Sound (WAV) | No |
| :tw-2705: | Beep | No |
| :tw-2705: | Print a Document | No |
| :tw-2705: | Open a File | No |
| :tw-2705: | Messagebox | No |
| :tw-274c: | Reverse Proxy | No |
| :tw-2705: | **Remote File Explorer** | No |
| :tw-2705: | **Screenshare** | No |
| :tw-2705: | **Webcam** | No |
| :tw-2705: | **Chat** | No |
| :tw-2705: | **Remote Command Prompt** | No |
| :tw-274c: | **Remote PowerShell** | No |
| :tw-274c: | **System Event Viewer** | Yes |
### Bug/To-Do List
| Type | Bug/To-Do | Affects | Priority | Status |
| :------------: | :------------ | :------------: | :------------: | :------------: |
| :tw-1f41b: | Messagebox does not appear on top | Client | Low | Not Fixed |
| :tw-1f41b: | Webcam module is highly unstable | Client | Medium | Not Fixed |
| :tw-1f41b: | Communication is single-threaded | Client | High | Not Fixed |
| :tw-1f41b: | Random memory leaks | Client | Medium | Not Fixed |
| :tw-1f41b: | The local cursor is not accurate | Client | Low | Not Fixed |
| :tw-1f41b: | Remote File Explorer is generally slow | Server | Low | Not Fixed |
| :tw-1f41b: | The Tasks panel is not updated regularly | Server | Low | Not Fixed |
| :tw-1f41b: | Single Tasks wait for background replies | Server | Medium | Not Fixed |
| :tw-1f41b: | Network Information is not returned | Client | Medium | Not Fixed |
| :tw-1f41b: | No exception mechanism is in place | Client | High | Not Fixed |
| :tw-1f41b: | Admin commands are unstable | Client | Low | Not Fixed |
| :tw-1f4d8: | Some arrays are 1-indexed | Server | Low | Not Done |
| :tw-1f4d8: | Some loop variables are global | Server | Medium | Not Done |
| :tw-1f4d8: | Improve the Remote File Explorer | Server | Low | Not Done |
| :tw-1f4d8: | Clean up the Communication unit | Server | Medium | Not Done |
| :tw-1f4d8: | Fix the GetParams function | Client | Low | Not Done |
| :tw-1f4d8: | Improve persistence | Client | Medium | Not Done |
| :tw-1f4d8: | Add the Manifest Cloner | Server | Medium | Not Done |
| :tw-1f4d8: | Implement Anti-Debugging code | Client | Medium | Not Done |
| :tw-1f4d8: | Implement Process Protection | Client | Medium | Not Done |
| :tw-1f4d8: | **Finish the Builder** | Server | High | Not Done |
| :tw-1f4d8: | **Add Settings** | Server | High | Not Done |
| :tw-1f4d8: | **Add Statistics** | Server | High | Not Done |
### Screenshots
![Control Interface](https://i.imgur.com/erv0QLD.png)
![Tasks Panel](https://i.imgur.com/admQ9mD.png)
### Environment and Dependencies
This project was created in [Lazarus-IDE](https://www.lazarus-ide.org/ "Lazarus-IDE"), a free cross-platform IDE.
Internal Dependencies: BGRAControls, Indy 10, ScrollingText.
External Dependencies: avicap32.dll, WinAPI.