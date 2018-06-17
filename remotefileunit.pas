unit RemoteFileUnit;

{$mode objfpc}{$H+}
{$WARN 4104 on : Implicit string type conversion from "$1" to "$2"}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StrUtils,
  ComCtrls, Menus, StdCtrls, Grids, IdContext, INIFiles, Types, LCLType, Base64,
  Communication;

type

  { TFileForm }

  TBookmark = record
    Name: String;
    RemotePath: String;
  end;

  TFileForm = class(TForm)
    IconList: TImageList;
    DirView: TListBox;
    LowStatusBar: TStatusBar;
    FileListMenu: TPopupMenu;
    FileListView: TStringGrid;
    AddBItem: TMenuItem;
    DirMenu: TPopupMenu;
    DownItem: TMenuItem;
    NewItem: TMenuItem;
    UpDialog: TOpenDialog;
    DownDialog: TSaveDialog;
    ToggleItem: TMenuItem;
    ORItem: TMenuItem;
    UpItem: TMenuItem;
    CopyItem: TMenuItem;
    DelItem: TMenuItem;
    CutItem: TMenuItem;
    RefItem: TMenuItem;
    RemBItem: TMenuItem;
    procedure AddBItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure CutItemClick(Sender: TObject);
    procedure DelItemClick(Sender: TObject);
    procedure DirViewMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure DirViewSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure DownItemClick(Sender: TObject);
    procedure FileListMenuDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure FileListMenuMeasureItem(Sender: TObject; {%H-}ACanvas: TCanvas;
      var AWidth, AHeight: Integer);
    procedure FileListViewClick(Sender: TObject);
    procedure FileListViewDblClick(Sender: TObject);
    procedure FileListViewDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; {%H-}aState: TGridDrawState);
    procedure FileListViewMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure NewItemClick(Sender: TObject);
    procedure ORItemClick(Sender: TObject);
    procedure RefItemClick(Sender: TObject);
    procedure RemBItemClick(Sender: TObject);
    procedure ToggleItemClick(Sender: TObject);
    procedure UpItemClick(Sender: TObject);
  private

  public
    procedure UpdateBookmarks;
    procedure AddBookmark(aName, Path: String);
    procedure RemoveBookmark(aName: String);
    function FindBookmarkPath(aName: String): String;
    procedure Status(StrToStatus: String);
    procedure ChangeCurrentDir(NewDir: String);
    function GetFileIcon(AType: String): LongInt;
  end;

var
  FileForm: TFileForm;
  TheContext: TIdContext;
  CurrentDir, CName, BTransmit, BTransmitType, ToCopy, ToCut, CopyType: String;
  SharedINI: TINIFile;
  Bookmarks: Array of TBookmark;
  DriveCount: LongInt = 0;
  DownlTo, UplTo, Huge: String;

implementation

{$R *.lfm}


{ TFileForm }

procedure TFileForm.Status(StrToStatus: String);
Begin
 FileForm.LowStatusBar.Panels[0].Text:=StrToStatus;
end;

procedure TFileForm.ChangeCurrentDir(NewDir: String);
Begin
 With FileForm do Begin
  CurrentDir:=NewDir;
  Status('Browsing '+NewDir);
 end;
end;

procedure TFileForm.UpdateBookmarks;
var Tmp: String;
    J: LongInt;
Begin
  SharedINI:=TINIFile.Create('Database.ini');
  Tmp:=SharedINI.ReadString(CName,'Bookmarks','');
   //Name|Path#Name|Path#
   While Pos('#',Tmp)>0 do Begin
    J:=High(Bookmarks);
    SetLength(Bookmarks, J + 2);
    Inc(J);
    Bookmarks[J].Name:=LeftStr(Tmp, Pos('|',Tmp)-1);
    Delete(Tmp,1,Pos('|', Tmp));
    Bookmarks[J].RemotePath:=LeftStr(Tmp, Pos('#',Tmp)-1);
    Delete(Tmp,1,Pos('#', Tmp));
    DirView.Items.Add(Bookmarks[J].Name);
   end;
   SharedINI.Free;
end;

function TFileForm.GetFileIcon(AType: String): LongInt;
var H: String;
Begin
 H:=StringReplace(AType,'File','',[rfReplaceAll]);
 H:=StringReplace(H,' ','',[rfReplaceAll]);
 Case H of
 'Folder': Result:=2;
 '.exe': Result:=4;
 '.pdf': Result:=5;
 '.doc', '.docx': Result:=6;
 '.ppt', '.pptx': Result:=7;
 '.xls', '.xlsx': Result:=8;
 '.txt': Result:=9;
 '.iso': Result:=10;
 '.rtf': Result:=11;
 '.rar', '.7z', '.tar', '.gz': Result:=12;
 '.zip': Result:=13;
 '.avi': Result:=14;
 '.mp4': Result:=15;
 '.mp3': Result:=16;
 '.jpg': Result:=17;
 '.png': Result:=18;
 '.html': Result:=19;
 '.xml': Result:=20;
 '.js': Result:=21;
 '.css': Result:=22;
 '.pif', '.dll', '.sys', '.ini', '.ocx', '.scr', '.o', '.obj': Result:=23;
 else Result:=3;
 end;
end;

procedure TFileForm.RemoveBookmark(aName: String);
var Tmp, P: String;
Begin
 SharedINI:=TINIFile.Create('Database.ini');
 Tmp:=SharedINI.ReadString(CName,'Bookmarks','');
 P:=LeftStr(Tmp, Pos(aName, Tmp) - 1);
 Delete(Tmp, 1, Pos(aName, Tmp));
 Delete(Tmp, 1, Pos('#', TMP));
 P+=Tmp;
 SharedINI.WriteString(CName, 'Bookmarks', P);
 SharedINI.Free;
 DirView.Items.Clear;
 DriveCount:=0;
 SendEmptyCommand(TheContext, 223);
end;

procedure TFileForm.AddBookmark(aName, Path: String);
Begin
  SharedINI:=TINIFile.Create('Database.ini');
  SharedINI.WriteString(CName, 'Bookmarks', SharedINI.ReadString(CName,'Bookmarks','')+
            aName+'|'+Path+'#');
  SharedINI.Free;
  DirView.Items.Clear;
  DriveCount:=0;
  SendEmptyCommand(TheContext, 223);
end;

function TFileForm.FindBookmarkPath(aName: String): String;
var J: LongInt;
    L: String;
Begin
 L:='';
 For J:=Low(Bookmarks) to High(Bookmarks) do
 if Bookmarks[J].Name=aName then Begin
   L:=Bookmarks[J].RemotePath;
   Break;
 end;
 Result:=L;
end;

procedure TFileForm.DirViewSelectionChange(Sender: TObject; User: boolean);
begin
 //Get files and subfolders
 if DirView.ItemIndex>-1 then Begin
 if (DirView.ItemIndex<=DriveCount-1) then
 ChangeCurrentDir(DirView.Items[DirView.ItemIndex]) else
 ChangeCurrentDir(IncludeTrailingPathDelimiter(FindBookmarkPath(DirView.Items[DirView.ItemIndex])));
 SendEncrypt(TheContext,224,CurrentDir,False);
 end;
end;

procedure TFileForm.DownItemClick(Sender: TObject);
begin
 if BTransmitType='File Folder' then
 DownDialog.FileName:=BTransmit+'.zip' else
 DownDialog.FileName:=BTransmit;
  if DownDialog.Execute then Begin
   Huge:='';
   DownlTo:=DownDialog.FileName;
   DownDialog.FileName:='';
   FileListView.Enabled:=False;
   DirView.Enabled:=False;
   LowStatusBar.Panels[0].Text:='Downloading '+CurrentDir+BTransmit+'...';
   if BTransmitType='File Folder' then
   SendEncrypt(TheContext,235,CurrentDir+BTransmit, False)
   else SendEncrypt(TheContext, 236,CurrentDir+BTransmit, False);
  end;
end;

procedure TFileForm.FileListMenuDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
var S: String;
    L: LongInt;
    Z: TBitmap;
begin
  ACanvas.Font:=FileListView.Font;
  if odDisabled in AState then
  ACanvas.Brush.Color:=$00342701 else
  if odSelected in AState then
  ACanvas.Brush.Color:=$00DB9834 else
  ACanvas.Brush.Color := $00433201;
  ACanvas.Rectangle(ARect);
  S:=(Sender as TMenuItem).Caption;
  Z:=TBitmap.Create;
  if (Sender as TMenuItem)=RemBItem then
  IconList.GetBitmap(1, Z) else Begin
  L:=FileListMenu.Items.IndexOf((Sender as TMenuItem));
  if L=0 then IconList.GetBitmap(0, Z)
  else if L<5 then IconList.GetBitmap(L+23, Z)
  else if L=5 then IconList.GetBitmap(26, Z)
  else if L=9 then IconList.GetBitmap(2, Z)
  else IconList.GetBitmap(L+22, Z);
  end;
  ACanvas.Draw(ARect.Left+2,ARect.Top+2,Z);
  ACanvas.TextOut(ARect.Left+26+4, ARect.Top+4, S);
  Z.Free;
end;

procedure TFileForm.FileListMenuMeasureItem(Sender: TObject; ACanvas: TCanvas;
  var AWidth, AHeight: Integer);
begin
  AWidth:=250;
  AHeight:=28
end;

procedure TFileForm.AddBItemClick(Sender: TObject);
var X: String;
begin
 X:='';
  if InputQuery('New Bookmark', 'Enter a name for your new Bookmark.', X) then Begin
   AddBookmark(X, CurrentDir+BTransmit);
  end;
end;

procedure TFileForm.CopyItemClick(Sender: TObject);
var WhereTo: String;
begin
  if ToCopy = '' then Begin
   ToCopy:=CurrentDir+BTransmit;
   CopyType:=BTransmitType;
   CopyItem.Caption:='Paste Here';
  end else Begin
   WhereTo:=ExtractFileName(ToCut);
   if CopyType = 'File Folder' then Begin
    if InputQuery('File Manager','Enter the new Folder Name:',WhereTo) then
     SendEncrypt(TheContext, 231,ToCopy+'#'+CurrentDir+WhereTo+'#', False);
   End else Begin
    if InputQuery('File Manager','Enter the new File Name:',WhereTo) then
     SendEncrypt(TheContext, 232,ToCopy+'#'+CurrentDir+WhereTo+'#', False);
   end;
   CopyItem.Caption:='Copy To';
   ToCopy:='';
  end;
end;

procedure TFileForm.CutItemClick(Sender: TObject);
var WhereTo: String;
begin
  if ToCut = '' then Begin
   ToCut:=CurrentDir+BTransmit;
   CopyType:=BTransmitType;
   CutItem.Caption:='Move Here';
  end else Begin
   WhereTo:=CurrentDir;
   if QuestionDlg ('File Manager','Do you really want to move "'+ToCut+'" to "'+CurrentDir+'"?',mtCustom,[mrYes,'Yes', mrNo, 'No', 'IsDefault'],'')=mrYes then
   if CopyType = 'File Folder' then Begin
     SendEncrypt(TheContext, 233,ToCut+'#'+WhereTo+ExtractFileName(ToCut)+'#', False);
   End else Begin
    SendEncrypt(TheContext, 234,ToCut+'#'+WhereTo+ExtractFileName(ToCut)+'#', False);
   end;
   CutItem.Caption:='Move To';
   ToCut:='';
  end;
end;

procedure TFileForm.DelItemClick(Sender: TObject);
var C: String;
begin
  if QuestionDlg ('File Manager','Do you really want to delete "'+BTransmit+'"?',mtCustom,[mrYes,'Yes', mrNo, 'No', 'IsDefault'],'')=mrYes then Begin
   if BTransmitType='File Folder' then
   C:='226@'+EncryptStr(CurrentDir+BTransmit, TheKey) else
   C:='227@'+EncryptStr(CurrentDir+BTransmit, TheKey);
   SendPlainStr(TheContext, C);
  end;
end;

procedure TFileForm.DirViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then Begin
  if DirView.ItemIndex>DriveCount-1 then
  RemBItem.Enabled:=True
  else RemBItem.Enabled:=False;
  end;
end;

procedure TFileForm.FileListViewClick(Sender: TObject);
begin
  FileListView.Options:=FileListView.Options+[goRowSelect];
end;

procedure TFileForm.FileListViewDblClick(Sender: TObject);
var II: LongInt;
    P: String;
begin
  II:=FileListView.Selection.Top;
  P:=FileListView.Cells[0, II];
  if FileListView.Cells[1, II]='File Folder' then Begin
    if P='..' then Begin
     P:=AnsiReverseString(CurrentDir);
     if P[1]='\' then
     Delete(P, 1, Pos('\', P));
     Delete(P, 1, Pos('\', P));
     ChangeCurrentDir(AnsiReverseString(P)+'\');
    End else
    ChangeCurrentDir(CurrentDir+P+'\');
    SendEncrypt(TheContext,224,CurrentDir,False);
  end;
end;

procedure TFileForm.FileListViewDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  S: string;
  aCanvas: TCanvas;
  Z: TBitmap;
begin
  if (ACol = 1) and (ARow > 0) then Begin
    S:=(Sender as TStringGrid).Cells[ACol, ARow];
    aCanvas := (Sender as TStringGrid).Canvas;
    Z:=TBitmap.Create;
    IconList.GetBitmap(GetFileIcon(S), Z);
    aCanvas.Draw(aRect.Left+4, aRect.Top+1, Z);
    Z.Free;
  end;
end;

procedure TFileForm.FileListViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var C, R: LongInt;
begin
  if Button = mbRight then Begin
   FileListView.MouseToCell(X, Y, C{%H-}, R{%H-});
   BTransmit:=FileListView.Cells[0, R];
   BTransmitType:=FileListView.Cells[1, R];
   if FileListView.Cells[1, R]<>'File Folder' then Begin
   AddBItem.Enabled:=False;
   end else Begin
    AddBItem.Enabled:=True;
   end;
  end;
end;

procedure TFileForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=False;
  FileListView.Enabled:=False;
  DirView.Enabled:=False;
  SendEmptyCommand(TheContext,776);
  CanClose:=True;
end;

procedure TFileForm.NewItemClick(Sender: TObject);
var X: String;
begin
 X:='';
 if InputQuery('File Manager', 'Enter a name for the New Folder:', X) then Begin
  SendEncrypt(TheContext,238,CurrentDir+X, False);
 end;
end;

procedure TFileForm.ORItemClick(Sender: TObject);
begin
 SendEncrypt(TheContext,228,CurrentDir+BTransmit,False);
end;

procedure TFileForm.RefItemClick(Sender: TObject);
begin
 SendEmptyCommand(TheContext,224);
end;

procedure TFileForm.RemBItemClick(Sender: TObject);
var N: String;
begin
 N:=DirView.Items.Strings[DirView.ItemIndex];
 if QuestionDlg ('Remove Bookmark','Do you really want to remove "'+N+'"?',mtCustom,[mrYes,'Yes', mrNo, 'No', 'IsDefault'],'')=mrYes then
 RemoveBookmark(N);
end;

procedure TFileForm.ToggleItemClick(Sender: TObject);
var C: String;
begin
  if QuestionDlg ('File Manager','Do you really want to toggle encryption on "'+BTransmit+'"?',mtCustom,[mrYes,'Yes', mrNo, 'No', 'IsDefault'],'')=mrYes then Begin
   if BTransmitType='File Folder' then
   C:='229@'+EncryptStr(CurrentDir+BTransmit, TheKey) else
   C:='230@'+EncryptStr(CurrentDir+BTransmit, TheKey);
   SendPlainStr(TheContext, C);
  end;
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

procedure TFileForm.UpItemClick(Sender: TObject);
var S, T: String;
begin
 if UpDialog.Execute then Begin
  Status('Upload in progress...');
  DirView.Enabled:=False;
  FileListView.Enabled:=False;
  SendEncrypt(TheContext,237,'FileName'+CurrentDir+ExtractFileName(UpDialog.FileName),False);
  S:=SFileToString(UpDialog.FileName);
  UpDialog.FileName:='';
  S:=EncodeStringBase64(S);
  While Length(S)>600 do Begin
  T:=LeftStr(S, 600);
  Delete(S,1,600);
  SendEncrypt(TheContext,237,T, False);
  End;
  if Length(Huge)>0 then SendEncrypt(TheContext,237,S, False);
  SendEncrypt(TheContext,237,'OVER', False);
  Status('Upload complete.');
  DirView.Enabled:=True;
  FileListView.Enabled:=True;
 end;
end;

end.

