package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class TextScene
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:ProjectDetails = null;

    private var xmlconv:SFXMLConversation = null;

    private var currentCommand:String = "";

    private var currentName:String = "";

    private var txtText:SFTextField = null;
    private var txtLabel:SFTextField = null;

    public function TextScene(myscreen:SFScreen, parentwin:ProjectDetails, projname:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projname;

      frmMain = new SFFrame(screen,100,70,475,465,"Text");
      pnlMain = frmMain.getPanel();

      var lblCatList:SFLabel = new SFLabel(pnlMain,10,10,450,25,"Enter scene text. Lines should not be longer than 40 characters.",false);

      var btnCreate:SFButton = new SFButton(pnlMain,210,385,120,40,"Create",onCreateClick);
      var btnCancel:SFButton = new SFButton(pnlMain,340,385,120,40,"Cancel",onCancelClick);

      var lblLabel:SFLabel = new SFLabel(pnlMain,10,320,450,25,"Scene label");
      txtLabel = new SFTextField(pnlMain,10,340,450,25,"New scene");

      txtText = new SFTextField(pnlMain,10,30,450,280,"",true);

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
/*      currentCommand = "getallimages";
      xmlconv.say(getImgs);*/
    }

    private function onCancelClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function onCreateClick(e:MouseEvent):void
    {
      var i:Number;

      var text:String = txtText.getText();      

      text = text.replace(/"/g,"");

      var strs:Array = text.split(String.fromCharCode(13));

      var pipes:String = "";

      for(i = 0; i < strs.length; i++)
      {
        if(strs[i] != "")
        {
          if(pipes != "")
          {
            pipes = pipes + "|";
          }
          SFScreen.addDebug(strs[i]);
          pipes = pipes + strs[i];
        }
      }

//      SFScreen.addDebug(pipes);

      var xml:String = "<command><function>createtext</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
      xml = xml + "<parameter name=\"text\" value=\"" + pipes + "\" />";
      xml = xml + "<parameter name=\"label\" value=\"" + txtLabel.getText() + "\" /></command>";

      var cmd:XML = new XML(xml);

      currentCommand = "createtext";
      SFScreen.addDebug(cmd.toXMLString());
      xmlconv.say(cmd);
    }

    private function xmlComplete(e:Event):void
    {
      // SFScreen.addDebug("complete");
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

        if(currentCommand == "createtext")
        {
          myparent.updateScenes();
          screen.removeChild(frmMain);
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

