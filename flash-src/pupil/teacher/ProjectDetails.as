package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class ProjectDetails
  {
    private var screen:SFScreen = null;

    public var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var xmlconv:SFXMLConversation = null;

    private var currentCommand:String = "";
    private var currentName:String = "";

    private var lblProjName:SFLabel = null;
    private var lblTeacherName:SFLabel = null;
    private var lblSceneCount:SFLabel = null;

    private var txtClone:SFTextField = null;

    private var lstScenes:SFList = null;
    private var lastPos:uint = 0;
    private var lastSel:uint = 0;

/*    private var rbsTypes:SFRadioButtonGroup = null;
    private var rbsPatterns:SFRadioButtonGroup = null;*/

    private var chkTypes:SFComboBox = null;
    private var chkPatterns:SFComboBox = null;

    public function ProjectDetails(myscreen:SFScreen, parentwin:TeacherMain, projectName:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projectName;

      frmMain = new SFFrame(screen,200,50,540,550,"Project details");
      pnlMain = frmMain.getPanel();

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);

      var lbl1:SFLabel = new SFLabel(pnlMain,10,10,150,20,"Project name");
      var lbl2:SFLabel = new SFLabel(pnlMain,10,30,150,20,"Created by");
      var lbl3:SFLabel = new SFLabel(pnlMain,10,50,150,20,"Number of scenes");
      var lbl4:SFLabel = new SFLabel(pnlMain,10,90,150,20,"Existing senes");
      var lbl7:SFLabel = new SFLabel(pnlMain,270,345,200,20,"Batch replace material",true);

      var btnCreate:SFButton = new SFButton(pnlMain,270,205,120,40,"Create",btnCreateClick);
      var btnGlobals:SFButton = new SFButton(pnlMain,270,280,120,40,"Globals",btnSettingsClick);
      var btnBlocks:SFButton = new SFButton(pnlMain,400,280,120,40,"Blocks",btnBlocksClick);
      var btnCatReplace:SFButton = new SFButton(pnlMain,270,370,120,40,"Category",btnCatReplaceClick);
      var btnImgReplace:SFButton = new SFButton(pnlMain,400,370,120,40,"Image",btnImgReplaceClick);
      var btnClose:SFButton = new SFButton(pnlMain,400,470,120,40,"Close",btnCloseClick);

      var btnClone:SFButton = new SFButton(pnlMain,10,470,80,40,"Copy",btnCloneClick);
      var btnEdit:SFButton = new SFButton(pnlMain,95,470,80,40,"Edit",btnEditClick);
      var btnDelete:SFButton = new SFButton(pnlMain,180,470,80,40,"Del",btnDeleteClick);

      var rbs:Array = new Array();
      rbs[0] = "Static image";
      rbs[1] = "Static category, random image";
      rbs[2] = "Select option, static image";
      rbs[3] = "Select option, random image";
      rbs[4] = "Text";

      var patt:Array = new Array();

      patt[0]  = "(1) single_centered";
      patt[1]  = "(1) single_stretched";
      patt[2]  = "(2) 2x1";
      patt[3]  = "(3) 3x1";
      patt[4]  = "(3) 1+2";
      patt[5]  = "(3) 2+1";
      patt[6]  = "(4) 2x2";
      patt[7]  = "(4) 4_as_plus";
      patt[8]  = "(5) 5_as_x";
      patt[9]  = "(5) 5_as_plus";
      patt[10] = "(6) 3x2";
      patt[11] = "(7) 3+1+3";
      patt[12] = "(8) 3+2+3";
      patt[13] = "(9) 3x3";

      var lbl5:SFLabel = new SFLabel(pnlMain,270,85,150,20,"Create scene of type:");
      chkTypes = new SFComboBox(pnlMain,270,110,250,25,rbs);
      var lbl6:SFLabel = new SFLabel(pnlMain,270,145,250,20,"...with image pattern:");
      chkPatterns = new SFComboBox(pnlMain,270,170,250,25,patt);

      chkTypes.setSelectedIndex(0);
      chkPatterns.setSelectedIndex(0);

      var lblClone:SFLabel = new SFLabel(pnlMain,10,415,250,25,"New name for clone");
      txtClone = new SFTextField(pnlMain,10,435,250,25);

      frmMain.registerTabComponent(btnCreate);
      frmMain.registerTabComponent(btnGlobals);
      frmMain.registerTabComponent(btnClone);
      frmMain.registerTabComponent(btnDelete);
      frmMain.registerTabComponent(btnClose);

      frmMain.grabTabControl();

      var cmd:XML = new XML("<command><function>getprojectdetails</function><parameter name=\"name\" value=\"" + projectName + "\" /></command>");
      currentCommand = "getprojectdetails";
      xmlconv.say(cmd);
    }

    private function onListSelect(index:Number = -1, text:String = null):void
    {
//      SFScreen.addDebug("List select: " + index + " " + text);

      if(index >= 0)
      {
        var arr:Array = text.split(" [");
        var name:String = arr[0];
        txtClone.setText(name);
      }
    }

    private function btnBlocksClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      var blk:BlockMain = new BlockMain(screen,this,currentName);
    }


    private function btnSettingsClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      var gbl:ProjectGlobals = new ProjectGlobals(screen,this,currentName);
    }

    private function btnEditClick(e:MouseEvent):void
    {
      SFScreen.addDebug("Edit");
      if(lstScenes.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a scene first");
      }
      else
      {
        var seltxt:String = lstScenes.getSelectedText();
        var arr:Array = seltxt.split(" [");
        var name:String = arr[0];
        var desc:String = arr[1];

        var arr2:Array = desc.split(" ");

        SFScreen.addDebug("selected name is " + name);

        var type:String = arr2[0];

        SFScreen.addDebug("selected type is " + type);

        var pattern:String = arr2[1];

        var reg:RegExp = /\]/;  
        
        pattern = pattern.replace(reg, "");  

        SFScreen.addDebug("pattern is " + pattern);

        var msg:SFShowMessage;

        if(type == "static_image")
        {
          var ssi:EditSelectStaticImage = new EditSelectStaticImage(screen,this,pattern,name,currentName);
        }
        if(type == "static_category_random_image")
        {
          var scri:EditStaticCategoryRandomImage = new EditStaticCategoryRandomImage(screen,this,pattern,name,currentName);
        }
        if(type == "select_option_static_image")
        {
          var osi:EditOptionStaticImage = new EditOptionStaticImage(screen,this,pattern,name,currentName);
        }
        if(type == "select_option_random_image")
        {
          var ori:EditOptionRandomImage = new EditOptionRandomImage(screen,this,pattern,name,currentName);
        }
        if(type == "text")
        {
          var txt:EditText = new EditText(screen,this,name,currentName);
        }
      }
    }


    private function btnCloneClick(e:MouseEvent):void
    {
      SFScreen.addDebug("btnCloneClick()");
      if(lstScenes.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a scene first");
      }
      else
      {
        var vertb:SFVerticalScrollBar = lstScenes.getVerticalScrollBar();

        if(vertb != null)
        {
          lastPos = vertb.getPos();
        }
        else
        {
          lastPos = 0;
        }
        lastSel = lstScenes.getSelectedIndex();

        var seltxt:String = lstScenes.getSelectedText();
        var arr:Array = seltxt.split(" [");
        var name:String = arr[0];
        SFScreen.addDebug("selected name is " + name);
        var clone:String = txtClone.getText();

        var msg:SFShowMessage;

        if(clone == "")
        {
          msg = new SFShowMessage(screen,"Clone name cannot be empty");
          return;
        }

        if(clone == name)
        {
          msg = new SFShowMessage(screen,"Clone name cannot be equal to original scene name");
          return;
        }

        var xml:String = "<command><function>clonescene</function>";
        xml = xml + "<parameter name=\"original\" value=\"" + name + "\" />";
        xml = xml + "<parameter name=\"clone\" value=\"" + clone + "\" />";
        xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
        xml = xml + "</command>";

        currentCommand = "clonescene";
        var cmd:XML = new XML(xml);
        SFScreen.addDebug(cmd.toXMLString());
        xmlconv.say(cmd);
      }
    }

    private function btnDeleteClick(e:MouseEvent):void
    {
//      SFScreen.addDebug("Delete");
      if(lstScenes.getSelectedIndex() < 0)
      {
        var s:SFShowMessage = new SFShowMessage(screen,"Please select a scene first");
      }
      else
      {
        var seltxt:String = lstScenes.getSelectedText();
        var arr:Array = seltxt.split(" [");
        var name:String = arr[0];
//        SFScreen.addDebug("selected name is " + name);

        var xml:String = "<command><function>deletescene</function><parameter name=\"scene\" value=\"" + name + "\" />";
        xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
        xml = xml + "</command>";

        var cmd:XML = new XML(xml);
//        SFScreen.addDebug(cmd.toXMLString());
        currentCommand = "deletescene";
        xmlconv.say(cmd);
      }
    }

    private function btnCatReplaceClick(e:MouseEvent):void
    {
      SFScreen.addDebug("catrep");
      var rc:ReplaceCategory = new ReplaceCategory(screen,this,currentName);
    }

    private function btnImgReplaceClick(e:MouseEvent):void
    {
      SFScreen.addDebug("imgrep");
      var ri:ReplaceImage = new ReplaceImage(screen,this,currentName);
    }

    private function btnCreateClick(e:MouseEvent):void
    {
      var msg:SFShowMessage;

      if(chkTypes.getSelectedIndex() < 0)
      {
        msg = new SFShowMessage(screen,"Please select a scene type");
        return;
      }

      if(chkPatterns.getSelectedIndex() < 0)
      {
        msg = new SFShowMessage(screen,"Please select a pattern");
        return;
      }

      var type:Number = chkTypes.getSelectedIndex();

      var patternTmp:String = chkPatterns.getSelectedText();
      var pattarr:Array = patternTmp.split(") ");
      var pattern:String = pattarr[1];
      var pattimg:String = pattarr[0];

      var paren:RegExp = /\(/;
      pattimg = pattimg.replace(paren,"");

      frmMain.releaseTabControl();

      if(type == 0)
      {
        var ssi:SelectStaticImage = new SelectStaticImage(screen,this,pattern,currentName);
      }
      if(type == 1)
      {
        var scri:StaticCategoryRandomImage = new StaticCategoryRandomImage(screen,this,pattern,currentName);
      }
      if(type == 2)
      {
        var osi:OptionStaticImage = new OptionStaticImage(screen,this,pattern,currentName);
      }
      if(type == 3)
      {
        var ori:OptionRandomImage = new OptionRandomImage(screen,this,pattern,currentName);
      }
      if(type == 4)
      {
        var txt:TextScene = new TextScene(screen,this,currentName);
      }
    }

    public function updateScenes():void
    {
      currentCommand = "getscenelist";
      var cmd:XML = new XML("<command><function>getscenelist</function><parameter name=\"name\" value=\"" + currentName + "\" /></command>");
      xmlconv.say(cmd);
    }


    private function btnCloseClick(e:MouseEvent):void
    {
      frmMain.releaseTabControl();
      screen.removeChild(frmMain);
      myparent.frmMain.grabTabControl();
    }

    private function xmlComplete(e:Event):void
    {
//      SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
//      SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();

      var data:XML;
      var row:XML = null;
      var arr:Array = new Array();
      var numelem:uint = 0;

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        if(currentCommand == "getscenelist")
        {
          if(lstScenes != null)
          {
            pnlMain.removeChild(lstScenes);
          }
//          SFScreen.addDebug(response.toXMLString());

          data = response.data[0];

          var description:String;
          var scenetype:String;
          var pattern:String;

          for each (row in data.row)
          {          
            description = row.column.(@name == "description");
            scenetype = row.column.(@name == "scenetype");
            pattern = row.column.(@name == "pattern");

            arr[numelem++] = description + " [" + scenetype + " " + pattern + "]";
          }

          if(lblSceneCount != null)
          {
            pnlMain.removeChild(lblSceneCount);
          }

          lblSceneCount = new SFLabel(pnlMain,160,50,250,20,"" + numelem,true);

          lstScenes = new SFList(pnlMain,10,110,250,300,arr,SFComponent.BEVEL_NONE,onListSelect);
          var vertb:SFVerticalScrollBar = lstScenes.getVerticalScrollBar();
          if(lastPos > 0)
          {
            vertb.setPos(lastPos);
          }
          if(lastSel > 0)
          {
            lstScenes.setSelectedIndex(lastSel);
          }
        }
        if(currentCommand == "getprojectdetails")
        {
          data = response.data[0].row[0];

          var projname:String = "";
          var teachername:String = "";

          projname = data.column.(@name == "name");
          teachername = data.column.(@name == "login");

          if(lblProjName != null)
          {
            pnlMain.removeChild(lblProjName);
          }

          lblProjName = new SFLabel(pnlMain,160,10,250,20,projname,true);

          if(lblTeacherName != null)
          {
            pnlMain.removeChild(lblTeacherName);
          }

          lblTeacherName = new SFLabel(pnlMain,160,30,250,20,teachername,true);

          currentCommand = "getscenelist";
          var cmd:XML = new XML("<command><function>getscenelist</function><parameter name=\"name\" value=\"" + projname + "\" /></command>");
          xmlconv.say(cmd);
        }
        if(currentCommand == "deletescene")
        {
          updateScenes();
        }
        if(currentCommand == "clonescene")
        {
          txtClone.setText("");
          updateScenes();
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

