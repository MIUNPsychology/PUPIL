package pupil.common
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.utils.Timer;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  import pupil.reaction.*;

  public class PupilScene
  {
    private var myname:String = "";
    private var mylead:String = "";
    private var mypattern:String = "";
    private var myproject:String = "";
    private var myscreen:SFScreen = null;
    private var mycanvas:SFComponent = null;
    private var optioncanvas:SFComponent = null;
    private var leadcanvas:SFComponent = null;
    private var images:ImageHash = null;
    private var display:DisplayProject = null;
    private var projdetails:Object = null;
    private var mytimeout:Number = 0;

    private var areawidth:Number = -1;
    private var areaheight:Number = -1;
    private var areaxmod:Number = 0;
    private var areaymod:Number = 0;

    private var myTimer:Timer = null;

    private var frameTrace:Boolean = false;
    private var frameStart:Number = 0;

    private const assumeHeight:uint = 27;

    public function PupilScene(screen:SFScreen, hash:ImageHash,scenename:String,pattern:String,projectname:String,details:Object,timeout:Number = 0,lead:String = "")
    {
      myname = scenename;
      mypattern = pattern;
      myproject = projectname;
      myscreen = screen;
      mytimeout = timeout;
      mylead = lead;

      images = hash;

      projdetails = details;

    }

    public function getLead():String
    {
      return mylead;
    }

    public function setAndRenderLead(lead:String):void
    {
      if(lead == null || lead == "") 
      {
        return;
      }

      if(projdetails['hideopts'] == "1")
      {
        return;
      }

      var canvas:SFComponent = getCanvas();

      var totalHeight:Number = assumeHeight + 22;

      var y:Number = myscreen.height - totalHeight;
      if(optioncanvas != null)
      {
        y = y - optioncanvas.height - 15;
      }

//      SFScreen.addDebug("lead: " + lead);

      leadcanvas = new SFComponent(canvas,10,y,myscreen.width-20,totalHeight, 0xDDDDFF);

      try
      {
        var f:TextFormat = new TextFormat();
        f.size = 20;
        f.bold = true;
        f.color = 0x000000;

        var tf_txt:TextField;

        tf_txt = new TextField();
        tf_txt.autoSize = TextFieldAutoSize.LEFT;
        tf_txt.text = lead;
        tf_txt.setTextFormat(f);
        tf_txt.selectable = false;
        tf_txt.multiline = false;
        tf_txt.x = 10;
        tf_txt.y = 10;
        //      tf_txt.height = assumeHeight;

        leadcanvas.addChild(tf_txt);
//        SFScreen.addDebug("after add txt");
      }
      catch(e:Error)
      {
        SFScreen.addDebug(e.toString());
      }
    }

    public function setAndRenderOptions(opts:Array):void
    {
      if(projdetails['hideopts'] == "1")
      {
        return;
      }

      var canvas:SFComponent = getCanvas();

      var f:TextFormat = new TextFormat();
      f.size = 18;
      f.bold = true;
      f.color = 0x000000;

      var totalHeight:Number = assumeHeight * opts.length + 20;

      optioncanvas = new SFComponent(canvas,10,myscreen.height - totalHeight - 5, myscreen.width - 20, totalHeight, 0xFFFFBB);

      var i:uint;
      var y:uint = 10;

      var tf_txt:TextField;

      for(i = 0; i < opts.length; i++)
      {
        tf_txt = new TextField();
        tf_txt.autoSize = TextFieldAutoSize.LEFT;
        tf_txt.text = opts[i];
        tf_txt.setTextFormat(f);
        tf_txt.selectable = false;
        tf_txt.multiline = false;
        tf_txt.x = 10;
        tf_txt.y = y;
        tf_txt.height = assumeHeight;

        optioncanvas.addChild(tf_txt);

        y = y + assumeHeight;
      }
    }

    public function getDetails():Object
    {
      return projdetails;
    }

    public function checkAreaSettings():void
    {
      if(areawidth < 0 || areaheight < 0)
      {
        var details:Object = getDetails();

        if(details['maxwidth'] != null && details['maxheight'] != null)
        {
          var mw:Number = details['maxwidth'];
          var mh:Number = details['maxheight'];

          if(mw > 0)
          {
            areawidth = mw;
            areaxmod = Math.floor((myscreen.width - mw) / 2);
          }
          else
          {
            areawidth = myscreen.width;
          }

          if(mh > 0)
          {
            areaheight = mh;
            if(optioncanvas != null)
            {
              areaymod = Math.floor((myscreen.height - optioncanvas.height - mh) / 2);
            }
            else
            {
              areaymod = Math.floor((myscreen.height - mh) / 2);
            }
          }
          else
          {
            areaheight = myscreen.height;
            if(optioncanvas != null)
            {
              // reduce height to account for options

              areaheight = areaheight - optioncanvas.height;

            }
          }
        }
      }
    }

    public function calculateStretchPercentage(imgwidth:Number, imgheight:Number):Number
    {
      /* Image width is % of area width? */
      var xper:Number = imgwidth / areawidth;

      /* Image height is % of area height? */
      var yper:Number = imgheight / areaheight;

      if(xper < yper)
      {
        // Y axis limits stretch
        return 1 / yper;
      }
      else
      {
        // X axis limits stretch
        return 1 / xper;
      }
      return 1;
    }

    public function calculateXPos(n:Number, imgwidth:Number):Number
    {
      checkAreaSettings();

      if(mypattern == "single_centered")
      {
        return areaxmod + Math.floor((areawidth/2) - (imgwidth/2));
      }

      if(mypattern == "single_stretched")
      {
        return areaxmod;
      }

      if(mypattern == "2x1")
      {
        if(n == 1) { return areaxmod; /* left */ }
        if(n == 2) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "3x1")
      {
        if(n == 1) { return areaxmod; /* left */ }
        if(n == 2) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 3) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "1+2")
      {
        if(n == 1) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 2) { return areaxmod; /* left */ }
        if(n == 3) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "2+1")
      {
        if(n == 1) { return areaxmod; /* left */ }
        if(n == 2) { return areaxmod + areawidth - imgwidth; /* right */ }
        if(n == 3) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
      }

      if(mypattern == "2x2")
      {
        if(n == 1 || n == 3) { return areaxmod; /* left */ }
        if(n == 2 || n == 4) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "4_as_plus")
      {
        if(n == 1 || n == 4) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 2) { return areaxmod; /* left */ }
        if(n == 3) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "5_as_x")
      {
        if(n == 3) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 1 || n == 4) { return areaxmod; /* left */ }
        if(n == 2 || n == 5) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "5_as_plus")
      {
        if(n == 1 || n == 5 || n == 3) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 2) { return areaxmod; /* left */ }
        if(n == 4) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "3x2")
      {
        if(n == 1 || n == 4) { return areaxmod; /* left */ }
        if(n == 2 || n == 5) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 3 || n == 6) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      if(mypattern == "3+1+3")
      {
        if(n == 1 || n == 5) { return areaxmod; /* left */ }
        if(n == 2 || n == 6) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 3 || n == 7) { return areaxmod + areawidth - imgwidth; /* right */ }
        if(n == 4) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
      }

      if(mypattern == "3+2+3")
      {
        if(n == 1 || n == 6) { return areaxmod; /* left */ }
        if(n == 2 || n == 7) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 3 || n == 8) { return areaxmod + areawidth - imgwidth; /* right */ }
        if(n == 4) { return areaxmod + Math.floor((areawidth/3) - (imgwidth/2)); /* mid-left */ }
        if(n == 5) { return areaxmod + Math.floor(((areawidth/3)*2) - (imgwidth/2)); /* mid-right */ }
      }

      if(mypattern == "3x3")
      {
        if(n == 1 || n == 4 || n == 7) { return areaxmod; /* left */ }
        if(n == 2 || n == 5 || n == 8) { return areaxmod + Math.floor((areawidth/2) - (imgwidth/2)); /* mid */ }
        if(n == 3 || n == 6 || n == 9) { return areaxmod + areawidth - imgwidth; /* right */ }
      }

      return 0;
    }

    public function calculateYPos(n:Number, imgheight:Number):Number
    {
      checkAreaSettings();

      if(mypattern == "single_centered")
      {
        return areaymod + Math.floor((areaheight/2) - (imgheight/2));
      }

      if(mypattern == "single_stretched")
      {
        return areaymod;
      }

      if(mypattern == "2x1")
      {
        return areaymod + Math.floor((areaheight/2) - (imgheight/2));
      }

      if(mypattern == "3x1")
      {
        return areaymod + Math.floor((areaheight/2) - (imgheight/2));
      }

      if(mypattern == "1+2")
      {
        if(n == 1) { return areaymod; /* top */ }
        if(n == 2 || n == 3) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "2+1")
      {
        if(n == 1 || n == 2) { return areaymod; /* top */ }
        if(n == 3) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "2x2")
      {
        if(n == 1 || n == 2) { return areaymod; /* top */ }
        if(n == 3 || n == 4) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "4_as_plus")
      {
        if(n == 1) { return areaymod; /* top */ }
        if(n == 2 || n == 3) { return areaymod + Math.floor((areaheight/2) - (imgheight/2)); /* mid */ }
        if(n == 4) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "5_as_x")
      {
        if(n == 1 || n == 2) { return areaymod; /* top */ }
        if(n == 3) { return areaymod + Math.floor((areaheight/2) - (imgheight/2)); /* mid */ }
        if(n == 4 || n == 5) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "5_as_plus")
      {
        if(n == 1) { return areaymod; /* top */ }
        if(n == 2 || n == 3 || n == 4) { return areaymod + Math.floor((areaheight/2) - (imgheight/2)); /* mid */ }
        if(n == 5) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "3x2")
      {
        if(n == 1 || n == 2 || n == 3) { return areaymod; /* top */ }
        if(n == 4 || n == 5 || n == 6) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "3+1+3")
      {
        if(n == 1 || n == 2 || n == 3) { return areaymod; /* top */ }
        if(n == 4) { return areaymod + Math.floor((areaheight/2) - (imgheight/2)); /* mid */ }
        if(n == 5 || n == 6 || n == 7) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "3+2+3")
      {
        if(n == 1 || n == 2 || n == 3) { return areaymod; /* top */ }
        if(n == 4 || n == 5) { return areaymod + Math.floor((areaheight/2) - (imgheight/2)); /* mid */ }
        if(n == 6 || n == 7 || n == 8) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      if(mypattern == "3x3")
      {
        if(n == 1 || n == 2 || n == 3) { return areaymod; /* top */ }
        if(n == 4 || n == 5 || n == 6) { return areaymod + Math.floor((areaheight/2) - (imgheight/2)); /* mid */ }
        if(n == 7 || n == 8 || n == 9) { return areaymod + areaheight - imgheight; /* bottom */ }
      }

      return 0;
    }

    public function getImageFromPath(path:String):SFRemoteImage
    {
      return images.getImageFromPath(path);
    }

    public function getImage(category:String, name:String):SFRemoteImage
    {
      return images.getImage(category,name);
    }

    public function getRandomImage(category:String, uniqueRandomSet:String = "",splicearray:Boolean = false):SFRemoteImage
    {
      //SFScreen.addDebug("getRandomImage() -- " + category + " -- " + uniqueRandomSet + " -- " + splicearray);
      var img:SFRemoteImage = images.getRandomImage(category, uniqueRandomSet, splicearray);
      if(img == null)
      {
        var msg:SFShowMessage = new SFShowMessage(myscreen,"Tried to get a random image from category " + category + " but there were none left.");
      }
      return img;
    }
    
    public function getCanvas():SFComponent
    {
      if(mycanvas == null)
      {
        mycanvas = new SFComponent(null,0,0,myscreen.width,myscreen.height,0xFFFFFF,1.0 );
        mycanvas.addEventListener(MouseEvent.CLICK, clickEvent);
      }

      return mycanvas;
    }

    private function clickEvent(e:MouseEvent):void
    {
      SFScreen.addDebug("mouse click: Intercepting");
      e.stopImmediatePropagation();
      e.stopPropagation();

      myscreen.stage.focus = mycanvas;
    }

    public function reportKeyDown(event:KeyboardEvent):void
    {
      try
      {
      if(event == null)
      {
        // assume timer 
        display.reportKey("time");
        mycanvas.removeEventListener(KeyboardEvent.KEY_DOWN, reportKeyDown);
        return;
      }
      else
      {
        frameTrace = false;
        myscreen.stage.removeEventListener(Event.ENTER_FRAME,enterFrame);  
      }

      var k:String = String.fromCharCode(event.charCode);
//      SFScreen.addDebug("Key Pressed: " + String.fromCharCode(event.charCode) + " (character code: " + event.charCode + ")");

      if(isValidKey(k))
      {
//        SFScreen.addDebug("Scene says key is valid, reporting to display");
        mycanvas.removeEventListener(KeyboardEvent.KEY_DOWN, reportKeyDown);
        display.reportKey(k);
      }
      else
      {
//        SFScreen.addDebug("Scene says key is invalid");
      }
      }
      catch(e:Error)
      {
        SFScreen.addDebug("reportKeyDown() -- " + e.toString());
      }
    }

    public function isInputScene():Boolean
    {
      return false;
    }

    public function reportInput():String
    {
      return " ";
    }

    public function inputWasCorrect():Boolean
    {
      return true;
    }

    public function isValidKey(keypress:String):Boolean
    {
      return false;
    }

    public function render():void
    {
      //
    }

    public function getDisplay():DisplayProject
    {
      return display;
    }

    public function show(dp:DisplayProject):void
    {
      display = dp;
      mycanvas.addEventListener(KeyboardEvent.KEY_DOWN, reportKeyDown);
      myscreen.addChild(mycanvas);
      myscreen.stage.stageFocusRect = false
      myscreen.stage.focus = mycanvas;

//      SFScreen.addDebug("Timeout is " + mytimeout);

      if(mytimeout != 0)
      {
//        SFScreen.addDebug("before event listener");
        frameStart = (new Date()).time;
        frameTrace = true;
        myscreen.stage.addEventListener(Event.ENTER_FRAME,enterFrame);  
//        myTimer = new Timer(mytimeout);
//        myTimer.addEventListener("timer",timeoutEvent);
//        myTimer.start();
//        SFScreen.addDebug("Added event listener");
      }
    }

    private function enterFrame(e:Event):void
    {
      if(frameTrace)
      {
//        var val1:Number = ((new Date()).time - frameStart);
//        var val2:Number = (mytimeout - 5);
//        SFScreen.addDebug("enter frame " + val1 + " " + val2);
        if( ((new Date()).time - frameStart) > (mytimeout - 2) )
        {
          frameTrace = false;
          myscreen.stage.removeEventListener(Event.ENTER_FRAME,enterFrame);  
          reportKeyDown(null);
        }
      }
    }

/*    private function timeoutEvent(event:TimerEvent):void
    {
      SFScreen.addDebug("timeoutEvent!?");
      myTimer.stop();
      reportKeyDown(null);
    }*/

    public function hide():void
    {
      try
      {
        myscreen.removeChild(mycanvas);
      }
      catch(e:Error)
      {
      }
    }

    public function getScreen():SFScreen 
    {
      return myscreen;
    }

    public function getType():String
    {
      return "must override this function";
    }

    public function getName():String
    {
      return myname;
    }

    public function getPattern():String
    {
      return mypattern;
    }

    public function getProject():String
    {
      return myproject;
    }
  }
}

