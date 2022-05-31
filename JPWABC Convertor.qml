//  JPWABC format file convertor plugin Version1.0.0 for MuseScore Ver.3.4+
//  
//  This plugin can convert the choosed stave to .jpwabc format file.
//  The .jpwabc format file will be saved to temporaryPath+Score FileName.jpwabc
//  eg. Moonlight.mscz - > C:/Users/LexChen/AppData/Local/Temp/Moonlight.jpwabc
//  .jpwabc is the file format of a software named JP-Word which supports numbered notation(JianPu).
//  JP-Word's homepage: <http://www.happyeo.com/intro_jpw.htm>
//
//  The following elements have been converted:
//  Chord,Rest,BarLine,KeySignature,TimeSignature,Tempo,Tie,Triplet(calculated by myself)
//  I couldn't find the following elements in MuscScore's Plugin sdk,so they were ignored:
//  Slur,Grace,Lines,Many Texts not having a corresponding object in JP-Word,etc
//
//  Copyright (C)2020- LexChen email: 2480102119@qq.com
//
//===================================================================================================
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import MuseScore 3.0
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import FileIO 3.0

MuseScore {
    menuPath: "Plugins."+qsTr("JPWABC Convertor")
    version: "1.0.0"
    description: qsTr("Convertor the selected Stave to .jpwabc format file")
    pluginType: "dialog"

    id: window
    width:300  // window size
    height:150

    ExclusiveGroup { id: exclusiveGroupKey }

    property var currentKey : 0
    property var solmizationType : 0
    property var gridX1 : 10
    property var gridX2 : 160
    
    FileIO {
        id: outfile
        source:  homePath()+"/"
        onError: lexDialog.openErrorDialog(msg)
    }     

    RowLayout { // choose staff
        id: row0
        x : gridX1
        y : 10
        Text {
            text: qsTr("Stave")
        }
    }

    RowLayout {
        id: row0R
        x : gridX2
        y : 8
        TextField {
            id: staveList
            width: 100
            text: "1"
        }
    }


    RowLayout {  // choose solmization
        id: rowJ
        x : gridX1
        y : 50
        Label {
            text: qsTr("Solmization")
        }
    }

    RowLayout {
        id: rowJR
        x : gridX2
        y : 48
        ComboBox {
            currentIndex: 0
            model: ListModel {
                id: solmizationMethod
                property var key
                ListElement { text: qsTr("首调"); sValue : 0 }
                ListElement { text: qsTr("固定音"); sValue : 1 }
            }
            width: 80
            onCurrentIndexChanged: {
                solmizationMethod.key = solmizationMethod.get(currentIndex).sValue
                solmizationType = solmizationMethod.key
            }
        }
    }


    RowLayout { //version
        id: rowVer
        x : 10
        y : 100
        Label {
            font.pointSize: 10
            text: "V"+version
        }
    }

    RowLayout {  //actions
        id: row7
        x : 120
        y : 98
        Button {
            id: closeButton
            text: qsTr("Cancel")
            onClicked: { Qt.quit() }
        }
        Button {
            id: okButton
            text: qsTr("Ok")
            onClicked: {
                convert()
            }
        }
    }

    MessageDialog {
        id: lexDialog
        visible: false
        modality: Qt.ApplicationModal
        title: ""
        text: ""
        onAccepted: {
            close();
        }
        function openErrorDialog(message) {
            title = qsTr("Error");
            text = message;
            open();
        }
        function openTipsDialog(message){
            title = qsTr("Information");
            text = message;
            open();
        }
    }


    function convert() {
        curScore.startCmd();
        doTransform();
        curScore.endCmd();
    }

    onRun: {
        if(typeof curScore === 'undefined'){
            Qt.quit();
        }
    }

    property var durationMap : [
        [4*this.division,"---",0], // whole
        [7*this.division/2,"--.",0], // half+dot+dot
        [3*this.division,"--",0], // half+dot
        [8*this.division/3,"---",3], // whole*2(breve)/3
        [2*this.division,"-",0], // half
        [7*this.division/4,"..",0], // dot+dot
        [3*this.division/2,".",0], // dot
        [4*this.division/3,"-",3], // whole/3
        [this.division,"",0], // 1/4 note (crochet)
        [7*this.division/8,"_..",0], // quaver(1/8 note) + dot + dot
        [3*this.division/4,"_.",0], // quaver+dot
        [2*this.division/3,"",3], // 1/2 note(minim)/3
        [this.division/2,"_",0], // quaver
        [7*this.division/16,"__..",0], // 1/16 note(semiquaver)+dot+dot
        [3*this.division/8,"__.",0], // semiquaver+dot
        [this.division/3,"_",3], // crochet/3
        [this.division/4,"__",0], // semiquaver
        [7*this.division/32,"___..",0], // 1/32 note(demi-semiquaver)+dot+dot
        [3*this.division/16,"___.",0], // demi-semiquaver+dot
        [this.division/6,"__",3], // quaver/3
        [this.division/8,"___",0], // demi-semiquaver
        [3*this.division/32,"____.",0], // 1/64 note(hemi-demi-semiquaver) +dot
        [this.division/12,"___",3], // semiquaver/3
        [this.division/16,"____",0], // hemi-demi-semiquaver
        ]
			
    property var keyNames : ["bC","bG","bD","bA","bE","bB","F","C","G","D","A","E","B","#F","#C"]
    property var baseNote : [59,66,61,56,63,58,65,60,67,62,57,64,59,66,61]
    property var sharpNotes : ["1","#1","2","#2","3","4","#4","5","#5","6","#6","7"]
    property var flatNotes : ["1","b2","2","b3","3","4","b5","5","b6","6","b7","7"]

    function doTransform() {
        var content = "// ************** JPW-ABC File Ver 1.0 (for JP-Word v5.30g) **************";

        var cursor = curScore.newCursor();
        var endTick;
        var selPart=0;
        var selectedStave = parseInt(staveList.text)-1;
        if(selectedStave<0 || selectedStave>=curScore.nstaves){
            lexDialog.openErrorDialog(qsTr("Stave no must be within [1,%1]").arg(curScore.nstaves));
            return;
        }
        if(curScore.scoreName!=undefined && curScore.scoreName!='undefined'){
            outfile.source += curScore.scoreName+".jpwabc";
        }else{
            outfile.source += "lex.jpwabc";
        }
        
        currentKey = curScore.keysig;
        var lastKey = currentKey;
        var lastNumerator = 0;
        var lastDenominator = 0;
        var voice=0;
        cursor.rewind(0);
        cursor.voice = voice;
        cursor.StaveIdx = selectedStave;

        content+="\n.Options\nVertSpacing = 1.00, 0.30, 0.20, 1.95\n\n";
        content+="\n.Fonts\nTitle = Microsoft YaHei, 8.00";
        content+="\nWordsByAndMusicBy = KaiTi_GB2312, 4.50";
        content+="\nSubTitle2 = FangSong_GB2312, 3.80";
        content+="\nSubTitle = FangSong_GB2312, 4.00";
        content+="\nKeyAndMeters = Microsoft YaHei, 3.00";
        content+="\nIntro = Arial, 3.00, [I]";
        content+="\nExpression = Microsoft YaHei, 3.50\n\n";
        content+="\n.Title\nIntro = QQ: 527254719";
        content+="\nTitle = {"+curScore.title+"}";
        content+="\nSubTitle = From：";
        content+="\nSubTitle2 = Singer：";
        if(solmizationType == 0){
            content+="\nKeyAndMeters = {1="+keyNames[cursor.keySignature+7]+",___LEX___}";
        }else{
            content+="\nKeyAndMeters = {1=C,___LEX___}";
        }
        content+="\nWordsByAndMusicBy = "+qsTr("Composor:")+curScore.composer+"\\n"+qsTr("Lyrics:")+curScore.lyricist+"\\n"+qsTr("Maker:cangerjun");
        content+="\nExpression = ";
        content+="\nLinePos = -3.0, -1.0, 11.0, 16.5, 10.5, 10.5, 18.0";
        content+="\n\n\n.Voice\n";
        var tickList = [];
        var index = 0;
        while(cursor.segment){
            var t = cursor.segment.tick
            tickList[index]=t;
            if(index>0){
                tickList[index-1]=t-tickList[index-1];
            }
            index++;
            cursor.next();
        }
        tickList[index-1]=curScore.lastSegment.tick-tickList[index-1];
        index=0;
        cursor.filter=-1;
        cursor.rewind(0);
        var barCount=1;
        var noteCount=1;
        var attachMent = "";
        var notFirst = 0;
        var voice = "";
        var tripletCount=-1;
        while (cursor.segment) {
            console.log("element="+cursor.element+","+cursor.element.type);
            var noteText = "";
            var txtBefore="";
            var txtAfter="";
            currentKey = cursor.keySignature;
            switch(cursor.element.type){
            case Element.CHORD:
                var note = cursor.element.notes[0];
                if(note.tieForward){ 
                    txtBefore="(";
                }
                if(note.tieBack ){
                    txtAfter=")";
                }
            case Element.REST:
                var n=isTriplet(tickList[index]);
                if(n){
                  if(tripletCount==-1){
                      txtBefore+="{("+n+"}";
                      tripletCount=0;
                  }
                  tripletCount++;
                  if(tripletCount==n){
                      txtAfter+=")";
                      tripletCount=-1;
                  }
                }
                noteText = txtBefore+abcSign(cursor.element.notes)+abcDuration(tickList[index])+txtAfter;
                index++;
                noteCount++;
                notFirst=1;
                break;
            case Element.BAR_LINE:
                if(cursor.element.barlineType==1){
                    noteText=" | ";
                }else if(cursor.element.barlineType==2){
                    noteText=" | ";
                }else if(cursor.element.barlineType==4){
                    noteText=" |: ";
                }else if(cursor.element.barlineType==8){
                    noteText=" :| ";
                }else if(cursor.element.barlineType==16){
                    noteText=" :: ";
                }else if(cursor.element.barlineType==32){
                    noteText=" |] ";
                }else if(cursor.element.barlineType==64){
                    noteText=" :|: ";
                }else if(cursor.element.barlineType==128){
                    noteText=" :: ";
                }
                if(cursor.prev()){
                    if( cursor.element.type!=Element.BAR_LINE && notFirst){
	                 barCount++;
                    }
                    cursor.next();
                }else{
                    cursor.rewind(0);
                }
                noteCount=1;
                break;
            case Element.KEYSIG  :
                if(solmizationType == 0 && currentKey!=lastKey){
                    attachMent+="\nText@"+barCount+","+noteCount+"(1.2,-2.8) = AttachText1, "+qsTr("")+"{1="+keyNames[currentKey+7]+"},{0.8,0.8}";
                    lastKey=currentKey;
                }
                break;
            case Element.TIMESIG  :
                var num = cursor.element.timesig.numerator;
                var dem = cursor.element.timesig.denominator;
                if(lastDenominator!=dem || lastNumerator!=num){
                    if(lastDenominator==0){
                        content=content.replace("___LEX___",num+"/"+dem);
                    }else{
                        noteText=" "+num+"/"+dem+" ";
                    }
                    lastDenominator=dem;
                    lastNumerator=num;
                }
                break;
            }
            voice+=noteText;
            cursor.next();
        }
        voice=voice.replace(/\|\|\|:/g,"|:");
        voice=voice.replace(/\:\|\|\:/g,":|:");
        voice=voice.replace(/::\|:/g,"|:");
        voice=voice.replace(/\|\|:/g,'|:');
        voice=voice.replace(/:\|\|:/g,":|:");
        content+=voice+"$(true)\n\n\n.Words\n\n\n.Attachments"+attachMent+"\n\n\n.Page\n\n\n";
        console.log("\n"+content);
        var rc = outfile.write(content);
        var info = qsTr(".jpwabc format file has been saved to ")+outfile.source;
        console.log(info);
        lexDialog.openTipsDialog(info);
        Qt.quit();
    }

    function abcDuration(tick){
        for(var i=0;i<durationMap.length;i++){
            if(Math.abs(durationMap[i][0]-tick)<5){
                return durationMap[i][1];
            }
        }
        return durationMap[0][1];
    }
    
    function isTriplet(tick){
        for(var i=0;i<durationMap.length;i++){
            if(Math.abs(durationMap[i][0]-tick)<5){
                return durationMap[i][2];
            }
        }
        return 0;
    }

    function abcSign(notes){
        if(notes == undefined || notes == 'undefined'){
            return "0";
        }
        var note = notes[notes.length-1];
        var valCenterC;
        var text="";
        if(solmizationType == 0){//first tune
            valCenterC = baseNote[currentKey+7];
        }else{  // fixed tune
            valCenterC = baseNote[7];
        }
        var pitchShift=valCenterC-60;
        var pitchOctaveIndex=parseInt((note.pitch-pitchShift)/12) - 5;
        var pitchIndex=(note.pitch-pitchShift) % 12 ;
        var appendix="";
        if(note.tpc>=6 && note.tpc<=12){ //fLat
            text=flatNotes[pitchIndex];
        }else if(note.tpc>=20 && note.tpc<=26){//sharp
            text=sharpNotes[pitchIndex];
        }else{//normal
            text=sharpNotes[pitchIndex];
        }
        if(pitchOctaveIndex!=0){
            var sign;
            if(pitchOctaveIndex>0){
                sign="g";
            }else{
                sign="d";
            }
            for(var i=0;i<Math.abs(pitchOctaveIndex);i++){
                text=text+sign;
            }
        }
        return text;
    }
}
