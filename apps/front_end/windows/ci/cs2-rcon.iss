[Setup]
AppName=Arkie
AppVersion={#AppVersion}
DefaultDirName={pf}\Arkie
DefaultGroupName=Arkie
OutputBaseFilename=arkie-{#AppVersion}-windows-setup
Compression=lzma
SolidCompression=yes

[Files]
; Copy everything from the Flutter build output folder
; Path is relative to this script (apps/front_end/windows/ci) back to apps/front_end/build/...
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Arkie"; Filename: "{app}\arkie.exe"
Name: "{commondesktop}\Arkie"; Filename: "{app}\arkie.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"
