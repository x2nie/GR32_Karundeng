object Form1: TForm1
  Left = 199
  Top = 118
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 328
    Width = 920
    Height = 125
    Align = alBottom
    TabOrder = 0
    object mmo1: TMemo
      Left = 16
      Top = 16
      Width = 393
      Height = 97
      TabOrder = 0
    end
    object btnShow: TButton
      Left = 440
      Top = 16
      Width = 75
      Height = 25
      Caption = '&Show'
      TabOrder = 1
    end
  end
  object img: TImgView32
    Left = 0
    Top = 0
    Width = 920
    Height = 328
    Align = alClient
    Bitmap.ResamplerClassName = 'TNearestResampler'
    BitmapAlign = baCustom
    Scale = 1.000000000000000000
    ScaleMode = smScale
    ScrollBars.ShowHandleGrip = True
    ScrollBars.Style = rbsDefault
    ScrollBars.Size = 16
    ScrollBars.Visibility = svAuto
    OverSize = 0
    TabOrder = 1
  end
end
