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

  public class TextScene extends PupilScene
  {
    public function TextScene(screen:SFScreen,scenename:String,projectname:String,details:Object,lead:String)
    {
      super(screen,null,scenename,null,projectname,details,0,lead);
//      SFScreen.addDebug("lead: " + lead);
    }

    public override function render():void
    {
      try
      {

        var details:Object = getDetails();
        var txtheight:Number;
        var txtwidth:Number;
        var centerizer:Number = 100;
        var canvas:SFComponent = getCanvas();
        var lead:String = getLead();
        var strs:Array = lead.split(/\|/g);

//        SFScreen.addDebug("strs: " + strs);

        var i:Number;

        var form:TextFormat = new TextFormat();
        form.font = "Arial";
        form.size = 18;
        form.bold = true;
        form.color = 0x000000;

        var txttop:TextField = new TextField();
        txttop.autoSize = TextFieldAutoSize.LEFT;
        txttop.text = "ABCDgyj";
        txttop.selectable = false;
        txttop.alwaysShowSelection = false;
        txttop.setTextFormat(form);

        txtheight = txttop.height;
        txtwidth = txttop.width;

        var increment:Number = Math.floor( canvas.height / (strs.length + 1) );

        var curpos:Number = increment;

        for(i = 0; i < strs.length; i++)
        {
          txttop = new TextField();
          txttop.autoSize = TextFieldAutoSize.LEFT;
          txttop.text = strs[i];
          txttop.selectable = false;
          txttop.alwaysShowSelection = false;
          txttop.setTextFormat(form);

          txtheight = txttop.height;
          txtwidth = txttop.width;

          txttop.x = Math.floor( (canvas.width / 2) - (txtwidth / 2) );
          txttop.y = curpos;

          curpos = curpos + increment;

          canvas.addChild(txttop);
        }
      }
      catch(e:Error)
      {
        SFScreen.addDebug("Error: " + e.toString());
      }
    }

    public override function isValidKey(keypress:String):Boolean
    {
      return true;
    }

    public override function getType():String
    {
      return "text";
    }

    public override function isInputScene():Boolean
    {
      return false;
    }

    public override function reportInput():String
    {
      return "~";
    }

    public override function inputWasCorrect():Boolean
    {
      return true;
    }

  }
}

