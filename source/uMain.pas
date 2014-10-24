unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GR32, GR32_Image, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    img: TImgView32;
    mmo1: TMemo;
    btnShow: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DrawLines;
    procedure DrawT(X: Integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.DrawLines;
var x,y,x2, i : Integer;
  c : TColor32;
begin
  c := color32(217,215,191);
  with img.Bitmap do
  begin
    x := 50;
    x2 := width - 50;
    y := 50;
    SetStipple([0,0,c,c ]);
    for i := 1 to 5 do
    begin
      //LineS(x,y,x2,y, color32(217,215,191));
      LineFP(x,y,x2,y);
      Inc(y, 16);
    end;
  end;
end;

procedure TForm1.DrawT(X: Integer);
var y,x2, i : Integer;
  c : TColor32;
begin
  c := clGray32;
  with img.Bitmap do
  begin
    x2 := x - 25;
    y := 50;
    LineS(x,y,x2,y+ 2*16, c);

  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  img.Bitmap.SetSize(600,1000);
  img.Bitmap.Clear(Color32(251,245,221));
  img.ScrollToCenter(0,0);
  DrawLines;
  DrawT(150);
  DrawT(190);
  DrawT(250);
end;

end.
