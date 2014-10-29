unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GR32_Image, GR32, GR32_Polygons, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    paint1: TPaintBox32;
    rgMode: TRadioGroup;
    btnClear: TButton;
    chkShowNodes: TCheckBox;
    btnExplode: TButton;
    procedure paint1PaintBuffer(Sender: TObject);
    procedure paint1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure paint1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure paint1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure paintBoxInvalidate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnExplodeClick(Sender: TObject);
  private
    { Privclate declarations }
    FNodes : TArrayOfFloatPoint;
    FCurrentIndex : Integer;
    FDragging : Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Math, GR32_Resamplers, GR32_Geometry, GR32_LowLevel, GR32_VectorUtils;
  
{$R *.dfm}

function MakeCurve(const Points: TArrayOfFloatPoint; Kernel: TCustomKernel;
  Closed: Boolean): TArrayOfFloatPoint;
const
  TOLERANCE: TFloat = 20.0;
  THRESHOLD: TFloat = 0.5;
var
  I, H, R: Integer;
  Filter: TFilterMethod;
  WrapProc: TWrapProc;

  procedure AddPoint(const P: TFloatPoint);
  var
    L: Integer;
  begin
    L := Length(Result);
    SetLength(Result, L + 1);
    Result[L] := P;
  end;

  function GetPoint(I: Integer; t: TFloat = 0.0): TFloatPoint;
  var
    f, Index: Integer;
    W: TFloat;
  begin
    Result.X := 0; Result.Y := 0;
    for f := -R to R do
    begin
      Index := WrapProc(I - f, H);
      W := Filter(f + t);
      Result.X := Result.X + W * Points[Index].X;
      Result.Y := Result.Y + W * Points[Index].Y;
    end;
  end;

  procedure Recurse(I: Integer; const P1, P2: TFloatPoint; const t1, t2: TFloat);
  var
    Temp: TFloat;
    P: TFloatPoint;
  begin
    AddPoint(P1);
    Temp := (t1 + t2) * 0.5;
    P := GetPoint(I, Temp);

    if (Abs(CrossProduct(FloatPoint(P1.X - P.X, P1.Y - P.Y),
      FloatPoint(P.X - P2.X, P.Y - P2.Y))) > TOLERANCE) or (t2 - t1 >= THRESHOLD) then
    begin
      Recurse(I, P1, P, t1, Temp);
      Recurse(I, P, P2, Temp, t2);
    end
    else AddPoint(P);
  end;

const
  WRAP_PROC: array[Boolean] of TWrapProc = (Clamp, Wrap);
begin
  WrapProc := Wrap_PROC[Closed];
  Filter := Kernel.Filter;
  R := Ceil(Kernel.GetWidth);
  H := High(Points);

  for I := 0 to H - 1 do
    Recurse(I, GetPoint(I), GetPoint(I + 1), 0, 1);

  if Closed then
    Recurse(H, GetPoint(H), GetPoint(0), 0, 1)
  else
    AddPoint(GetPoint(H));
end;


procedure TForm1.paint1PaintBuffer(Sender: TObject);
var
  LCurve : TArrayOfFloatPoint;


  procedure DrawCurve();
  var
    K: TCustomKernel;
  begin
    if Length(FNodes) <=0 then
      Exit;

    // create interpolation kernel
    K := TGaussianKernel.Create;
    try
      // subdivide recursively and interpolate
      LCurve := MakeCurve(FNodes, K, False);
      PolylineFS( paint1.Buffer, LCurve, clBlack32, False, 1.3);
    finally
      K.Free;
    end;

  end;

var i : Integer;

begin
  paint1.Buffer.Clear(clWhite32);
  case rgMode.ItemIndex of
    0 : PolylineFS( paint1.Buffer, FNodes, clBlack32, False, 1.3);
    2 : DrawCurve();
  end;
//

  if chkShowNodes.Checked then
  for I := 0 to High(FNodes) do
  begin
    LCurve := Circle(FNodes[I].X, FNodes[I].Y, 4);
    PolygonFS(paint1.Buffer, LCurve, $FF000000);
    LCurve := Ellipse(FNodes[I].X, FNodes[I].Y, 2.75, 2.75);
    PolygonFS(paint1.Buffer, LCurve, $FF00FF00);
  end;


end;

procedure TForm1.paint1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var index : integer;
begin
  FDragging := True;
  FCurrentIndex := -1;

  for index := 0 to Length(FNodes) -1 do
    if Sqr(FNodes[Index].X - X) + Sqr(FNodes[Index].Y - Y)  < 25 then
    begin
      {if (Length(FNodes) > 5) and (Button = mbRight) then
      begin
        if Index < Length(FNodes) - 1 then
          Move(FNodes[Index + 1], FNodes[Index],
            (Length(FNodes) - Index - 1) * SizeOf(TFloatPoint));
        SetLength(FNodes, Length(FNodes) - 1);
        PaintBox32.Invalidate;
      end
      else}
        FCurrentIndex := Index;
      //Exit;
    end;

  if FCurrentIndex < 0 then
  begin
    FCurrentIndex := Length(FNodes);
    SetLength(FNodes, FCurrentIndex+1);
    FNodes[FCurrentIndex] := FloatPoint(X,Y);
  end;

  paint1.Invalidate;

end;

procedure TForm1.paint1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if FDragging then
  begin
    FNodes[FCurrentIndex] := FloatPoint(X,Y);

    paint1.Invalidate;

  end;
end;

procedure TForm1.paint1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

procedure TForm1.paintBoxInvalidate(Sender: TObject);
begin
  paint1.Invalidate;
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  FNodes := nil;
  paint1.Invalidate;
end;

procedure TForm1.btnExplodeClick(Sender: TObject);
var
  K: TCustomKernel;
begin
  if Length(FNodes) <=0 then
    Exit;

  // create interpolation kernel
  K := TGaussianKernel.Create;
  try
    // subdivide recursively and interpolate
    FNodes := MakeCurve(FNodes, K, False);
  finally
    K.Free;
  end;
  paint1.Invalidate;
end;

end.
