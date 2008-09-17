unit FailFixture;

interface

uses Fixture,
     Parse ;

type
  fitFailFixture = class(TFixture)
  public
    procedure doTable(tables: TParse); override;
  end;

  fitPassFixture = class( TFixture )
  public
    procedure doTable( tables : TParse ) ; override;
  end;

  fitErrorFixture = class( TFixture )
  public
    procedure doTable( tables : TParse ) ; override;
  end;

  fitIgnoreFixture = class( TFixture )
  public
    procedure doTable( tables : TParse ) ; override;
  end;

implementation

uses classes, sysUtils;

{ FailFixture }

procedure fitFailFixture.doTable(tables: TParse);
begin
  wrong( tables );
end;

{ fitPassFixture }

procedure fitPassFixture.doTable(tables: TParse);
begin
  right( tables );
end;

{ fitIgnoreFixture }

procedure fitIgnoreFixture.doTable(tables: TParse);
begin
  ignore( tables );
end;

{ fitErrorFixture }

procedure fitErrorFixture.doTable(tables: TParse);
begin
  doException( tables, Exception.Create( 'Exception created' ) );
end;

initialization

  classes.RegisterClass( fitFailFixture );
  classes.registerClass( fitPassFixture );
  classes.registerClasses( [ fitIgnoreFixture, fitErrorFixture ] );

end.
