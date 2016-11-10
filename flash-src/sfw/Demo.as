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



package
{
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.*;
  import sfw.*;
  import sfw.textformat.*;
  import sfw.net.*;

  public class Demo extends MovieClip
  {
    private var screen:SFScreen = null;

    private var xmlconv:SFXMLConversation = null;

    public var horiz:SFHorizontalScrollBar = null;
    public var vert:SFVerticalScrollBar = null;

    public var netobj:SFNetObject = null;

    public function Demo()
    {
      screen = new SFScreen(this,0xFFFFFF,1.0,true,true);

/*      var cmp:SFComponent = new SFComponent(screen,140,40,100,100);
      cmp.drawBevel(SFComponent.BEVEL_UP,4);*/

      var menuItems:Array = new Array();
      menuItems[0] = new SFMenuItem("menu item",menuItemClick);
      menuItems[1] = new SFMenuItem("menu item 2",menuItemClick);
      menuItems[2] = new SFMenuItem("menu item 3",menuItemClick);

      var menus:Array = new Array();
      menus[0] = new SFMenu("Test",menuItems);

      var mainmenu:SFMainMenu = new SFMainMenu(menus);

      var demoWin:SFFrame = new SFFrame(screen,240,40,600,600,"Demo",mainmenu);
      var panel:SFPanel = demoWin.getPanel();

      var panel3:SFPanel = new SFPanel(panel,110,10,50,50, SFComponent.BEVEL_DOWN);
      var panel4:SFPanel = new SFPanel(panel,210,10,50,50, SFComponent.BEVEL_FRAME);
      var button:SFButton = new SFButton(panel,10,10,70,40,"Button",buttonClick);
      var label1:SFLabel = new SFLabel(panel,150,100,100,20,"A label");
      var label2:SFLabel = new SFLabel(panel,150,130,100,20,"A bold label",true);
      var txt:SFTextField = new SFTextField(panel,150,160,100);
      var chk:SFCheckBox = new SFCheckBox(panel,10,100,100,20,"CheckBox");

      var prg:SFProgressBar = new SFProgressBar(panel,150,200,100,10);
      prg.setPos(50);

      horiz = new SFHorizontalScrollBar(panel,150,230,100,17,20,horizChange);
      vert = new SFVerticalScrollBar(panel,260,130,17,100,20,vertChange);

      var rbs:Array = new Array();
      rbs[0] = new SFRadioButton(panel,10,150,100,20,"RadioButton 1");
      rbs[1] = new SFRadioButton(panel,10,170,100,20,"RadioButton 2");
      rbs[2] = new SFRadioButton(panel,10,190,100,20,"RadioButton 3");

      var rdbg:SFRadioButtonGroup = new SFRadioButtonGroup(rbs);

      var pnlTest:SFPanel = new SFPanel(null,0,0,200,200,SFComponent.BEVEL_NONE);

      var shape:Shape=new Shape();      
      shape.graphics.lineStyle(1,0xFFFFFF);
      shape.graphics.beginFill(0xFFFFFF);
      shape.graphics.drawRect(0,0,pnlTest.width,pnlTest.height);
      shape.graphics.lineStyle(1,0x000000);
      shape.graphics.beginFill(0xFF0000);
      shape.graphics.drawRect(10,10,80,80);
      shape.graphics.beginFill(0x00FF00);
      shape.graphics.drawRect(50,50,80,80);
      shape.graphics.beginFill(0x0000FF);
      shape.graphics.drawRect(90,90,80,80);

      pnlTest.addChild(shape);

      var items:Array = ["line 1","line 2", "A really long line", "line 4", "line 5", "line 6", "line 7"];

      var list:SFList = new SFList(panel,320,300,200,100,items);

      var scroller:SFScrollPane = new SFScrollPane(panel,320,100,150,150,pnlTest);

      var phpbtn:SFButton = new SFButton(panel,10,300,70,40,"PHP",phpTest);
      var javabtn:SFButton = new SFButton(panel,10,350,70,40,"Java",javaTest);

      demoWin.registerTabComponent(button);
      demoWin.registerTabComponent(javabtn);
      demoWin.registerTabComponent(phpbtn);
      demoWin.grabTabControl();

    }

    private function phpTest(e:MouseEvent):void
    {

      var tbl:SFNetTable = new SFNetTable(3,3,["a","b","c"]);

      var r:uint = 0;
      var c:uint = 0;

      for(r = 0; r < 3; r++)
      {
        for(c = 0; c < 3; c++)
        {
          tbl.setValue(r,c,"c" + c + " r" + r);
        }
      }

      xmlconv = new SFXMLConversation("php/xml.php",javaDone);

      xmlconv.sayNetTable(tbl);
    }

    // KNAPP FÖR JAVA
    
    private function javaTest(e:MouseEvent):void
    {
      netobj = new SFNetObject();
      netobj.setValue("message","heya");
      netobj.setValue("bluttan","blurk");

      xmlconv = new SFXMLConversation("php/xml.php",javaDone);
      xmlconv.sayNetObject(netobj);
    }

    private function javaDone(e:Event):void
    {
      SFScreen.addDebug("done");

      var tbl:SFNetTable = xmlconv.getLastResponseAsNetTable();

//      SFScreen.addDebug(xmlconv.getLastResponse().toString());
    }

    private function httpLoaded():void
    {
      var msg:SFShowMessage = new SFShowMessage(screen,netobj.getValue("response"));
    }

    private function buttonClick(e:MouseEvent):void 
    {
      var msg:SFShowMessage = new SFShowMessage(screen,"Button click with really long text message");
    }

    private function menuItemClick(e:MouseEvent):void 
    {
      SFScreen.addDebug("Menu item");
    }

    private function horizChange():void
    {
      SFScreen.addDebug("Horizontal scrollbar change, pos now: " + horiz.getPos());
    }

    private function vertChange():void
    {
      SFScreen.addDebug("Vertical scrollbar change, pos now: " + vert.getPos());
    }
  }
}

