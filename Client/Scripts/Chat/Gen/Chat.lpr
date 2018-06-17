program Chat;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, ChatUnit, Windows;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TChatForm, ChatForm);
  //ShowWindow(GetConsoleWindow, SW_HIDE);
  if ParamStr(1)<>'chat' then Application.ShowMainForm:=False;
  Application.Run;
end.

