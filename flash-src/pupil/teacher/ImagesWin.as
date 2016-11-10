package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class ImagesWin
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:TeacherMain = null;

    private var lstCat:SFList = null;
    private var lstImg:SFList = null;

    private var prgUpload:SFProgressBar = null;
    private var fup:SFFileUpload = null;

    private var xmlconv:SFXMLConversation = null;

    private var getCats:XML = null;

    private var categorylist:Array = null;
    private var currentCommand:String = "";

    private var txtNewCat:SFTextField = null;

    private var project:String = null;

    public function ImagesWin(myscreen:SFScreen, parentwin:TeacherMain, aproject:String)
    {
      screen = myscreen;
      myparent = parentwin;

      project = aproject;

      getCats = new XML("<command><function>getcategorylist</function><parameter name=\"project\" value=\"" + project + "\" /></command>");

      frmMain = new SFFrame(screen,200,30,380,460,"Image management");
      pnlMain = frmMain.getPanel();

      var lblCat:SFLabel = new SFLabel(pnlMain,10,10,150,25,"Categories");
      var lblImg:SFLabel = new SFLabel(pnlMain,10,195,150,25,"Images in category");
      var lblNewCat:SFLabel = new SFLabel(pnlMain,220,10,150,25,"New category name");

      txtNewCat = new SFTextField(pnlMain,220,35,150);

      var btnAddCat:SFButton = new SFButton(pnlMain,220,70,120,40,"Add category",btnAddCatClick);
      var btnDelCat:SFButton = new SFButton(pnlMain,220,120,120,40,"Delete category",btnDelCatClick);
      var btnAddImg:SFButton = new SFButton(pnlMain,220,220,120,40,"Add image",btnAddImgClick);
      var btnDelImg:SFButton = new SFButton(pnlMain,220,270,120,40,"Delete image",btnDelImgClick);
      var btnClose:SFButton = new SFButton(pnlMain,220,380,120,40,"Done",btnCloseClick);

      var lblProgress:SFLabel = new SFLabel(pnlMain,10,380,150,25,"Progress");

      prgUpload = new SFProgressBar(pnlMain,10,405,200,15);

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getcategorylist";
      xmlconv.say(getCats);
    }

    public function atSelect(e:Event = null):void
    {
      // SFScreen.addDebug("onSelect()");
      fup.doUpload();
    }

    private function atCancel(e:Event):void
    {
      SFScreen.addDebug("onCancel()");

    }

    private function atComplete(e:Event):void
    {
      // SFScreen.addDebug("onComplete()");
      prgUpload.setPos(100);

      var msg:SFShowMessage = new SFShowMessage(screen,"Image successfully uploaded");

      var text:String = lstCat.getSelectedText();

      var getlist:XML = new XML("<command><function>getimagesforcategory</function><parameter name=\"name\" value=\"" + text + "\" /></command>");
      // SFScreen.addDebug(getlist.toXMLString());
      currentCommand = "getimagesforcategory";
      xmlconv.say(getlist);
    }

    private function atError(e:IOErrorEvent):void
    {
      SFScreen.addDebug("onError()");
      var msg:SFShowMessage = new SFShowMessage(screen,"Image upload failed: " + e.toString());

    }

    private function atProgress(e:ProgressEvent):void
    {
      // SFScreen.addDebug("onProgress()");

      var done:Number = e.bytesLoaded;
      var total:Number = e.bytesTotal;

      var prg:uint = Math.floor(total/done);
      prgUpload.setPos(prg);
    }

    private function btnDelCatClick(e:MouseEvent):void
    {
      var index:Number;
      var text:String;

      index = lstCat.getSelectedIndex();
      if(index >= 0)
      {
        text = lstCat.getSelectedText();
        var delcat:XML = new XML("<command><function>deletecategory</function><parameter name=\"name\" value=\"" + text + "\" /></command>");
        // SFScreen.addDebug(delcat.toXMLString());
        currentCommand = "deletecategory";
        xmlconv.say(delcat);
      }
      else
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please select a valid category first");
      }
    }


    private function btnAddImgClick(e:MouseEvent):void
    {
      var index:Number;
      var text:String;

      index = lstCat.getSelectedIndex();
      if(index >= 0)
      {
        text = lstCat.getSelectedText();
        fup = new SFFileUpload("../pupil/upload",text,atSelect,atCancel,atComplete,atError,atProgress);
        fup.browse();
      }
      else
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please select a valid category first");
      }
    }

    private function btnDelImgClick(e:MouseEvent):void
    {
      var index:Number;
      var img:String;
      var cat:String;

      index = lstImg.getSelectedIndex();
      if(index >= 0)
      {
        cat = lstCat.getSelectedText();
        img = lstImg.getSelectedText();

        var xml:String = "<command><function>deleteimage</function><parameter name=\"image\" value=\"" + img + "\" />";
        xml = xml + "<parameter name=\"category\" value=\"" + cat + "\" /></command>";
        var delimg:XML = new XML(xml);
        // SFScreen.addDebug(delimg.toXMLString());
        currentCommand = "deleteimage";
        xmlconv.say(delimg);
      }
      else
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please select a valid image first");
      }
    }


    private function btnAddCatClick(e:MouseEvent):void
    {
      // SFScreen.addDebug("btnAddCatClick()");

      var name:String = txtNewCat.getText();
      if(name == null || name == "")
      {
        var msg:SFShowMessage = new SFShowMessage(screen,"Please add a valid name!");
      }
      else
      {
        var newcatxml:XML = new XML("<command><function>addcategory</function><parameter name=\"name\" value=\"" + name + "\" />" +
            "<parameter name=\"project\" value=\"" + project + "\" /></command>");
        currentCommand = "addcategory";
        xmlconv.say(newcatxml);
      }
    }

    private function btnCloseClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function onListSelect(index:Number = -1, text:String = null):void
    {
      // SFScreen.addDebug("List select: " + index + " " + text);

      if(index >= 0)
      {
        var getlist:XML = new XML("<command><function>getimagesforcategory</function><parameter name=\"name\" value=\"" + text + "\" /></command>");
        // SFScreen.addDebug(getlist.toXMLString());
        currentCommand = "getimagesforcategory";
        xmlconv.say(getlist);
      }
    }


    private function xmlComplete(e:Event):void
    {
      // SFScreen.addDebug("complete");
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

        if(currentCommand == "getimagesforcategory")
        {
          var imagelist:Array = new Array();
          //categorylist[0] = "test";

          for each (row in data.row)
          {          
            imagelist[numelem++] = row.column.(@name == "file_name");
          }

          if(lstImg != null)
          {
            pnlMain.removeChild(lstImg);
          }
          lstImg = new SFList(pnlMain,10,220,200,150,imagelist);
        }

        if(currentCommand == "getcategorylist")
        {
          categorylist = new Array();
          //categorylist[0] = "test";

          for each (row in data.row)
          {          
            categorylist[numelem++] = row.column.(@name == "name");
          }

          if(lstCat != null)
          {
            pnlMain.removeChild(lstCat);
          }
          lstCat = new SFList(pnlMain,10,35,200,150,categorylist,SFComponent.BEVEL_NONE,onListSelect);

          if(lstImg != null)
          {
            pnlMain.removeChild(lstImg);
          }
          lstImg = new SFList(pnlMain,10,220,200,150,new Array());
        }
        if(currentCommand == "addcategory")
        {
          currentCommand = "getcategorylist";
          xmlconv.say(getCats);
        }
        if(currentCommand == "deletecategory")
        {
          currentCommand = "getcategorylist";
          xmlconv.say(getCats);
        }
        if(currentCommand == "deleteimage")
        {
          onListSelect(lstCat.getSelectedIndex(), lstCat.getSelectedText());
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

