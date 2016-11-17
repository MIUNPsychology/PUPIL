/* --- START OF LICENSE AND COPYRIGHT BLURB ---

   This file is a part of the PUPIL project, see
   
     http://github.com/MIUNPsychology/PUPIL

   Copyright 2016 Department of Psychology, Mid Sweden University

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   --- END OF LICENSE AND COPYRIGHT BLURB --- */



package sfw
{
  import flash.display.*;
  import flash.events.*;
  import flash.text.*;

  import sfw.textformat.*;

  public class SFScreen extends SFComponent
  {
    public static var DEBUG_txt:TextField = null;

    public static var activeScreen:SFScreen = null;

    public function SFScreen(container:DisplayObjectContainer, backgroundColor:uint = COLOR_INPUT, alphaValue:Number = 1.0, drawBorder:Boolean = false, enableDebugBackdrop:Boolean = false) 
    {
      super(null,0,0,container.stage.stageWidth,container.stage.stageHeight,backgroundColor,alphaValue);

      if(drawBorder)
      {
        var shape:Shape = new Shape();
        shape.graphics.lineStyle(1,COLOR_FRAME,alphaValue);
        shape.graphics.drawRect(0,0,container.stage.stageWidth-1,container.stage.stageHeight-1);
        addChild(shape);
      }

      activeScreen = this;

      if(enableDebugBackdrop)
      {
        DEBUG_txt = new TextField();
        DEBUG_txt.defaultTextFormat = new SFDebugTextFormat();
        DEBUG_txt.width = this.width-5;
        DEBUG_txt.height = this.height-5;
        DEBUG_txt.multiline = true;
        DEBUG_txt.selectable = false;
        DEBUG_txt.setTextFormat(new SFDebugTextFormat());

        DEBUG_txt.text = "DEBUG ENABLED\n";
        addChild(DEBUG_txt);
      }

      container.addChild(this);
    }

    public static function addDebug(msg:String):void
    {
      if(DEBUG_txt != null)
      {
        DEBUG_txt.appendText(msg + "\n");
      }
    }

    public static function addError(e:Error):void
    {
      if(DEBUG_txt != null)
      {
        DEBUG_txt.appendText("ERROR: " + e.name + " (" + e.errorID + ") " + e.message + "\n");
      }
    }
  }
}

