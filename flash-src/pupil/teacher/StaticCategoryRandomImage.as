package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class StaticCategoryRandomImage
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:ProjectDetails = null;

    private var xmlconv:SFXMLConversation = null;

    private var getImgs:XML = <command><function>getallimages</function></command>;

    private var currentCommand:String = "";

    private var myPattern:String = "";

    private var categories:Array = new Array();
    private var images:Object = new Object();

    private var lstCat:SFList = null;
    private var lstImg:SFList = null;

    private var arrSetBtn:Array = new Array();
    private var arrCatTxt:Array = new Array();
    private var arrKeyTxt:Array = new Array();

    private var myMaxPos:uint = 0;

    private var txtLabel:SFTextField = null;
    private var txtCorrect:SFTextField = null;
    private var txtTimeout:SFTextField = null;

    private var currentName:String = "";

    private var chkUnique:SFCheckBox = null;

    public function StaticCategoryRandomImage(myscreen:SFScreen, parentwin:ProjectDetails, pattern:String, projname:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projname;

      myPattern = pattern;

      getImgs = new XML("<command><function>getallimages</function><parameter name=\"project\" value=\"" + projname + "\" /></command>");

      myMaxPos = TeacherMain.patterns[pattern];

      frmMain = new SFFrame(screen,170,70,695,465,"Static category, random image");
      pnlMain = frmMain.getPanel();

      var lblCatList:SFLabel = new SFLabel(pnlMain,10,10,150,25,"Select category",false);

      var lblCat:SFLabel = new SFLabel(pnlMain,340,10,80,25,"Category",false);
      var lblKey:SFLabel = new SFLabel(pnlMain,640,10,40,25,"Key",false);

      var i:uint;

      for(i = 0; i < myMaxPos; i++)
      {
        arrSetBtn[i] = new SFButton(pnlMain,250,35 + (i * 30),80,25,"image " + (i+1),onImageClick);
        arrCatTxt[i] = new SFTextField(pnlMain,340,35 + (i * 30),290,25);
        arrKeyTxt[i] = new SFTextField(pnlMain,640,35 + (i * 30),40,25,"" + (i+1));
      }

      chkUnique = new SFCheckBox(pnlMain,250,325,120,25,"Ensure unique images");
      chkUnique.check();

      var lblLabel:SFLabel = new SFLabel(pnlMain,250,365,120,25,"Scene label");
      txtLabel = new SFTextField(pnlMain,250,390,120,25,"New scene");

      var lblCorrect:SFLabel = new SFLabel(pnlMain,460,325,200,25,"Correct answer (\"~\" for any)");
      txtCorrect = new SFTextField(pnlMain,460,350,200,25,"~");

      var lblTimeout:SFLabel = new SFLabel(pnlMain,10,370,225,25,"Timeout (0 for none)");
      txtTimeout = new SFTextField(pnlMain,10,395,225,25,"0");

      var btnCreate:SFButton = new SFButton(pnlMain,430,385,120,40,"Create",onCreateClick);
      var btnCancel:SFButton = new SFButton(pnlMain,560,385,120,40,"Cancel",onCancelClick);


      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getallimages";
      xmlconv.say(getImgs);
    }

    private function onCancelClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function onCreateClick(e:MouseEvent):void
    {
      var i:Number;

      var xml:String = "<command><function>createscri</function>";

      var cat:String;
      var key:String;

      var msg:SFShowMessage;

      for(i = 0; i < myMaxPos; i++)
      {
        cat = arrCatTxt[i].getText();
        key = arrKeyTxt[i].getText();

        if(cat != "" && key != "")
        {
          xml = xml + "<parameter name=\"category " + (i+1) + "\" value=\"" + cat + "\" />";
          xml = xml + "<parameter name=\"key " + (i+1) + "\" value=\"" + key + "\" />";
        }
        else
        {
          msg = new SFShowMessage(screen,"Parameters are not properly assigned for image " + (i+1));
          return;
        }
      }

      if(chkUnique.isChecked())
      {
        xml = xml + "<parameter name=\"noduplicates\" value=\"true\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"noduplicates\" value=\"false\" />";
      }
      xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
      xml = xml + "<parameter name=\"pattern\" value=\"" + myPattern + "\" />";
      xml = xml + "<parameter name=\"correct\" value=\"" + txtCorrect.getText() + "\" />";
      xml = xml + "<parameter name=\"timeout\" value=\"" + txtTimeout.getText() + "\" />";
      xml = xml + "<parameter name=\"label\" value=\"" + txtLabel.getText() + "\" /></command>";

      var cmd:XML = new XML(xml);

      // SFScreen.addDebug(cmd.toXMLString());

      currentCommand = "createscri";
      xmlconv.say(cmd);

    }


    private function xmlComplete(e:Event):void
    {
      //SFScreen.addDebug("complete");
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

        if(currentCommand == "createscri")
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
            lstCat = new SFList(pnlMain,10,35,225,320,categories /*,SFComponent.BEVEL_NONE,onListSelect */);
            //lstImg = new SFList(pnlMain,10,225,225,150,new Array());
          }
          catch(e:Error)
          {
            SFScreen.addDebug("Helvete " + e.toString());
          }
        }
      }
    }

    private function onImageClick(e:MouseEvent):void
    {
      var btn:SFButton = SFButton(e.currentTarget);

      var msg:SFShowMessage;

      if( lstCat.getSelectedIndex() < 0 )
      {
        msg = new SFShowMessage(screen,"Please select a category first");
        return;
      }

      var cat:String = lstCat.getSelectedText();
      var btnt:String = btn.getText();

      var tmp:Array = btnt.split(" ");
      var num:Number = Number(tmp[1]);

      num--;
      
      arrCatTxt[num].setText(cat);
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

