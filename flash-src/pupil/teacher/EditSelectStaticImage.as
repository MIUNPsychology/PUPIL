package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class EditSelectStaticImage
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:ProjectDetails = null;

    private var xmlconv:SFXMLConversation = null;

    private var getImgs:XML = null;

    private var currentCommand:String = "";

    private var myPattern:String = "";

    private var categories:Array = new Array();
    private var images:Object = new Object();

    private var lstCat:SFList = null;
    private var lstImg:SFList = null;

    private var arrSetBtn:Array = new Array();
    private var arrCatTxt:Array = new Array();
    private var arrImgTxt:Array = new Array();
    private var arrKeyTxt:Array = new Array();

    private var myMaxPos:uint = 0;

    private var txtLabel:SFTextField = null;
    private var txtTimeout:SFTextField = null;
    private var txtCorrect:SFTextField = null;

    private var currentName:String = "";
    private var currentScene:String = "";

    public function EditSelectStaticImage(myscreen:SFScreen, parentwin:ProjectDetails, pattern:String, scenename:String, projname:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projname;
      currentScene = scenename;

      getImgs = new XML("<command><function>getallimages</function><parameter name=\"project\" value=\"" + projname + "\" /></command>");

      myPattern = pattern;

      myMaxPos = TeacherMain.patterns[pattern];

      frmMain = new SFFrame(screen,170,70,695,465,"Edit Static Image");
      pnlMain = frmMain.getPanel();

      var lblCatList:SFLabel = new SFLabel(pnlMain,10,10,150,25,"Select category",false);
      var lblImgList:SFLabel = new SFLabel(pnlMain,10,200,150,25,"Select Image",false);

      var lblCat:SFLabel = new SFLabel(pnlMain,340,10,80,25,"Category",false);
      var lblImg:SFLabel = new SFLabel(pnlMain,490,10,80,25,"Image",false);
      var lblKey:SFLabel = new SFLabel(pnlMain,640,10,40,25,"Key",false);

      var i:uint;

      for(i = 0; i < myMaxPos; i++)
      {
        arrSetBtn[i] = new SFButton(pnlMain,250,35 + (i * 30),80,25,"image " + (i+1),onImageClick);
        arrCatTxt[i] = new SFTextField(pnlMain,340,35 + (i * 30),140,25,"XXX");
        arrImgTxt[i] = new SFTextField(pnlMain,490,35 + (i * 30),140,25,"XXX");
        arrKeyTxt[i] = new SFTextField(pnlMain,640,35 + (i * 30),40,25,"XXX");
      }

      var lblLabel:SFLabel = new SFLabel(pnlMain,250,325,200,25,"Scene label");
      txtLabel = new SFTextField(pnlMain,250,350,200,25,"XXX");

      var lblCorrect:SFLabel = new SFLabel(pnlMain,460,325,200,25,"Correct answer (\"~\" for any)");
      txtCorrect = new SFTextField(pnlMain,460,350,200,25,"XXX");

      var lblTimeout:SFLabel = new SFLabel(pnlMain,10,370,225,25,"Timeout (0 for none)");
      txtTimeout = new SFTextField(pnlMain,10,395,225,25,"XXX");

      var btnCreate:SFButton = new SFButton(pnlMain,430,385,120,40,"Save",onCreateClick);
      var btnCancel:SFButton = new SFButton(pnlMain,560,385,120,40,"Cancel",onCancelClick);

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);

      var xml:String = "<command><function>getsceneinfo</function>";
      xml = xml + "<parameter name=\"scenename\" value=\"" + currentScene + "\" />";
      xml = xml + "<parameter name=\"projectname\" value=\"" + currentName + "\" />";
      xml = xml + "</command>";

      currentCommand = "getsceneinfo";
      xmlconv.say(new XML(xml));
    }

    private function onCancelClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function onCreateClick(e:MouseEvent):void
    {
      var i:Number;

      var xml:String = "<command><function>updatessi</function>";

      var cat:String;
      var img:String;
      var key:String;

      var msg:SFShowMessage;

      for(i = 0; i < myMaxPos; i++)
      {
        cat = arrCatTxt[i].getText();
        img = arrImgTxt[i].getText();
        key = arrKeyTxt[i].getText();

        if(cat != "" && img != "" && key != "")
        {
          xml = xml + "<parameter name=\"category " + (i+1) + "\" value=\"" + cat + "\" />";
          xml = xml + "<parameter name=\"file " + (i+1) + "\" value=\"" + img + "\" />";
          xml = xml + "<parameter name=\"key " + (i+1) + "\" value=\"" + key + "\" />";
        }
        else
        {
          msg = new SFShowMessage(screen,"Parameters are not properly assigned for image " + (i+1));
          return;
        }
      }

      xml = xml + "<parameter name=\"scene\" value=\"" + currentScene + "\" />";
      xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
      xml = xml + "<parameter name=\"pattern\" value=\"" + myPattern + "\" />";
      xml = xml + "<parameter name=\"timeout\" value=\"" + txtTimeout.getText() + "\" />";
      xml = xml + "<parameter name=\"correct\" value=\"" + txtCorrect.getText() + "\" />";
      xml = xml + "<parameter name=\"label\" value=\"" + txtLabel.getText() + "\" /></command>";

      var cmd:XML = new XML(xml);

      currentCommand = "updatessi";
      xmlconv.say(cmd);
      SFScreen.addDebug(cmd.toXMLString());
    }


    private function xmlComplete(e:Event):void
    {
//      SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
//      SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        var numelem:uint = 0;
        var data:XML = response.data[0];
        var row:XML = null;

        var filename:String;
        var category:String;


        if(currentCommand == "updatessi")
        {
          myparent.updateScenes();
          screen.removeChild(frmMain);
        }

        if(currentCommand == "getallimages")
        {
          var lastcat:String = "kdlghskdlghsfkljh";
          var imgs:Array;
          var len:uint;

          for each (row in data.row)
          {          
            filename = row.column.(@name == "file_name");
            category = row.column.(@name == "category");

            if(lastcat != category)
            {
              images[category] = new Array();
              len = categories.length;
              categories[len] = category;
              lastcat = category;
            }

            imgs = images[category] as Array;
            len = imgs.length;
            imgs[len] = filename;
          }
          try
          {
            if(lstCat != null)
            {
              pnlMain.removeChild(lstCat);
            }
            lstCat = new SFList(pnlMain,10,35,225,150,categories,SFComponent.BEVEL_NONE,onListSelect);
            lstImg = new SFList(pnlMain,10,225,225,130,new Array());

            
          }
          catch(e:Error)
          {
            SFScreen.addDebug("Helvete " + e.toString());
          }
        }

        if(currentCommand == "getsceneinfo")
        {
          var currDesc:String = response.description;
          var currCorrect:String = response.correctkey;
          var currTimeout:String = response.timeout;

          txtLabel.setText(currDesc);
          txtCorrect.setText(currCorrect);
          txtTimeout.setText(currTimeout);

          var ssi:XML = response.ssi[0];

          var ssientry:XML;

          var currImage:String;
          var currKeychar:String;
          var currPosition:String;

          var imgPart:Array;

          var img:String;
          var cat:String;

          var pos:uint;

          for each (ssientry in ssi.ssientry)
          {
            currImage = ssientry.@image;
            currKeychar = ssientry.@keychar;
            currPosition = ssientry.@position;

            imgPart = currImage.split("/");
            img = imgPart[1];
            cat = imgPart[0];

            pos = parseInt(currPosition);
            pos--;

            arrCatTxt[pos].setText(cat);
            arrImgTxt[pos].setText(img);
            arrKeyTxt[pos].setText(currKeychar);

          }

          currentCommand = "getallimages";
          xmlconv.say(getImgs);
        }
      }
    }

    private function onImageClick(e:MouseEvent):void
    {
      var btn:SFButton = SFButton(e.currentTarget);

      var msg:SFShowMessage;

      if( lstCat.getSelectedIndex() < 0 || lstImg.getSelectedIndex() < 0 )
      {
        msg = new SFShowMessage(screen,"Please select an image first");
        return;
      }

      var cat:String = lstCat.getSelectedText();
      var img:String = lstImg.getSelectedText();

      var btnt:String = btn.getText();

      var tmp:Array = btnt.split(" ");
      var num:Number = Number(tmp[1]);

      num--;
      
      arrCatTxt[num].setText(cat);
      arrImgTxt[num].setText(img);
    }

    private function onListSelect(index:Number = -1, text:String = null):void
    {
      if(index >= 0)
      {
        if(lstImg != null)
        {
          pnlMain.removeChild(lstImg);
        }
        lstImg = new SFList(pnlMain,10,225,225,130,images[text]);
      }
    }

    private function xmlMalformed(e:Event):void
    {
      SFScreen.addDebug("malformed");
    }

    private function xmlProgress(e:Event):void
    {
//      SFScreen.addDebug("progress");
    }

    private function xmlIoError(e:Event):void
    {
      SFScreen.addDebug("io error");
    }

    private function xmlSecurityError(e:Event):void
    {
      SFScreen.addDebug("security error");
    }

    private function xmlOpen(e:Event):void
    {
//      SFScreen.addDebug("open");
    }

    private function xmlHTTPStatus(e:Event):void
    {
//      SFScreen.addDebug("http status");
    }

  }
}

