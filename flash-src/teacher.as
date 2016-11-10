package
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import flash.system.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  import pupil.reaction.*;
  import pupil.teacher.*;

  public class teacher extends MovieClip
  {
    private var screen:SFScreen = null;
    private var mainwin:TeacherMain = null;

    private var debug:Boolean = false;

    public function teacher()
    {
      screen = new SFScreen(this,0xFFFFFF,1.0,debug,debug);
      mainwin = new TeacherMain(screen);
    }
  }
}

