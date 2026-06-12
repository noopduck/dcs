This is for fixing DCS (Digital Combat Simulator) tested on Fedora 44

This setup is made using the following setup

1. Steam
2. Downloaded and installed DCS downloaded from the DCS web site.
3. Added the DCS installer in steam
4. Ran the installer successfully, no issues
5. Added the DCS.exe from the bin-mt directory inside steam, run the find command below to locate your DCS.exe location

   #shell@fedora:~/projects/dcs-fix-fedora44$ find /home/$USER/ -iname DCS.exe
   #/home/shell/.local/share/Steam/steamapps/compatdata/2954704094/pfx/drive_c/Program Files/Eagle Dynamics/DCS World/bin-mt/DCS.exe

6. Run the script dcs.sh

7. Set steam compatibilty mode to GE-proton 10-34
8. Add this in the Launch options
   WINEDLLOVERRIDES='wbemprox=n' %command% --no-launcher

9. Run DCS and enjoy.

