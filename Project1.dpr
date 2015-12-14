program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Chapin};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TChapin, Chapin);
  Application.Run;
end.
