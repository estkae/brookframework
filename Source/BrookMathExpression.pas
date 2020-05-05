(*  _                     _
 * | |__  _ __ ___   ___ | | __
 * | '_ \| '__/ _ \ / _ \| |/ /
 * | |_) | | | (_) | (_) |   <
 * |_.__/|_|  \___/ \___/|_|\_\
 *
 * Microframework which helps to develop web Pascal applications.
 *
 * Copyright (c) 2012-2020 Silvio Clecio <silvioprog@gmail.com>
 *
 * Brook framework is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * Brook framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with Brook framework; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *)

unit BrookMathExpression;

{$I BrookDefines.inc}

interface

uses
  Marshalling,
  libsagui,
  BrookHandledClasses;

type
  (* experimental *)
  TBrookExpressionExtension = class(TBrookHandledCollectionItem)
  end;

  (* experimental *)
  TBrookExpressionExtensionClass = class of TBrookExpressionExtension;

  (* experimental *)
  TBrookExpressionExtensions = class(TBrookHandledOwnedCollection)
  end;

  (* experimental *)
  TBrookExpression = class(TBrookHandledPersistent)
  private
    FExtensions: TBrookExpressionExtensions;
    FHandle: Psg_expr;
    procedure SetExtensions(AValue: TBrookExpressionExtensions);
  protected
    function GetHandle: Pointer; override;
    function CreateExtensions: TBrookExpressionExtensions; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class function GetExtensionClass: TBrookExpressionExtensionClass; virtual;
    procedure Compile(const AExpression: string); virtual;
    function Evaluate: Double; virtual;
    function GetVariable(const AName: string): Double; virtual;
    procedure SetVariable(const AName: string; const AValue: Double); virtual;
    property Variables[const AName: string]: Double read GetVariable
      write SetVariable; default;
    property Extensions: TBrookExpressionExtensions read FExtensions
      write SetExtensions;
  end;

  (* experimental *)
  TBrookMathExpression = class(TBrookHandledComponent)
  end;

implementation

{ TBrookExpression }

constructor TBrookExpression.Create;
begin
  inherited Create;
  SgLib.Check;
  FHandle := sg_expr_new;
end;

destructor TBrookExpression.Destroy;
begin
  SgLib.Check;
  sg_expr_free(FHandle);
  inherited Destroy;
end;

function TBrookExpression.CreateExtensions: TBrookExpressionExtensions;
begin
  Result := TBrookExpressionExtensions.Create(Self, GetExtensionClass);
end;

class function TBrookExpression.GetExtensionClass: TBrookExpressionExtensionClass;
begin
  Result := TBrookExpressionExtension;
end;

function TBrookExpression.GetHandle: Pointer;
begin
  Result := FHandle;
end;

procedure TBrookExpression.SetExtensions(AValue: TBrookExpressionExtensions);
begin
  FExtensions.Clear;
  if Assigned(AValue) then
    FExtensions.Assign(AValue);
end;

procedure TBrookExpression.Compile(const AExpression: string);
var
  M: TMarshaller;
begin
  SgLib.Check;
  SgLib.CheckLastError(sg_expr_compile(FHandle, M.ToCString(AExpression),
    Length(AExpression), nil));
end;

function TBrookExpression.GetVariable(const AName: string): Double;
var
  M: TMarshaller;
begin
  SgLib.Check;
  Result := sg_expr_var(FHandle, M.ToCString(AName), Length(AName));
end;

procedure TBrookExpression.SetVariable(const AName: string;
  const AValue: Double);
var
  M: TMarshaller;
begin
  SgLib.Check;
  SgLib.CheckLastError(sg_expr_set_var(FHandle, M.ToCString(AName),
    Length(AName), AValue));
end;

function TBrookExpression.Evaluate: Double;
begin
  SgLib.Check;
  Result := sg_expr_eval(FHandle);
end;

end.
