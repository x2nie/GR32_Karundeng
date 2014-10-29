unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  GR32_Image, GR32, GR32_Layers, GR32_Polygons, GR32_Transforms,
  StdCtrls, ExtCtrls,
  GR32_RangeBars,
  Menus,
  ExtDlgs;

type
  THitTestEvent = procedure (X, Y: Integer; var Hit: Boolean) of object;

  TVirtueLayer = class(TPositionedLayer)
  private
    FOnHitTest: THitTestEvent;
  protected
  protected
    function DoHitTest(X, Y: Integer): Boolean; override;
  public
    property OnHitTest : THitTestEvent read FOnHitTest write FOnHitTest;
  end;

  TForm1 = class(TForm)
    paint1: TPaintBox32;
    PnlControl: TPanel;
    PnlImage: TPanel;
    LblScale: TLabel;
    ScaleCombo: TComboBox;
    PnlImageHeader: TPanel;
    CbxImageInterpolate: TCheckBox;
    CbxOptRedraw: TCheckBox;
    PnlBitmapLayer: TPanel;
    LblOpacity: TLabel;
    PnlBitmapLayerHeader: TPanel;
    GbrLayerOpacity: TGaugeBar;
    chkShowNodes: TCheckBox;
    PnlMagnification: TPanel;
    LblMagifierOpacity: TLabel;
    LblMagnification: TLabel;
    LblRotation: TLabel;
    PnlMagnificationHeader: TPanel;
    GbrMagnOpacity: TGaugeBar;
    GbrMagnMagnification: TGaugeBar;
    GbrMagnRotation: TGaugeBar;
    CbxMagnInterpolate: TCheckBox;
    PnlButtonMockup: TPanel;
    LblBorderRadius: TLabel;
    LblBorderWidth: TLabel;
    PnlButtonMockupHeader: TPanel;
    GbrBorderRadius: TGaugeBar;
    GbrBorderWidth: TGaugeBar;
    rgMode: TRadioGroup;
    btnClear: TButton;
    btnExplode: TButton;
    ImgView: TImgView32;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    SetBackground1: TMenuItem;
    dlgOpenPic1: TOpenPictureDialog;
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
    procedure SetBackground1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ScaleComboChange(Sender: TObject);
  private
    { Privclate declarations }
    FNodes : TArrayOfFloatPoint;
    FCurrentIndex : Integer;
    FDragging : Boolean;
    FLineLayer : TVirtueLayer;
    FTransformation : TAffineTransformation;
    procedure LayerMouseDown(Sender: TObject; Buttons: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LayerMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure LayerMouseUp(Sender: TObject; Buttons: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintSimpleDrawingHandler(Sender: TObject; Buffer: TBitmap32);
    procedure LayerHitTest(X, Y: Integer; var Hit: Boolean); 
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Math, jpeg,
   GR32_Resamplers, GR32_Geometry, GR32_LowLevel, GR32_VectorUtils;
  
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
var  
  flipflop : Boolean;
begin
  WrapProc := Wrap_PROC[Closed];
  Filter := Kernel.Filter;
  R := Ceil(Kernel.GetWidth);
  H := High(Points);

  flipflop := True;
  for I := 0 to H - 1 do
  begin
    //Recurse(I, GetPoint(I), GetPoint(I + 1), 0, 1);
    //flipflop := not flipflop;
    if flipflop then
      Recurse(I, GetPoint(I), GetPoint(I + 1), 0, 1)
    else
      AddPoint(GetPoint(I));
  end;

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
      PolylineFS( paint1.Buffer, LCurve, clBlue32, False, 1.3);
    finally
      K.Free;
    end;

  end;

var
  i : Integer;
  c : TColor32;
begin
  paint1.Buffer.Clear(clWhite32);

  if chkShowNodes.Checked then
  for I := 0 to High(FNodes) do
  begin
    LCurve := Circle(FNodes[I].X, FNodes[I].Y, 4);
    //PolygonFS(paint1.Buffer, LCurve, $70000000);
    PolylineFS(paint1.Buffer,LCurve,clYellowgreen32,True,1);
    //LCurve := Ellipse(FNodes[I].X, FNodes[I].Y, 2.75, 2.75);
    if i = 0 then
      c := clLime32
    else if i = Length(FNodes) -1 then
      c := clFuchsia32
    else
      c := clAqua32;
    PolygonFS(paint1.Buffer, LCurve, $D0000000 or (c and $FFFFFF) );
  end;

  case rgMode.ItemIndex of
    0 : PolylineFS( paint1.Buffer, FNodes, clBlue32, False, 1.3);
    2 : DrawCurve();
  end;
//


end;

procedure TForm1.paint1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var I,index : integer;
  L,A : Double;
begin
  FDragging := True;
  index := -1;

  L := 1000;

  for I := 0 to Length(FNodes) -1 do
  begin
    A := Sqr(FNodes[I].X - X) + Sqr(FNodes[I].Y - Y);
    if (A  < 25) and (A < L) then
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
      //Exit;
      L := A;
      index := I;
    end;
  end;

  //DELETE
  if (Button = mbRight) and (index >= 0) then
  begin
    for I := index to Length(FNodes) -2 do
    begin
      FNodes[I] := FNodes[I+1];
    end;
    SetLength(FNodes, Length(FNodes) - 1);

    paint1.Invalidate;
    Exit;
  end;

  //INSERT
  if (ssShift in Shift) and (index >= 0) then
  begin
    SetLength(FNodes, Length(FNodes) + 1);

    for I := Length(FNodes) -1 downto index +1 do
    begin
      FNodes[I] := FNodes[I-1];
    end;

    Inc(index);
  end;

  FCurrentIndex := index;
  
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
  FLineLayer.Changed;
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

procedure TForm1.SetBackground1Click(Sender: TObject);
var P : TPicture;
begin
  if dlgOpenPic1.Execute then
  begin
    P := TPicture.Create;
    try
      P.LoadFromFile(dlgOpenPic1.FileName);
      //ImgView.Bitmap.LoadFromFile(dlgOpenPic1.FileName);
      ImgView.Bitmap.Assign(P);
    finally
      P.Free;
    end;

  end;
end;

procedure TForm1.FormCreate(Sender: TObject);

  procedure CreatePositionedLayer;
  var
    P: TPoint;
  begin
    // get coordinates of the center of viewport
    with ImgView.GetViewportRect do
      P := ImgView.ControlToBitmap(GR32.Point((Right + Left) div 2, (Top + Bottom) div 2));

    FLineLayer := TVirtueLayer.Create(ImgView.Layers);
    FLineLayer.Location := FloatRect(0,0,1,1);
    FLineLayer.Scaled := True;
    FLineLayer.MouseEvents := True;
    FLineLayer.OnMouseDown := LayerMouseDown;
    FLineLayer.OnMouseMove := LayerMouseMove;
    FLineLayer.OnMouseUp := LayerMouseUp;
    FLineLayer.OnHitTest := LayerHitTest;
    FLineLayer.OnPaint := PaintSimpleDrawingHandler;
    //FLineLayer.OnDblClick := LayerDblClick;
  end;

begin
  CreatePositionedLayer();
  FTransformation := TAffineTransformation.Create;
end;

{ TVirtueLayer }

function TVirtueLayer.DoHitTest(X, Y: Integer): Boolean;
begin
  if Assigned(FOnHitTest) then
    FOnHitTest(X,Y, result)
  else
    result := inherited DoHitTest(X,Y);
end;

procedure TForm1.LayerMouseDown(Sender: TObject; Buttons: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var I,index : integer;
  L,A : Double;
  P : TFloatPoint;
begin
  P := FTransformation.ReverseTransform(FloatPoint(X,Y));
  index := -1;

  L := 1000;

  for I := 0 to Length(FNodes) -1 do
  begin
    A := Sqr(FNodes[I].X - P.X) + Sqr(FNodes[I].Y - P.Y);
    if (A  < 25) and (A < L) then
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
      //Exit;
      L := A;
      index := I;
    end;
  end;

  //DELETE
  if (Buttons = mbRight) and (index >= 0) then
  begin
    for I := index to Length(FNodes) -2 do
    begin
      FNodes[I] := FNodes[I+1];
    end;
    SetLength(FNodes, Length(FNodes) - 1);

    FLineLayer.Changed;
    Exit;
  end;

  //INSERT
  if (ssShift in Shift) and (index >= 0) then
  begin
    SetLength(FNodes, Length(FNodes) + 1);

    for I := Length(FNodes) -1 downto index +1 do
    begin
      FNodes[I] := FNodes[I-1];
    end;

    Inc(index);
  end;

  FCurrentIndex := index;
  FDragging := True;

  
  if FCurrentIndex < 0 then
  begin
    FCurrentIndex := Length(FNodes);
    SetLength(FNodes, FCurrentIndex+1);
    FNodes[FCurrentIndex] := P;//FloatPoint(X,Y);
  end;

  FLineLayer.Changed;
end;

procedure TForm1.PaintSimpleDrawingHandler(Sender: TObject;
  Buffer: TBitmap32);
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
      PolylineFS( Buffer, LCurve, clBlue32, False, 1.3, jsMiter, esButt, 4, FTransformation);
    finally
      K.Free;
    end;

  end;

var
  i : Integer;
  c : TColor32;
  R : TRect;
begin
  //Buffer.Clear(clWhite32);
  FTransformation.Clear;
  FTransformation.Scale(ImgView.Scale);
  R := ImgView.GetBitmapRect;
  FTransformation.Translate(R.Left, R.Top);
  Buffer.FrameRectS(R, clRed32);

  if chkShowNodes.Checked then
  for I := 0 to High(FNodes) do
  begin
    LCurve := Circle(FNodes[I].X, FNodes[I].Y, 4);
    //PolygonFS(paint1.Buffer, LCurve, $70000000);
    PolylineFS(Buffer,LCurve,clYellowgreen32,True,1, jsMiter, esButt, 4, FTransformation);
    //LCurve := Ellipse(FNodes[I].X, FNodes[I].Y, 2.75, 2.75);
    if i = 0 then
      c := clLime32
    else if i = Length(FNodes) -1 then
      c := clFuchsia32
    else
      c := clAqua32;
    PolygonFS(Buffer, LCurve, $D0000000 or (c and $FFFFFF), pfAlternate, FTransformation );
  end;

  case rgMode.ItemIndex of
    0 : PolylineFS( Buffer, FNodes, clBlue32, False, 1.3, jsMiter, esButt, 4, FTransformation);
    2 : DrawCurve();
  end;
end;

procedure TForm1.LayerMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var  
  P : TFloatPoint;
begin
  if FDragging then
  begin
    P := FTransformation.ReverseTransform(FloatPoint(X,Y));
    FNodes[FCurrentIndex] := P;//FloatPoint(X,Y);

    FLineLayer.Changed;

  end;
end;

procedure TForm1.LayerMouseUp(Sender: TObject; Buttons: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
  begin
    FDragging := False;
  end;
end;

procedure TForm1.LayerHitTest(X, Y: Integer; var Hit: Boolean);
begin
  Hit := True;
end;

procedure TForm1.ScaleComboChange(Sender: TObject);
var
  S: string;
  I: Integer;
begin
  S := ScaleCombo.Text;
  S := StringReplace(S, '%', '', [rfReplaceAll]);
  S := StringReplace(S, ' ', '', [rfReplaceAll]);
  if S = '' then Exit;
  I := StrToIntDef(S, -1);
  if (I < 1) or (I > 2000) then
    I := Round(ImgView.Scale * 100)
  else
    ImgView.Scale := I * 0.01;
  ScaleCombo.Text := IntToStr(I) + '%';
  ScaleCombo.SelStart := Length(ScaleCombo.Text) - 1;

end;

end.
