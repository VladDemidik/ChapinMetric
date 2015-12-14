object Chapin: TChapin
  Left = 0
  Top = 0
  Caption = 'Chapin'
  ClientHeight = 449
  ClientWidth = 696
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MemoCode: TMemo
    Left = 32
    Top = 24
    Width = 233
    Height = 257
    TabOrder = 0
  end
  object mResult: TMemo
    Left = 416
    Top = 24
    Width = 233
    Height = 257
    TabOrder = 1
  end
  object ButtonLoadFromFileCode: TButton
    Left = 288
    Top = 22
    Width = 105
    Height = 25
    Caption = #1057#1095#1080#1090#1072#1090#1100' '#1089' '#1092#1072#1081#1083#1072
    TabOrder = 2
    OnClick = ButtonLoadFromFileCodeClick
  end
  object ButtonMake: TButton
    Left = 288
    Top = 64
    Width = 105
    Height = 25
    Caption = #1052#1077#1090#1088#1080#1082#1072
    TabOrder = 3
    OnClick = ButtonMakeClick
  end
  object OpenDialogCode: TOpenDialog
    Left = 656
    Top = 336
  end
end
