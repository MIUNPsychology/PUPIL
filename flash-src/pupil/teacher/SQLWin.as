package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class SQLWin
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var xmlconv:SFXMLConversation = null;
    private var currentCommand:String = "";

    private var lstFiles:SFList = null;
    private var txtSave:SFTextField = null;
    private var txtSQL:SFTextField = null;

    public function SQLWin(myscreen:SFScreen, parentwin:TeacherMain)
    {
      screen = myscreen;
      myparent = parentwin;

      frmMain = new SFFrame(screen,300,100,460,415,"SQL files");
      pnlMain = frmMain.getPanel();

      var btnShow:SFButton = new SFButton(pnlMain,320,10,120,40,"Show data",btnShowClick);
      var btnLoad:SFButton = new SFButton(pnlMain,320,60,120,40,"Load",btnLoadClick);
      var btnDelete:SFButton = new SFButton(pnlMain,320,110,120,40,"Delete",btnDeleteClick);
      var btnSave:SFButton = new SFButton(pnlMain,320,245,120,40,"Save",btnSaveClick);
      var btnClose:SFButton = new SFButton(pnlMain,320,340,120,40,"Done",btnCloseClick);

      var lblSave:SFLabel = new SFLabel(pnlMain,10,160,300,25,"Save as (create if not exists)");
      txtSave = new SFTextField(pnlMain,10,185,300,25);

      var lblSQL:SFLabel = new SFLabel(pnlMain,10,220,300,25,"SQL code");
      txtSQL = new SFTextField(pnlMain,10,245,300,135,"",true);

      frmMain.registerTabComponent(btnShow);
      frmMain.registerTabComponent(btnClose);
     
      frmMain.grabTabControl();

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      var xml:XML = new XML("<command><function>listsql</function></command>");
      currentCommand = "listsql";
      xmlconv.say(xml);
    }

    private function xmlComplete(e:Event):void
    {
      //SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
      //SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        if(currentCommand == "getsqlfile")
        {
          txtSQL.setText(response);
          txtSave.setText(lstFiles.getSelectedText());
        }

        if(currentCommand == "listsql")
        {
          var files:Array = new Array();

          for each (var file:XML in response.file)
          {
            files[files.length] = file;
          }

          if(lstFiles != null)
          {
            pnlMain.removeChild(lstFiles);
          }

          lstFiles = new SFList(pnlMain,10,10,300,140,files);
        }
        if(currentCommand == "savesql")
        {
          var msg:SFShowMessage = new SFShowMessage(screen,"SQL data saved");
          var xml:XML = new XML("<command><function>listsql</function></command>");
          currentCommand = "listsql";
          xmlconv.say(xml);
        }
        if(currentCommand == "deletesql")
        {
          var msg1:SFShowMessage = new SFShowMessage(screen,"SQL file deleted");
          var xml1:XML = new XML("<command><function>listsql</function></command>");
          currentCommand = "listsql";
          xmlconv.say(xml1);
        }
      }
    }

    private function btnSaveClick(e:MouseEvent):void
    {
      var name:String = txtSave.getText();
      var sql:String = txtSQL.getText();

      var msg:SFShowMessage = null;

      if(name == "")
      {
        msg = new SFShowMessage(screen,"Enter a file name first");
        return;
      }

      if(sql == "")
      {
        msg = new SFShowMessage(screen,"Write something in the SQL field first");
        return;
      }

      var re:RegExp = /^[a-zA-Z0-9]+\.sql$/;
      var r:Object = re.exec(name);

      if(r == null)
      {
        msg = new SFShowMessage(screen,"File names may may only contain [a-zA-Z0-9_], and must end with .sql");
        return;
      }

      var xml:XML = new XML("<command><function>savesql</function><parameter name=\"name\" value=\"" + name + "\" /></command>");

      xml.data = sql;

      currentCommand = "savesql";
      xmlconv.say(xml);
    }

    private function btnShowClick(e:MouseEvent):void
    {
      if(lstFiles.getSelectedIndex() < 0)
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Select a file first");
        return;
      }

      var name:String = lstFiles.getSelectedText();

      var req:URLRequest = new URLRequest("../sql/" + name);
      navigateToURL(req,"_blank");
    }

    private function btnLoadClick(e:MouseEvent):void
    {
      if(lstFiles.getSelectedIndex() < 0)
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Select a file first");
        return;
      }

      var name:String = lstFiles.getSelectedText();

      currentCommand = "getsqlfile";
      var xml:XML = new XML("<command><function>getsqlfile</function><parameter name=\"name\" value=\"" + name + "\" /></command>");

      xmlconv.say(xml);
    }

    private function btnDeleteClick(e:MouseEvent):void
    {
      if(lstFiles.getSelectedIndex() < 0)
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Select a file first");
        return;
      }

      var name:String = lstFiles.getSelectedText();

      currentCommand = "deletesql";
      var xml:XML = new XML("<command><function>deletesql</function><parameter name=\"name\" value=\"" + name + "\" /></command>");

      xmlconv.say(xml);
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

