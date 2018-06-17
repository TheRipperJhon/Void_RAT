unit ChatUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TChatForm }

  TChatForm = class(TForm)
    MessageEdit: TEdit;
    ChatLog: TMemo;
  private

  public

  end;

var
  ChatForm: TChatForm;
  MyName: String;

implementation

{$R *.lfm}

end.

