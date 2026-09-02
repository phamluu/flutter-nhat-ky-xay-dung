#define MyAppName "Nhat Ky Cong Trinh"
#define MyAppVersion "1.0.2"
#define MyAppPublisher "My Company"
#define MyAppExeName "nhat_ky_xay_dung.exe"

#define AppOrgFolder "dhlc.art"
#define AppDataFolder "nhat_ky_xay_dung"

[Setup]
AppId={{YOUR-APP-GUID-HERE}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

OutputDir=installer
OutputBaseFilename=NhatKyCongTrinh

Compression=lzma
SolidCompression=yes

ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

PrivilegesRequired=admin

WizardStyle=modern

[Files]
Source: "build\windows\x64\runner\Release\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs


[Icons]
Name: "{autoprograms}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\{#MyAppExeName}"

Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\{#MyAppExeName}"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

Type: filesandordirs; Name: "{userappdata}\{#MyAppPublisher}\{#MyAppName}"
Type: filesandordirs; Name: "{userappdata}\{#MyAppName}"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
    DataDir: String;
begin
    if CurUninstallStep = usUninstall then
        begin
// Lấy đường dẫn động qua biến #define
            DataDir := ExpandConstant('{userappdata}\{#AppOrgFolder}\{#AppDataFolder}');
            if DirExists(DataDir) then
            begin
                if MsgBox('Bạn có muốn xóa toàn bộ dữ liệu ứng dụng (Database, Cấu hình) không?', mbConfirmation, MB_YESNO) = IDYES then
                begin
                    DelTree(DataDir, True, True, True);
                end;
            end;
        end;
end;
