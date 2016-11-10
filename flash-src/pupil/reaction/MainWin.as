package pupil.reaction
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class MainWin
  {
    private var screen:SFScreen = null;
    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;

    private var xmlconv:SFXMLConversation = null;

    private var xmlGetProjectList:XML = <command><function>getprojectlist</function></command>;
    private var currentCommand:String = "";

    private var btnOpen:SFButton = null;
    private var lstProject:SFList = null;
    private var listelements:Array = new Array();
    private var lblLoading:SFLabel = null;

    public function MainWin(myscreen:SFScreen)
    {
      screen = myscreen;

      frmMain = new SFFrame(screen,240,40,525,380,"Image experiment");
      pnlMain = frmMain.getPanel();

      lblLoading = new SFLabel(pnlMain,10,10,300,25,"Fetching project list...");

      xmlconv = new SFXMLConversation("../pupil/experiment",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getprojectlist";
      xmlconv.say(xmlGetProjectList);
    }

    private function xmlComplete(e:Event):void
    {
      SFScreen.addDebug("complete");
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

        if(currentCommand == "getprojectlist")
        {
          listelements = new Array();
          var pname:String;
          var pdesc:String;

          for each (row in data.row)
          {          
            //SFScreen.addDebug(row.column.(@name == "name"));
            pname = row.column.(@name == "name");
            pdesc = row.column.(@name == "description");

            listelements[numelem++] = pname + " -- " + pdesc;
          }

          updateProjectList();

        }
      }
    }

    private function openProject(name:String):void
    {
      SFScreen.addDebug("About to open project " + name);

      var lp:LoadProject = new LoadProject(screen,name);

    }

    private function btnOpenClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
        return;
      }

      var seltxt:String = lstProject.getSelectedText();
      var arr:Array = seltxt.split(" -- ");
      var name:String = arr[0];

      SFScreen.addDebug("selected name is " + name);
      openProject(name);
    }

    private function updateProjectList():void
    {
      if(lstProject != null)
      {
        pnlMain.removeChild(lstProject);
      }

      if(btnOpen != null)
      {
        pnlMain.removeChild(btnOpen);
      }

      if(lblLoading != null)
      {
        pnlMain.removeChild(lblLoading);
      }

      btnOpen = new SFButton(pnlMain,360,10,150,40,"Open project",btnOpenClick);
      lstProject = new SFList(pnlMain,10,10,340,330,listelements,SFComponent.BEVEL_DOWN);
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

