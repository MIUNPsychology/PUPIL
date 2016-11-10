package pupil.reaction
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;
  import pupil.common.*;

  import flash.utils.Timer;
  import flash.events.TimerEvent;

  public class DisplayProject
  {
    private var screen:SFScreen = null;
    private var project:String = null;

    private var xmlconv:SFXMLConversation = null;
    private var currentCommand:String = "";

    private var currentScene:Number = 0;
    private var sobs:Array = null;
    private var bobs:Array = null;

    private var abstimestart:Array = new Array();
    private var abstimeend:Array = new Array();
    private var scenename:Array = new Array();
    private var deltatime:Array = new Array();
    private var inputkey:Array = new Array();
    private var correctkey:Array = new Array();

    private var projectdetails:Object = null;

    private var scenePhase:String = "white pause";
    private var lastCorrect:String = "";

    private var timer:Timer = null;

    private var flashy:SFComponent = null;

    private var whiteFlash:SFComponent = null;
    private var greenFlash:SFComponent = null;
    private var redFlash:SFComponent = null;
    
    private var blklist:Array = null;

    private function timestampstart():void
    {
      // SFScreen.addDebug("timestamp start " + currentScene);
      var scene:PupilScene = PupilScene(sobs[currentScene]);

      var d:Date = new Date();
      var t:Number = d.time;

      abstimestart[currentScene] = t;
      scenename[currentScene] = scene.getName();
    }

    private function timestampend():void
    {
      var scene:PupilScene = PupilScene(sobs[currentScene]);

      var d:Date = new Date();
      var t:Number = d.time;

      abstimeend[currentScene] = t;
      deltatime[currentScene] = t - abstimestart[currentScene];
    }

    public function DisplayProject(myscreen:SFScreen, myproject:String, sceneobjects:Array, detailshash:Object, blocklist:Array)
    {
      screen = myscreen;
      project = myproject;
      projectdetails = detailshash;
      blklist = blocklist;

      var tmpscene:PupilScene = null;

      var slist:Array;
      var s:Number;
      var i:Number;
      var n:Number;
      var r:Number;
      var blk:Object;
      var image:SFRemoteImage = null;
      var imgcmp:SFComponent = null;

      sobs = new Array();
      bobs = new Array();

      var projectrandom:String = detailshash['blockrandom'];

      // SFScreen.addDebug("Global block random: " + projectrandom);

      if(projectrandom == "1")
      {
        // Randomize block order
        while(blocklist.length > 0)
        {            
          r = blocklist.length;
          n = Math.floor(Math.random() * r - 0.0001);
          blk = blocklist.splice(n,1)[0];
          // SFScreen.addDebug("Adding block " + blk['name']);
          bobs[bobs.length] = blk;
        }
      }
      else
      {
        // blocks are shown in alphabetical order
        for(i = 0; i < blocklist.length; i++)
        {
          blk = blocklist[i];
          // SFScreen.addDebug("Adding block " + blk['name']);
          bobs[bobs.length] = blk;
        }
      }

      for(i = 0; i < bobs.length; i++)
      {
        blk = bobs[i];
        // SFScreen.addDebug("Adding scenes for block " + blk['name']);
        slist = blk['scenes'];        
        // SFScreen.addDebug("Internal block random: " + blk['random']);
        // SFScreen.addDebug("Internal textfirst: " + blk['textfirst']);

        if(blk['textfirst'] == "1")
        {
          // splice text scenes before determining rest of order

          n = 0;

          // SFScreen.addDebug("Splicing text scenes for block " + blk['name']);

          while(slist.length > 0 && n < slist.length)
          {
            s = slist[n];
            tmpscene = PupilScene( sceneobjects[s] );
            // SFScreen.addDebug(" -- scene " + s + " is a text scene: " + (tmpscene is TextScene));

            if( tmpscene is TextScene )
            {
              sobs[sobs.length] = tmpscene;
              slist.splice(n,1);
            }
            else
            {
              n++;
            }
          }

        }

        if(blk['random'] == "0")
        {
          // We don't need to randomize inside block
          for(n = 0; n < slist.length; n++)          
          {
            s = slist[n];
            sobs[sobs.length] = sceneobjects[s];
            // SFScreen.addDebug("-- Scene " + s);
          }
        }
        else
        {
          // Randomization inside block
          while(slist.length > 0)
          {            
            r = slist.length;
            n = Math.floor(Math.random() * r - 0.0001);
            s = slist.splice(n,1)[0];
            sobs[sobs.length] = sceneobjects[s];
            // SFScreen.addDebug("-- Scene " + s);
          }
        }
      }

      var scene:PupilScene = PupilScene(sobs[0]);

      if(detailshash["pauseimg"] == "")
      {
        whiteFlash = new SFComponent(null,0,0,screen.width-1,screen.height-1,0xFFFFFF);
      }
      else
      {
        whiteFlash = new SFComponent(null,0,0,screen.width-1,screen.height-1,0xFFFFFF);
        image = scene.getImageFromPath(detailshash["pauseimg"]);
        imgcmp = image.asComponent(whiteFlash,0,0);
        imgcmp.x = Math.floor((screen.width / 2) - (imgcmp.width / 2));
        imgcmp.y = Math.floor((screen.height / 2) - (imgcmp.height / 2));
      }

      if(detailshash["rightimg"] == "")
      {
        greenFlash = new SFComponent(null,0,0,screen.width-1,screen.height-1,0x00FF00);
      }
      else
      {
        greenFlash = new SFComponent(null,0,0,screen.width-1,screen.height-1,0xFFFFFF);
        image = scene.getImageFromPath(detailshash["rightimg"]);
        imgcmp = image.asComponent(greenFlash,0,0);
        imgcmp.x = Math.floor((screen.width / 2) - (imgcmp.width / 2));
        imgcmp.y = Math.floor((screen.height / 2) - (imgcmp.height / 2));
      }

      if(detailshash["wrongimg"] == "")
      {
        redFlash = new SFComponent(null,0,0,screen.width-1,screen.height-1,0xFF0000);
      }
      else
      {
        redFlash = new SFComponent(null,0,0,screen.width-1,screen.height-1,0xFFFFFF);
        image = scene.getImageFromPath(detailshash["wrongimg"]);
        imgcmp = image.asComponent(redFlash,0,0);
        imgcmp.x = Math.floor((screen.width / 2) - (imgcmp.width / 2));
        imgcmp.y = Math.floor((screen.height / 2) - (imgcmp.height / 2));
      }

      if(detailshash["displaywelcome"] == "1")
      {
        displayWelcome();
      }
      else
      {
        displayFirstScene();
      }
    }

    public function displayWelcome():void
    {
      var welcome:WelcomeScene = new WelcomeScene(screen,projectdetails);
      welcome.render();
      welcome.show(this);
    }

    public function displayFirstScene():void
    {
      try
      {
        if(sobs[0] == null)
        {
          // SFScreen.addDebug("null");
        }
        else
        {
          // SFScreen.addDebug("not null");
        }

        currentScene = 0;
        flipScene();
      }
      catch(error:Error)
      {
        SFScreen.addError(error);
      }
    }

    public function finishLast():void
    {
      // SFScreen.addDebug("finishLast()");

      var i:uint;
      var scene:PupilScene;

      for(i = 0; i < sobs.length; i++)
      {
        scene = PupilScene(sobs[i]);
        try
        {
          scene.hide();
        }
        catch(e:Error)
        {
//          var msg1:SFShowMessage = new SFShowMessage(screen,"Error " + e.toString());
        }
      }

      var redir:String = projectdetails['urlredirect'];

      SFScreen.addDebug("At last page: " + projectdetails);
      SFScreen.addDebug("Urlredirect: " + redir);

      if(redir == "")
      {
        scene = PupilScene(sobs[0]);
        scene.hide();
        var msg:SFShowMessage = new SFShowMessage(screen,"End of project");
      }
      else
      {
        SFScreen.addDebug("Before redirect: " + redir);
        var url:URLRequest = new URLRequest("" + redir);
        navigateToURL(url,"_self");
        SFScreen.addDebug("After redirect: " + url);
      }
    }

    public function reportKey(keypress:String):void
    {
      // SFScreen.addDebug("ReportKey: " + keypress + " -- " + currentScene);

      inputkey[currentScene] = keypress;

      timestampend();
      var scene:PupilScene = PupilScene(sobs[currentScene]);

      if(scene.inputWasCorrect())
      {
        correctkey[currentScene] = "1";
        lastCorrect = "1";
      }
      else
      {
        correctkey[currentScene] = "0";
        lastCorrect = "0";
      }

      currentScene++;

      if(currentScene >= sobs.length)
      {
        var start:Number;
        var end:Number;
        var delta:Number;
        var name:String;
        var key:String;
        var correct:String;

        var cmd:String = "<command><function>registerinput</function>";
        cmd = cmd + "<parameter name=\"project\" value=\"" + project + "\" />";
        cmd = cmd + "<data>";
          
        for(var i:uint = 0; i < sobs.length; i++)
        {
          start = abstimestart[i];
          end = abstimeend[i];
          delta = deltatime[i];
          name = scenename[i]
          key = inputkey[i];
          correct = correctkey[i];

          //SFScreen.addDebug("Scene " + (i+1) + ": " + start + " " + end + " " + delta + " " + key + " (formal scene name was " + name + ")");

          cmd = cmd + "<scene displayno=\"" + (i+1) + "\" ";
          cmd = cmd + "start=\"" + start + "\" ";
          cmd = cmd + "end=\"" + end + "\" ";
          cmd = cmd + "delta=\"" + delta + "\" ";
          cmd = cmd + "keychar=\"" + key + "\" ";
          cmd = cmd + "correct=\"" + correct + "\" ";
          cmd = cmd + "name=\"" + name + "\" />";
        }
        cmd = cmd + "</data></command>";

        var xml:XML = new XML(cmd);
        
        // SFScreen.addDebug(xml.toXMLString());

        xmlconv = new SFXMLConversation("../pupil/experiment",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);
        currentCommand = "registerinput";
        xmlconv.say(xml);
      }
      else
      {
        scene.hide();
        scenePhase = "scene hide";
        flipScene();
      }
    }

    private function flashRed():void
    {
//      SFScreen.addDebug("red");
      flashy = redFlash;
      screen.addChild(flashy);
      scenePhase = "white pause";
//      SFScreen.addDebug("changed scene phase to " + scenePhase);
      makeTimer(800);
    }

    private function flashGreen():void
    {
//      SFScreen.addDebug("green");
      scenePhase = "white pause";
      flashy = greenFlash;
      screen.addChild(flashy);
//      SFScreen.addDebug("changed scene phase to " + scenePhase);
      makeTimer(800);
    }

    private function flashWhite():void
    {
//      SFScreen.addDebug("white");
      scenePhase = "show next";
      flashy = whiteFlash;
      screen.addChild(flashy);
//      SFScreen.addDebug("changed scene phase to " + scenePhase);

      var min:Number = Number(projectdetails['whitemin']);
      var max:Number = Number(projectdetails['whitemax']);

      var delta:Number = max - min;

      var rand:Number = 1;

      if(delta > 0)
      {
        rand = Math.floor( Math.random()*delta );
      }

//      SFScreen.addDebug("White space: " + max + "-" + min + "=" + delta + " [delay " + (min + rand) + "]" );
      makeTimer(min + rand);
    }

    private function flashTimeout(event:TimerEvent):void                                                  
    {
//      SFScreen.addDebug("timeout " + scenePhase);
      timer.stop();
      timer = null;

      if(flashy != null)
      {
        screen.removeChild(flashy);
        flashy = null;
      }

      flipScene();
    }

    private function makeTimer(time:Number):void
    {
      timer = new Timer(time);
      timer.addEventListener("timer", flashTimeout);
      timer.start();
    }

    private function flipScene():void
    {
//      SFScreen.addDebug("flipScene() -- " + scenePhase);

      var white:Boolean = projectdetails['flashwhite'] == "1";

      var red:Boolean = projectdetails['flashwrong'] == "1";
      red = red && (lastCorrect == "0");

      var green:Boolean = projectdetails['flashright'] == "1";
      green = green && (lastCorrect == "1");

//      SFScreen.addDebug("W=" + white + " R=" + red + " G=" + green);

      if(scenePhase == "scene hide")
      {
        if(red)
        {
          flashRed();
          return;
        }

        if(green)
        {
          flashGreen();
          return;
        }

        scenePhase = "white pause";
      }

      if(scenePhase == "white pause")
      {
        if(white)
        {
          flashWhite();
          return;
        }

        scenePhase = "show next";
      }

      if(scenePhase == "show next")
      {
        var scene:PupilScene = PupilScene(sobs[currentScene]);
        timestampstart();
        scene.show(this);
      }
    }

    private function xmlComplete(e:Event):void
    {
      //      SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
      //      SFScreen.addDebug(response.toXMLString());
      var result:String = response.name();
          var scene:PupilScene;
          var i:uint;

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
          for(i = 0; i < sobs.length; i++)
          {
            scene = PupilScene(sobs[i]);
            try
            {
              scene.hide();
            }
            catch(e:Error)
            {
//              var msg1:SFShowMessage = new SFShowMessage(screen,"Error " + e.toString());
            }
          }

      }
      else
      {
        var numelem:uint = 0;
        var data:XML = response.data[0];
        var row:XML = null;
        var cmd:XML = null;

        if(currentCommand == "registerinput")
        {

          for(i = 0; i < sobs.length; i++)
          {
            scene = PupilScene(sobs[i]);
            try
            {
              scene.hide();
            }
            catch(e:Error)
            {
//              var msg1:SFShowMessage = new SFShowMessage(screen,"Error " + e.toString());
            }
          }

          if(projectdetails['displaythanks'] == "1")
          {
            var thanks:OutroScene = new OutroScene(screen,projectdetails);
            thanks.render();
            thanks.show(this);
          }
          else
          {
            var redir:String = projectdetails['urlredirect'];

            SFScreen.addDebug("At last page: " + projectdetails);
            SFScreen.addDebug("Urlredirect: " + redir);

            if(redir == "")
            {
              scene = PupilScene(sobs[0]);
              scene.hide();
              var msg:SFShowMessage = new SFShowMessage(screen,"End of project");
            }
            else
            {
              SFScreen.addDebug("Before redirect: " + redir);
              var url:URLRequest = new URLRequest("" + redir);
              navigateToURL(url,"_self");
              SFScreen.addDebug("After redirect: " + url);
            }
          }
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

