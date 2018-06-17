unit WebcamUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, IdContext,
  Communication;

type

  { TWebcamForm }

  TWebcamForm = class(TForm)
    CamImage: TImage;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  private

  public

  end;

var
  WebcamForm: TWebcamForm;
  WebContext, MainC: TIdContext;

implementation

{$R *.lfm}

{ TWebcamForm }

procedure TWebcamForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=False;
  SendEmptyCommand(MainC, 401);
  SendEmptyCommand(MainC, 776);
  CanClose:=True;
end;

end.

