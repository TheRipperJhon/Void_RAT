unit RemoteCMDUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, IdContext, Windows, Communication;

type

  { TRemoteCMDForm }

  TRemoteCMDForm = class(TForm)
    Console: TMemo;
    CommandEDT: TEdit;
    procedure CommandEDTClick(Sender: TObject);
    procedure CommandEDTKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ConsoleChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  private

  public

  end;

var
  RemoteCMDForm: TRemoteCMDForm;
  TheContext: TIdContext;

implementation

{$R *.lfm}

{ TRemoteCMDForm }

procedure TRemoteCMDForm.CommandEDTClick(Sender: TObject);
begin
  if CommandEDT.Text='Enter a command...' then CommandEDT.Text:='';
end;

procedure TRemoteCMDForm.CommandEDTKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Ord(Key)=13 then Begin
   SendEncrypt(TheContext,7,CommandEDT.Text, False);
   CommandEDT.Text:='';
   CommandEDT.Enabled:=False;
  end;
end;

procedure TRemoteCMDForm.ConsoleChange(Sender: TObject);
begin
   SendMessage(Console.Handle, EM_LINESCROLL, 0, Console.Lines.Count);
end;

procedure TRemoteCMDForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=False;
  CommandEDT.Enabled:=False;
  SendEmptyCommand(TheContext, 776);
  CanClose:=True;
end;

end.

