;
; Belvedere Installer Script
;
;	Author:		Matthew Shorts <mshorts@gmail.com> 
;	Version: 	0.2
;	

;General Application defines
!define PRODUCT_NAME "Belvedere"
!define PRODUCT_VERSION "0.5"
!define PRODUCT_PUBLISHER "Lifehacker"
!define PRODUCT_WEB_SITE "http://lifehacker.com/341950/belvedere-automates-your-self+cleaning-pc"
!define PRODUCT_HELP_TEXT "Belvedere Help.chm"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

;Start Menu Item Defines
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"

;Finish Page Defines
!define MUI_FINISHPAGE_RUN "$INSTDIR\${PRODUCT_NAME}.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\${PRODUCT_HELP_TEXT}"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Show Help Text"

;Product information
VIAddVersionKey ProductName "${PRODUCT_NAME}"
VIAddVersionKey CompanyName "${PRODUCT_PUBLISHER}"
VIAddVersionKey FileDescription "${PRODUCT_NAME} Installer"
VIAddVersionKey FileVersion "0.1"
VIAddVersionKey LegalCopyright ""
VIAddVersionKey ProductVersion "${PRODUCT_VERSION}"
VIProductVersion 1.0.0.0

;Compression options
CRCCheck on
SetCompress force
SetCompressor lzma
SetDatablockOptimize on

BrandingText "${PRODUCT_NAME} ${PRODUCT_VERSION}"

;UI Define
!include "MUI.nsh"

;MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNABORTWARNING
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

;-- Pages --
;Welcome page
!insertmacro MUI_PAGE_WELCOME
;Directory page
!insertmacro MUI_PAGE_DIRECTORY
;Instfiles page
!insertmacro MUI_PAGE_INSTFILES
;Finish page
!insertmacro MUI_PAGE_FINISH
;Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES
;Language files
!insertmacro MUI_LANGUAGE "English"

;Installation Information
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "install-${PRODUCT_NAME}-${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "Installation" secApp
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File Belvedere.exe
  File "${PRODUCT_HELP_TEXT}"
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\Belvedere.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\Belvedere.exe"
  CreateShortCut "$SMPROGRAMS\Startup\${PRODUCT_NAME}.lnk" "$INSTDIR\Belvedere.exe"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninst.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Help.lnk" "$INSTDIR\${PRODUCT_HELP_TEXT}"
SectionEnd

;Post Installation Process
Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\Belvedere.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Belvedere.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

;Initialization of Install
Function .onInit
   StrCpy $0 "${PRODUCT_NAME}.exe"
   KillProc::FindProcesses
   StrCmp $1 "-1" uhoh
   StrCmp $0 "0" completed
   MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "You must end ${PRODUCT_NAME} before I proceed.  Would you like me to do that for you?" IDYES kill IDNO buhbye
 
kill:
   StrCpy $0 "${PRODUCT_NAME}.exe"
   KillProc::KillProcesses
   StrCmp $1 "-1" uhoh
   Goto completed
 
uhoh:
   MessageBox MB_ICONINFORMATION|MB_OK "Uh oh, system failure!  The tubes must be clogged!"
   Abort

buhbye:
  MessageBox MB_ICONINFORMATION|MB_OK "${PRODUCT_NAME} ${PRODUCT_VERSION} installation has been aborted."
  Abort  
   
completed:
   Return
FunctionEnd

;Initialization of Unistall
Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2 IDNO
  Abort
  
  StrCpy $0 "${PRODUCT_NAME}.exe"
  KillProc::KillProcesses
  StrCmp $1 "-1" uhoh
  Goto completed

uhoh:
   MessageBox MB_ICONINFORMATION|MB_OK "Uh oh, system failure!  The tubes must be clogged!"
   Abort
   
completed:
   Return
FunctionEnd

;Success of Uninstallation
Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

;Uninstall section
Section Uninstall
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\${PRODUCT_HELP_TEXT}"
  Delete "$INSTDIR\Belvedere.exe"
  Delete "$INSTDIR\rules.ini"
  Delete "$INSTDIR\resources\both.png"
  Delete "$INSTDIR\resources\belvederename.png"
  Delete "$INSTDIR\resources\belvedere.ico"
  Delete "$INSTDIR\resources\belvedere-paused.ico"

  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Help.lnk"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\Startup\${PRODUCT_NAME}.lnk"

  RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
  RMDir "$INSTDIR\resources\"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
