unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, RegExpr, Vcl.Dialogs, Vcl.StdCtrls;

type
  Value = record
  name : string;
  is_used : boolean;
  control_val : boolean;
  IO_val : boolean;
  end;
  TValue = array of Value;
  TChapin = class(TForm)
    MemoCode: TMemo;
    mResult: TMemo;
    ButtonLoadFromFileCode: TButton;
    ButtonMake: TButton;
    OpenDialogCode: TOpenDialog;
    procedure ButtonLoadFromFileCodeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonMakeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
   types = '(long int|float|long float|double|bool|short int|unsigned int|char|int|void)';
var
  Chapin: TChapin;
  RegExpro : TRegExpr;
  global_values, local_values : TValue;
  input_vars, modificated_vars, managing_vars, parasitic_vars: integer;

implementation

{$R *.dfm}

procedure deletePrivateLiterals( Var sourceCode:string);
begin
  regExpro.Expression:='"(/\*)|(\*/)"';
  sourceCode:=regExpro.Replace(sourceCode,'',true);
end;

procedure deleteComments( var sourceCode: string) ;
begin
  regExpro.ModifierM:= True;
  regExpro.Expression:='//.*?$';
  sourceCode:= regExpro.Replace(sourceCode,'',true);
  regExpro.ModifierS:= True;
  regExpro.Expression:='/\*.*?\*/';
  sourceCode:= regExpro.Replace(sourceCode,'',true);
  regExpro.ModifierS:= False;
end;

procedure deleteLiterals(var sourceCode: string) ;
begin
  regExpro.Expression:='''.?''';
  sourceCode:= regExpro.Replace(sourceCode,'''''',true);
  regExpro.Expression:='".*?"';
  sourceCode:= regExpro.Replace(sourceCode,'""',true);
end;

procedure MetricData(var values : TValue;var nArray : byte);
var
   i : integer;
begin
   for i := 0 to nArray - 1 do
   begin
      if values[i].is_used then
         inc(modificated_vars)
      else
         inc(parasitic_vars);
      if values[i].control_val then
         inc(managing_vars);
      if values[i].IO_val then
         inc(input_vars);
   end;
   nArray := 0;
   setlength(values, nArray);
end;

procedure SearchValue(values : TValue; nValues : integer; code : string; values_global : TValue; nGlobalValues : integer);
var
   i, j : integer;
   check : boolean;
begin
   for i := 0 to nValues - 1 do
   begin
      RegExpro.Expression :=  'switch *\(.*' + values[i].name + '|if *\(.*' + values[i].name;
      if RegExpro.Exec(code) then
         values[i].control_val := true;
      RegExpro.Expression := '(\W|\[)' + values[i].name + '(\W|\])';
      if RegExpro.Exec(code) then
         values[i].is_used := true;
      RegExpro.Expression := '(scanf *\(.*' + values[i].name + '.*\) *;|printf *\(.*' + values[i].name + '.*\) *;|cout *<< *' + values[i].name + ' *;|cin *>> *' + values[i].name + ' *;)';
      if RegExpro.Exec(code) then
         values[i].IO_val := true;
   end;
   for i := 0 to nGlobalValues - 1 do
   begin
      check := false;
      for j := 0 to nValues - 1 do
         if values[j].name = values_global[i].name then
            check := true;
      if not check then
      begin
      RegExpro.Expression :=  '(switch *\( *\( *|for *\( *\(| *|if *\(.*)' + values_global[i].name;
      if RegExpro.Exec(code) then
         values_global[i].control_val := true;
      RegExpro.Expression := '(\W|\[)' + values_global[i].name + '(\W|\])';
      if RegExpro.Exec(code) then
         values_global[i].is_used := true;
      RegExpro.Expression := '(scanf\(.*' + values_global[i].name + '.*\) *;|printf\(.*' + values_global[i].name + '.*\) *;|cout *<< *' + values_global[i].name + ' *;|cin *>> *' + values_global[i].name + ' *;)';
      if RegExpro.Exec(code) then
         values_global[i].IO_val := true;
      end;
   end;

end;



procedure TChapin.ButtonLoadFromFileCodeClick(Sender: TObject);
begin
  if OpenDialogCode.Execute then
      MemoCode.Lines.LoadFromFile(OpenDialogCode.FileName)
  else
      showmessage('Error');
end;

procedure search_new_values(var value_arr :TValue; var nArray : integer;code : string);
var
  i: integer;
  RegExpro_extra : TRegExpr;
begin
  RegExpro.Expression := types + ' +\W*([a-zA-Z_]+)\W';
  //RegExpro.Expression := types + ' .*\(' types +
  if RegExpro.Exec(code) then
  begin
    RegExpro.Expression := ' +\W*([a-zA-Z_]+)\W';
    if RegExpro.Exec(code) then
      repeat
        inc(nArray);
        SetLength(value_arr, nArray);
        value_arr[nArray - 1].name := Trim(RegExpro.Match[1]);
      until not RegExpro.ExecNext();
    end;
end;

procedure TChapin.FormCreate(Sender: TObject);
begin
  RegExpro := TRegExpr.create;
end;

procedure TChapin.ButtonMakeClick(Sender: TObject);
var
   counter : byte;
   i : integer;
   NUMBER_VALUES, NUMBER_VALUES_LOCAL, j : byte;
   module, code : string;
   metric_result : integer;
   check : boolean;
begin
   parasitic_vars := 0;
   managing_vars := 0;
   input_vars := 0;
   modificated_vars := 0;
   NUMBER_VALUES := 0;
   NUMBER_VALUES_LOCAL := 0;
   setLength(global_values, NUMBER_VALUES);
   setLength(local_values, NUMBER_VALUES_LOCAL);
   counter := 0;
   module := '';
   number_values := 0;
  code := MemoCode.Lines.text;

  deletePrivateLiterals(code);
  deleteComments(code);
  deleteLiterals(code);
  MemoCode.Lines.Text := code;

   i := 0;
   if length(MemoCode.Text) > 0 then
   begin
   repeat
      check := false;
      if length(MemoCode.Lines[i]) <> 0 then
      begin
      RegExpro.Expression := ' *' + types + ' +([a-zA-Z]+)\(.*\)';
      if RegExpro.Exec(MemoCode.Lines[i]) then
      begin
         module := Trim(RegExpro.Match[2]);
         inc(i);
      end;
      RegExpro.Expression := '{';
      if RegExpro.Exec(MemoCode.Lines[i]) then
      begin
         inc(counter);
      end;
      RegExpro.Expression := '}';
      if RegExpro.Exec(MemoCode.Lines[i]) then
      begin
         dec(counter);
         if counter = 0 then
         begin
            MetricData(local_values, NUMBER_VALUES_LOCAL);
            module := '';
         end;
      end;
         check := false;
         RegExpro.Expression := types + ' +\W*([a-zA-Z_]+)\W';
         if RegExpro.Exec(MemoCode.Lines[i]) then
         begin
            RegExpro.Expression := '(\W)* *([a-zA-Z]+)\W';
            repeat
               if module <> '' then
               begin
                  check := true;
                  inc(NUMBER_VALUES_LOCAL);
                  setLength(local_values, NUMBER_VALUES_LOCAL);
                  local_values[NUMBER_VALUES_LOCAL - 1].name := Trim(RegExpro.Match[2]);
                  local_values[NUMBER_VALUES_LOCAL - 1].is_used := false;
                  local_values[NUMBER_VALUES_LOCAL - 1].control_val := false;
                  local_values[NUMBER_VALUES_LOCAL - 1].IO_val := false;
                  showmessage(local_values[NUMBER_VALUES_LOCAL - 1].name);
               end
               else
               begin
                   check := true;
                  inc(NUMBER_VALUES);
                  setLength(global_values, NUMBER_VALUES);
                  global_values[NUMBER_VALUES - 1].name := Trim(RegExpro.Match[2]);
                  global_values[NUMBER_VALUES - 1].is_used := false;
                  global_values[NUMBER_VALUES - 1].control_val := false;
                  global_values[NUMBER_VALUES - 1].IO_val := false;
                  showmessage(global_values[NUMBER_VALUES - 1].name);


               end;
            until not RegExpro.ExecNext();
      end;
      end;
      if check then
               inc(i);

               SearchValue(local_values, NUMBER_VALUES_LOCAL, MemoCode.Lines[i], global_values, NUMBER_VALUES);


      if check then
         dec(i);
            inc(i);
   until (i = MemoCode.Lines.Count);
   MetricData(global_values, NUMBER_VALUES);
   metric_result:= input_vars + 2*modificated_vars + 3*managing_vars + Trunc((1/2)*parasitic_vars);
   mResult.Clear;
mResult.Lines.Add('Количество переменных ввода: '+ IntToStr(input_vars));
mResult.Lines.Add('Количество модифицируемых переменных: '+ IntToStr(modificated_vars));
mResult.Lines.Add('Количество управляющих переменных: '+ IntToStr(managing_vars));
mResult.Lines.Add('Количество паразитных переменных: '+ IntToStr(parasitic_vars));
mResult.Lines.Add('Значение метрики Чепина: '+ IntToStr(metric_result));
  // MemoResult.Lines.Add(global_values[NUMBER_VALUES - 1].name);

end;
end;

end.
