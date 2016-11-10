package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class CloneProjectWin
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var txtProject:SFTextField = null;
    private var txtDesc:SFTextField = null;

    private var old:String;

    public function CloneProjectWin(myscreen:SFScreen, parentwin:TeacherMain, oldName:String)
    {
      screen = myscreen;
      myparent = parentwin;
      old = oldName;

      frmMain = new SFFrame(screen,300,130,380,200,"Clone Project \"" + oldName + "\"");
      pnlMain = frmMain.getPanel();

      var lblProject:SFLabel = new SFLabel(pnlMain,10,10,350,20,"New project name (alphanumeric, no spaces, unique)");
      var lblDesc:SFLabel = new SFLabel(pnlMain,10,60,150,20,"New project description ");

      txtProject = new SFTextField(pnlMain,10,30,350);
      txtDesc = new SFTextField(pnlMain,10,80,350);

      var btnOK:SFButton = new SFButton(pnlMain,10,115,100,40,"OK",btnOKClick);
      var btnCancel:SFButton = new SFButton(pnlMain,260,115,100,40,"Cancel",btnCancelClick);

      frmMain.registerTabComponent(txtProject);
      frmMain.registerTabComponent(txtDesc);
      frmMain.registerTabComponent(btnOK);
      frmMain.registerTabComponent(btnCancel);
      
      frmMain.grabTabControl();
    }

    private function btnOKClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnOKClick()");
      var prjname:String = txtProject.getText();
      var msg:SFShowMessage;

      if(prjname == "")
      {
        msg = new SFShowMessage(screen,"Please enter a project name");
        return;
      }

      var re:RegExp = /[^a-z0-9]/g;

      if(re.test(prjname))
      {
        msg = new SFShowMessage(screen,"Project names may not contain spaces and only contain a-z and 0-9");
        return;
      }

      frmMain.releaseTabControl();
      screen.removeChild(frmMain);
      myparent.frmMain.grabTabControl();
      myparent.cloneProject(txtProject.getText(),txtDesc.getText(),old);
    }

    private function btnCancelClick(e:MouseEvent):void
    {
      //SFScreen.addDebug("btnCancelClick()");
      frmMain.releaseTabControl();
      screen.removeChild(frmMain);
      myparent.frmMain.grabTabControl();
    }
  }
}

