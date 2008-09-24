// Author David Glassborow
{$H+}
unit DetailedRTTI;

  // Some functions for playing with rich RTTI in objects
  // Free to use in anyway, at your own risk.

interface

uses
  TypInfo,
  ObjAuto;

const
  SHORT_LEN = sizeof(ShortString) - 1;

type

{  TParamInfoHelper = record helper for TParamInfo
  public
   function AsString: string;
   function NextParam: PParamInfo;
  end;

  TReturnInfoHelper = record helper for TReturnInfo
  public
   function AsString: string;
  end;

  TMethodInfoHeaderHelper = record helper for TMethodInfoHeader
  private
    function GetReturnInfo: PReturnInfo;
  public
    property ReturnInfo: PReturnInfo read GetReturnInfo;
  end;}

{  TObjectHelper = class helper for TObject
  private
  public
    function RTTIMethodsAsString: string;
    function GetMethodReturnInfo(MethodName: string): PReturnInfo;
  end;
}
  TDummy = class(TObject)
  end;
  
  function DescriptionOfMethod( Obj: TObject; MethodName: string ): string;
  function GetMethodReturnInfo(Obj: TObject; MethodName: string): PReturnInfo;

  //Lazar
  function NextParam( Obj:PParamInfo ):PParamInfo;
  function ParamInfoAsString( Obj:PParamInfo ):string;
  function GetReturnInfo(Obj:PMethodInfoHeader):PReturnInfo;
  function ReturnInfoAsString(Obj:PReturnInfo):string;

implementation

uses
  SysUtils;

function DescriptionOfMethod( Obj: TObject; MethodName: string ): string;
var
  header: PMethodInfoHeader;
  headerEnd: Pointer;
  Params, Param: PParamInfo;
  returnInfo: PReturnInfo;
begin
  header := ObjAuto.GetMethodInfo( Obj, MethodName );
  // Check the length is greater than just that of the name
  if Header.Len <= SizeOf(TMethodInfoHeader) - SHORT_LEN + Length(Header.Name) then
  begin
    Result := 'No rich RTTI';
    exit;
  end;

  headerEnd := Pointer(Integer(header) + header^.Len);
  // Get a pointer to the param info
  Params := PParamInfo(Integer(header) + SizeOf(header^) - SHORT_LEN + SizeOf(TReturnInfo) + Length(header^.Name));
  // Loop over the parameters
  Param := Params;
  Result := '';
  while Integer(Param) < Integer(headerEnd) do
  begin
    Result := Result + ParamInfoAsString(Param) + '; ';
    // Find next param
    Param := NextParam(Param);
  end;
  Delete( Result, Length(Result)-1,2 );

  // Now the return
  returnInfo := GetReturnInfo( header );
  if assigned( returnInfo.ReturnType ) then
    Result := Format( 'function %s( %s ): %s', [ MethodName, Result, ReturnInfoAsString(returnInfo) ] )
  else
    Result := Format( 'procedure %s( %s )%s', [ MethodName, Result, ReturnInfoAsString(returnInfo) ] );
end;

{ TParamInfoHelper }

function ParamInfoAsString(Obj:PParamInfo): string;
begin
  Result := '';
  if pfResult in Obj.Flags then exit;         // Seems to be extra info about the return function, not sure what it means
  Result := Obj.Name + ': ' + Obj.ParamType^.Name;
  if pfVar in Obj.Flags then             // Should really handle the other flags here
    Result := 'var ' + Result;
end;

function NextParam(Obj:PParamInfo): PParamInfo;
begin
  Result := PParamInfo(Integer(Obj) + SizeOf(Obj) - SHORT_LEN + Length(Obj.Name));
end;

{ TMethodInfoHeaderHelper }

function GetReturnInfo(Obj:PMethodInfoHeader): PReturnInfo;
begin
  Result := PReturnInfo(Integer(Obj) + SizeOf(TMethodInfoHeader) - SHORT_LEN + Length(Obj.Name));
end;

{ TReturnInfoHelper }

function ReturnInfoAsString(Obj:PReturnInfo):string;
var
  c: string;
begin
  Assert( Obj.Version = 1, 'Version of ReturnInfo incorrect' );
  if assigned( Obj.ReturnType ) then
    Result := Obj.ReturnType^.Name;
  Result := Result + ';';
  case Obj.CallingConvention of
    ccRegister: ;// Default
    ccCdecl: c := 'cdecl';
    ccPascal: c := 'pascal';
    ccStdCall: c := 'stdcall';
    ccSafeCall: c := 'safecall';
  end;
  if c <> '' then Result := Result + ' ' + c + ';';
end;

{ TObjectHelper }

{
function TObjectHelper.RTTIMethodsAsString: string;
var
  MethodInfo: Pointer;
  Count: Integer;
  method: PMethodInfoHeader;
  i: Integer;
begin
    MethodInfo := PPointer(Integer(PPointer(self)^) + vmtMethodTable)^;
    if MethodInfo <> nil then
    begin
      // Scan method and get string about each
      Count := PWord(MethodInfo)^;
      Inc(Integer(MethodInfo), 2);
      method := MethodInfo;
      for i := 0 to Count - 1 do
      begin
        Result := Result + DescriptionOfMethod(self, method.Name) + sLineBreak;
        Inc(Integer(method), PMethodInfoHeader(method)^.Len); // Get next method
      end;
    end;
end;
}

function GetMethodReturnInfo(Obj: TObject; MethodName: string): PReturnInfo;
var
  header: PMethodInfoHeader;
begin
//  Result := nil;
  header := ObjAuto.GetMethodInfo( Obj, MethodName );
  if header = nil then
    raise Exception.CreateFmt('There is no method %s in fixture %s', [MethodName, Obj.ClassName]);  
  // Check the length is greater than just that of the name
  if Header.Len <= SizeOf(TMethodInfoHeader) - SHORT_LEN + Length(Header.Name) then
  begin
    raise Exception.Create('No rich RTTI');
    exit;
  end;
  Result := GetReturnInfo(header);
end;

end.

