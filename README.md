Belvedere
=========

An automated file manager for Windows
-------------------------------------

* Platform: Windows (XP and later)
* Language(s): AutoHotkey, NSIS (for the installer)
* License: GPL v3 

See [LICENSE.txt](https://github.com/imaginationac/belvedere/blob/master/LICENSE.txt) for licensing details.

#How to build the installer.

1. Clone the repo: `git clone git://github.com/imaginationac/belvedere.git`
2. Download and install [NSIS](http://prdownloads.sourceforge.net/nsis/nsis-2.46-setup.exe?download)
3. Download [KIllProc plug-in for NSIS](http://code.google.com/p/mulder/downloads/detail?name=NSIS-KillProc-Plugin.2011-04-09.zip&can=4&q=) 
4. Download and install [Microsoft HTML Help Workshop 1.3](http://www.microsoft.com/download/en/details.aspx?displaylang=en&id=21138).
5. Download and install [AutoHotkey_L](http://www.autohotkey.com/download/).
6. Compile Belvedere.ahk (in the root of the repo) and move the .exe into the /installer directory.
7. Compile /help/Belvedere Help.hhp with HTML Help Workshop and move the .chm to the /installer directory.
8. Compile /installer/install.nsi
9. Make sure to test the installer.

#How to run.

1. Download the installer -or-
2. Install AutoHotkey and run Belvedere.ahk.
