package pupil.reaction
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class SelectProject
  {
    private var screen:SFScreen = null;

    private var xmlconv:SFXMLConversation = null;

    public function SelectProject(myscreen:SFScreen)
    {
      screen = myscreen;

      var demoWin:SFFrame = new SFFrame(screen,240,40,600,600,"Projekt");
      var panel:SFPanel = demoWin.getPanel();

      var javabtn:SFButton = new SFButton(panel,10,10,70,40,"Java",javaTest);
    }

    private function javaTest(e:MouseEvent):void
    {
      /*netobj = new SFNetObject();
      netobj.setValue("message","heya");
      netobj.setValue("bluttan","blurk");*/

      /*SFXMLConversation(serverUrl:String,onComplete:Function = null,onMalformed:Function = null,onProgress:Function = null,
          onIoError:Function = null, onSecurityError:Function = null, onOpen:Function = null, onHTTPStatus:Function = null)*/

      xmlconv = new SFXMLConversation("../pupil/reaction",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);

      var somexml:XML = <hej>hopp</hej>;

      xmlconv.say(somexml);
    }

    private function xmlComplete(e:Event):void
    {
      SFScreen.addDebug("complete");

      var response:XML = xmlconv.getLastResponse();

      SFScreen.addDebug(response.toXMLString());
    }

    private function xmlMalformed(e:Event):void
    {
      SFScreen.addDebug("malformed");
    }

    private function xmlProgress(e:Event):void
    {
      SFScreen.addDebug("progress");
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
      SFScreen.addDebug("open");
    }

    private function xmlHTTPStatus(e:Event):void
    {
      SFScreen.addDebug("http status");
    }

  }
}

