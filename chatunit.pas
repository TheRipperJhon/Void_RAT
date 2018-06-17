unit ChatUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, IdContext,
  Communication;

type

  { TChatForm }

  TChatForm = class(TForm)
    MessageEdit: TEdit;
    ChatLog: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

  public

  end;

var
  ChatForm: TChatForm;
  MyName: String;
  ChatContext: TIdContext;

implementation

{$R *.lfm}

{ TChatForm }

procedure TChatForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
 CanClose:=False;
 SendEmptyCommand(ChatContext, 502);
 SendEmptyCommand(ChatContext, 776);
 CanClose:=True;
end;

procedure TChatForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key=13 then Begin
    Key:=0;
    MessageEdit.Text:=StringReplace(MessageEdit.Text,sLineBreak,'',[rfReplaceAll, rfIgnoreCase]);
    if SendEncrypt(ChatContext,501,MyName+': '+MessageEdit.Text) then
    ChatLog.Lines.Add(MyName+': '+MessageEdit.Text);
    MessageEdit.Text:='';
  end;
end;


end.

