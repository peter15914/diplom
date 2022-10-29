object Form1: TForm1
  Left = 29
  Top = 120
  Width = 756
  Height = 372
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 288
    Top = 8
    Width = 5
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object i1: TPaintBox
    Left = 8
    Top = 64
    Width = 537
    Height = 273
  end
  object Label1: TLabel
    Left = 560
    Top = 56
    Width = 151
    Height = 13
    Caption = #1082#1086#1083'-'#1074#1086' '#1089#1074#1073#1086#1076#1085#1099#1093' '#1087#1077#1088#1077#1084#1077#1085#1085#1099#1093
  end
  object Label4: TLabel
    Left = 560
    Top = 176
    Width = 5
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Button1: TButton
    Left = 16
    Top = 0
    Width = 83
    Height = 25
    Caption = 'ReRead data'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 16
    Top = 32
    Width = 75
    Height = 25
    Caption = 'interpolate'
    TabOrder = 0
    OnClick = Button2Click
  end
  object cb1: TCheckBox
    Left = 456
    Top = 24
    Width = 97
    Height = 17
    Caption = 'Draw triangles'
    TabOrder = 2
  end
  object Button3: TButton
    Left = 480
    Top = 0
    Width = 57
    Height = 17
    Caption = 'Repaint'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 112
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 4
  end
  object Edit2: TEdit
    Left = 112
    Top = 32
    Width = 41
    Height = 21
    TabOrder = 5
  end
  object Edit3: TEdit
    Left = 552
    Top = 80
    Width = 177
    Height = 21
    TabOrder = 6
  end
  object Edit4: TEdit
    Left = 552
    Top = 136
    Width = 169
    Height = 21
    TabOrder = 7
  end
  object Edit5: TEdit
    Left = 168
    Top = 8
    Width = 65
    Height = 21
    TabOrder = 8
  end
  object Edit6: TEdit
    Left = 168
    Top = 32
    Width = 65
    Height = 21
    TabOrder = 9
  end
  object cb2: TCheckBox
    Left = 552
    Top = 165
    Width = 97
    Height = 17
    Caption = #1058#1077#1085#1100
    TabOrder = 10
  end
  object Button4: TButton
    Left = 568
    Top = 0
    Width = 113
    Height = 25
    Caption = 'Generate *.grd file'
    TabOrder = 11
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 552
    Top = 304
    Width = 89
    Height = 25
    Caption = 'Generate func'
    TabOrder = 12
    OnClick = Button5Click
  end
  object cb3: TCheckBox
    Left = 456
    Top = 40
    Width = 97
    Height = 17
    Caption = 'Show levels'
    Checked = True
    State = cbChecked
    TabOrder = 13
  end
  object rg1: TRadioGroup
    Left = 552
    Top = 224
    Width = 185
    Height = 65
    Caption = #1042#1099#1074#1086#1076#1080#1090#1100
    ItemIndex = 0
    Items.Strings = (
      #1056#1077#1096#1077#1085#1080#1077
      #1047#1072#1076#1072#1085#1085#1091#1102' '#1092#1091#1085#1082#1094#1080#1102)
    TabOrder = 14
    OnClick = rg1Click
  end
  object SaveDialog1: TSaveDialog
    FileName = 'data.grd'
    Filter = '*.grd|*.grd'
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 704
    Top = 8
  end
  object OpenDialog1: TOpenDialog
    FileName = 'datanew'
    Filter = '*.*|*.*'
    Left = 288
    Top = 16
  end
end
