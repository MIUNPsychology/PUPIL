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

  public class SFShowMessage extends SFFrame
  {
    private static const ASSUME_CHAR_WIDTH:Number = 8;
    private static const ASSUME_DIALOG_HEIGHT:Number = 85;
    private static const TEXTFORMAT_SHOWMESSAGE:TextFormat = new SFShowMessageTextFormat();

    public function SFShowMessage(owner:SFScreen,msg:String) 
    {
      super(owner,
          Math.floor((owner.width / 2) - ((msg.length * ASSUME_CHAR_WIDTH) / 2)),
          Math.floor((owner.height / 2) - (ASSUME_DIALOG_HEIGHT / 2)),
          ASSUME_CHAR_WIDTH * msg.length + 20,
          ASSUME_DIALOG_HEIGHT,
          "Message");

      var panel:SFPanel = getPanel();
      var aHeight:Number = panel.height;
      var aWidth:Number = panel.width;

      var tf_txt:TextField = new TextField();
      tf_txt.text = msg;
      tf_txt.autoSize = TextFieldAutoSize.CENTER;
      tf_txt.x = BEVEL_WIDTH;
      tf_txt.width = aWidth-BEVEL_WIDTH;
      tf_txt.selectable = false;

      tf_txt.setTextFormat( TEXTFORMAT_SHOWMESSAGE );

      tf_txt.y = 5;

      panel.addChild(tf_txt);

      var btn:SFButton = new SFButton(panel, Math.floor(panel.width / 2) - 20, 30, 40, 25, "OK",okClick);
    }

    private function okClick(e:MouseEvent):void 
    {
      getScreen().removeChild(this);
    }


  }
}

