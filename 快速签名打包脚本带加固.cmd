@echo off
set baseDir=D:\MultiChannelPackaging
::需要加固的安装包文件名（需放在baseApkInput文件夹内）
set inputfile=**********

::腾讯加固sid
::sid和skey来自腾讯云账号，注册腾讯云账号后需要单独申请。
::申请地址：https://console.cloud.tencent.com/cam/capi

set legu_sid=*********************

::腾讯加固skey
set legu_skey=***************

::jks签名文件名
set jksFileName=*******

::jks签名信息
set jksStorePassword=********
set jksKeyPassword=*******
set jksKeyAlias=*******

::升级渠道和测试渠道
set channelupgrade=appupgrade,testgroup


set inputDir=%baseDir%\input
set outputDir=%baseDir%\output
set jksDir=%baseDir%\jksFile
set inputfileLegu=%inputfile%_legu
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
echo 请确保baseApkInput下存在%inputfile%.apk
echo ------------------------------------------  
pause 

echo 开始进行加固...
::进行腾讯加固
%JavaDir% -jar %baseDir%\ms-shield.jar -sid %legu_sid% -skey %legu_skey% -uploadType file -uploadPath %baseDir%/baseApkInput/%inputfile%.apk -downloadType file -downloadPath %baseDir%/input


::准备开始重签名，检测输入文件
if exist %outputDir%\result rd/s/q %outputDir%\result 

if not exist %inputDir%\%inputfileLegu%.apk echo inputDir下不存在%inputfileLegu%.apk 请检查 
pause
if not exist %inputDir%\%inputfileLegu%.apk exit



if not exist %outputDir%\result md %outputDir%\result

%outputDir:~0,2%
cd %outputDir%

::对齐资源
%baseDir%\zipalign.exe -v 4 %inputDir%\%inputfileLegu%.apk %outputDir%\result\%inputfileLegu%_no_sign.apk 

echo ------------------------------------------ 
echo 对齐资源已完成 生成文件%inputfileLegu%_no_sign.apk 
echo ------------------------------------------  
pause 

cd %outputDir%
%outputDir:~0,2%

::签名
%JavaDir% -jar %baseDir%\apksigner.jar sign  --ks %jksDir%\%jksFileName%.jks  --ks-key-alias %jksKeyAlias% --ks-pass pass:%jksStorePassword%  --key-pass pass:%jksKeyPassword%  --out %outputDir%\result\%inputfileLegu%_sign.apk  %outputDir%\result\%inputfileLegu%_no_sign.apk  


echo -----------------------------------
echo 签名已完成 生成文件%inputfileLegu%_sign.apk
echo -----------------------------------
pause

::签名校验
%JavaDir% -jar %baseDir%\CheckAndroidV2Signature.jar  %outputDir%\result\%inputfileLegu%_sign.apk

echo ------------------------------------------------------
echo 检查v2签名效果完成 isV2OK: v2签名是否成功 如成功请继续 
echo ------------------------------------------------------
pause


Set /p str=是否生成渠道包？Y 是   N 否


If not %str%==Y If not %str%==y exit

::生成渠道包(推广渠道包在channel.txt填写)
:2
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -f   %baseDir%\channel.txt  %outputDir%\result\%inputfileLegu%_sign.apk   %outputDir%\result\channelresult
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -c   %channelupgrade%  %outputDir%\result\%inputfileLegu%_sign.apk   %outputDir%\result\channelresult\channelUpgrade

echo -----------------------------------------------
echo 生成%channel%渠道包完成  
echo 文件目录channelresult
echo -----------
echo 生成%channelupgrade%渠道包完成 
echo 文件目录channelresult\channelUpgrade
echo -----------------------------------------------
pause 

start %outputDir%\result