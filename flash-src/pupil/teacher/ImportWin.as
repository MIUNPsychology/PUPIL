package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class ImportWin
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:StudentsWin = null;

    private var xmlconv:SFXMLConversation = null;

    private var getStudents:XML = <command><function>getallstudents</function></command>;

    private var currentCommand:String = "";

    private var lstStudents:SFList = null;

    private var txtKod:SFTextField = null;
    private var txtTillf:SFTextField = null;
    private var txtTakt:SFTextField = null;

    private var students:Array = null;

    public function ImportWin(myscreen:SFScreen, parentwin:StudentsWin)
    {
      screen = myscreen;
      myparent = parentwin;

      frmMain = new SFFrame(screen,250,50,430,450,"Import students");
      pnlMain = frmMain.getPanel();

      var lblKod:SFLabel = new SFLabel(pnlMain,10,10,200,25,"Katalogkod (t.ex 25051)");
      txtKod = new SFTextField(pnlMain,10,35,200,25);

      var btnList:SFButton = new SFButton(pnlMain,300,10,120,40,"List",btnListClick);
      var btnImport:SFButton = new SFButton(pnlMain,300,60,120,40,"Import",btnImportClick);
      var btnClose:SFButton = new SFButton(pnlMain,300,110,120,40,"Close",btnCloseClick);

      frmMain.registerTabComponent(txtKod);
      frmMain.registerTabComponent(btnList);
      frmMain.registerTabComponent(btnImport);
      frmMain.registerTabComponent(btnClose);

      frmMain.grabTabControl();

      screen.stage.focus = btnClose;

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
    }

    private function btnImportClick(e:MouseEvent):void
    {
      SFScreen.addDebug("btnImportClick()");

      var kod:String = txtKod.getText();      

      var xml:String = "<command><function>importstudents</function>";
      xml = xml + "<parameter name=\"kod\" value=\"" + kod + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "importstudents";
      xmlconv.say(cmd);
    }

    private function btnCloseClick(e:MouseEvent):void
    {
      SFScreen.addDebug("btnCloseClick()");
      frmMain.releaseTabControl();
      screen.removeChild(frmMain);
      myparent.frmMain.grabTabControl();
      myparent.reloadStudents();
    }

    private function btnListClick(e:MouseEvent):void
    {
      SFScreen.addDebug("btnListClick()");

      var kod:String = txtKod.getText();      

      var xml:String = "<command><function>importlist</function>";
      xml = xml + "<parameter name=\"kod\" value=\"" + kod + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "importlist";
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

        if(currentCommand == "updatestudent")
        {
          var msg:SFShowMessage = new SFShowMessage(screen,"Password updated");
        }

        if(currentCommand == "importlist")
        {
//          SFScreen.addDebug(response.toXMLString());
          students = new Array();

          var panv:String;
          var pfor:String;
          var peft:String;

          for each (row in data.row)
          {
            //SFScreen.addDebug(row.column.(@name == "name"));
            panv = row.column.(@name == "anvid");
            pfor = row.column.(@name == "fornamn");
            peft = row.column.(@name == "efternamn");

            students[numelem++] = panv + " (" + pfor + " " + peft + ")";
          }

          if(lstStudents != null)
          {
            pnlMain.removeChild(lstStudents);
          }

          lstStudents = new SFList(pnlMain,10,70,280,340,students);
        }

        if(currentCommand == "importstudents")
        {
          var tmp1:SFShowMessage = new SFShowMessage(screen,"Ok, student list was updated");
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

