{*******************************************************}
{                                                       }
{       ADO 数据流化                                    }
{                                                       }
{       版权所有 (C) 2013      YangYxd                  }
{                                                       }
{*******************************************************}

unit YxdAdoStream;

interface

{$IF RTLVersion>=24}
{$LEGACYIFEND ON}
{$IFEND}

{$IF defined(FPC)}
  {$DEFINE USEINLINE}
{$IFEND}
{$IF RTLVersion>=18}
  {$DEFINE USEINLINE}
{$IFEND}


uses
  Windows, Classes, Sysutils, comobj, ActiveX,
  {$IFDEF USEINLINE}Ole2, {$ENDIF}
  adoint, adodb, db;

{$IFNDEF USEINLINE}
const
  IID_IPersistStream: TGUID = (
    D1:$00000109;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IStream: TGUID = (
    D1:$0000000C;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));


{$ENDIF}

function CheckADODataSet(const ADataSet: TDataSet): TCustomADODataSet;
/// <summary>
/// 从流中加载数据集对象
/// </summary>
procedure StreamToDataSet(AStream: TStream; ADataSet: TCustomADODataSet);
/// <summary>
/// 将数据集写入流中
/// </summary>
procedure DataSetToStream(ADataSet: TCustomADODataSet; AStream: TStream);

implementation

resourcestring
  SInvalidDataSet = '参数DataSet必须是AdoDataSet';

function CheckADODataSet(const ADataSet: TDataSet): TCustomADODataSet;
begin
  if not (ADataSet is TCustomADODataSet) then
    raise Exception.Create(SInvalidDataSet)
  else
    Result := TCustomADODataSet(ADataSet);
end;

procedure DataSetToStream(ADataSet:TCustomADODataSet; AStream:TStream);
var
  ATemp: TStreamAdapter;
  ADataSetStream: IPersistStream;
  AIntf: IStream;
  ARecs: OleVariant;
  ASet: _Recordset;
begin
  ASet := ADataSet.Recordset;
  while (ASet.State = adStateClosed) do begin //如果执行存储过程一类的脚本,可能存在多个结果集
    ASet := ADataSet.Recordset.NextRecordset(ARecs);
    if ASet = nil then
      raise Exception.Create('数据集无数据');
  end;
  OleCheck(ASet.QueryInterface(System.PGuid(@IID_IPersistStream)^, ADataSetStream));
  ATemp := TStreamAdapter.Create(AStream);
  try
    ATemp.GetInterface(System.PGuid(@IID_IStream)^, AIntf);
    OleCheck(OleSaveToStream(ADataSetStream, AIntf));
  finally
    ASet._Release;
    ATemp.FreeInstance;
    AIntf := nil;
  end;
end;

procedure StreamToDataSet(AStream:TStream; ADataSet: TCustomADODataSet);
var
  ATemp: Classes.TStreamAdapter;
  ARecordSet: ADOInt.Recordset;
  AIntf: IStream;
begin
  ATemp := Classes.TStreamAdapter.Create(AStream);
  try
    ADataSet.LockType := ltBatchOptimistic;
    ADataSet.Recordset := nil;
    try
      ATemp.GetInterface(System.PGuid(@IID_IStream)^, AIntf);
      ComObj.OleCheck({$IFDEF USEINLINE}Ole2.{$ENDIF}OleLoadFromStream(AIntf,
        {$IFDEF USEINLINE}Ole2.{$ENDIF}PGuid(@AdoInt.IID__Recordset)^, ARecordset));
      ADataSet.Recordset := ARecordSet;
    except
      OutputDebugString(PChar(Exception(ExceptObject).Message));
    end;
  finally
    ATemp.FreeInstance;
    AIntf := nil;
  end;
end;

end.
