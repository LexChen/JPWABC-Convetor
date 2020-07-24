# JPWABC-Convetor
Convert musescore file to jp-word file<br>
This plugin can convert the choosed stave to .jpwabc format file.<br>
The .jpwabc format file will be saved to temporaryPath+Score FileName.jpwabc<br>
eg. Moonlight.mscz - > C:/Users/LexChen/AppData/Local/Temp/Moonlight.jpwabc<br>
.jpwabc is the file format of a software named JP-Word which supports numbered notation(JianPu).<br>
JP-Word's homepage ~  http://www.happyeo.com/intro_jpw.htm<br>

The following elements have been converted:<br>
Chord,Rest,BarLine,KeySignature,TimeSignature,Tempo,Tie,Triplet(calculated by myself)<br>
I couldn't find the following elements in MuscScore's Plugin sdk,so they were ignored:<br>
Slur,Grace,Lines,Many Texts not having a corresponding object in JP-Word,etc<br>

==========Simplified Chinese====================<br>

这是一个Musecore插件，该插件用来将musescore打开的五线谱转换为jp-word的简谱格式。<br>
点击插件运行时只需要选择两个选项：<br>
1）要转换哪一行五线谱。缺省为第1行，顺序为从上到下编号<br>
2）要转换为首调记谱（First Tune）还是固定唱名记谱（Fixed Aria），缺省为首调记谱<br>
转换成功后，文件会被自动保存在临时目录下<br>
例如要转换的乐谱文件名为 Moonlight.mscz ，你当前登录的windows用户名为LexChen，那么<br>
转换完成后，文件会被自动保存在 C:/Users/LexChen/AppData/Local/Temp/Moonlight.jpwabc<br>
完成时会有弹窗提示，所以你不用记住这些东西。<br>
转换完成后用JP-Word打开该文件即可。<br>
JP-Word的下载地址~  http://www.happyeo.com/intro_jpw.htm<br>
<br>
安装方式：将JPWABC Convertor.qml放到musescore的插件（plugin）目录下即可
<br>
作者联系方式：  QQ  2480102119<br>
