package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class BlockScenes
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:BlockMain = null;

    private var xmlconv:SFXMLConversation = null;

    private var txtAddCode:SFTextField = null;
    private var txtRemCode:SFTextField = null;

    private var project:String = null;

    private var currentCommand:String = null;
    private var currentBlock:String = null;

    private var lstAll:SFList = null;
    private var allArray:Array = null;

    private var lstAdded:SFList = null;
    private var addedArray:Array = null;

    private var chkRandom:SFCheckBox = null;
    private var chkTextFirst:SFCheckBox = null;

    private var getscenesinblock:XML = null;
    private var getscenesnotinblock:XML = null;
    private var getblocksettings:XML = null;

    private var lastPos:uint = 0;

    public function BlockScenes(myscreen:SFScreen, parentwin:BlockMain, aproject:String, blockName:String)
    {
      screen = myscreen;
      myparent = parentwin;

      project = aproject;
      currentBlock = blockName;

      lastPos = 0;

      frmMain = new SFFrame(screen,200,30,564,390,"Scenes in block " + blockName);
      pnlMain = frmMain.getPanel();

      var lblWithout:SFLabel = new SFLabel(pnlMain,10,10,220,25,"Available scenes");

      var lblWith:SFLabel = new SFLabel(pnlMain,310,10,220,25,"Added scenes");

      var btnClose:SFButton = new SFButton(pnlMain,430,320,120,40,"Close",btnCloseClick);
      var btnSave:SFButton = new SFButton(pnlMain,300,320,120,40,"Save",btnSaveClick);

      var btnAddStud:SFButton = new SFButton(pnlMain,260,110,40,40,">",btnAddClick);
      var btnRemStud:SFButton = new SFButton(pnlMain,260,210,40,40,"<",btnRemClick);

      chkRandom = new SFCheckBox(pnlMain,10,315,200,25,"Display in random order");          
      chkTextFirst = new SFCheckBox(pnlMain,10,340,200,25,"Always show text scenes first");          

      allArray = new Array();
      addedArray = new Array();

      var xml:String = "<command><function>getblocksettings</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + project + "\" />";
      xml = xml + "<parameter name=\"block\" value=\"" + currentBlock + "\" />";
      xml = xml + "</command>";

      getblocksettings = new XML(xml);

      xml = "<command><function>scenesinblock</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + project + "\" />";
      xml = xml + "<parameter name=\"block\" value=\"" + currentBlock + "\" />";
      xml = xml + "</command>";

      getscenesinblock = new XML(xml);

      xml = "<command><function>scenesnotinblock</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + project + "\" />";
      xml = xml + "<parameter name=\"block\" value=\"" + currentBlock + "\" />";
      xml = xml + "</command>";

      getscenesnotinblock = new XML(xml);

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getblocksettings";
      //SFScreen.addDebug(getscenesinblock.toXMLString());
      xmlconv.say(getblocksettings);
    }

    private function btnAddClick(e:MouseEvent):void
    { 
      if(lstAll.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a scene first");
      }
      else
      {
        var name:String = lstAll.getSelectedText();
        SFScreen.addDebug("selected name is " + name);

        var vert:SFVerticalScrollBar = lstAll.getVerticalScrollBar();
        if(vert != null)
        {
          lastPos = vert.getPos();
        }

        var xml:String = "<command><function>addscenetoblock</function>";
        xml = xml + "<parameter name=\"project\" value=\"" + project + "\" />";
        xml = xml + "<parameter name=\"block\" value=\"" + currentBlock + "\" />";
        xml = xml + "<parameter name=\"scene\" value=\"" + name + "\" />";
        xml = xml + "</command>";

        var cmd:XML = new XML(xml);
        currentCommand = "addscenetoblock";
        SFScreen.addDebug(cmd.toXMLString());
        xmlconv.say(cmd);
      }
    }

    private function btnRemClick(e:MouseEvent):void
    {
      if(lstAdded.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a scene first");
      }
      else
      {
        var name:String = lstAdded.getSelectedText();
        SFScreen.addDebug("selected name is " + name);

        var xml:String = "<command><function>removescenefromblock</function>";
        xml = xml + "<parameter name=\"project\" value=\"" + project + "\" />";
        xml = xml + "<parameter name=\"block\" value=\"" + currentBlock + "\" />";
        xml = xml + "<parameter name=\"scene\" value=\"" + name + "\" />";
        xml = xml + "</command>";

        var cmd:XML = new XML(xml);
        currentCommand = "removescenefromblock";
        SFScreen.addDebug(cmd.toXMLString());
        xmlconv.say(cmd);
      }
    }

    private function btnSaveClick(e:MouseEvent):void
    {
      var random:String = "0";
      var textfirst:String = "0";

      if(chkRandom.isChecked())
      {
        random = "1";
      }

      if(chkTextFirst.isChecked())
      {
        textfirst = "1";
      }

      var xml:String = "<command><function>blocksettings</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + project + "\" />";
      xml = xml + "<parameter name=\"block\" value=\"" + currentBlock + "\" />";
      xml = xml + "<parameter name=\"random\" value=\"" + random + "\" />";
      xml = xml + "<parameter name=\"textfirst\" value=\"" + textfirst + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      currentCommand = "blocksettings";
      SFScreen.addDebug(cmd.toXMLString());
      xmlconv.say(cmd);
    }

    private function btnCloseClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function xmlComplete(e:Event):void
    {
      var response:XML = xmlconv.getLastResponse();
      SFScreen.addDebug(currentCommand);
      SFScreen.addDebug(response.toXMLString());
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
        var name:String;
        var arr:Array = new Array();

        if(currentCommand == "getscenesnotinblock")
        {
          data = response.data[0];

          for each (row in data.row)
          {          
            name = row.column.(@name == "scene");
            arr[numelem++] = name;
          }

          if(lstAll != null)
          {
            pnlMain.removeChild(lstAll);
          }

          lstAll = new SFList(pnlMain,10,40,240,270,arr);
          var vert:SFVerticalScrollBar = lstAll.getVerticalScrollBar();
          if(vert != null && lastPos > 0)
          {
            vert.setPos(lastPos);
          }
        }

        if(currentCommand == "getscenesinblock")
        {
          data = response.data[0];

          for each (row in data.row)
          {          
            name = row.column.(@name == "scene");
            arr[numelem++] = name;
          }

          if(lstAdded != null)
          {
            pnlMain.removeChild(lstAdded);
          }

          lstAdded = new SFList(pnlMain,310,40,240,270,arr);
          currentCommand = "getscenesnotinblock";
          xmlconv.say(getscenesnotinblock);
        }

        if(currentCommand == "addscenetoblock")
        {
          currentCommand = "getscenesinblock";
          xmlconv.say(getscenesinblock);
        }

        if(currentCommand == "removescenefromblock")
        {
          currentCommand = "getscenesinblock";
          xmlconv.say(getscenesinblock);
        }

        if(currentCommand == "getblocksettings")
        {
          data = response.data[0];
          row = data.row[0];
          var random:String = row.column.(@name == "random");
          var textfirst:String = row.column.(@name == "textfirst");

          SFScreen.addDebug("Random: " + random);
          SFScreen.addDebug("TextFirst: " + textfirst);
          
          if(random == "1") { chkRandom.check(); }
          if(textfirst == "1") { chkTextFirst.check(); }

          currentCommand = "getscenesinblock";
          xmlconv.say(getscenesinblock);
        }

        if(currentCommand == "blocksettings")
        {
          var tmp1:SFShowMessage = new SFShowMessage(screen,"The display settings were saved");
        }
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

