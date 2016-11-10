package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class BlockMain
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:ProjectDetails = null;

    private var xmlconv:SFXMLConversation = null;

    private var currentCommand:String = "";

    private var currentName:String = "lkjghdkjhg";

    private var lstBlocks:SFList = null;
    private var txtBlock:SFTextField = null;

    private var getblocklist:XML = null;

    public function BlockMain(myscreen:SFScreen, parentwin:ProjectDetails, projname:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projname;

      frmMain = new SFFrame(screen,170,70,460,440,"Block definition");
      pnlMain = frmMain.getPanel();

      var lblBlockList:SFLabel = new SFLabel(pnlMain,10,10,200,25,"Defined blocks",false);
      var lblNewBlock:SFLabel = new SFLabel(pnlMain,245,10,200,25,"New block",false);
      txtBlock = new SFTextField(pnlMain,245,30,200,25);

      var btnAdd:SFButton = new SFButton(pnlMain,245,60,200,40,"Add",onAddClick);
      var btnDel:SFButton = new SFButton(pnlMain,245,110,200,40,"Delete",onDeleteClick);
      var btnScenes:SFButton = new SFButton(pnlMain,245,160,200,40,"Scenes",onScenesClick);
//      var btnOrder:SFButton = new SFButton(pnlMain,245,240,200,40,"Order",onOrderClick);

      var btnCancel:SFButton = new SFButton(pnlMain,245,365,200,40,"Close",onCancelClick);

      var arr:Array = new Array();

      var xml:String = "<command><function>getblocklist</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
      xml = xml + "</command>";

      getblocklist = new XML(xml);
      
//      SFScreen.addDebug(getblocklist.toXMLString());

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getblocklist";
      xmlconv.say(getblocklist);
    }

    private function onAddClick(e:MouseEvent):void
    {
      var name:String = txtBlock.getText();

      if(name == '')
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Enter a valid name first");
        return;
      }

      var xml:String = "<command><function>addblock</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
      xml = xml + "<parameter name=\"name\" value=\"" + name + "\" />";
      xml = xml + "</command>";
      
      var cmd:XML = new XML(xml);
      SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "addblock";
      xmlconv.say(cmd);
    }

    private function onDeleteClick(e:MouseEvent):void
    {
      if(lstBlocks.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a block first");
      }
      else
      {
        var name:String = lstBlocks.getSelectedText();
        SFScreen.addDebug("selected name is " + name);

        var xml:String = "<command><function>deleteblock</function><parameter name=\"block\" value=\"" + name + "\" />";
        xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
        xml = xml + "</command>";

        var cmd:XML = new XML(xml);
        SFScreen.addDebug(cmd.toXMLString());
        currentCommand = "deleteblock";
        xmlconv.say(cmd);
      }
    }

    private function onScenesClick(e:MouseEvent):void
    {
      if(lstBlocks.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a block first");
      }
      else
      {
        var name:String = lstBlocks.getSelectedText();
        SFScreen.addDebug("selected name is " + name);
        var scn:BlockScenes = new BlockScenes(screen,this,currentName,name);
      }
    }

    private function onCancelClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function xmlComplete(e:Event):void
    {
      //SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
      //SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();
      var msg:SFShowMessage;

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        var numelem:uint = 0;
        var data:XML = response.data[0];
        var row:XML = null;

        if(currentCommand == "getblocklist")
        {
          data = response.data[0];

          var name:String;
          var arr:Array = new Array();

          for each (row in data.row)
          {          
            name = row.column.(@name == "name");
            arr[numelem++] = name;
          }

          if(lstBlocks != null)
          {
            pnlMain.removeChild(lstBlocks);
          }

          lstBlocks = new SFList(pnlMain,10,30,220,370,arr);
        }

        if(currentCommand == "addblock")
        {
          currentCommand = "getblocklist";
          xmlconv.say(getblocklist);
        }

        if(currentCommand == "deleteblock")
        {
          currentCommand = "getblocklist";
          xmlconv.say(getblocklist);
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

