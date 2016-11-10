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

  public class OutroScene extends PupilScene
  {
    private var keychars:Array = new Array();
    private var imagenames:Array = new Array();

    private var projectdetails:Object = null;

    public function OutroScene(screen:SFScreen, details:Object)
    {
      super(screen,null,"","","",null);
      projectdetails = details;
    }

    public override function render():void
    {
      var txtheight:Number;
      var txtwidth:Number;

      var centerizer:Number = 100;

      var canvas:SFComponent = getCanvas();

      var form:TextFormat = new TextFormat();
      form.font = "Arial";
      form.size = 18;
      form.bold = true;
      form.color = 0x000000;

      var txttop:TextField = new TextField();

      txttop.autoSize = TextFieldAutoSize.LEFT;
      txttop.text = projectdetails["thankstop"];
      txttop.selectable = false;
      txttop.alwaysShowSelection = false;
      txttop.setTextFormat(form);

      txtheight = txttop.height;
      txtwidth = txttop.width;

      txttop.x = Math.floor( (canvas.width / 2) - (txtwidth / 2) );
      txttop.y = Math.floor( (canvas.height / 4) - (txtheight * 0.75)  ) + centerizer;

      canvas.addChild(txttop);

      var txtmid:TextField = new TextField();

      txtmid.autoSize = TextFieldAutoSize.LEFT;
      txtmid.text = projectdetails["thanksmid"];
      txtmid.selectable = false;
      txtmid.alwaysShowSelection = false;
      txtmid.setTextFormat(form);

      txtheight = txtmid.height;
      txtwidth = txtmid.width;

      txtmid.x = Math.floor( (canvas.width / 2) - (txtwidth / 2) );
      txtmid.y = Math.floor( (canvas.height / 2) - (txtheight / 2)  );

      canvas.addChild(txtmid);

      var txtbottom:TextField = new TextField();

      txtbottom.autoSize = TextFieldAutoSize.LEFT;
      txtbottom.text = projectdetails["thanksbottom"];
      txtbottom.selectable = false;
      txtbottom.alwaysShowSelection = false;
      txtbottom.setTextFormat(form);

      txtheight = txtbottom.height;
      txtwidth = txtbottom.width;

      txtbottom.x = Math.floor( (canvas.width / 2) - (txtwidth / 2) );
      txtbottom.y = Math.floor( (canvas.height * 0.75) - (txtheight * 0.25)  ) - centerizer;

      canvas.addChild(txtbottom);

    }

    public override function reportKeyDown(event:KeyboardEvent):void
    {
      SFScreen.addDebug("Overridden reportkey");
      hide();
      getDisplay().finishLast();

    }

    public override function isValidKey(keypress:String):Boolean
    {
      return true;
    }

    public override function getType():String
    {
      return "thanks";
    }
  }
}

