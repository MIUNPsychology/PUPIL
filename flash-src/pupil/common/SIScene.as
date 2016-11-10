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

  public class SIScene extends PupilScene
  {
    private var keychars:Array = new Array();
    private var imagenames:Array = new Array();

    private var pressedkey:String = "";
    private var wascorrect:Boolean = false;
    private var correctkey:String = "~";

    public function SIScene(screen:SFScreen, hash:ImageHash,siinfo:XML, scenename:String,pattern:String,projectname:String,details:Object,correct:String,timeout:Number = 0)
    {
      super(screen,hash,scenename,pattern,projectname,details,timeout);

//      SFScreen.addDebug(siinfo.toXMLString());

      correctkey = correct;

      var pos:String;
      var img:String;
      var key:String;

      var row:XML;

      var posnum:Number;

      for each (row in siinfo.ssientry)
      {
        img = row.@image;
        pos = row.@position;
        key = row.@keychar;
        posnum = Number(pos);

        keychars[posnum] = key;
        imagenames[posnum] = img;

//        SFScreen.addDebug(img);
      }
    }

    public override function render():void
    {
      var canvas:SFComponent = getCanvas();

      var image:SFRemoteImage = null;
      var imgcmp:SFComponent = null;

      var ix:Number = 0;
      var iy:Number = 0;

      for(var i:Number = 1; i < imagenames.length; i++)
      {        
        image = getImageFromPath(imagenames[i]);
        imgcmp = image.asComponent(canvas,0,0);
        
        ix = calculateXPos(i,imgcmp.width);
        iy = calculateYPos(i,imgcmp.height);

        imgcmp.x = ix;
        imgcmp.y = iy;


//        SFScreen.addDebug("Image " + i + " (" + ix + "," + iy + ")");
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
      return "static_image";
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

