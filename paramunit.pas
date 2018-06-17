unit ParamUnit;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, BCButton;

type

  { TParamForm }

  TParamForm = class(TForm)
    CenterMarker: TShape;
    ExecuteButton: TBCButton;
    HintLabel: TLabel;
    procedure ExecuteButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  ParamForm: TParamForm;
  ExitType: LongInt;
  EClosing: Boolean = false;

implementation

{$R *.lfm}

{ TParamForm }

procedure TParamForm.ExecuteButtonClick(Sender: TObject);
begin
  ExitType:=0;
  EClosing:=True;
  ParamForm.Close;
end;

procedure TParamForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=False;
  if Not(EClosing) then
  ExitType:=-1;
  EClosing:=False;
  CanClose:=True;
end;

procedure TParamForm.FormCreate(Sender: TObject);
begin
  //CloseID:=TObject.Create;
end;

procedure TParamForm.FormDestroy(Sender: TObject);
begin
  //CloseID:=TObject.Free;
end;

end.

