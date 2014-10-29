object Form1: TForm1
  Left = 196
  Top = 152
  Width = 928
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object paint1: TPaintBox32
    Left = 24
    Top = 16
    Width = 337
    Height = 337
    TabOrder = 0
    OnMouseDown = paint1MouseDown
    OnMouseMove = paint1MouseMove
    OnMouseUp = paint1MouseUp
    OnPaintBuffer = paint1PaintBuffer
  end
  object rgMode: TRadioGroup
    Left = 496
    Top = 32
    Width = 137
    Height = 177
    Caption = 'rgMode'
    ItemIndex = 0
    Items.Strings = (
      'Polyline'
      'Spline'
      'Adaptive Curve')
    TabOrder = 1
    OnClick = paintBoxInvalidate
  end
  object btnClear: TButton
    Left = 696
    Top = 32
    Width = 75
    Height = 25
    Caption = 'btnClear'
    TabOrder = 2
    OnClick = btnClearClick
  end
  object chkShowNodes: TCheckBox
    Left = 496
    Top = 224
    Width = 97
    Height = 17
    Caption = 'chkShowNodes'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = paintBoxInvalidate
  end
  object btnExplode: TButton
    Left = 696
    Top = 80
    Width = 75
    Height = 25
    Caption = 'btnExplode'
    TabOrder = 4
    OnClick = btnExplodeClick
  end
end
