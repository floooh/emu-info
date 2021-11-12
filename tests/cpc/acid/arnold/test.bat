set PATH=%PATH%;%~dp0\..\..\exe\Debug\arnold_debug
arnold_debug /?
arnold_debug --help
arnold_debug /h
arnold_debug /unknown
arnold_debug --unknown
arnold_debug /cr 2
arnold_debug --crtctype 2
arnold_debug tester.dsk tester.cpr tester.sna tester.cdt
arnold_debug /cfg cpc6128en
arnold_debug --config cpc6128en
arnold_debug /ns
arnold_debug --nosplash
arnold_debug /na
arnold_debug --noaudio
arnold_debug /nj
arnold_debug --nojoystick
arnold_debug /t tester.cdt
arnold_debug --tape tester.cdt
arnold_debug /d tester.dsk
arnold_debug --disc tester.dsk
arnold_debug /a tester.dsk
arnold_debug --drivea tester.dsk
arnold_debug /b tester.dsk
arnold_debug --driveb tester.dsk

arnold_debug /da tester.dsk
arnold_debug --diska tester.dsk
arnold_debug /db tester.dsk
arnold_debug --diskb tester.dsk
arnold_debug /dc tester.dsk
arnold_debug --diskc tester.dsk
arnold_debug /dd tester.dsk
arnold_debug --diskd tester.dsk

arnold_debug /c tester.cpr
arnold_debug --cart tester.cpr

arnold_debug /s tester.sna
arnold_debug --snapshot tester.sna

arnold_debug /at "|TAPE:RUN"""
arnold_debug --autotype "|TAPE:RUN"""

arnold_debug /as tester.cdt
arnold_debug --autostart tester.cdt
arnold_debug /as tester.dsk
arnold_debug --autostart tester.dsk
arnold_debug /as tester.cpr
arnold_debug --autostart tester.cpr
arnold_debug /as tester.sna
arnold_debug --autostart tester.sna
