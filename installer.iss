#define MyAppName "Nhat Ky Cong Trinh"
#define MyAppVersion "1.0.2"
#define MyAppPublisher "My Company"
#define MyAppExeName "nhat_ky_xay_dung.exe"

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