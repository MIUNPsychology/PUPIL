package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class StudentsWin
  {
    private var screen:SFScreen = null;

    public var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var xmlconv:SFXMLConversation = null;

    private var getStudents:XML = <command><function>getallstudents</function></command>;

    private var currentCommand:String = "";

    private var lstStudents:SFList = null;

    private var txtLogin:SFTextField = null;
    private var txtPass:SFTextField = null;
    private var txtNewPass:SFTextField = null;

    private var students:Array = null;

    public function StudentsWin(myscreen:SFScreen, parentwin:TeacherMain)
    {
      screen = myscreen;
      myparent = parentwin;

      frmMain = new SFFrame(screen,200,30,420,430,"Student management");
      pnlMain = frmMain.getPanel();

      var lblStudent:SFLabel = new SFLabel(pnlMain,10,10,200,25,"Existing students");

      var lblLogin:SFLabel = new SFLabel(pnlMain,200,10,200,25,"Student login");
      txtLogin = new SFTextField(pnlMain,200,35,200,25);

      var lblPass:SFLabel = new SFLabel(pnlMain,200,70,200,25,"Student password");
      txtPass = new SFTextField(pnlMain,200,95,200,25);

      var btnAdd:SFButton = new SFButton(pnlMain,200,130,70,40,"Add",btnAddStudentClick);

      var lblNewPass:SFLabel = new SFLabel(pnlMain,200,200,200,25,"New password");
      txtNewPass = new SFTextField(pnlMain,200,225,200,25);
      var btnPass:SFButton = new SFButton(pnlMain,200,260,70,40,"Set",btnPassClick);

      var btnDelete:SFButton = new SFButton(pnlMain,10,350,120,40,"Delete",btnDeleteClick);
      var btnImport:SFButton = new SFButton(pnlMain,140,350,120,40,"Import",btnImportClick);
      var btnClose:SFButton = new SFButton(pnlMain,280,350,120,40,"Close",btnCloseClick);

      frmMain.registerTabComponent(txtLogin);
      frmMain.registerTabComponent(txtPass);
      frmMain.registerTabComponent(btnAdd);
      frmMain.registerTabComponent(txtNewPass);
      frmMain.registerTabComponent(btnPass);
      frmMain.registerTabComponent(btnDelete);
      frmMain.registerTabComponent(btnClose);

      frmMain.grabTabControl();

      screen.stage.focus = btnClose;

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getallstudents";
      xmlconv.say(getStudents);
    }

    public function reloadStudents():void
    {
      currentCommand = "getallstudents";
      xmlconv.say(getStudents);
    }

    private function btnPassClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnPassClick()");

      if(lstStudents.getSelectedIndex() < 0)
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Select a student first");
        return;
      }

      var student:String = lstStudents.getSelectedText();
      var pass:String = txtNewPass.getText();      

      var xml:String = "<command><function>updatestudent</function>";
      xml = xml + "<parameter name=\"login\" value=\"" + student + "\" />";
      xml = xml + "<parameter name=\"pass\" value=\"" + pass + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      //SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "updatestudent";
      xmlconv.say(cmd);
    }

    private function btnImportClick(e:MouseEvent):void
    {
      SFScreen.addDebug("btnImportClick()");
      var iw:ImportWin = new ImportWin(screen,this);
    }


    private function btnDeleteClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnDeleteClick()");

      if(lstStudents.getSelectedIndex() < 0)
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Select a student first");
        return;
      }

      var student:String = lstStudents.getSelectedText();

      var xml:String = "<command><function>deletestudent</function>";
      xml = xml + "<parameter name=\"login\" value=\"" + student + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      //SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "deletestudent";
      xmlconv.say(cmd);
    }



    private function btnAddStudentClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnAddStudentClick()");
      var login:String = txtLogin.getText();
      var pass:String = txtPass.getText();

      var xml:String = "<command><function>addstudent</function>";
      xml = xml + "<parameter name=\"login\" value=\"" + login + "\" />";
      xml = xml + "<parameter name=\"pass\" value=\"" + pass + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      //SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "addstudent";
      xmlconv.say(cmd);
    }

    private function btnCloseClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      screen.removeChild(frmMain);
      myparent.frmMain.grabTabControl();
    }

    private function onListSelect(index:Number = -1, text:String = null):void
    {
      //SFScreen.addDebug("List select: " + index + " " + text);
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
        var numelem:uint = 0;
        var data:XML = response.data[0];
        var row:XML = null;

        if(currentCommand == "updatestudent")
        {
          var msg:SFShowMessage = new SFShowMessage(screen,"Password updated");
        }


        if(currentCommand == "getallstudents")
        {
//          SFScreen.addDebug(response.toXMLString());
          students = new Array();

          var plogin:String;
          var ppass:String;

          for each (row in data.row)
          {
            //SFScreen.addDebug(row.column.(@name == "name"));
            plogin = row.column.(@name == "login");
            ppass = row.column.(@name == "pass");

            students[numelem++] = plogin;
          }

          if(lstStudents != null)
          {
            pnlMain.removeChild(lstStudents);
          }

          lstStudents = new SFList(pnlMain,10,35,180,300,students);
        }
        if(currentCommand == "addstudent")
        {
//          SFScreen.addDebug(response.toXMLString());
          txtLogin.setText("");
          txtPass.setText("");
          currentCommand = "getallstudents";
          xmlconv.say(getStudents);
        }
        if(currentCommand == "deletestudent")
        {
          txtLogin.setText("");
          txtPass.setText("");
          currentCommand = "getallstudents";
          xmlconv.say(getStudents);
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

