unit Communication;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdContext;

const
  CKEY1 = 77776;
  CKEY2 = 13666;

var
  TheKey: Word = 333;

function EncryptStr(const S :WideString; Key: Word): String;
function DecryptStr(const S: String; Key: Word): String;
function SendEncrypt(AContext: TIdContext; CmdNum: LongInt; Params: String;
                               AddFinalDelimiter: Boolean = true): Boolean;
function SendEmptyCommand(AContext: TIdContext; CmdNum: LongInt): Boolean;
function SendPlain(AContext: TIdContext; CmdNum: LongInt; Params: String;
                               AddFinalDelimiter: Boolean = true): Boolean;
function SendPlainStr(AContext: TIdContext; Str: String): Boolean;
function SendEncryptStr(AContext: TIdContext; Str: String): Boolean;

implementation

function EncryptStr(const S :WideString; Key: Word): String;
var   i          :Integer;
      RStr       :String;
      RStrB      :TBytes Absolute RStr;
begin
  Result:= '';
  RStr:= UTF8Encode(S);
  for i := 0 to Length(RStr)-1 do begin
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (RStrB[i] + Key) * CKEY1 + CKEY2;
  end;
  for i := 0 to Length(RStr)-1 do begin
    Result:= Result + IntToHex(RStrB[i], 2);
  end;
end;

function DecryptStr(const S: String; Key: Word): String;
var   i, tmpKey  :Integer;
      RStr       :String;
      RStrB      :TBytes Absolute RStr;
      tmpStr     :string;
begin
  tmpStr:= UpperCase(S);
  SetLength(RStr, Length(tmpStr) div 2);
  i:= 1;
  try
    while (i < Length(tmpStr)) do begin
      RStrB[i div 2]:= StrToInt('$' + tmpStr[i] + tmpStr[i+1]);
      Inc(i, 2);
    end;
  except
    Result:= '';
    Exit;
  end;
  for i := 0 to Length(RStr)-1 do begin
    tmpKey:= RStrB[i];
    RStrB[i] := RStrB[i] xor (Key shr 8);
    Key := (tmpKey + Key) * CKEY1 + CKEY2;
  end;
  Result:= {%H-}UTF8Decode(RStr);
end;

function SendEncrypt(AContext: TIdContext; CmdNum: LongInt; Params: String;
                               AddFinalDelimiter: Boolean = true): Boolean;
var OK: Boolean = true;
    ToSend: String;
Begin
 OK:=True;
 ToSend:=Params;
 if AddFinalDelimiter then ToSend += '#';
 ToSend:=EncryptStr(ToSend, TheKey);
 ToSend:=IntToStr(CmdNum)+'@'+ToSend;
 try
   AContext.Connection.IOHandler.WriteLn(ToSend);
 except on E: Exception do Ok:=False;
 end;
 SendEncrypt:=OK;
end;

function SendPlain(AContext: TIdContext; CmdNum: LongInt; Params: String;
                               AddFinalDelimiter: Boolean = true): Boolean;
var OK: Boolean = true;
    ToSend: String;
Begin
 OK:=True;
 ToSend:=IntToStr(CmdNum)+'@'+Params;
 if AddFinalDelimiter then ToSend += '#';
 try
   AContext.Connection.IOHandler.WriteLn(ToSend);
 except on E: Exception do Ok:=False;
 end;
 SendPlain:=OK;
end;

function SendPlainStr(AContext: TIdContext; Str: String): Boolean;
var OK: Boolean = true;
Begin
 OK:=True;
 try
   AContext.Connection.IOHandler.WriteLn(Str);
 except on E: Exception do OK:=False;
 end;
 SendPlainStr:=OK;
end;

function SendEncryptStr(AContext: TIdContext; Str: String): Boolean;
var OK: Boolean = true;
Begin
 OK:=True;
 try
   AContext.Connection.IOHandler.WriteLn(EncryptStr(Str, TheKey));
 except on E: Exception do OK:=False;
 end;
 SendEncryptStr:=OK;
end;

function SendEmptyCommand(AContext: TIdContext; CmdNum: LongInt): Boolean;
var OK: Boolean = true;
Begin
 OK:=True;
 try
   AContext.Connection.IOHandler.WriteLn(IntToStr(CmdNum)+'@');
 except on E: Exception do OK:=False;
 end;
 SendEmptyCommand:=OK;
end;

end.

