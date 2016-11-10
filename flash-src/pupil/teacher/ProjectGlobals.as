package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class ProjectGlobals
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:ProjectDetails = null;

    private var xmlconv:SFXMLConversation = null;

    private var currentCommand:String = "";
    private var currentName:String = "";

    private var chkInstructions:SFCheckBox = null;
    private var chkThankYou:SFCheckBox = null;

    private var txtUrl:SFTextField = null;
    private var txtInst1:SFTextField = null;
    private var txtInst2:SFTextField = null;
    private var txtInst3:SFTextField = null;
    private var txtThanks1:SFTextField = null;
    private var txtThanks2:SFTextField = null;
    private var txtThanks3:SFTextField = null;

    private var txtMaxHeight:SFTextField = null;
    private var txtMaxWidth:SFTextField = null;

    private var btnCancel:SFButton = null;

    private var chkFlashRight:SFCheckBox = null;
    private var chkFlashWrong:SFCheckBox = null;
    private var chkFlashWhite:SFCheckBox = null;
    private var chkHideText:SFCheckBox = null;
    private var chkSplice:SFCheckBox = null;

    private var chkBlockRandom:SFCheckBox = null;

    private var txtWhiteMin:SFTextField = null;
    private var txtWhiteMax:SFTextField = null;

    private var rbs:Array = new Array();
    private var rbg:SFRadioButtonGroup = null;

    private var txtSubSet:SFTextField = null;

    private var rightimg:String = "";
    private var wrongimg:String = "";
    private var pauseimg:String = "";

    private var cbxOnRight:SFComboBox = null;
    private var cbxOnWrong:SFComboBox = null;
    private var cbxOnPause:SFComboBox = null;

    public function ProjectGlobals(myscreen:SFScreen, parentwin:ProjectDetails, projectName:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projectName;

      frmMain = new SFFrame(screen,160,50,640,570,"Project settings");
      pnlMain = frmMain.getPanel();

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);

      var cmd:XML = new XML("<command><function>getprojectdetails</function><parameter name=\"name\" value=\"" + projectName + "\" /></command>");
      currentCommand = "getprojectdetails";
      xmlconv.say(cmd);
    }

    private function xmlComplete(e:Event):void
    {
      SFScreen.addDebug("complete " + currentCommand);
      var response:XML = xmlconv.getLastResponse();
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
        if(currentCommand == "updateproject")
        {
          screen.removeChild(frmMain);
          myparent.frmMain.grabTabControl();
        }

        if(currentCommand == "getallimages")
        {
//          SFScreen.addDebug(response.toXMLString());
          var imgs:Array = new Array();
          imgs[0] = "(don't use image)";

          var category:String;
          var file:String;

          data = response.data[0];

          for each (row in data.row)
          {          
            category = row.column.(@name == "category");
            file = row.column.(@name == "file_name");

            imgs[imgs.length] = category + "/" + file;
          }

          cbxOnRight = new SFComboBox(pnlMain,100,445,240,25,imgs);
          cbxOnWrong = new SFComboBox(pnlMain,100,475,240,25,imgs);
          cbxOnPause = new SFComboBox(pnlMain,100,505,240,25,imgs);

          var rightidx:Number = 0;
          var wrongidx:Number = 0;
          var pauseidx:Number = 0;

          var i:Number;

          SFScreen.addDebug("right: " + rightimg);
          SFScreen.addDebug("wrong: " + wrongimg);
          SFScreen.addDebug("pause: " + pauseimg);

          for(i = 1; i < imgs.length; i++)
          {
            if(imgs[i] == rightimg) { rightidx = i; }
            if(imgs[i] == wrongimg) { wrongidx = i; }
            if(imgs[i] == pauseimg) { pauseidx = i; }
          }

          cbxOnRight.setSelectedIndex(rightidx);
          cbxOnWrong.setSelectedIndex(wrongidx);
          cbxOnPause.setSelectedIndex(pauseidx);
        }

        if(currentCommand == "getprojectdetails")
        {
          data = response.data[0].row[0];
//          SFScreen.addDebug(data.toXMLString());

          var projname:String = "";
          var teachername:String = "";
          var count:String = "";

          projname = data.column.(@name == "name");
          teachername = data.column.(@name == "login");

          var displaywelcome:String = data.column.(@name == "displaywelcome");
          var displaythanks:String = data.column.(@name == "displaythanks");
          var welcometop:String = data.column.(@name == "welcometop");
          var welcomemid:String = data.column.(@name == "welcomemid");
          var welcomebottom:String = data.column.(@name == "welcomebottom");
          var thankstop:String = data.column.(@name == "thankstop");
          var thanksmid:String = data.column.(@name == "thanksmid");
          var thanksbottom:String = data.column.(@name == "thanksbottom");
          var urlredirect:String = data.column.(@name == "urlredirect");
          var maxwidth:String = data.column.(@name == "maxwidth");
          var maxheight:String = data.column.(@name == "maxheight");

          var flashright:String = data.column.(@name == "flashright");
          var flashwrong:String = data.column.(@name == "flashwrong");
          var displaypolicy:String = data.column.(@name == "displaypolicy");
          var subsetsize:String = data.column.(@name == "subsetsize");

          var hideopts:String = data.column.(@name == "hideopts");
          var flashwhite:String = data.column.(@name == "flashwhite");
          var whitemin:String = data.column.(@name == "whitemin");
          var whitemax:String = data.column.(@name == "whitemax");

          var blockrandom:String = data.column.(@name == "blockrandom");

          if(data.column.(@name == "rightimage") != "")
          {
            rightimg = data.column.(@name == "rightcategory") + "/" + data.column.(@name == "rightimage");
          }

          if(data.column.(@name == "wrongimage") != "")
          {
            wrongimg = data.column.(@name == "wrongcategory") + "/" + data.column.(@name == "wrongimage");
          }

          if(data.column.(@name == "pauseimage") != "")
          {
            pauseimg = data.column.(@name == "pausecategory") + "/" + data.column.(@name == "pauseimage");
          }

          var splicearray:String = data.column.(@name == "splicearray");

          chkInstructions = new SFCheckBox(pnlMain,10,10,150,25,"Display instruction screen");
          if(displaywelcome == "1") { chkInstructions.check(); }

          var lblInstTop:SFLabel = new SFLabel(pnlMain,20,35,70,25,"Top");
          var lblInstMid:SFLabel = new SFLabel(pnlMain,20,60,70,25,"Middle");
          var lblInstBottom:SFLabel = new SFLabel(pnlMain,20,85,70,25,"Bottom");

          txtInst1 = new SFTextField(pnlMain,100,35,200,25,welcometop);
          txtInst2 = new SFTextField(pnlMain,100,60,200,25,welcomemid);
          txtInst3 = new SFTextField(pnlMain,100,85,200,25,welcomebottom);

          chkThankYou = new SFCheckBox(pnlMain,330,10,150,25,"Display thank you screen");
          if(displaythanks == "1") { chkThankYou.check(); }

          var lblThanksTop:SFLabel = new SFLabel(pnlMain,340,35,70,25,"Top");
          var lblThanksMid:SFLabel = new SFLabel(pnlMain,340,60,70,25,"Middle");
          var lblThanksBottom:SFLabel = new SFLabel(pnlMain,340,85,70,25,"Bottom");

          txtThanks1 = new SFTextField(pnlMain,420,35,200,25,thankstop);
          txtThanks2 = new SFTextField(pnlMain,420,60,200,25,thanksmid);
          txtThanks3 = new SFTextField(pnlMain,420,85,200,25,thanksbottom);

          var lblURL:SFLabel = new SFLabel(pnlMain,10,130,200,25,"URL to redirect to when done");
          txtUrl = new SFTextField(pnlMain,10,155,200,25,urlredirect);

          var lblArea:SFLabel = new SFLabel(pnlMain,330,130,200,25,"Layout area size (0 = window)");
          var lblWidth:SFLabel = new SFLabel(pnlMain,340,155,70,25,"Width");
          var lblHeight:SFLabel = new SFLabel(pnlMain,340,180,70,25,"Height");

          txtMaxWidth = new SFTextField(pnlMain,420,155,200,25,maxwidth);
          txtMaxHeight = new SFTextField(pnlMain,420,180,200,25,maxheight);

          chkFlashRight = new SFCheckBox(pnlMain,330,225,155,25,"Flash green if correct answer");
          if(flashright == "1")
          {
            chkFlashRight.check();
          }

          chkFlashWrong = new SFCheckBox(pnlMain,330,250,155,25,"Flash red if wrong answer");
          if(flashwrong == "1")
          {
            chkFlashWrong.check();
          }

          chkHideText = new SFCheckBox(pnlMain,330,275,155,25,"Always hide option texts");      
          if(hideopts == "1")
          {
            chkHideText.check();
          }

          chkFlashWhite = new SFCheckBox(pnlMain,330,300,155,25,"Random white pause between scenes");
          if(flashwhite == "1")
          {
            chkFlashWhite.check();
          }

          var lblWhiteMin:SFLabel = new SFLabel(pnlMain,350,330,155,25,"Min");
          var lblWhiteMax:SFLabel = new SFLabel(pnlMain,350,360,155,25,"Max");

          txtWhiteMin = new SFTextField(pnlMain,390,330,155,25,whitemin);
          txtWhiteMax = new SFTextField(pnlMain,390,360,155,25,whitemax);

          var lblDisplay:SFLabel = new SFLabel(pnlMain,10,200,180,25,"Display policy");

          rbs[0] = new SFRadioButton(pnlMain,10,225,180,25,"Display all scenes, in order");
          rbs[1] = new SFRadioButton(pnlMain,10,250,180,25,"Display all scenes, randomly");
          rbs[2] = new SFRadioButton(pnlMain,10,275,180,25,"Display a subset randomly");

          rbg = new SFRadioButtonGroup(rbs);

          var lblSubset:SFLabel = new SFLabel(pnlMain,10,310,180,25,"Subset size");
          txtSubSet = new SFTextField(pnlMain,10,335,200,25,"0");

          SFRadioButton(rbs[0]).check();
          if(displaypolicy == "2") { SFRadioButton(rbs[1]).check(); }
          if(displaypolicy == "3") 
          { 
            SFRadioButton(rbs[2]).check(); 
            txtSubSet.setText(subsetsize);
          }

          chkSplice = new SFCheckBox(pnlMain,10,380,200,25,"Splice category array on randomization");
          if(splicearray == "1")
          {
            chkSplice.check();
          }

          var lblUseImg:SFLabel = new SFLabel(pnlMain,10,420,300,25,"Use images instead of single color");
          var lblOnRight:SFLabel = new SFLabel(pnlMain,20,445,200,25,"On right");
          var lblOnWrong:SFLabel = new SFLabel(pnlMain,20,475,200,25,"On wrong");
          var lblOnPause:SFLabel = new SFLabel(pnlMain,20,505,200,25,"Interstimuli");

          chkBlockRandom = new SFCheckBox(pnlMain,370,440,200,25,"Randomize blocks");

          if(blockrandom == "1")
          {
            chkBlockRandom.check();
          }

          var btnOk:SFButton = new SFButton(pnlMain,370,490,120,40,"OK",okClick);
          btnCancel = new SFButton(pnlMain,500,490,120,40,"Cancel",cancelClick);

          //screen.stage.focus = btnCancel;
          
          frmMain.registerTabComponent(txtInst1);
          frmMain.registerTabComponent(txtInst2);
          frmMain.registerTabComponent(txtInst3);
          frmMain.registerTabComponent(txtThanks1);
          frmMain.registerTabComponent(txtThanks2);
          frmMain.registerTabComponent(txtThanks3);
          frmMain.registerTabComponent(txtUrl);
          frmMain.registerTabComponent(txtMaxWidth);
          frmMain.registerTabComponent(txtMaxHeight);
          frmMain.registerTabComponent(txtSubSet);
          frmMain.registerTabComponent(txtWhiteMin);
          frmMain.registerTabComponent(txtWhiteMax);
          frmMain.registerTabComponent(btnOk);
          frmMain.registerTabComponent(btnCancel);

          frmMain.grabTabControl();
          var getImgs:XML = new XML("<command><function>getallimages</function><parameter name=\"project\" value=\"" + currentName + "\" /></command>");
          currentCommand = "getallimages";
          xmlconv.say(getImgs);
        }
      }
    }

    private function okClick(e:MouseEvent):void
    {
      var xml:String = "<command><function>updateproject</function>";

      frmMain.releaseTabControl();

      xml = xml + "<parameter name=\"name\" value=\"" + currentName+ "\" />";
      if(chkInstructions.isChecked())
      {
        xml = xml + "<parameter name=\"displaywelcome\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"displaywelcome\" value=\"0\" />";
      }

      if(chkThankYou.isChecked())
      {
        xml = xml + "<parameter name=\"displaythanks\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"displaythanks\" value=\"0\" />";
      }

      xml = xml + "<parameter name=\"welcometop\" value=\"" + txtInst1.getText() + "\" />";
      xml = xml + "<parameter name=\"welcomemid\" value=\"" + txtInst2.getText() + "\" />";
      xml = xml + "<parameter name=\"welcomebottom\" value=\"" + txtInst3.getText() + "\" />";
      xml = xml + "<parameter name=\"thankstop\" value=\"" + txtThanks1.getText() + "\" />";
      xml = xml + "<parameter name=\"thanksmid\" value=\"" + txtThanks2.getText() + "\" />";
      xml = xml + "<parameter name=\"thanksbottom\" value=\"" + txtThanks3.getText() + "\" />";
      xml = xml + "<parameter name=\"urlredirect\" value=\"" + txtUrl.getText() + "\" />";
      xml = xml + "<parameter name=\"maxwidth\" value=\"" + txtMaxWidth.getText() + "\" />";
      xml = xml + "<parameter name=\"maxheight\" value=\"" + txtMaxHeight.getText() + "\" />";

      if(chkBlockRandom.isChecked())
      {
        xml = xml + "<parameter name=\"blockrandom\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"blockrandom\" value=\"0\" />";
      }

      if(chkFlashRight.isChecked())
      {
        xml = xml + "<parameter name=\"flashright\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"flashright\" value=\"0\" />";
      }

      if(chkFlashWrong.isChecked())
      {
        xml = xml + "<parameter name=\"flashwrong\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"flashwrong\" value=\"0\" />";
      }

      xml = xml + "<parameter name=\"displaypolicy\" value=\"" + (rbg.getCheckedIndex() + 1) + "\" />";
      xml = xml + "<parameter name=\"subsetsize\" value=\"" + txtSubSet.getText() + "\" />";

      if(chkHideText.isChecked())
      {
        xml = xml + "<parameter name=\"hideopts\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"hideopts\" value=\"0\" />";
      }

      if(chkFlashWhite.isChecked())
      {
        xml = xml + "<parameter name=\"flashwhite\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"flashwhite\" value=\"0\" />";
      }

      if(chkSplice.isChecked())
      {
        xml = xml + "<parameter name=\"splicearray\" value=\"1\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"splicearray\" value=\"0\" />";
      }

      xml = xml + "<parameter name=\"whitemin\" value=\"" + txtWhiteMin.getText() + "\" />";
      xml = xml + "<parameter name=\"whitemax\" value=\"" + txtWhiteMax.getText() + "\" />";

      if(cbxOnRight.getSelectedIndex() > 0)
      {
        xml = xml + "<parameter name=\"rightimage\" value=\"" + cbxOnRight.getSelectedText() + "\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"rightimage\" value=\"\" />";
      }

      if(cbxOnWrong.getSelectedIndex() > 0)
      {
        xml = xml + "<parameter name=\"wrongimage\" value=\"" + cbxOnWrong.getSelectedText() + "\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"wrongimage\" value=\"\" />";
      }

      if(cbxOnPause.getSelectedIndex() > 0)
      {
        xml = xml + "<parameter name=\"pauseimage\" value=\"" + cbxOnPause.getSelectedText() + "\" />";
      }
      else
      {
        xml = xml + "<parameter name=\"pauseimage\" value=\"\" />";
      }


      xml = xml + "</command>";

      var cmd:XML = new XML(xml);
      currentCommand = "updateproject";
      SFScreen.addDebug(cmd.toXMLString());
      xmlconv.say(cmd);

//      screen.removeChild(frmMain);
    }

    private function cancelClick(e:MouseEvent):void
    {
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

