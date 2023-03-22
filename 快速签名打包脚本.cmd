@echo off
set baseDir=D:\MultiChannelPackaging
set inputfile=LionEye_V2.1.0_20230322095658689_release_all

set jksFileName=lionnews

set jksStorePassword=lionmobo
set jksKeyPassword=lionmobo
set jksKeyAlias=key0

set channelupgrade=appupgrade,testgroup


set inputDir=%baseDir%\input
set outputDir=%baseDir%\output
set jksDir=%baseDir%\jksFile
set JavaDir=%baseDir%\jre\bin\java.exe


echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo �˽ű���Ҫ������walle���������ʹ��
echo https://github.com/Petterpx/walle
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

echo ------------------------------------------ 
echo ��ǰbaseDir=%baseDir%
echo ��ǰJavaDir=%JavaDir%
echo ��ǰjksFileName=%jksFileName%
echo ��ǰinputDir=%inputDir%
echo ��ǰoutputDir=%outputDir%\result
echo ��ǰ����������channelupgrade=%channelupgrade%
echo ��ǰinputfileAPK=%inputfile%
echo ------------------------------------------ 
echo ��ȷ���Ѿ��޸���cmd�ļ��е� outputDir��channel
echo ��ȷ��inputDir�´���%inputfile%.apk
echo ------------------------------------------  
pause 


if exist %outputDir%\result rd/s/q %outputDir%\result 

if not exist %inputDir%\%inputfile%.apk echo inputDir�²�����%inputfile%.apk ���� 
pause
if not exist %inputDir%\%inputfile%.apk exit



if not exist %outputDir%\result md %outputDir%\result

%outputDir:~0,2%
cd %outputDir%

%baseDir%\zipalign.exe -v 4 %inputDir%\%inputfile%.apk %outputDir%\result\%inputfile%_no_sign.apk 

echo ------------------------------------------ 
echo ������Դ����� �����ļ�%inputfile%_no_sign.apk 
echo ------------------------------------------  
pause 

cd %outputDir%
%outputDir:~0,2%

%JavaDir% -jar %baseDir%\apksigner.jar sign  --ks %jksDir%\%jksFileName%.jks  --ks-key-alias %jksKeyAlias% --ks-pass pass:%jksStorePassword%  --key-pass pass:%jksKeyPassword%  --out %outputDir%\result\%inputfile%_sign.apk  %outputDir%\result\%inputfile%_no_sign.apk  


echo -----------------------------------
echo ǩ������� �����ļ�%inputfile%_sign.apk
echo -----------------------------------
pause

%JavaDir% -jar %baseDir%\CheckAndroidV2Signature.jar  %outputDir%\result\%inputfile%_sign.apk

echo ------------------------------------------------------
echo ���v2ǩ��Ч����� isV2OK: v2ǩ���Ƿ�ɹ� ��ɹ������ 
echo ------------------------------------------------------
pause


Set /p str=�Ƿ�������������Y ��   N ��


If not %str%==Y If not %str%==y exit

:2
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -f   %baseDir%\channel.txt  %outputDir%\result\%inputfile%_sign.apk   %outputDir%\result\channelresult
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -c   %channelupgrade%  %outputDir%\result\%inputfile%_sign.apk   %outputDir%\result\channelresult\channelUpgrade

echo -----------------------------------------------
echo ����%channel%���������  
echo �ļ�Ŀ¼channelresult
echo -----------
echo ����%channelupgrade%��������� 
echo �ļ�Ŀ¼channelresult\channelUpgrade
echo -----------------------------------------------
pause 

start %outputDir%\result