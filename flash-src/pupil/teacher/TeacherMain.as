package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class TeacherMain
  {
    public static var patterns:Object = new Object();

    private var screen:SFScreen = null;

    private var xmlconv:SFXMLConversation = null;

    private var lstProject:SFList = null;

    private var listelements:Array = new Array();
    public var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;

    private var currentCommand:String = "";
    private var tmpstr:String = "";

    private var xmlGetProjectList:XML = <command><function>getprojectlist</function></command>;

    public function TeacherMain(myscreen:SFScreen)
    {
      screen = myscreen;

      patterns["single_centered"] = 1;
      patterns["single_stretched"] = 1;
      patterns["2x1"] = 2;
      patterns["3x1"] = 3;
      patterns["1+2"] = 3;
      patterns["2+1"] = 3;
      patterns["2x2"] = 4;
      patterns["4_as_plus"] = 4;
      patterns["5_as_x"] = 5;
      patterns["5_as_plus"] = 5;
      patterns["3x2"] = 6;
      patterns["3+1+3"] = 7;
      patterns["3+2+3"] = 8;
      patterns["3x3"] = 9;

      frmMain = new SFFrame(screen,240,30,590,510,"Project");
      pnlMain = frmMain.getPanel();

      var lblProject:SFLabel = new SFLabel(pnlMain,10,10,150,20,"Existing projects");

      var btnNew:SFButton = new SFButton(pnlMain,450,30,120,40,"New",btnNewClick);
      var btnEdit:SFButton = new SFButton(pnlMain,450,80,120,40,"Edit",btnEditClick);
      var btnData:SFButton = new SFButton(pnlMain,450,130,120,40,"Data",btnDataClick);
      var btnDelete:SFButton = new SFButton(pnlMain,450,180,120,40,"Delete",btnDeleteClick);
      var btnStudents:SFButton = new SFButton(pnlMain,450,230,120,40,"Students",btnStudentsClick);
      var btnImages:SFButton = new SFButton(pnlMain,450,280,120,40,"Images",btnImagesClick);

      var btnSQL:SFButton = new SFButton(pnlMain,450,330,120,40,"SQL",btnSQLClick);
      var btnPermissions:SFButton = new SFButton(pnlMain,450,380,120,40,"Permissions",btnPermissionsClick);
      var btnClone:SFButton = new SFButton(pnlMain,450,430,120,40,"Clone",btnCloneClick);

      frmMain.registerTabComponent(btnNew);
      frmMain.registerTabComponent(btnEdit);
      frmMain.registerTabComponent(btnData);
      frmMain.registerTabComponent(btnDelete);
      frmMain.registerTabComponent(btnPermissions);
      frmMain.registerTabComponent(btnImages);
      frmMain.registerTabComponent(btnSQL);
      frmMain.registerTabComponent(btnPermissions);
      frmMain.registerTabComponent(btnClone);

      frmMain.grabTabControl();

      var lblLoading:SFLabel = new SFLabel(pnlMain,80,170,100,40,"Loading...");

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);

      currentCommand = "getprojectlist";
      xmlconv.say(xmlGetProjectList);
    }

    private function btnNewClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      //SFScreen.addDebug("btnNewClick() -- not implemented");
      var np:NewProjectWin = new NewProjectWin(screen,this);
    }

    private function btnCloneClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
      }
      else
      {
        var seltxt:String = lstProject.getSelectedText();
        var arr:Array = seltxt.split(" -- ");
        var name:String = arr[0];
        SFScreen.addDebug("selected name is " + name);

        frmMain.releaseTabControl();
        var clonewin:CloneProjectWin = new CloneProjectWin(screen,this,name);
      }
    }

    private function btnEditClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
      }
      else
      {
        var seltxt:String = lstProject.getSelectedText();
        var arr:Array = seltxt.split(" -- ");
        var name:String = arr[0];
        // SFScreen.addDebug("selected name is " + name);

        frmMain.releaseTabControl();
        var pd:ProjectDetails = new ProjectDetails(screen,this,name);
      }
        
//      SFScreen.addDebug("btnEditClick() -- not implemented");
    }

    private function btnSQLClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      var dw:SQLWin = new SQLWin(screen,this);
    }

    private function btnDataClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
      }
      else
      {
        var seltxt:String = lstProject.getSelectedText();
        var arr:Array = seltxt.split(" -- ");
        var name:String = arr[0];
        // SFScreen.addDebug("selected name is " + name);

        frmMain.releaseTabControl();
        var dw:DataWin = new DataWin(screen,this,name);
      }
    }

    private function btnDeleteClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
      }
      else
      {
        var seltxt:String = lstProject.getSelectedText();
        var arr:Array = seltxt.split(" -- ");
        var name:String = arr[0];
        SFScreen.addDebug("selected name is " + name);

        var cmd:XML = new XML("<command><function>deleteproject</function><parameter name=\"name\" value=\"" + name + "\" /></command>");
//        SFScreen.addDebug(cmd.toXMLString());
        currentCommand = "deleteproject";
        xmlconv.say(cmd);
      }
    }

    private function btnStudentsClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      var sw:StudentsWin = new StudentsWin(screen,this);
    }

    private function btnImagesClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
      }
      else
      {
        var seltxt:String = lstProject.getSelectedText();
        var arr:Array = seltxt.split(" -- ");
        var name:String = arr[0];
        // SFScreen.addDebug("selected name is " + name);

        frmMain.releaseTabControl();
        //      SFScreen.addDebug("btnImagesClick() -- not implemented");      
        var imgw:ImagesWin = new ImagesWin(screen,this,name);
      }
    }

    private function btnPermissionsClick(e:MouseEvent):void
    {
      if(lstProject.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a project first");
      }
      else
      {
        var seltxt:String = lstProject.getSelectedText();
        var arr:Array = seltxt.split(" -- ");
        var name:String = arr[0];
        SFScreen.addDebug("selected name is " + name);

        frmMain.releaseTabControl();
        var permw:PermissionsWin = new PermissionsWin(screen,this,name);
      }
    }


    public function createProject(name:String, desc:String):void
    {
      var cmd:XML = new XML("<command><function>createproject</function><parameter name=\"name\" value=\"" + name + "\" /><parameter name=\"description\" value=\"" + desc + "\" /></command>");      

//      SFScreen.addDebug(cmd.toXMLString());

      tmpstr = name + " -- " + desc;
      currentCommand = "createproject";

      xmlconv.say(cmd);
    }

    public function cloneProject(name:String, desc:String, oldName:String):void
    {
      var xmls:String = "<command><function>cloneproject</function>";
      xmls = xmls + "<parameter name=\"name\" value=\"" + name + "\" />";
      xmls = xmls + "<parameter name=\"description\" value=\"" + desc + "\" />";
      xmls = xmls + "<parameter name=\"oldname\" value=\"" + oldName + "\" />";
      xmls = xmls + "</command>";

      var cmd:XML = new XML(xmls);      

      SFScreen.addDebug(cmd.toXMLString());

      currentCommand = "cloneproject";

      xmlconv.say(cmd);
    }


    private function updateProjectList():void
    {
      if(lstProject != null)
      {
        pnlMain.removeChild(lstProject);
      }

      lstProject = new SFList(pnlMain,10,30,425,440,listelements,SFComponent.BEVEL_DOWN);
    }


    private function javaTest(e:MouseEvent):void
    {

      var somexml:XML = <hej>hopp</hej>;

      xmlconv.say(somexml);
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
        if(currentCommand == "getprojectlist")
        {
          listelements = new Array();
          var numelem:uint = 0;

          var data:XML = response.data[0];

          var pname:String;
          var pdesc:String;

          for each (var row:XML in data.row)
          {          
            //SFScreen.addDebug(row.column.(@name == "name"));
            pname = row.column.(@name == "name");
            pdesc = row.column.(@name == "description");

            listelements[numelem++] = pname + " -- " + pdesc;
          }

          updateProjectList();
        }
        if(currentCommand == "createproject")
        {
          currentCommand = "getprojectlist";
          xmlconv.say(xmlGetProjectList);
        }
        if(currentCommand == "deleteproject")
        {
          currentCommand = "getprojectlist";
          xmlconv.say(xmlGetProjectList);
        }
        if(currentCommand == "cloneproject")
        {
          currentCommand = "getprojectlist";
          xmlconv.say(xmlGetProjectList);
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

