program KarundengDemo;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  Stenografi_Karundeng in 'Stenografi_Karundeng.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
