package pupil.common
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  import pupil.reaction.*;

  public class SORIScene extends PupilScene
  {
    private var keychars:Array = new Array();
    private var catnames:Array = new Array();
    private var optiontxt:Array = new Array();

    private var pressedkey:String = "";
    private var wascorrect:Boolean = false;
    private var correctkey:String = "~";

    private var mylead:String = "";

    public function SORIScene(screen:SFScreen, hash:ImageHash,soriinfo:XML, scenename:String,pattern:String,projectname:String,details:Object,correct:String,timeout:Number = 0,lead:String = "")
    {
      super(screen,hash,scenename,pattern,projectname,details,timeout,lead);

//      SFScreen.addDebug(soriinfo.toXMLString());

      correctkey = correct;

      mylead = lead;

      var pos:String;
      var img:String;
      var cat:String;
      var txt:String;
      var key:String;

      var row:XML;

      var posnum:Number;

      for each (row in soriinfo.soricat)
      {
        pos = row.@position;
        cat = row.@category;
        posnum = Number(pos);

        catnames[posnum] = cat;

        // SFScreen.addDebug(catnames[posnum]);
      }

      posnum = 0;

      for each (row in soriinfo.soriopt)
      {
        key = row.@keychar;
        txt = row.@optiontxt;

        keychars[posnum] = key;
        optiontxt[posnum] = txt;

        posnum++;

        //SFScreen.addDebug("('" + key + "') " + txt);
      }
    }

    public override function render():void
    {
//      SFScreen.addDebug("About to render SORI");
      setAndRenderOptions(optiontxt);
      setAndRenderLead(mylead);

      var canvas:SFComponent = getCanvas();

      var image:SFRemoteImage = null;
      var imgcmp:SFComponent = null;

      var ix:Number = 0;
      var iy:Number = 0;

      var details:Object = getDetails();

//      SFScreen.addDebug("splicearray: " + details['splicearray']);

      for(var i:Number = 1; i < catnames.length; i++)
      {        
        if(details['splicearray'] == "1")
        {        
          image = getRandomImage(catnames[i],catnames[i],true);
        }
        else
        {
          image = getRandomImage(catnames[i],catnames[i],false);
        }

        imgcmp = image.asComponent(canvas,0,0);
        
        ix = calculateXPos(i,imgcmp.width);
        iy = calculateYPos(i,imgcmp.height);

        imgcmp.x = ix;
        imgcmp.y = iy;
//        SFScreen.addDebug("Image " + i + " (" + ix + "," + iy + ") -- " + catnames[i]);
      }
    }

    public override function isValidKey(keypress:String):Boolean
    {
      var i:uint;
      for(i = 0; i < keychars.length; i++)
      {
        if(keypress == keychars[i])
        {
          // SFScreen.addDebug("pressed key: " + keypress);
          // SFScreen.addDebug("correct key: " + correctkey);

          pressedkey = keypress;
          wascorrect = (correctkey == "~") || (keypress == correctkey);
          return true;
        }
      }

      return false;
    }

    public override function getType():String
    {
      return "select_option_random_image";
    }

    public override function isInputScene():Boolean
    {
      return true;
    }

    public override function reportInput():String
    {
      return pressedkey;
    }

    public override function inputWasCorrect():Boolean
    {
      return wascorrect;
    }

  }
}

