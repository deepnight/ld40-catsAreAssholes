@echo off
cd ..
echo HL...
haxe hl.hxml

echo Flash...
haxe flash.hxml

echo JS...
haxe js.hxml

echo Copying...
copy bin\client.hl redist\CatsAreAssholes\hlboot.dat
copy bin\client.swf redist
copy bin\client.js redist
copy index.html redist

del redist\*.zip
pause