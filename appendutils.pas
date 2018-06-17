unit AppendUtils;

{$mode delphi}{$H+}

interface

uses
  Classes, Windows, SysUtils;

type
  TBytes = Array of Byte;

function SafeReadFile(FileName: String): AnsiString;
function ReadEOF(FileName, Delimit1, Delimit2: String): String;
function WriteEOF(FileName, Res, Delimit1, Delimit2: String): Boolean;
function AlterResource(AExeFile, AResName: string; const AResContent: TBytes): Boolean;
function WriteADS(FileName, StreamName, Data: String): Boolean;
function ReadADS(FileName, StreamName: String): String;
function StringToBytes(Str: String): TBytes;

implementation

function SafeReadFile(FileName: String): AnsiString;
var
  F             :File;
  Buffer        :AnsiString;
  Size          :Integer;
  ReadBytes     :Integer;
  DefaultFileMode:Byte;
begin
  Result := '';
  DefaultFileMode := FileMode;
  FileMode := 0;
  AssignFile(F, FileName);
  Reset(F, 1);

  if (IOResult = 0) then
  begin
    Size := FileSize(F);
    while (Size > 1024) do
    begin
      SetLength(Buffer, 1024);
      BlockRead(F, Buffer[1], 1024, ReadBytes);
      Result := Result + Buffer;
      Dec(Size, ReadBytes);
    end;
    SetLength(Buffer, Size);
    BlockRead(F, Buffer[1], Size);
    Result := Result + Buffer;
    CloseFile(F);
  end;

  FileMode := DefaultFileMode;
end;

function ReadEOF(FileName, Delimit1, Delimit2: String): String;
var
  Buffer      :AnsiString;
begin
  Buffer := SafeReadFile(FileName);
  Delete(Buffer, 1, Pos(Delimit1, Buffer)+Length(Delimit1) - 1);
  Result:=LeftStr(Buffer, Pos(Delimit2, Buffer) - 1);
end;

function WriteEOF(FileName, Res, Delimit1, Delimit2: String): Boolean;
var
  F: TextFile;
begin
  Result:=True;
  try
    AssignFile(F,FileName);
    Append(F);
    Writeln(F,Delimit1+Res+Delimit2);
    CloseFile(F);
  except
    Result:=False;
  end;
end;

function StringToBytes(Str: String): TBytes;
Begin
  Result:=TEncoding.UTF8.GetBytes(Str);
end;

function AlterResource(AExeFile, AResName: string; const AResContent: TBytes): Boolean;
var
  vResHandle: THandle;
begin
  Result:=True;
  AExeFile := ExpandFileName(AExeFile);

  vResHandle := BeginUpdateResource(PChar(AExeFile), False);
  if vResHandle=0 then Result:=False else Begin
    try
      Result:=UpdateResource(vResHandle, RT_RCDATA,
              PChar(UpperCase(AResName)), LANG_NEUTRAL, AResContent, Length(AResContent));
    finally
      EndUpdateResource(vResHandle, False);
    end;
  end;
end;

function WriteADS(FileName, StreamName, Data: String): Boolean;
var F: Text;
Begin
  Result:=True;
  try
    AssignFile(F,FileName+':'+StreamName);
    Rewrite(F);
    Write(F, Data);
    CloseFile(F);
  except
    Result:=False;
  end;
end;

function ReadADS(FileName, StreamName: String): String;
var F: Text;
    Full, P: String;
Begin
 Full:='';
 try
   AssignFile(F,FileName+':'+StreamName);
   Reset(F);
   While Not(EOF(F)) do Begin
     Readln(F, P);
     Full+=P+sLineBreak;
   end;
   //You should remove the last LineBreak
   CloseFile(F);
 except
   Full:='';
 end;
 Result:=Full;
end;

end.

