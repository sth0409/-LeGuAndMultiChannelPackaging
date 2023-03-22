@echo off
set baseDir=D:\MultiChannelPackaging
::��Ҫ�ӹ̵İ�װ���ļ����������baseApkInput�ļ����ڣ�
set inputfile=**********

::��Ѷ�ӹ�sid
::sid��skey������Ѷ���˺ţ�ע����Ѷ���˺ź���Ҫ�������롣
::�����ַ��https://console.cloud.tencent.com/cam/capi

set legu_sid=*********************

::��Ѷ�ӹ�skey
set legu_skey=***************

::jksǩ���ļ���
set jksFileName=*******

::jksǩ����Ϣ
set jksStorePassword=********
set jksKeyPassword=*******
set jksKeyAlias=*******

::���������Ͳ�������
set channelupgrade=appupgrade,testgroup


set inputDir=%baseDir%\input
set outputDir=%baseDir%\output
set jksDir=%baseDir%\jksFile
set inputfileLegu=%inputfile%_legu
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
echo ��ȷ��baseApkInput�´���%inputfile%.apk
echo ------------------------------------------  
pause 

echo ��ʼ���мӹ�...
::������Ѷ�ӹ�
%JavaDir% -jar %baseDir%\ms-shield.jar -sid %legu_sid% -skey %legu_skey% -uploadType file -uploadPath %baseDir%/baseApkInput/%inputfile%.apk -downloadType file -downloadPath %baseDir%/input


::׼����ʼ��ǩ������������ļ�
if exist %outputDir%\result rd/s/q %outputDir%\result 

if not exist %inputDir%\%inputfileLegu%.apk echo inputDir�²�����%inputfileLegu%.apk ���� 
pause
if not exist %inputDir%\%inputfileLegu%.apk exit



if not exist %outputDir%\result md %outputDir%\result

%outputDir:~0,2%
cd %outputDir%

::������Դ
%baseDir%\zipalign.exe -v 4 %inputDir%\%inputfileLegu%.apk %outputDir%\result\%inputfileLegu%_no_sign.apk 

echo ------------------------------------------ 
echo ������Դ����� �����ļ�%inputfileLegu%_no_sign.apk 
echo ------------------------------------------  
pause 

cd %outputDir%
%outputDir:~0,2%

::ǩ��
%JavaDir% -jar %baseDir%\apksigner.jar sign  --ks %jksDir%\%jksFileName%.jks  --ks-key-alias %jksKeyAlias% --ks-pass pass:%jksStorePassword%  --key-pass pass:%jksKeyPassword%  --out %outputDir%\result\%inputfileLegu%_sign.apk  %outputDir%\result\%inputfileLegu%_no_sign.apk  


echo -----------------------------------
echo ǩ������� �����ļ�%inputfileLegu%_sign.apk
echo -----------------------------------
pause

::ǩ��У��
%JavaDir% -jar %baseDir%\CheckAndroidV2Signature.jar  %outputDir%\result\%inputfileLegu%_sign.apk

echo ------------------------------------------------------
echo ���v2ǩ��Ч����� isV2OK: v2ǩ���Ƿ�ɹ� ��ɹ������ 
echo ------------------------------------------------------
pause


Set /p str=�Ƿ�������������Y ��   N ��


If not %str%==Y If not %str%==y exit

::����������(�ƹ���������channel.txt��д)
:2
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -f   %baseDir%\channel.txt  %outputDir%\result\%inputfileLegu%_sign.apk   %outputDir%\result\channelresult
%JavaDir% -jar %baseDir%\walle-cli-all.jar batch -c   %channelupgrade%  %outputDir%\result\%inputfileLegu%_sign.apk   %outputDir%\result\channelresult\channelUpgrade

echo -----------------------------------------------
echo ����%channel%���������  
echo �ļ�Ŀ¼channelresult
echo -----------
echo ����%channelupgrade%��������� 
echo �ļ�Ŀ¼channelresult\channelUpgrade
echo -----------------------------------------------
pause 

start %outputDir%\result