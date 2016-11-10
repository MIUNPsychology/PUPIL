package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class PermissionsWin
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var xmlconv:SFXMLConversation = null;

    private var txtAddCode:SFTextField = null;
    private var txtRemCode:SFTextField = null;

    private var project:String = null;

    private var currentCommand:String = null;

    private var lstWith:SFList = null;
    private var withlist:Array = null;

    private var lstWithout:SFList = null;
    private var withoutlist:Array = null;

    private var getwithxml:XML = null;
    private var getwithoutxml:XML = null;

    public function PermissionsWin(myscreen:SFScreen, parentwin:TeacherMain, aproject:String)
    {
      screen = myscreen;
      myparent = parentwin;

      project = aproject;

      getwithxml = new XML("<command><function>getwithpermission</function><parameter name=\"project\" value=\"" + project + "\" /></command>");
      getwithoutxml = new XML("<command><function>getwithoutpermission</function><parameter name=\"project\" value=\"" + project + "\" /></command>");

      frmMain = new SFFrame(screen,200,30,564,515,"Permission management (project: " + aproject + ")");
      pnlMain = frmMain.getPanel();

      var lblAddCode:SFLabel = new SFLabel(pnlMain,10,10,150,25,"Add course with code");
      txtAddCode = new SFTextField(pnlMain,10,35,150);
      var btnAddCode:SFButton = new SFButton(pnlMain,10,70,120,40,"Add",btnAddCodeClick);
      var lblWithout:SFLabel = new SFLabel(pnlMain,10,130,220,25,"Students WITHOUT permission");

      var lblRemCode:SFLabel = new SFLabel(pnlMain,310,10,200,25,"Remove course with code");
      txtRemCode = new SFTextField(pnlMain,310,35,150);
      var btnRemCode:SFButton = new SFButton(pnlMain,310,70,120,40,"Remove",btnRemCodeClick);
      var lblWith:SFLabel = new SFLabel(pnlMain,310,130,220,25,"Students WITH permission");

      var btnClose:SFButton = new SFButton(pnlMain,430,440,120,40,"Close",btnCloseClick);

      var btnAddStud:SFButton = new SFButton(pnlMain,260,230,40,40,">",btnAddClick);
      var btnRemStud:SFButton = new SFButton(pnlMain,260,330,40,40,"<",btnRemClick);

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getwithoutpermission";
      xmlconv.say(getwithoutxml);
    }

    private function btnAddClick(e:MouseEvent):void
    {
      // SFScreen.addDebug("btnAddClick()");
      var index:Number;
      var login:String;

      index = lstWithout.getSelectedIndex();
      if(index >= 0)
      {
        login = lstWithout.getSelectedText();

        var xml:String = "<command><function>addpermission</function><parameter name=\"project\" value=\"" + project + "\" />";
        xml = xml + "<parameter name=\"login\" value=\"" + login + "\" /></command>";
        var addperm:XML = new XML(xml);
        //SFScreen.addDebug(addperm.toXMLString());
        currentCommand = "addpermission";
        xmlconv.say(addperm);
      }
      else
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please select a valid login first");
      }
    }

    private function btnRemClick(e:MouseEvent):void
    {
      // SFScreen.addDebug("btnRemClick()");
      var index:Number;
      var login:String;

      index = lstWith.getSelectedIndex();
      if(index >= 0)
      {
        login = lstWith.getSelectedText();

        var xml:String = "<command><function>rempermission</function><parameter name=\"project\" value=\"" + project + "\" />";
        xml = xml + "<parameter name=\"login\" value=\"" + login + "\" /></command>";
        var remperm:XML = new XML(xml);
        //SFScreen.addDebug(remperm.toXMLString());
        currentCommand = "rempermission";
        xmlconv.say(remperm);
      }
      else
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please select a valid login first");
      }
    }

    private function btnAddCodeClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnAddCodeClick()");

      var code:String = txtAddCode.getText();
      if(code == null || code == "")
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please enter a valid code!");
      }
      else
      {
        var xml:String = "<command><function>addcodepermission</function><parameter name=\"project\" value=\"" + project + "\" />";
        xml = xml + "<parameter name=\"code\" value=\"" + code + "\" /></command>";
        var addperm:XML = new XML(xml);
        //SFScreen.addDebug(addperm.toXMLString());
        currentCommand = "addcodepermission";
        xmlconv.say(addperm);
      }
    }

    private function btnRemCodeClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnRemCodeClick()");

      var code:String = txtRemCode.getText();
      if(code == null || code == "")
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please enter a valid code!");
      }
      else
      {
        var xml:String = "<command><function>remcodepermission</function><parameter name=\"project\" value=\"" + project + "\" />";
        xml = xml + "<parameter name=\"code\" value=\"" + code + "\" /></command>";
        var remperm:XML = new XML(xml);
        //SFScreen.addDebug(remperm.toXMLString());
        currentCommand = "remcodepermission";
        xmlconv.say(remperm);
      }
    }

    private function btnCloseClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function xmlComplete(e:Event):void
    {
      // SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
      //SFScreen.addDebug(response.toXMLString());
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

        if(currentCommand == "getwithpermission")
        {
          withlist = new Array();

          for each (row in data.row)
          {          
            withlist[numelem++] = row.column.(@name == "login");
          }

          if(lstWith != null)
          {
            pnlMain.removeChild(lstWith);
          }
          lstWith = new SFList(pnlMain,310,160,240,270,withlist);
        }

        if(currentCommand == "getwithoutpermission")
        {
          withoutlist = new Array();

          for each (row in data.row)
          {          
            withoutlist[numelem++] = row.column.(@name == "login");
          }

          if(lstWithout != null)
          {
            pnlMain.removeChild(lstWithout);
          }
          lstWithout = new SFList(pnlMain,10,160,240,270,withoutlist);

          currentCommand = "getwithpermission";          
          xmlconv.say(getwithxml);
        }

        if(currentCommand == "rempermission")
        {
          //SFScreen.addDebug(response.toXMLString());
          currentCommand = "getwithoutpermission";          
          xmlconv.say(getwithoutxml);          
        }

        if(currentCommand == "addpermission")
        {
          //SFScreen.addDebug(response.toXMLString());
          currentCommand = "getwithoutpermission";          
          xmlconv.say(getwithoutxml);          
        }

        if(currentCommand == "addcodepermission")
        {
          //SFScreen.addDebug(response.toXMLString());
          currentCommand = "getwithoutpermission";          
          xmlconv.say(getwithoutxml);          
        }

        if(currentCommand == "remcodepermission")
        {
          //SFScreen.addDebug(response.toXMLString());
          currentCommand = "getwithoutpermission";          
          xmlconv.say(getwithoutxml);          
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

