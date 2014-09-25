unit RouteManage;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  StdCtrls, ComCtrls;

type
  TfrmRouteManage = class(TForm)
    GroupBox1: TGroupBox;
    ListViewRoute: TListView;
    ButtonEdit: TButton;
    ButtonDelete: TButton;
    ButtonOK: TButton;
    ButtonAddRoute: TButton;
    procedure ButtonDeleteClick(Sender: TObject);
  private
    procedure RefShowRoute();
    procedure ProcessListViewDelete();
    procedure ProcessListViewSelect();
    procedure ProcessAddRoute();
    procedure ProcessEditRoute();

    
  public
    procedure Open;
    
  end;

var
  frmRouteManage: TfrmRouteManage;

implementation

uses LSShare, RouteEdit;

{$R *.dfm}



procedure TfrmRouteManage.Open;
begin
  RefShowRoute();

  ShowModal;
end;

procedure TfrmRouteManage.RefShowRoute;
var
  i, ii: Integer;
  ListItem: TListItem;
  RouteInfo: pTRouteInfo;
  sGameGate: string;
begin
  ListViewRoute.Clear;
  ButtonEdit.Enabled := False;
  ButtonDelete.Enabled := False;
  for i := Low(g_Config.GateRoute) to High(g_Config.GateRoute) do begin
    RouteInfo := @g_Config.GateRoute[i];
    if RouteInfo.nGateCount = 0 then
      break;
    sGameGate := '';
    ListItem := ListViewRoute.Items.Add;
    ListItem.Data := RouteInfo;
    ListItem.Caption := IntToStr(i);
    ListItem.SubItems.Add(RouteInfo.sSelGateIP);
    ListItem.SubItems.Add(IntToStr(RouteInfo.nGateCount));
    for ii := 0 to RouteInfo.nGateCount - 1 do begin
      sGameGate := format('%s %s:%d ', [sGameGate, RouteInfo.sGameGateIP[ii],
        RouteInfo.nGameGatePort[ii]]);
    end;
    ListItem.SubItems.Add(sGameGate);
  end;

end;

procedure TfrmRouteManage.ButtonDeleteClick(Sender: TObject);
begin
  if Sender = ButtonDelete then begin
    ProcessListViewDelete();
  end
  else if Sender = ListViewRoute then begin
    ProcessListViewSelect();
  end
  else if Sender = ButtonAddRoute then begin
    ProcessAddRoute();
  end
  else if Sender = ButtonOK then begin
    
    SaveGateConfig(@g_Config);
    Close();
  end
  else if Sender = ButtonEdit then begin
    ProcessEditRoute();
  end;

end;

procedure TfrmRouteManage.ProcessListViewSelect;
var
  ListItem: TListItem;
begin
  ListItem := ListViewRoute.Selected;
  if ListItem = nil then
    Exit;
  ButtonEdit.Enabled := True;
  ButtonDelete.Enabled := True;
end;

procedure TfrmRouteManage.ProcessListViewDelete;
var
  ii: Integer;
  ListItem: TListItem;
  RouteInfo: pTRouteInfo;
begin
  ListItem := ListViewRoute.Selected;
  if ListItem = nil then
    Exit;
  RouteInfo := ListItem.Data;
  RouteInfo.nGateCount := 0;
  RouteInfo.sSelGateIP := '';

  for ii := Low(RouteInfo.sGameGateIP) to High(RouteInfo.sGameGateIP) do begin
    RouteInfo.sGameGateIP[ii] := '';
    RouteInfo.nGameGatePort[ii] := 0;
  end;
  RefShowRoute();

end;

procedure TfrmRouteManage.ProcessAddRoute;
var
  
  RouteInfo: pTRouteInfo;
  nNulIdx: Integer;
  AddRoute: TRouteInfo;
begin
  nNulIdx := ListViewRoute.Items.Count;
  if nNulIdx >= 20 then begin
    MessageBox(Handle, 'The number of routes has reached the specified number, can not increase the route!!!',
      'Message', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  RouteInfo := @g_Config.GateRoute[nNulIdx];
  frmRouteEdit.m_RouteInfo := RouteInfo^;
  frmRouteEdit.Caption := 'Increae Gateway Routing';
  AddRoute := frmRouteEdit.Open;
  if AddRoute.nGateCount >= 1 then begin
    RouteInfo^ := AddRoute;
  end;
  RefShowRoute();
end;

procedure TfrmRouteManage.ProcessEditRoute;
var
  ListItem: TListItem;
  RouteInfo: pTRouteInfo;
  EditRoute: TRouteInfo;
begin
  ListItem := ListViewRoute.Selected;
  if ListItem = nil then
    Exit;
  RouteInfo := ListItem.Data;
  frmRouteEdit.m_RouteInfo := RouteInfo^;
  frmRouteEdit.Caption := 'Modify Gateway Routing';
  EditRoute := frmRouteEdit.Open;
  if EditRoute.nGateCount >= 1 then begin
    RouteInfo^ := EditRoute;
  end;
  RefShowRoute();

end;

end.
