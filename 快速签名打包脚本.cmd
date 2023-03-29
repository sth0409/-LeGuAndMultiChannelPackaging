@echo off
set baseDir=D:\MultiChannelPackaging
set inputfile=*********

set jksFileName=*********

set jksStorePassword=*********
set jksKeyPassword=*********
set jksKeyAlias=*********

set channelupgrade=appupgrade,testgroup


set inputDir=%baseDir%\input
set outputDir=%baseDir%\output
set jksDir=%baseDir%\jksFile
set JavaDir=%baseDir%\jre\bin\java.exe


echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 此脚本需要与美团walle打包框架配合使用
echo https://github.com/Petterpx/walle
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

echo ------------------------------------------ 
echo 当前baseDir=%baseDir%
echo 当前JavaDir=%JavaDir%
echo 当前jksFileName=%jksFileName%
echo 当前inputDir=%inputDir%
echo 当前outputDir=%outputDir%\result
echo 当前升级渠道包channelupgrade=%channelupgrade%
echo 当前inputfileAPK=%inputfile%
echo ------------------------------------------ 
echo 请确保已经修改了cmd文件中的 outputDir，channel
echo 请确保inputDir下存在%inputfile%.apk
echo ------------------------------------------  
pause 


if exist %outputDir%\result rd/s/q %outputDir%\result 

if not exist %inputDir%\%inputfile%.apk echo inputDir下不存在%inputfile%.apk 请检查 
pause
if not exist %inputDir%\%inputfile%.apk exit



if not exist %outputDir%\result md %outputDir%\result

%outputDir:~0,2%
cd %outputDir%

%baseDir%\zipalign.exe -v 4 %inputDir%\%inputfile%.apk %outputDir%\result\%inputfile%_no_sign.apk 

echo ------------------------------------------ 
echo 对齐资源已完成 生成文件%inputfile%_no_sign.apk 
echo ------------------------------------------  
pause 

cd %outputDir%
%outputDir:~0,2%

%JavaDir% -jar %baseDir%\apksigner.jar sign  --ks %jksDir%\%jksFileName%.jks  --ks-key-alias %jksKeyAlias% --ks-pass pass:%jksStorePassword%  --key-pass pass:%jksKeyPassword%  --out %outputDir%\result\%inputfile%_sign.apk  %outputDir%\result\%inputfile%_no_sign.apk  


echo -----------------------------------
echo 签名已完成 生成文件%inputfile%_sign.apk
echo -----------------------------------
pause

%JavaDir% -jar %baseDir%\CheckAndroidV2Signature.jar  %outputDir%\result\%inputfile%_sign.apk

echo ------------------------------------------------------
echo 检查v2签名效果完成 isV2OK: v2签名是否成功 如成功请继续 
echo ------------------------------------------------------
pause


Set /p str=是否生成渠道包？Y 是   N 否


If not %str%==Y If not %str%==y exit

:2
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -f   %baseDir%\channel.txt  %outputDir%\result\%inputfile%_sign.apk   %outputDir%\result\channelresult
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -c   %channelupgrade%  %outputDir%\result\%inputfile%_sign.apk   %outputDir%\result\channelresult\channelUpgrade

echo -----------------------------------------------
echo 生成%channel%渠道包完成  
echo 文件目录channelresult
echo -----------
echo 生成%channelupgrade%渠道包完成 
echo 文件目录channelresult\channelUpgrade
echo -----------------------------------------------
pause 

start %outputDir%\result
