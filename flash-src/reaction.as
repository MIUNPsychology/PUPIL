package
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  import pupil.reaction.*;

  public class reaction extends MovieClip
  {
    private var screen:SFScreen = null;
    private var mainwin:MainWin = null;

    private var loadProject:LoadProject = null;

    private var loader:Loader = null;
    private var mc:MovieClip = null;

    private var showMovie:Boolean = true;

    private var defaultproj:String = "";

    public function reaction()
    {
      var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;

      defaultproj = paramObj['project'];

      if(defaultproj == null)
      {
        defaultproj = "";
      }

      stage.frameRate = 100;
      if(showMovie)
      {
        screen = new SFScreen(this,0xFFFFFF,1.0);
        loadAndShow();
      }
      else
      {
        screen = new SFScreen(this,0xFFFFFF,1.0,true,true);
        showFirstWindow();
      }
    }

    private function showFirstWindow():void
    {
      if(defaultproj != "")
      {
        if(loadProject == null)
        {
          loadProject = new LoadProject(screen,defaultproj);
        }
      }
      else
      {
        if(mainwin == null)
        {
          mainwin = new MainWin(screen);
        }
      }
    }

    private function loadAndShow():void
    {
      loader = new Loader();
      configureListeners(loader.contentLoaderInfo);

      var request:URLRequest = new URLRequest("intromovie.swf");
      try {
        loader.load(request);
      } catch (error:Error) {
        SFScreen.addDebug("Unable to load requested document.");
      }
    }      

    private function configureListeners(dispatcher:IEventDispatcher):void {
      dispatcher.addEventListener(Event.COMPLETE, completeHandler);
      dispatcher.addEventListener(Event.OPEN, openHandler);
      dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
      dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
      dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }

    private function completeHandler(event:Event):void {
      SFScreen.addDebug("" + loader);
      SFScreen.addDebug("" + loader.content);

      mc = MovieClip(loader.content);
      mc.addEventListener(Event.ENTER_FRAME, enterFrame); 

      var mw:Number = mc.width;
      var mh:Number = mc.height;
      var sw:Number = screen.width;
      var sh:Number = screen.height;

      var halfpos:Number = sw/2;

      SFScreen.addDebug(halfpos + " " + mw + " " + mh + " " + sw + " " + sh);

      mc.x = Math.floor( (sw/2) - (mw/2) );
      mc.y = Math.floor( (sh/2) - (mh/2) );

      screen.addChild(mc);
      mc.play();
//      addChild(event.currentTarget.content);
    }

    private function enterFrame(e:Event):void
    {
      if(mc.currentFrame == mc.totalFrames)
      {
        mc.stop();
        showFirstWindow();
      }

      //reach here
    } 

    private function openHandler(event:Event):void {
      SFScreen.addDebug("openHandler: " + event);
    }

    private function progressHandler(event:ProgressEvent):void {
      SFScreen.addDebug("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
      SFScreen.addDebug("securityErrorHandler: " + event);
    }

    private function httpStatusHandler(event:HTTPStatusEvent):void {
      SFScreen.addDebug("httpStatusHandler: " + event);
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
      SFScreen.addDebug("ioErrorHandler: " + event);
    }    
  }
}

