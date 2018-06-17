unit ManifestUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, Windows, Process, SysUtils;

function GetSysDir: String;
function GetManifest(AExeFile: String): Boolean;
function ExtractProperty(PName: String; SeparateTag: Boolean = false): String;

var Manifest: String;
    VersionInfo: String;

implementation

function GetSysDir: String;
var
dir : array [0..max_path] of char;
begin
GetSystemDirectory(dir, max_path);
result:=StrPas(dir);
end;

function GetManifest(AExeFile: String): Boolean;
var Sigcheck: TProcess;
    FFile: Text;
    Full, Loc: String;
Begin
 Sigcheck:=TProcess.Create(nil);
 Sigcheck.Executable:=GetSysDir+'\cmd.exe';
 Sigcheck.ShowWindow:=swoHIDE;
 Sigcheck.Parameters.Add('/C modules\sigcheck\sigcheck.exe -m "'+AExeFile+'" > C.manifest');
 Sigcheck.Execute;
 Repeat
  //Oh-oh, we need ProcessMessages, or a new Thread
 until Not(Sigcheck.Running);
 Sigcheck.Free;
 if FileExists('C.manifest') then Begin
   try
     AssignFile(FFile, 'C.manifest');
     Reset(FFile);
     Full:='';
     While Not(EOF(FFile)) do Begin
      Readln(FFile, Loc);
      Full+=loc+sLineBreak;
     end;
     CloseFile(FFile);
     DeleteFile('C.manifest');
     Delete(Full, 1, Pos('<', Full) - 1);
     Manifest:=Full;
     Result:=True;
   except
     Result:=False;
   end;
 end else Result:=False;
end;

function ExtractProperty(PName: String; SeparateTag: Boolean = false): String;
var X: String;
Begin
 X:=Manifest;
 Delete(X, 1, Pos(PName, X)+Length(PName)-1);
 if SeparateTag then Begin
  Delete(X, 1, Pos('>', X));
  Result:=LeftStr(X, Pos('<', X) - 1);
 end else Begin
  Delete(X, 1, Pos('"', X));
  Result:=LeftStr(X, Pos('"', X) - 1);
 end;
end;



end.

