package pupil.teacher
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class ReplaceImage
  {
    private var screen:SFScreen = null;

    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;
    private var myparent:ProjectDetails = null;

    private var xmlconv:SFXMLConversation = null;

    private var getImgs:XML = <command><function>getallimages</function></command>;

    private var currentCommand:String = "";

    private var categories:Array = new Array();
    private var images:Object = new Object();

    private var lstCat:SFList = null;
    private var lstDestCat:SFList = null;
    private var lstImg:SFList = null;
    private var lstDestImg:SFList = null;

    private var currentName:String = "lkjghdkjhg";

    public function ReplaceImage(myscreen:SFScreen, parentwin:ProjectDetails, projname:String)
    {
      screen = myscreen;
      myparent = parentwin;
      currentName = projname;

      getImgs = new XML("<command><function>getallimages</function><parameter name=\"project\" value=\"" + projname + "\" /></command>");

      frmMain = new SFFrame(screen,170,70,490,440,"Batch replace images");
      pnlMain = frmMain.getPanel();

      var lblCatList:SFLabel = new SFLabel(pnlMain,10,10,200,25,"Select current category",false);
      var lblDestCatList:SFLabel = new SFLabel(pnlMain,245,10,200,25,"Replace with category",false);

      var btnReplace:SFButton = new SFButton(pnlMain,220,365,120,40,"Replace",onReplaceClick);
      var btnCancel:SFButton = new SFButton(pnlMain,350,365,120,40,"Close",onCancelClick);

      xmlconv = new SFXMLConversation("../pupil/teacher",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
      currentCommand = "getallimages";
      xmlconv.say(getImgs);
    }

    private function onCancelClick(e:MouseEvent):void
    {
      screen.removeChild(frmMain);
    }

    private function onReplaceClick(e:MouseEvent):void
    {
      SFScreen.addDebug("replace");

      var msg:SFShowMessage;

      if( lstCat.getSelectedIndex() < 0 )
      {
        msg = new SFShowMessage(screen,"Please select a source category first");
        return;
      }

      if( lstDestCat.getSelectedIndex() < 0 )
      {
        msg = new SFShowMessage(screen,"Please select a replacement category first");
        return;
      }

      if( lstImg.getSelectedIndex() < 0 )
      {
        msg = new SFShowMessage(screen,"Please select a source image first");
        return;
      }

      if( lstDestImg.getSelectedIndex() < 0 )
      {
        msg = new SFShowMessage(screen,"Please select a replacement image first");
        return;
      }


      var cat:String = lstCat.getSelectedText();
      var dest:String = lstDestCat.getSelectedText();

      SFScreen.addDebug(cat);
      SFScreen.addDebug(dest);

      var sourceImg:String = lstImg.getSelectedText();
      var destImg:String = lstDestImg.getSelectedText();

      SFScreen.addDebug(sourceImg);
      SFScreen.addDebug(destImg);

      var xml:String = "<command><function>replaceimage</function>";
      xml = xml + "<parameter name=\"project\" value=\"" + currentName + "\" />";
      xml = xml + "<parameter name=\"sourcecat\" value=\"" + cat + "\" />";
      xml = xml + "<parameter name=\"destinationcat\" value=\"" + dest + "\" />";
      xml = xml + "<parameter name=\"sourceimg\" value=\"" + sourceImg + "\" />";
      xml = xml + "<parameter name=\"destinationimg\" value=\"" + destImg + "\" />";
      xml = xml + "</command>";

      var cmd:XML = new XML(xml);

      SFScreen.addDebug(cmd.toXMLString());
      currentCommand = "replaceimage";
      xmlconv.say(cmd);
    }

    private function xmlComplete(e:Event):void
    {
      //SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
//      SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();
      var msg:SFShowMessage;

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        var numelem:uint = 0;
        var data:XML = response.data[0];
        var row:XML = null;

        var filename:String;
        var category:String;

        if(currentCommand == "replaceimage")
        {
          SFScreen.addDebug(response.toXMLString());
          SFScreen.addDebug(response.toXMLString());
          msg = new SFShowMessage(screen,"Images replaced (if any)");
        }

        if(currentCommand == "getallimages")
        {
          var lastcat:String = "kdlghskdlghsfkljh";
          var imgs:Array;
          var len:uint;

          for each (row in data.row)
          {          
            filename = row.column.(@name == "file_name");
            category = row.column.(@name == "category");

            if(lastcat != category)
            {
              images[category] = new Array();
              len = categories.length;
              categories[len] = category;
              lastcat = category;
            }

            imgs = images[category] as Array;
            len = imgs.length;
            imgs[len] = filename;
          }
          try
          {
            if(lstCat != null)
            {
              pnlMain.removeChild(lstCat);
            }
            lstCat = new SFList(pnlMain,10,35,225,160,categories,SFComponent.BEVEL_NONE,onSourceSelect);
            lstDestCat = new SFList(pnlMain,245,35,225,160,categories,SFComponent.BEVEL_NONE,onDestSelect);
            lstImg = new SFList(pnlMain,10,205,225,150,new Array());
            lstDestImg = new SFList(pnlMain,245,205,225,150,new Array());
          }
          catch(e:Error)
          {
            SFScreen.addDebug("Helvete " + e.toString());
          }
        }
      }
    }

    private function onSourceSelect(index:Number = -1, text:String = null):void
    {
      if(index >= 0)
      {
        if(lstImg != null)
        {
          pnlMain.removeChild(lstImg);
        }
        lstImg = new SFList(pnlMain,10,205,225,150,images[text]);
      }
    }

    private function onDestSelect(index:Number = -1, text:String = null):void
    {
      if(index >= 0)
      {
        if(lstDestImg != null)
        {
          pnlMain.removeChild(lstDestImg);
        }
        lstDestImg = new SFList(pnlMain,245,205,225,150,images[text]);
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

