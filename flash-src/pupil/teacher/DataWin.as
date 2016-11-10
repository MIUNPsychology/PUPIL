package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class DataWin
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var myproject:String = "";

    private var xmlconv:SFXMLConversation = null;
    private var currentCommand:String = "";

    public function DataWin(myscreen:SFScreen, parentwin:TeacherMain, project:String)
    {
      screen = myscreen;
      myparent = parentwin;
      myproject = project;

      frmMain = new SFFrame(screen,300,150,405,85,"Data for project");
      pnlMain = frmMain.getPanel();

      var btnShow:SFButton = new SFButton(pnlMain,10,10,120,40,"Show data",btnShowClick);
      var btnReset:SFButton = new SFButton(pnlMain,140,10,120,40,"Reset data",btnResetClick);
      var btnClose:SFButton = new SFButton(pnlMain,270,10,120,40,"Done",btnCloseClick);

      frmMain.registerTabComponent(btnShow);
      frmMain.registerTabComponent(btnReset);
      frmMain.registerTabComponent(btnClose);
     
      frmMain.grabTabControl();

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
    }

    private function xmlComplete(e:Event):void
    {
      //SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
    //  SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        if(currentCommand == "resetdata")
        {
          var msg:SFShowMessage = new SFShowMessage(screen,"All data have been remove for this project");
        }
      }
    }

    private function btnShowClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnShowClick()");
      var req:URLRequest = new URLRequest("../sql/showdata.sql?1=" + myproject);
      navigateToURL(req,"_blank");
    }

    private function btnResetClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnResetClick()");

      var xml:String = "<command><function>resetdata</function>";
      xml = xml + "<parameter name=\"name\" value=\"" + myproject + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      currentCommand = "resetdata";
      //SFScreen.addDebug(cmd.toXMLString());
      xmlconv.say(cmd);
    }

    private function btnCloseClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnCloseClick()");
      frmMain.releaseTabControl();
      screen.removeChild(frmMain);
      myparent.frmMain.grabTabControl();
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

