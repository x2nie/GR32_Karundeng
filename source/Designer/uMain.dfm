object Form1: TForm1
  Left = 218
  Top = 114
  Width = 917
  Height = 582
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ImgView: TImgView32
    Left = 0
    Top = 0
    Width = 778
    Height = 536
    Align = alClient
    Bitmap.ResamplerClassName = 'TNearestResampler'
    BitmapAlign = baCustom
    RepaintMode = rmOptimizer
    Scale = 1.000000000000000000
    ScaleMode = smScale
    ScrollBars.ShowHandleGrip = True
    ScrollBars.Style = rbsDefault
    ScrollBars.Size = 16
    ScrollBars.Visibility = svAuto
    SizeGrip = sgNone
    OverSize = 0
    TabOrder = 2
    TabStop = True
  end
  object paint1: TPaintBox32
    Left = 352
    Top = 40
    Width = 337
    Height = 337
    TabOrder = 0
    Visible = False
    OnMouseDown = paint1MouseDown
    OnMouseMove = paint1MouseMove
    OnMouseUp = paint1MouseUp
    OnPaintBuffer = paint1PaintBuffer
  end
  object PnlControl: TPanel
    Left = 778
    Top = 0
    Width = 131
    Height = 536
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object PnlImage: TPanel
      Left = 0
      Top = 0
      Width = 131
      Height = 130
      Align = alTop
      TabOrder = 0
      object LblScale: TLabel
        Left = 8
        Top = 24
        Width = 30
        Height = 13
        Caption = 'Scale:'
      end
      object ScaleCombo: TComboBox
        Left = 16
        Top = 40
        Width = 105
        Height = 21
        DropDownCount = 9
        ItemHeight = 13
        TabOrder = 0
        Text = '100%'
        OnChange = ScaleComboChange
        Items.Strings = (
          '    25%'
          '    50%'
          '    75%'
          '  100%'
          '  200%'
          '  300%'
          '  400%'
          '  800%'
          '1600%')
      end
      object PnlImageHeader: TPanel
        Left = 1
        Top = 1
        Width = 129
        Height = 16
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Image Properties'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object CbxImageInterpolate: TCheckBox
        Left = 16
        Top = 72
        Width = 97
        Height = 17
        Caption = 'Interpolated'
        TabOrder = 2
      end
      object CbxOptRedraw: TCheckBox
        Left = 16
        Top = 96
        Width = 105
        Height = 17
        Caption = 'Optimize Repaints'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
    end
    object PnlBitmapLayer: TPanel
      Left = 0
      Top = 130
      Width = 131
      Height = 247
      Align = alTop
      TabOrder = 1
      object LblOpacity: TLabel
        Left = 8
        Top = 24
        Width = 53
        Height = 13
        Caption = 'Pen Width:'
        FocusControl = GbrLayerOpacity
      end
      object PnlBitmapLayerHeader: TPanel
        Left = 1
        Top = 1
        Width = 129
        Height = 16
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Line Properties'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object GbrLayerOpacity: TGaugeBar
        Left = 16
        Top = 40
        Width = 105
        Height = 12
        Backgnd = bgPattern
        HandleSize = 16
        LargeChange = 10
        Max = 16
        Min = 1
        ShowArrows = False
        ShowHandleGrip = True
        Style = rbsMac
        Position = 16
      end
      object chkShowNodes: TCheckBox
        Left = 16
        Top = 64
        Width = 97
        Height = 17
        Caption = 'Show nodes'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = paintBoxInvalidate
      end
      object rgMode: TRadioGroup
        Left = 10
        Top = 96
        Width = 111
        Height = 81
        Caption = 'rgMode'
        ItemIndex = 0
        Items.Strings = (
          'Polyline'
          'Spline'
          'Adaptive Curve')
        TabOrder = 3
        OnClick = paintBoxInvalidate
      end
      object btnClear: TButton
        Left = 16
        Top = 192
        Width = 105
        Height = 17
        Caption = 'Clear'
        TabOrder = 4
        OnClick = btnClearClick
      end
      object btnExplode: TButton
        Left = 16
        Top = 216
        Width = 105
        Height = 17
        Caption = 'Explode'
        TabOrder = 5
        OnClick = btnExplodeClick
      end
    end
    object PnlMagnification: TPanel
      Left = 0
      Top = 487
      Width = 131
      Height = 168
      Align = alTop
      TabOrder = 2
      Visible = False
      object LblMagifierOpacity: TLabel
        Left = 8
        Top = 24
        Width = 39
        Height = 13
        Caption = 'Opacity:'
      end
      object LblMagnification: TLabel
        Left = 8
        Top = 64
        Width = 66
        Height = 13
        Caption = 'Magnification:'
      end
      object LblRotation: TLabel
        Left = 8
        Top = 104
        Width = 43
        Height = 13
        Caption = 'Rotation:'
      end
      object PnlMagnificationHeader: TPanel
        Left = 1
        Top = 1
        Width = 129
        Height = 16
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Magnifier (All) Properties'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object GbrMagnOpacity: TGaugeBar
        Left = 16
        Top = 40
        Width = 105
        Height = 12
        Backgnd = bgPattern
        HandleSize = 16
        Max = 255
        ShowArrows = False
        ShowHandleGrip = True
        Style = rbsMac
        Position = 255
      end
      object GbrMagnMagnification: TGaugeBar
        Left = 16
        Top = 80
        Width = 105
        Height = 12
        Backgnd = bgPattern
        HandleSize = 16
        Max = 50
        ShowArrows = False
        ShowHandleGrip = True
        Style = rbsMac
        Position = 10
      end
      object GbrMagnRotation: TGaugeBar
        Left = 16
        Top = 120
        Width = 105
        Height = 12
        Backgnd = bgPattern
        HandleSize = 16
        Max = 180
        Min = -180
        ShowArrows = False
        ShowHandleGrip = True
        Style = rbsMac
        Position = 0
      end
      object CbxMagnInterpolate: TCheckBox
        Left = 16
        Top = 144
        Width = 97
        Height = 17
        Caption = 'Interpolated'
        TabOrder = 4
      end
    end
    object PnlButtonMockup: TPanel
      Left = 0
      Top = 377
      Width = 131
      Height = 110
      Align = alTop
      TabOrder = 3
      Visible = False
      object LblBorderRadius: TLabel
        Left = 8
        Top = 24
        Width = 70
        Height = 13
        Caption = 'Border Radius:'
      end
      object LblBorderWidth: TLabel
        Left = 8
        Top = 64
        Width = 65
        Height = 13
        Caption = 'Border Width:'
      end
      object PnlButtonMockupHeader: TPanel
        Left = 1
        Top = 1
        Width = 129
        Height = 16
        Align = alTop
        BevelOuter = bvNone
        Caption = 'Button (All) Properties'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object GbrBorderRadius: TGaugeBar
        Left = 16
        Top = 40
        Width = 105
        Height = 12
        Backgnd = bgPattern
        HandleSize = 16
        Max = 20
        Min = 1
        ShowArrows = False
        ShowHandleGrip = True
        Style = rbsMac
        Position = 5
      end
      object GbrBorderWidth: TGaugeBar
        Left = 16
        Top = 80
        Width = 105
        Height = 12
        Backgnd = bgPattern
        HandleSize = 16
        Max = 30
        Min = 10
        ShowArrows = False
        ShowHandleGrip = True
        Style = rbsMac
        Position = 20
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 104
    Top = 40
    object File1: TMenuItem
      Caption = '&File'
      object Open1: TMenuItem
        Caption = '&Open'
        ShortCut = 16463
      end
      object Save1: TMenuItem
        Caption = '&Save'
        ShortCut = 16467
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object SetBackground1: TMenuItem
        Caption = 'Set &Background'
        ShortCut = 16450
        OnClick = SetBackground1Click
      end
    end
  end
  object dlgOpenPic1: TOpenPictureDialog
    Left = 360
    Top = 120
  end
end
