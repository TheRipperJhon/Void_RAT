unit ScreenUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, IdContext, Communication;

type

  { TScreenForm }

  TScreenForm = class(TForm)
    CursorCheck: TCheckBox;
    KeysCheck: TCheckBox;
    ClickCheck: TCheckBox;
    MoveCheck: TCheckBox;
    CompressLabel: TLabel;
    Scr: TImage;
    CursorLabel: TLabel;
    KeysLabel: TLabel;
    ClickLabel: TLabel;
    MoveLabel: TLabel;
    SettingsPanel: TPanel;
    CompressTrackBar: TTrackBar;
    procedure CompressTrackBarChange(Sender: TObject);
    procedure CursorCheckChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ScrMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ScrMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  ScreenForm: TScreenForm;
  SCon, CCon: TIdContext;

implementation

{$R *.lfm}

{ TScreenForm }

procedure TScreenForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if KeysCheck.Checked then Begin
  SendPlain(CCon,307,IntToStr(Key), False);
 end;
end;

procedure TScreenForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if KeysCheck.Checked then Begin
  SendPlain(CCon,308,IntToStr(Key), False);
 end;
end;

procedure TScreenForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=False;
  SendEmptyCommand(CCon, 776);
  CanClose:=True;
end;

procedure TScreenForm.CursorCheckChange(Sender: TObject);
begin
  if CursorCheck.Checked then Begin
   SendEmptyCommand(CCon, 301);
   Scr.Cursor:=crNone;
  end
  else Begin
   SendEmptyCommand(CCon, 302);
   Scr.Cursor:=crDefault;
  end;
end;

procedure TScreenForm.CompressTrackBarChange(Sender: TObject);
begin
  SendPlain(CCon,309,IntToStr(CompressTrackBar.Position), False);
end;

procedure TScreenForm.ScrMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if ClickCheck.Checked then Begin
  if Not(MoveCheck.Checked) then
  SendPlain(CCon,303,IntToStr(X)+'/'+
  IntToStr(Scr.Width)+','+IntToStr(Y)+'/'+IntToStr(Scr.Height), False);
  if Button = mbLeft then
  SendEmptyCommand(CCon, 304) else
  SendEmptyCommand(CCon, 305)
 end;
end;

procedure TScreenForm.ScrMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if MoveCheck.Checked then Begin
  SendPlain(CCon,303,IntToStr(X)+'/'+
  IntToStr(Scr.Width)+','+IntToStr(Y)+'/'+IntToStr(Scr.Height), False);
 end;
end;

procedure TScreenForm.ScrMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if ClickCheck.Checked then Begin
  if Not(MoveCheck.Checked) then
  SendPlain(CCon,303,IntToStr(X)+'/'+
  IntToStr(Scr.Width)+','+IntToStr(Y)+'/'+IntToStr(Scr.Height), False);
  SendEmptyCommand(CCon ,306);
 end;
end;

end.

