unit main;

interface
{$I 'qdac.inc'}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, YxdStr,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls,yxdjson, YxdRtti, qstring, qjson;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    mmResult: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button9: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    mmResult2: TMemo;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
  private
    { Private declarations }
    procedure DoCopyIf(ASender,AItem:TQJson;var Accept:Boolean;ATag:Pointer);
    procedure DoDeleteIf(ASender,AChild:TQJson;var Accept:Boolean;ATag:Pointer);
    procedure DoFindIf(ASender,AChild:TQJson;var Accept:Boolean;ATag:Pointer);
    procedure DoCopyIfY(ASender: JSONBase; AItem:PJSONValue;var Accept:Boolean;ATag:Pointer);
    procedure DoDeleteIfY(ASender: JSONBase; AChild:PJSONValue;var Accept:Boolean;ATag:Pointer);
    procedure DoFindIfY(ASender: JSONBase; AChild:PJSONValue;var Accept:Boolean;ATag:Pointer);
  public
    { Public declarations }
    function Add(X,Y:Integer):Integer;
  end;
type
  TRttiTestSubRecord=record
    Int64Val: Int64;
    UInt64Val: UInt64;
    UStr: String;
    AStr:AnsiString;
    SStr:ShortString;
    IntVal: Integer;
    MethodVal: TNotifyEvent;
    SetVal: TBorderIcons;
    WordVal: Word;
    ByteVal: Byte;
    ObjVal: TObject;
    DtValue: TDateTime;
    tmValue: TTime;
    dValue:TDate;
    CardinalVal: Cardinal;
    ShortVal: Smallint;
    CurrVal: Currency;
    EnumVal: TAlign;
    CharVal: Char;
    VarVal:Variant;
    ArrayVal: TBytes;
    {$IFDEF UNICODE}
    IntArray:TArray<Integer>;
    {$ENDIF}
  end;
  TRttiUnionRecord=record
    case Integer of
       0:(iVal:Integer);
//       1:(bVal:Boolean);
    end;

  TRttiTestRecord=record
    Name:QStringW;
    Id:Integer;
    SubRecord:TRttiTestSubRecord;
    UnionRecord:TRttiUnionRecord;
  end;
  //Test for user
  TTitleRecord = packed record
    Title: TFileName;
    Date: TDateTime;
  end;

  TTitleRecords = packed record
    Len: Integer;
    TitleRecord: array[0..100] of TTitleRecord;
  end;
  TFixedRecordArray=array[0..1] of TRttiUnionRecord;
  TRttiObjectRecord=record
    Obj:TStringList;
  end;
  TDeviceType = (dtSM3000,dtSM6000,dtSM6100,dtSM7000,dtSM8000);
  //上位机所有命令
  TRCU_Cmd = record
    ID:string;   //命令ID 为了缩减命令，设备名称+.+INDEX
    DevcType:TDeviceType;//设备类型，比如 SM-6000
    Rcu_Kind:Integer;//配件类型
    Name:string; //命令名称，比如继电器
    KEY_IDX:Integer;//按键命令，如果是双个组合键，值大于255
    SHOW_IDX:Integer;//显示顺序
    {$IFDEF UNICODE}
    Cmds:TArray<TArray<Byte>>;// 命令字节,有可能是多个模式
    {$ENDIF}
    //返回值处理
    ResultValue:string;//返回值处理的公式，json表达式
    RCU_Type_ID:string;// 所属主机ID
    RCU_Type_Name:string; //主机类型名称，比如 是 SM-6000
//    procedure Clear;
  end;
  //场景信息，是一串组合的命令
  TSence = record
    Name:string;//场景名称
    {$IFDEF UNICODE}
    Cmds:TArray<string>;//TArray<TPlc_Cmd>;
    {$ENDIF}
  end;
  //每个客房信息
  TRoom = record
    Hotel_ID:string; //酒店ID
    Hotel_Code:string; //酒店编码
    Room_ID:string;  //客房ID
    ROOM_Name:string; //真实的客房名称
    //客房编号，X区X栋X层X房 = X.X.X.X
    Room_Code:string;//客房号 为了便于客户端调用，Room_Code做条件
    RCU_TYPE_ID:string;//基于哪种设备
    RCU_Type_Name:string;     //RCU名称
    RCU_HOST:string;
    RCU_Port:string;
    {$IFDEF UNICODE}
    Cmds:TArray<TRCU_Cmd>;//原始的命令信息
    {$ENDIF}
    //客房里的设备信息以及设备名称
//    Cmd_Name_Ids:TNameValueRow;  // ID和名称对应 ，，保留命令原来的排序
    //酒店客房里的场景信息，一个场景对应多条命令
    {$IFDEF UNICODE}
    Sences:TArray<TSence>;
    {$ENDIF}
//    procedure Clear;
  end;
var
  Form1: TForm1;

implementation
uses typinfo{$IFDEF UNICODE},rtti{$ENDIF};
{$R *.dfm}

function GetFileSize(AFileName:String):Int64;
var
  sr:TSearchRec;
  AHandle:Integer;
begin
AHandle:=FindFirst(AFileName,faAnyFile,sr);
if AHandle=0 then
  begin
  Result:=sr.Size;
  FindClose(sr);
  end
else
  Result:=0;
end;
function TForm1.Add(X, Y: Integer): Integer;
begin
Result:=X+Y;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  AJson,AItem:TQJson;
  YJson: JSONObject;
  YItem: PJSONValue;
  S:String;
begin
s := '';
AJson:=TQJson.Create;
try
  AJson.Add('Item1',0);
  AJson.Add('Item2',true);
  AJson.Add('Item3',1.23);
  for AItem in AJson do
    begin
    S:=S+AItem.Name+' => '+AItem.AsString+#13#10;
    end;
  mmResult.Lines.Add(S);
finally
  AJson.Free;
end;
s := '';
YJson:=JSONObject.Create;
try
  YJson.put('Item1',0);
  YJson.put('Item2',true);
  YJson.put('Item3',1.23);
  for YItem in YJson do
    begin
    S:=S+YItem.FName+' => '+YItem.AsString+#13#10;
    end;
  mmResult2.Lines.Add(S);
finally
  YJson.Free;
end;
end;

procedure TForm1.Button11Click(Sender: TObject);
var
  AJson:TQJson;
  YJson:JSONObject;
begin
YJson:=JSONObject.Create;
try
  //强制路径访问，如果路径不存在，则会创建路径，路径分隔符可以是./\之一
  YJson.ForcePath('demo1.item[0].name').AsString:='102';
  YJson.ForcePath('demo1.item[0].name').AsString:='103';
  YJson.ForcePath('demo1.item[1].name').AsString:='100';
  try
    ShowMessage('YxdJSON 下面正常会抛出一个异常');
    YJson.ForcePath('demo1[0].item[1]').AsString:='200';
  except
    //这个应该抛出异常，demo1是对象不是数组，所以是错的
  end;
  //访问第6个元素，前5个元素会自动设置为null
  YJson.ForcePath('demo2[5]').AsInteger:=103;
  //强制创建一个空数组对象，然后调用Add方法添加子成员
  YJson.ForcePath('demo3[]').AsJsonArray.add(1.23);
  //下面的代码将生成"demo4":[{"Name":"demo4"}]的结果
  YJson.ForcePath('demo4[].Name').AsString:='demo4';
  //直接强制路径存在
  YJson.ForcePath('demo5[0]').AsString:='demo5';
  mmResult2.Text:=YJson.ToString(4);
  mmResult2.Lines.add(YJson.ForcePath('demo1.item[1]').GetPath());
finally
  YJson.Free;
end;
AJson:=TQJson.Create;
try
  //强制路径访问，如果路径不存在，则会创建路径，路径分隔符可以是./\之一
  AJson.ForcePath('demo1.item[0].name').AsString:='1';
  AJson.ForcePath('demo1.item[1].name').AsString:='100';
  try
    ShowMessage('QJson 下面正常会抛出一个异常');
    AJson.ForcePath('demo1[0].item[1]').AsString:='200';
  except
    //这个应该抛出异常，demo1是对象不是数组，所以是错的
  end;
  //访问第6个元素，前5个元素会自动设置为null
  AJson.ForcePath('demo2[5]').AsInteger:=103;
  //强制创建一个空数组对象，然后调用Add方法添加子成员
  AJson.ForcePath('demo3[]').Add('Value',1.23);
  //下面的代码将生成"demo4":[{"Name":"demo4"}]的结果
  AJson.ForcePath('demo4[].Name').AsString:='demo4';
  //直接强制路径存在
  AJson.ForcePath('demo5[0]').AsString:='demo5';
  mmResult.Text:=AJson.AsJson;
finally
  AJson.Free;
end;
end;

procedure TForm1.Button12Click(Sender: TObject);
var
  AJson:TQJson;
  YJson:JSONObject;
  AList:TQJsonItemList;
  YList:JSONList;
begin
AJson:=TQJson.Create;
try
  AJson.Parse(
    '{'+
    '"object":{'+
    ' "name":"object_1",'+
    ' "subobj":{'+
    '   "name":"subobj_1"'+
    '   },'+
    ' "subarray":[1,3,4]'+
    ' },'+
    '"array":[100,200,300,{"name":"object"}]'+
    '}');
  AList:=TQJsonItemList.Create;
  AJson.ItemByRegex('sub.+',AList,true);
  mmResult.Lines.Add('ItemByRegex找到'+IntToStr(AList.Count)+'个结点');
  AList.Free;
  mmResult.Lines.Add('ItemByPath(''object\subobj\name'')='+AJson.ItemByPath('object\subobj\name').AsString);
  mmResult.Lines.Add('ItemByPath(''object\subarray[1]'')='+AJson.ItemByPath('object\subarray[1]').AsString);
  mmResult.Lines.Add('ItemByPath(''array[1]'')='+AJson.ItemByPath('array[1]').AsString);
  mmResult.Lines.Add('ItemByPath(''array[3].name'')='+AJson.ItemByPath('array[3].name').AsString);
finally
  AJson.Free;
end;
yJson:=JSONObject.Create;
try
  yJson.Parse(
    '{'+
    '"object":{'+
    ' "name":"object_1",'+
    ' "subobj":{'+
    '   "name":"subobj_1"'+
    '   },'+
    ' "subarray":[1,3,4]'+
    ' },'+
    '"array":[100,200,300,{"name":"object"}]'+
    '}');
  YList := JSONList.Create;
  yJson.ItemByRegex('sub.+',YList,true);
  mmResult2.Lines.Add('ItemByRegex找到'+IntToStr(YList.Count)+'个结点');
  YList.Free;
  mmResult2.Lines.Add('ItemByPath(''object\subobj\name'')='+yJson.ItemByPath('object\subobj\name', '\').AsString);
  mmResult2.Lines.Add('ItemByPath(''object\subarray[1]'')='+yJson.ItemByPath('object\subarray[1]', '\').AsString);
  mmResult2.Lines.Add('ItemByPath(''array[1]'')='+yJson.ItemByPath('array[1]').AsString);
  mmResult2.Lines.Add('ItemByPath(''array[3].name'')='+yJson.ItemByPath('array[3].name').AsString);
finally
  yJson.Free;
end;
end;

procedure TForm1.Button13Click(Sender: TObject);
{$IFNDEF UNICODE}
begin
  ShowMessage('不支持的功能');
{$ELSE}
var
  AJson:TQJson;
  AValue:TValue;
  YJSON: JSONObject;
begin
AJson:=TQJson.Create;
try
  with AJson.Add('Add') do
    begin
    Add('X').AsInteger:=100;
    Add('Y').AsInteger:=200;
    end;
  AValue:=AJson.ItemByName('Add').Invoke(Self);
  mmResult.Lines.Add(AJson.AsJson);
  mmResult.Lines.Add('.Invoke='+IntToStr(AValue.AsInteger));
finally
  AJson.Free;
end;
YJSON:=JSONObject.Create;
try
  with YJSON.AddChildObject('Add') do
    begin
    Add('X').AsInteger:=100;
    Add('Y').AsInteger:=200;
    end;
  AValue:=YJSON.getItem('Add').AsJsonObject.Invoke(Self);
  mmResult2.Lines.Add(YJSON.ToString(4));
  mmResult2.Lines.Add('.Invoke='+IntToStr(AValue.AsInteger));
finally
  YJSON.Free;
end;
{$ENDIF}
end;

procedure TForm1.Button14Click(Sender: TObject);
var
  yjson: JSONObject;
begin
  yjson := JSONObject.Create;
  try
    yjson.PutObject('test', Self);
    yjson.GetJsonObject('test').GetItem('Caption').AsString := 'YxdJson RTTI Test';
    yjson.GetJsonObject('test').ToObject(Self);
    mmResult2.Text := yjson.ToString(4);
  finally
    yjson.Free;
  end;
end;

procedure TForm1.Button15Click(Sender: TObject);
var
  AJson:TQJson;
  YJson:JSONObject;
  S:String;
begin
AJson:=TQJson.Create;
try
  AJson.Add('Text').AsString:='Hello,中国';
  ShowMessage(AJson.Encode(True,True));
  AJson.Parse(AJson.Encode(True,True));
  ShowMessage(AJson.AsJson);
finally
  AJson.Free;
end;
YJson:=JSONObject.Create;
try
  YJson.put('Text', 'Hello,中国');
  ShowMessage(YJson.tostring(4, True));
  YJson.Parse(YJson.tostring(4, True));
  ShowMessage(YJson.ToString(4));
finally
  YJson.Free;
end;
end;

procedure TForm1.Button16Click(Sender: TObject);
var
  AJson:TQJson;
  Yjson: JSONObject;
  procedure DoTry(S:QStringW);
  begin
  if AJson.TryParse(S) then
    ShowMessage(AJson.AsString)
  else
    ShowMessage('QJson 解析失败'#13#10+S);
  end;
  procedure DoTry2(S:JSONString);
  begin
  if Yjson.TryParse(S) then
    ShowMessage(Yjson.ToString)
  else
    ShowMessage('YJson 解析失败'#13#10+S);
  end;
begin
AJson:=TQJson.Create;
try
  DoTry('{aaa}');
  DoTry('{"aaa":100}');
finally
  AJson.Free;
end;
Yjson:=JSONObject.Create;
try
  DoTry2('{aaa}');
  DoTry2('{"aaa":100}');
finally
  Yjson.Free;
end;
end;

procedure TForm1.Button17Click(Sender: TObject);
var
  YJson:JSONObject;
begin
YJson:=JSONObject.Create;
try
  //强制路径访问，如果路径不存在，则会创建路径，路径分隔符可以是./\之一
  YJson.ForcePath('demo1.item[0].name').AsString:='1';
  YJson.ForcePath('demo1.item[0].name').AsString:='122';
  YJson.ForcePath('demo1.item[1].name').AsString:='100';
  //下面的代码将生成"demo4":[{"Name":"demo4"}]的结果
  YJson.ForcePath('demo4[].Name').AsString:='demo4';
  mmResult2.Text:=YJson.ToString(4);
finally
  YJson.Free;
end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  AJson:TQJson;
  YJson:JSONObject;
  I:Integer;
  T:Cardinal;
begin
AJson:=TQJson.Create;
try
  T:=GetTickCount;
  for I := 0 to 1000000 do
    AJson.Add('_'+IntToStr(I),Now);
  T:=GetTickCount-T;
  mmResult.Clear;
  mmResult.Lines.Add('qjson 添加1000,000个结点用时:'+IntToStr(T)+'ms');
finally
  AJson.Free;
end;
yJson:=JSONObject.Create;
try
  T:=GetTickCount;
  for I := 0 to 1000000 do
    yJson.put('_'+IntToStr(I),Now);
  T:=GetTickCount-T;
  mmResult2.Clear;
  mmResult2.Lines.Add('yjson 添加1000,000个结点用时:'+IntToStr(T)+'ms');
finally
  yJson.Free;
end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  AJson:TQJson;
  YJSON:JSONObject;
  TestRecord:TRttiTestRecord;
begin
AJson:=TQJson.Create;
YJson:=JSONObject.Create;
try
  TestRecord.Id:=10001;
  TestRecord.Name:='Complex Record';
  TestRecord.UnionRecord.iVal:=100;
  TestRecord.SubRecord.Int64Val:=1;
  TestRecord.SubRecord.UInt64Val:=2;
  TestRecord.SubRecord.UStr:='Test String';
  TestRecord.SubRecord.IntVal:=3;
  TestRecord.SubRecord.MethodVal:=Button2Click;
  TestRecord.SubRecord.SetVal:=[{$IFDEF UNICODE}TBorderIcon.{$ENDIF}biSystemMenu];
  TestRecord.SubRecord.WordVal:=4;
  TestRecord.SubRecord.ByteVal:=5;
  TestRecord.SubRecord.ObjVal:=Button2;
  TestRecord.SubRecord.DtValue:=Now;
  TestRecord.SubRecord.tmValue:=Time;
  TestRecord.SubRecord.dValue:=Now;
  TestRecord.SubRecord.CardinalVal:=6;
  TestRecord.SubRecord.ShortVal:=7;
  TestRecord.SubRecord.CurrVal:=8.9;
  TestRecord.SubRecord.EnumVal:={$IFDEF UNICODE}TAlign.{$ENDIF}alTop;
  TestRecord.SubRecord.CharVal:='A';
  TestRecord.SubRecord.VarVal:=VarArrayOf(['VariantArray',1,2.5,true,false]);
  SetLength(TestRecord.SubRecord.ArrayVal,3);
  TestRecord.SubRecord.ArrayVal[0]:=100;
  TestRecord.SubRecord.ArrayVal[1]:=101;
  TestRecord.SubRecord.ArrayVal[2]:=102;
  AJson.Add('IP','192.168.1.1');
  with AJson.Add('FixedTypes') do
    begin
    AddDateTime('DateTime',Now);
    Add('Integer',1000);
    Add('Boolean',True);
    Add('Float',1.23);
    Add('Array',[1,'goods',true,3.4]);
    {$IFDEF UNICODE}
    Add('RTTIObject').FromRtti(Button2);
    Add('RTTIRecord').FromRecord(TestRecord);
    {$ENDIF}
    end;
  with AJson.Add('AutoTypes') do
    begin
    Add('Integer','-100');
    Add('Float','-12.3');
    Add('Array','[2,''goods'',true,4.5]');
    Add('Object','{"Name":"Object_Name","Value":"Object_Value"}');
    Add('ForceArrayAsString','[2,''goods'',true,4.5]',jdtString);
    Add('ForceObjectAsString','{"Name":"Object_Name","Value":"Object_Value"}',jdtString);
    end;
  with AJson.Add('AsTypes') do
    begin
    Add('Integer').AsInteger:=123;
    Add('Float').AsFloat:=5.6;
    Add('Boolean').AsBoolean:=False;
    Add('VarArray').AsVariant:=VarArrayOf([9,10,11,2]);
    Add('Array').AsArray:='[10,3,22,99]';
    Add('Object').AsObject:='{"Name":"Object_2","Value":"Value_2"}';
    end;
  mmResult.Clear;
  mmResult.Lines.Add('QJSON 添加测试结果:');
  mmResult.Lines.Add(AJson.Encode(True));
  YJson.put('IP','192.168.1.1');
  with YJson.addChildObject('FixedTypes') do
    begin
    putDateTime('DateTime',Now);
    put('Integer',1000);
    put('Boolean',True);
    put('Float',1.23);
    addChildArray('Array',[1,'goods',true,3.4]);
    {$IFDEF UNICODE}
    putObject('RTTIObject', Button2);
    putRecord('RTTIRecord', TestRecord);
    {$ENDIF}
    end;
  with YJson.addChildObject('AutoTypes') do
    begin
    put('Integer','-100');
    putJSON('Float','-12.3');
    putJSON('Array','[2,''goods'',true,4.5]');
    putJSON('Object','{"Name":"Object_Name","Value":"Object_Value"}');
    put('ForceArrayAsString','[2,''goods'',true,4.5]');
    put('ForceObjectAsString','{"Name":"Object_Name","Value":"Object_Value"}');
    end;
  with YJson.addChildObject('AsTypes') do
    begin
    put('Integer', 123);
    put('Float', 5.6);
    put('Boolean', False);
    put('VarArray', VarArrayOf([9,10,11,2]));
    putJSON('Array', '[10,3,22,99]');
    putJSON('Object', '{"Name":"Object_2","Value":"Value_2"}');
    end;
  mmResult2.Clear;
  mmResult2.Lines.Add('YxdJSON 添加测试结果:');
  mmResult2.Lines.Add(YJson.ToString(4));
finally
  AJson.Free;
  YJson.Free;
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  AJson:TQJson;
  YJson:JSONObject;
  T:Cardinal;
  i: Integer;
  Speed:Cardinal;
  procedure PreCache;
  var
    AStream:TMemoryStream;
  begin
  AStream:=TMemoryStream.Create;
  try
    AStream.LoadFromFile(OpenDialog1.FileName);
  finally
    AStream.Free;
  end;
  end;
begin
if OpenDialog1.Execute then
  begin
//  uJsonTest;
  try
  YJson:=JSONObject.Create;
  try
    T:=GetTickCount;
    for i := 0 to 2 do
      YJson.LoadFromFile(OpenDialog1.FileName);
    T:=GetTickCount-T;
    if T>0 then
      Speed:=(GetFileSize(OpenDialog1.FileName)*1000 div T)
    else
      Speed:=0;
    mmResult2.Clear;
    mmResult2.Lines.Add('加载的JSON文件内容：');
    mmResult2.Lines.Add(YJson.ToString(4));
    mmResult2.Lines.Add('YxdJson加载用时:'+IntToStr(T)+'ms，速度:'+RollupSize(Speed));
    //mmResult2.Lines.Add(YJson.ToString(4));
  finally
    YJson.Free;
  end;
  except end;
  end;

  try
  AJson:=TQJson.Create;
  try
    T:=GetTickCount;
    for i := 0 to 2 do
    AJson.LoadFromFile(OpenDialog1.FileName);
    T:=GetTickCount-T;
    if T>0 then
      Speed:=(GetFileSize(OpenDialog1.FileName)*1000 div T)
    else
      Speed:=0;
    mmResult.Clear;
    mmResult.Lines.Add('加载的JSON文件内容：');
    mmResult.Lines.Add(AJson.Encode(True));
    mmResult.Lines.Add('QJson加载用时:'+IntToStr(T)+'ms，速度:'+RollupSize(Speed));
  finally
    AJson.Free;
  end;
  except end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  AJson:TQJson;
  YJson:JSONObject;
  II:Integer;
  T1,T2:Cardinal;
  Speed:Cardinal;
begin
if SaveDialog1.Execute then
  begin
  AJson:=TQJson.Create;
  try
    mmResult.Clear;
    T1:=GetTickCount;
    with AJson.Add('Integers',jdtObject) do
      begin
      for II := 0 to 2000000 do
        Add('Node'+IntToStr(II)).AsInteger :=II;
      end;
    T1:=GetTickCount-T1;
    T2:=GetTickCount;
    AJson.SaveToFile(SaveDialog1.FileName,teAnsi,false);
    T2:=GetTickCount-T2;
    if T2>0 then
      Speed:=(GetFileSize(SaveDialog1.FileName)*1000 div T2)
    else
      Speed:=0;
    mmResult.Lines.Add('QJSON 生成200万结点用时'+IntToStr(T1)+'ms,保存用时:'+IntToStr(T2)+'ms，速度：'+RollupSize(Speed));
  finally
    AJson.Free;
  end;
  YJson:=JSONObject.Create;
  try
    mmResult2.Clear;
    T1:=GetTickCount;
    with YJson.AddChildObject('Integers') do
      begin
      for II := 0 to 2000000 do
        add('Node'+IntToStr(II)).AsInteger := II;
      end;
    T1:=GetTickCount-T1;
    T2:=GetTickCount;
    YJson.SaveToFile(SaveDialog1.FileName, 4, YxdStr{$IFDEF UNICODE}.TTextEncoding{$ENDIF}.teAnsi,false);
    T2:=GetTickCount-T2;
    if T2>0 then
      Speed:=(GetFileSize(SaveDialog1.FileName)*1000 div T2)
    else
      Speed:=0;
    mmResult2.Lines.Add('YxdJSON 生成200万结点用时'+IntToStr(T1)+'ms,保存用时:'+IntToStr(T2)+'ms，速度：'+RollupSize(Speed));
  finally
    YJson.Free;
  end;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  AJson:TQJson;
  yjson: JSONObject;
begin
AJson:=TQJson.Create;
try
  AJson.Parse('{"results":[],"status":102,"msg":"IP\/SN\/SCODE\/REFERER Illegal:"}');
  mmResult.Text := (AJson.Encode(True));
finally
  AJson.Free;
end;
yjson:=JSONObject.Create;
try
  yjson.Parse('{"results":[],"status":102,"msg":"IP\/SN\/SCODE\/REFERER Illegal:"}');
  mmResult2.Text := (yjson.ToString(4));
finally
  yjson.Free;
end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  ARec, BRec: TRttiTestSubRecord;
  AJson,ACopy:TQJson;
  YJson,YCopy:JSONObject;
  t: Cardinal;
  I: Integer;
begin
{$IFNDEF UNICODE}
  ShowMessage('本功能在当前IDE中不受支持.');
{$ELSE}
  ARec.Int64Val:=1;
  ARec.UInt64Val:=2;
  ARec.UStr:='Test String';
  ARec.AStr:='AnsiString';
  ARec.SStr:='ShortString';
  ARec.IntVal:=3;
  ARec.MethodVal:=Button2Click;
  ARec.SetVal:=[{$IFDEF UNICODE}TBorderIcon.{$ENDIF}biSystemMenu];
  ARec.WordVal:=4;
  ARec.ByteVal:=5;
  ARec.ObjVal:=Button2;
  ARec.DtValue:=Now;
  ARec.tmValue:=Time;
  ARec.dValue:=Now;
  ARec.CardinalVal:=6;
  ARec.ShortVal:=7;
  ARec.CurrVal:=8.9;
  ARec.EnumVal:={$IFDEF UNICODE}TAlign.{$ENDIF}alTop;
  ARec.CharVal:='A';
  ARec.VarVal:=VarArrayOf(['VariantArray',1,2.5,true,false]);
  SetLength(ARec.ArrayVal,3);
  ARec.ArrayVal[0]:=100;
  ARec.ArrayVal[1]:=101;
  ARec.ArrayVal[2]:=102;
  SetLength(ARec.IntArray,2);
  ARec.IntArray[0]:=300;
  ARec.IntArray[1]:=200;
  BRec := ARec;
  t := GetTickCount;
  for i := 0 to 1000 do begin
  AJson:=TQJson.Create;
  try
    {$IFDEF UNICODE}
    AJson.Add('Record').FromRecord(ARec);
    ACopy:=AJson.ItemByName('Record').Copy;
    ACopy.ItemByName('Int64Val').AsInt64:=100;
    ACopy.ItemByPath('UStr').AsString:='UnicodeString-ByJson';
    ACopy.ItemByPath('AStr').AsString:='AnsiString-ByJson';
    ACopy.ItemByPath('SStr').AsString:='ShortString-ByJson';
    ACopy.ItemByPath('EnumVal').AsString:='alBottom';
    ACopy.ItemByPath('SetVal').AsString:='[biHelp]';
    ACopy.ItemByPath('ArrayVal').AsJson:='[10,30,15]';
    ACopy.ItemByPath('VarVal').AsVariant:=VarArrayOf(['By Json',3,4,false,true]);
    ACopy.ToRecord<TRttiTestSubRecord>(ARec);
    ACopy.Free;
    AJson.Add('NewRecord').FromRecord(ARec);
    {$ENDIF}

    mmResult.text := (AJson.AsJson);
  finally
    AJson.Free;
  end;
  end;
  t := GetTickCount - t;
  mmResult.Lines.add(Format('QJson %dms.', [t]));
  ARec := BRec;
  t := GetTickCount;
  for i := 0 to 1000 do begin
  YJson:=JSONObject.Create;
  try
    {$IFDEF UNICODE}
    YJson.PutRecord('Record', ARec);
    YCopy:=YJson.getItem('Record').AsJsonObject.Clone;
    YCopy.getItem('Int64Val').AsInt64:=100;
    YCopy.ItemByPath('UStr').AsString:='UnicodeString-ByJson';
    YCopy.ItemByPath('AStr').AsString:='AnsiString-ByJson';
    YCopy.ItemByPath('SStr').AsString:='ShortString-ByJson';
    YCopy.ItemByPath('EnumVal').AsString:='alBottom';
    YCopy.ItemByPath('SetVal').AsString:='[biHelp]';
    YCopy.ItemByPath('ArrayVal').AsJsonArray.Parse('[10,30,15]');
    YCopy.ItemByPath('VarVal').AsVariant:=VarArrayOf(['By Json',3,4,false,true]);
    YCopy.ToRecord<TRttiTestSubRecord>(ARec);
    YCopy.Free;
    YJson.PutRecord('NewRecord', ARec);
    {$ENDIF}

    mmResult2.text := (YJson.ToString(4));
  finally
    YJson.Free;
  end;
  end;
  t := GetTickCount - t;
  mmResult2.Lines.add(Format('YxdJson %dms.', [t]));
  {$ENDIF}
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  AStream:TMemoryStream;
  AJson:TQJson;
  S:QStringW;
  AEncode:TTextEncoding;
begin
AStream:=TMemoryStream.Create;
AJson:=TQJson.Create;
try
  AJson.DataType:=jdtObject;
  S:='{"record1":{"id":100,"name":"name1"}}'#13#10+
    '{"record2":{"id":200,"name":"name2"}}'#13#10+
    '{"record3":{"id":300,"name":"name3"}}'#13#10;
  //UCS2
  mmResult.Lines.Add('Unicode 16 LE编码:');
  AEncode:=teUnicode16LE;
  AStream.Size:=0;
  SaveTextW(AStream,S,False);
  AStream.Position:=0;
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add('第一次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第二次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第三次解析结果:');
  mmResult.Lines.Add(AJson.AsJson);
  //UTF-8
  mmResult.Lines.Add('UTF8编码:');
  AEncode:=teUtf8;
  AStream.Size:=0;
  SaveTextU(AStream,qstring.Utf8Encode(S),False);
  AStream.Position:=0;
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第一次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第二次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第三次解析结果:');
  mmResult.Lines.Add(AJson.AsJson);
  //ANSI
  mmResult.Lines.Add(#13#10'ANSI编码:');
  AEncode:=teAnsi;
  AStream.Size:=0;
  SaveTextA(AStream,qstring.AnsiEncode(S));
  AStream.Position:=0;
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add('第一次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第二次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第三次解析结果:');
  mmResult.Lines.Add(AJson.AsJson);
  //UCS2BE
  mmResult.Lines.Add(#13#10'Unicode16BE编码:');
  AEncode:=teUnicode16BE;
  AStream.Size:=0;
  SaveTextWBE(AStream,S,False);
  AStream.Position:=0;
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add('第一次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第二次解析结果:'#13#10);
  mmResult.Lines.Add(AJson.AsJson);
  AJson.Clear;
  AJson.ParseBlock(AStream,AEncode);
  mmResult.Lines.Add(#13#10'第三次解析结果:');
  mmResult.Lines.Add(AJson.AsJson);
finally
  AStream.Free;
  AJson.Free;
end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  AJson,AItem:TQJson;
  YJson, A, B: JSONObject;
  YItem: JSONArray;
  YItemValue: PJSONValue;
  II:Integer;
  DynArray:array of Integer;
  RecordArray:array of TRttiUnionRecord;
begin
AJson:=TQJson.Create;
try
  //添加数组元素的N种方式演示
  // 1. 直接调用Add数组元素文本的方式
  AJson.Add('AddArrayText','["Item1",100,null,true,false,123.4]',jdtArray);//jdtArray如果省略会自动测试，如果明确知道，就不要让其判断增加开销
  // 2. 直接添加数组
  AJson.Add('AddArray',['Item1',100,Null,True,False,123.4]);
  // 3. 直接用VarArrayOf赋值
  AJson.Add('AsVariant').AsVariant:=VarArrayOf(['Item1',100,Null,True,False,123.4]);
  //对于动态数组，由于
  SetLength(DynArray,5);
  DynArray[0]:=100;
  DynArray[1]:=200;
  DynArray[2]:=300;
  DynArray[3]:=400;
  DynArray[4]:=500;
  AJson.Add('DynArray').AsVariant:=DynArray;
  {$IFDEF UNICODE}
  SetLength(RecordArray,2);
  RecordArray[0].iVal:=1;
  RecordArray[1].iVal:=2;
  with AJson.Add('RecordArray',jdtArray) do
    begin
    for II := 0 to High(RecordArray) do
      Add.FromRecord(RecordArray[II]);
    end;
  {$ENDIF}
//  AJson.Add('RecordArray').AsVariant:=RecordArray;
// 4. 直接用AsArray来赋给数组文件
  AJson.Add('AsArray').AsArray:='["Item1",100,null,true,false,123.4]';
  // 5. 手动逐个添加元素
  with AJson.Add('Manul') do
    begin
    DataType:=jdtArray;
    Add.AsString:='Item1';
    Add.AsInteger:=100;
    Add;
    Add.AsBoolean:=True;
    Add.AsBoolean:=False;
    Add.AsFloat:=123.4;
    end;
  // 添加对象数组和上面类型，只是子结点换成是对象就可以了
  AJson.Add('Object',[TQJson.Create.Add('Item1',100).Parent,TQJson.Create.Add('Item2',true).Parent]);
  mmResult.Lines.Add(AJson.AsJson);
  //访问数组中的元素
  mmResult.Lines.Add('使用for in枚举数组Manul的元素值');
  II:=0;
  for AItem in AJson.ItemByName('Manul') do
     begin
     mmResult.Lines.Add('Manul['+IntToStr(II)+']='+AItem.AsString);
     Inc(II);
     end;
  mmResult.Lines.Add('使用普通for循环枚举数组Manul的元素值');
  AItem:=AJson.ItemByName('Manul');
  for II := 0 to AItem.Count-1 do
     mmResult.Lines.Add('Manul['+IntToStr(II)+']='+AItem[II].AsString);
finally
  FreeObject(AJson);
end;
YJson:=JSONObject.Create;
try
  //添加数组元素的N种方式演示
  // 1. 直接调用Add数组元素文本的方式
  YJson.putJSON('AddArrayText','["Item1",100,null,true,false,123.4]');//jdtArray如果省略会自动测试，如果明确知道，就不要让其判断增加开销
  // 2. 直接添加数组
  YJson.put('AddArray',['Item1',100,Null,True,False,123.4]);
  // 3. 直接用VarArrayOf赋值
  YJson.put('AsVariant', VarArrayOf(['Item1',100,Null,True,False,123.4]));
  //对于动态数组，由于
  SetLength(DynArray,5);
  DynArray[0]:=100;
  DynArray[1]:=200;
  DynArray[2]:=300;
  DynArray[3]:=400;
  DynArray[4]:=500;
  YJson.put('DynArray', DynArray);
  {$IFDEF UNICODE}
  SetLength(RecordArray,2);
  RecordArray[0].iVal:=1;
  RecordArray[1].iVal:=2;
  with YJson.AddChildArray('RecordArray') do
    begin
    for II := 0 to High(RecordArray) do
      putRecord(RecordArray[II]);
    end;
  {$ENDIF}
//  AJson.Add('RecordArray').AsVariant:=RecordArray;
// 4. 直接用AsArray来赋给数组文件
  YJson.putJSON('AsArray', '["Item1",100,null,true,false,123.4]');
  // 5. 手动逐个添加元素
  with YJson.AddChildArray('Manul') do
    begin
    Add('Item1');
    Add(100);
    Add(NULL);
    Add(True);
    Add(False);
    Add(123.4);
    end;
  // 添加对象数组和上面类型，只是子结点换成是对象就可以了
  a := JSONObject.Create;
  a.Put('Item1', 100);
  b := JSONObject.Create;
  b.Put('Item2', True);
  YJson.AddChildArray('Object',[a, b]);
  mmResult2.Lines.Add(YJson.ToString(4));
  //访问数组中的元素
  mmResult2.Lines.Add('使用for in枚举数组Manul的元素值');
  II:=0;
  for YItemValue in YJson.GetJsonArray('Manul') do
     begin
     mmResult2.Lines.Add('Manul['+IntToStr(II)+']='+YItemValue.AsString);
     Inc(II);
     end;
  mmResult2.Lines.Add('使用普通for循环枚举数组Manul的元素值');
  YItem:=YJson.GetJsonArray('Manul');
  for II := 0 to YItem.Count-1 do
     mmResult2.Lines.Add('Manul['+IntToStr(II)+']='+YItem[II].AsString);
finally
  FreeObject(YJson);
end;
end;

procedure TForm1.Button9Click(Sender: TObject);
const
  TMPSTR = '{'+
    '"object":{'+
    ' "name":"object_1",'+
    ' "subobj":{'+
    '   "name":"subobj_1"'+
    '   },'+
    ' "subarray":[1,3,4]'+
    ' },'+
    '"array":[100,200,300,{"name":"object"}]'+
    '}';
var
  AJson,AItem:TQJson;
  YJSON:JSONObject;
  YItem:JSONObject;
begin
AJson:=TQJson.Create;
try
  AJson.Parse(TMPSTR);
  {$IFDEF UNICODE}
  AItem:=AJson.CopyIf(nil,procedure(ASender,AChild:TQJson;var Accept:Boolean;ATag:Pointer)
    begin
    Accept:=(AChild.DataType<>jdtArray);
    end);
  {$ELSE}
  AItem:=AJson.CopyIf(nil,DoCopyIf);
  {$ENDIF}
  mmResult.Lines.Add('CopyIf来复制除了数组类型外的所有结点');
  mmResult.Lines.Add(AItem.AsJson);
  mmResult.Lines.Add('FindIf来查找指定的结点');
  {$IFDEF UNICODE}
  mmResult.Lines.Add(AItem.FindIf(nil,true,procedure(ASender,AChild:TQJson;var Accept:Boolean;ATag:Pointer)
    begin
    Accept:=(AChild.Name='subobj');
    end).AsJson);
  {$ELSE}
  mmResult.Lines.Add(AItem.FindIf(nil,true,DoFindIf).AsJson);
  {$ENDIF}
  mmResult.Lines.Add('删除上面结果中的subobj结点');
  {$IFDEF UNICODE}
  AItem.DeleteIf(nil,true,procedure(ASender,AChild:TQJson;var Accept:Boolean;ATag:Pointer)
    begin
    Accept:=(AChild.Name='subobj');
    end);
  {$ELSE}
  AItem.DeleteIf(nil,true,DoDeleteIf);
  {$ENDIF}
  mmResult.Lines.Add(AItem.AsJson);
finally
  FreeObject(AItem);
  FreeObject(AJson);
end;

YJson:=JSONObject.Create;
try
  YJson.Parse(TMPSTR);
  {$IFDEF UNICODE}
  YItem:=YJson.CopyIf(nil,procedure(ASender: JSONBase; AChild: PJSONValue;var Accept:Boolean;ATag:Pointer)
    begin
    Accept:=not Assigned(AChild.AsJsonArray);
    end) as JSONObject;
  {$ELSE}
  YItem:=YJson.CopyIf(nil,DoCopyIfY) as JSONObject;
  {$ENDIF}
  mmResult2.Lines.Add('CopyIf来复制除了数组类型外的所有结点');
  mmResult2.Lines.Add(YItem.ToString(4));
  mmResult2.Lines.Add('FindIf来查找指定的结点');
  {$IFDEF UNICODE}
  mmResult2.Lines.Add(YItem.FindIf(nil,true,procedure(ASender: JSONBase; AChild: PJSONValue;var Accept:Boolean;ATag:Pointer)
    begin
    Accept:=(AChild.FName='subobj');
    end).ToString(4));
  {$ELSE}
  mmResult2.Lines.Add(YItem.FindIf(nil,true,DoFindIfY).ToString(4));
  {$ENDIF}
  mmResult2.Lines.Add('删除上面结果中的subobj结点');
  {$IFDEF UNICODE}
  YItem.DeleteIf(nil,true,procedure(ASender: JSONBase; AChild: PJSONValue;var Accept:Boolean;ATag:Pointer)
    begin
    Accept:=(AChild.FName='subobj');
    end);
  {$ELSE}
  YItem.DeleteIf(nil,true,DoDeleteIfY);
  {$ENDIF}
  mmResult2.Lines.Add(YItem.ToString(4));
finally
  FreeObject(YItem);
  FreeObject(YJson);
end;

end;

procedure TForm1.DoCopyIf(ASender, AItem: TQJson; var Accept: Boolean;
  ATag: Pointer);
begin
Accept:=(AItem.DataType<>jdtArray);
end;
procedure TForm1.DoCopyIfY(ASender: JSONBase; AItem: PJSONValue;
  var Accept: Boolean; ATag: Pointer);
begin
Accept:=not Assigned(AItem.AsJsonArray);
end;

procedure TForm1.DoDeleteIf(ASender,AChild:TQJson;var Accept:Boolean;ATag:Pointer);
begin
Accept:=(AChild.Name='subobj');
end;

procedure TForm1.DoDeleteIfY(ASender: JSONBase; AChild: PJSONValue;
  var Accept: Boolean; ATag: Pointer);
begin
Accept:=(AChild.FName='subobj');
end;

procedure TForm1.DoFindIf(ASender, AChild: TQJson; var Accept: Boolean;
  ATag: Pointer);
begin
Accept:=(AChild.Name='subobj');
end;

procedure TForm1.DoFindIfY(ASender: JSONBase; AChild: PJSONValue;
  var Accept: Boolean; ATag: Pointer);
begin
Accept:=(AChild.FName='subobj');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
ReportMemoryLeaksOnShutdown:=True;
OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
end;

procedure TForm1.Panel1Click(Sender: TObject);
var
  S:QStringA;
begin
S:='Hello,world';
ShowMessage(S);
end;

end.
