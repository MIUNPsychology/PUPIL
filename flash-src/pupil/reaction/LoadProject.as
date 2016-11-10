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

  public class LoadProject
  {
    private var screen:SFScreen = null;
    private var frmMain:SFFrame = null;
    private var pnlMain:SFPanel = null;

    private var xmlconv:SFXMLConversation = null;
    private var currentCommand:String = "";

    private var btnOpen:SFButton = null;
    private var lstProject:SFList = null;
    private var listelements:Array = new Array();
    private var lblLoading:SFLabel = null;

    private var project:String = null;

    private var numscenes:Number = 0;
    private var numimages:Number = 0;

    private var blocklist:Array = null;
    private var scenelist:Array = null;
    private var imagelist:Array = null;

    private var thingsToLoad:uint = 0;
    private var loadedSoFar:uint = 0;
    private var currentScene:uint = 0;
    private var currentPosition:uint = 0;

    private var prgProgress:SFProgressBar = null;

    private var bulk:SFBulkImageLoader = null;
    private var sceneobjects:Array = new Array();
    private var imageHash:ImageHash = new ImageHash();

    private var detailshash:Object;

    public function LoadProject(myscreen:SFScreen, myproject:String)
    {
      screen = myscreen;
      project = myproject;

      frmMain = new SFFrame(screen,280,120,435,90,"Loading project data");
      pnlMain = frmMain.getPanel();

      lblLoading = new SFLabel(pnlMain,10,10,300,25,"Calculating what to load...");

      xmlconv = new SFXMLConversation("../pupil/experiment",xmlComplete,xmlMalformed,xmlProgress,xmlIoError,xmlSecurityError,xmlOpen,xmlHTTPStatus);

      var cmd:XML = new XML("<command><function>getprojectdetails</function><parameter name=\"name\" value=\"" + project + "\" /></command>");
      currentCommand = "getprojectdetails";
      xmlconv.say(cmd);
    }

    private function xmlComplete(e:Event):void
    {
//      SFScreen.addDebug("complete");
      var response:XML = xmlconv.getLastResponse();
//      SFScreen.addDebug(response.toXMLString());
//      SFScreen.addDebug(currentCommand);
      var result:String = response.name();

      if(result == "error")
      {
        var tmp:SFShowMessage = new SFShowMessage(screen,"Last command did not complete. Error was: " + response);
      }
      else
      {
        var numelem:uint = 0;
        var data:XML = response.data[0];
        var row:XML = null;
        var cmd:XML = null;

        if(currentCommand == "getsceneinfo")
        {
          try
          {
            //SFScreen.addDebug(response.toXMLString());

            var scenename:String = response.description;
            var projectname:String = response.project;
            var pattern:String = response.pattern;
            var scenetype:String = response.scenetype;
            var correct:String = response.correctkey;
            var timeout:Number = response.timeout;
            var lead:String = response.lead;

            var validtype:Boolean = false;

            var sceneinfo:PupilScene = null;

            if(scenetype == "static_image")
            {
              validtype = true;
              sceneobjects[sceneobjects.length] = new SIScene(screen,imageHash,response.ssi[0],scenename,pattern,projectname,detailshash,correct,timeout);
            }

            if(scenetype == "static_category_random_image")
            {
              validtype = true;
              sceneobjects[sceneobjects.length] = new SCRIScene(screen,imageHash,response.scri[0],scenename,pattern,projectname,detailshash,correct,timeout);
            }

            if(scenetype == "select_option_static_image")
            {
              validtype = true;
              sceneobjects[sceneobjects.length] = new SOSIScene(screen,imageHash,response.sosi[0],scenename,pattern,projectname,detailshash,correct,timeout,lead);
            }

            if(scenetype == "select_option_random_image")
            {
              validtype = true;
              sceneobjects[sceneobjects.length] = new SORIScene(screen,imageHash,response.sori[0],scenename,pattern,projectname,detailshash,correct,timeout,lead);
            }
            if(scenetype == "text")
            {
              validtype = true;
              sceneobjects[sceneobjects.length] = new TextScene(screen,scenename,projectname,detailshash,lead);
            }

            currentScene++;
            updatePosition();
            loadNextScene();
          }
          catch(e:Error)
          {
            SFScreen.addDebug(e.toString());
          }
        }

        if(currentCommand == "listuniqueimages")
        {
          imagelist = new Array();
//          SFScreen.addDebug(response.toXMLString());
          var fn:String;

          for each (row in response.image)
          {
            fn = "images/" + row.@category + "/" + row.@file;
            imagelist[numelem++] = fn;
//            SFScreen.addDebug("Image: " + fn);
          }

          numimages = imagelist.length;
//          SFScreen.addDebug("We have " + numimages + " images");
          if(lblLoading != null)
          {
            pnlMain.removeChild(lblLoading);
          }
          lblLoading = new SFLabel(pnlMain,10,10,300,25,"Loading scene info");

          thingsToLoad = numscenes + numimages;

          updatePosition();

          loadNextScene();
        }

        if(currentCommand == "getblockscenelist")
        {
          //SFScreen.addDebug(response.toXMLString());

          blocklist = new Array();
          scenelist = new Array();

          var blkscene:Array;

          var scene:Object;
          var blk:Object;
          var random:String;
          var textfirst:String;

          var curblockitem:Number = -1;
          var lastblock:String = "öljgsljgasöldgjöglkj";

          for each (row in data.row)
          {          
            
            scene = new Object;

            scene['block'] = row.column.(@name == "block");
            scene['scenetype'] = row.column.(@name == "scenetype");
            scene['description'] = row.column.(@name == "description");
            scene['images'] = row.column.(@name == "images");
            scene['pattern'] = row.column.(@name == "pattern");

            random = row.column.(@name == "random");
            textfirst = row.column.(@name == "textfirst");

            scenelist[numelem++] = scene;

            if(scene['block'] != lastblock)
            {
              curblockitem++;
              lastblock = scene['block'];

              blk = new Object;

              blk['name'] = lastblock;
              blk['random'] = random;
              blk['textfirst'] = textfirst;
              blk['scenes'] = new Array();

              // SFScreen.addDebug("Block " + curblockitem + ": " + lastblock + " random=" + random + " textfirst=" + textfirst);

              blocklist[curblockitem] = blk;
            }

            blkscene = blk['scenes'];
            blkscene[blkscene.length] = numelem - 1;
            
            // SFScreen.addDebug("Scene " + (numelem -1) + ": " + scene['block'] + " " + scene['description'] + " " + scene['scenetype'] + " " + scene['pattern']);
          }

          numscenes = numelem;
          SFScreen.addDebug("We have " + numscenes + " scenes");

          cmd = new XML("<command><function>listuniqueimages</function><parameter name=\"name\" value=\"" + project + "\" /></command>");
          currentCommand = "listuniqueimages";
          xmlconv.say(cmd);
        }


        if(currentCommand == "getprojectdetails")
        {
          data = response.data[0].row[0];
//          SFScreen.addDebug(data.toXMLString());

          var projname:String = "";
          var teachername:String = "";
          var count:String = "";

          projname = data.column.(@name == "name");
          teachername = data.column.(@name == "login");

          detailshash = new Object();

          detailshash["displaywelcome"] = data.column.(@name == "displaywelcome");
          detailshash["displaythanks"] = data.column.(@name == "displaythanks");
          detailshash["welcometop"] = data.column.(@name == "welcometop");
          detailshash["welcomemid"] = data.column.(@name == "welcomemid");
          detailshash["welcomebottom"] = data.column.(@name == "welcomebottom");
          detailshash["thankstop"] = data.column.(@name == "thankstop");
          detailshash["thanksmid"] = data.column.(@name == "thanksmid");
          detailshash["thanksbottom"] = data.column.(@name == "thanksbottom");
          detailshash["urlredirect"] = data.column.(@name == "urlredirect");
          detailshash["maxwidth"] = data.column.(@name == "maxwidth");
          detailshash["maxheight"] = data.column.(@name == "maxheight");
          detailshash["flashright"] = data.column.(@name == "flashright");
          detailshash["flashwrong"] = data.column.(@name == "flashwrong");
          detailshash["displaypolicy"] = data.column.(@name == "displaypolicy");
          detailshash["subsetsize"] = data.column.(@name == "subsetsize");
          detailshash["flashwhite"] = data.column.(@name == "flashwhite");
          detailshash["hideopts"] = data.column.(@name == "hideopts");
          detailshash["whitemin"] = data.column.(@name == "whitemin");
          detailshash["whitemax"] = data.column.(@name == "whitemax");
          detailshash["splicearray"] = data.column.(@name == "splicearray");
          detailshash["blockrandom"] = data.column.(@name == "blockrandom");

          SFScreen.addDebug("urlredirect: " + detailshash["urlredirect"]);

          if(data.column.(@name == "rightimage") != "")
          {
            detailshash["rightimg"] = data.column.(@name == "rightcategory") + "/" + data.column.(@name == "rightimage");
          }
          else
          {
            detailshash["rightimg"] = "";
          }

          if(data.column.(@name == "wrongimage") != "")
          {
            detailshash["wrongimg"] = data.column.(@name == "wrongcategory") + "/" + data.column.(@name == "wrongimage");
          }
          else
          {
            detailshash["wrongimg"] = "";
          }

          if(data.column.(@name == "pauseimage") != "")
          {
            detailshash["pauseimg"] = data.column.(@name == "pausecategory") + "/" + data.column.(@name == "pauseimage");
          }
          else
          {
            detailshash["pauseimg"] = "";
          }

          cmd = new XML("<command><function>getblockscenelist</function><parameter name=\"name\" value=\"" + project + "\" /></command>");
          currentCommand = "getblockscenelist";
          xmlconv.say(cmd);
        }
      }
    }

    private function updatePosition():void
    {
      if(prgProgress == null)
      {
        prgProgress = new SFProgressBar(pnlMain,10,35,300,16,thingsToLoad);
      }

      loadedSoFar++;

      prgProgress.setPos(loadedSoFar);

    }

    private function loadNextScene():void
    {
      if(currentScene < scenelist.length)
      {
        var scene:Object = scenelist[currentScene];
        var xml:String = "<command><function>getsceneinfo</function>";
        xml = xml + "<parameter name=\"scenename\" value=\"" + scene['description'] + "\" />";
        xml = xml + "<parameter name=\"projectname\" value=\"" + project + "\" />";
        xml = xml + "</command>";

        var cmd:XML = new XML(xml);
        currentCommand = "getsceneinfo";
//        SFScreen.addDebug(cmd.toXMLString());
        xmlconv.say(cmd);
      }
      else
      {
        loadImages();
      }
    }

    private function loadImages():void
    {
      if(lblLoading != null)
      {
        pnlMain.removeChild(lblLoading);
      }
      
      lblLoading = new SFLabel(pnlMain,10,10,300,25,"Loading images");

      var i:Number;

      bulk = new SFBulkImageLoader(imagelist,bulkOnComplete,bulkOnError,bulkOnProgress);

    }

    private function onStartClick(e:MouseEvent = null):void
    {
      SFScreen.addDebug("Start project");

      try
      {
        var disp:DisplayProject = new DisplayProject(screen,project,sceneobjects,detailshash,blocklist);
        screen.removeChild(frmMain);
      }
      catch(error:Error)
      {
        SFScreen.addDebug("nils! " + error);
      }
    }

    private function bulkOnComplete():void
    {
 //     SFScreen.addDebug("bulk complete");
      if(lblLoading != null)
      {
        pnlMain.removeChild(lblLoading);
      }
      
      lblLoading = new SFLabel(pnlMain,10,10,300,25,"Done!");

      imageHash.registerImages(bulk,imagelist);

      var scene:PupilScene = null;

      for(var i:Number = 0; i < sceneobjects.length; i++)
      {
        scene = PupilScene(sceneobjects[i]);
        scene.render();
      }

      SFScreen.addDebug("Done rendering.");
      SFScreen.addDebug("displaypolicy is: " + detailshash['displaypolicy']);
      SFScreen.addDebug("subsetsize is: " + detailshash['subsetsize']);

      var sob1:Array = new Array();
      var r:Number;
      var n:Number;
      var p:PupilScene;

      if(detailshash['displaypolicy'] == "2")
      {
        // Randomize all

        while(sceneobjects.length > 0)
        {
          r = Math.floor(Math.random() * sceneobjects.length - 0.0001);
          p = sceneobjects.splice(r,1)[0];
          sob1[sob1.length] = p;
          // SFScreen.addDebug(r + " -- " + p + " -- " + sob1[sob1.length-1]);
        }

        sceneobjects = sob1;
//        SFScreen.addDebug("sceneobject: " + sceneobjects.length);
      }

      if(detailshash['displaypolicy'] == "3")
      {
        // randomize subset

        for(n = 0; n < Number(detailshash['subsetsize']); n++)
        {
          r = Math.floor(Math.random() * sceneobjects.length - 0.0001);
          p = sceneobjects.splice(r,1)[0];
          sob1[sob1.length] = p;
//          SFScreen.addDebug(r + " -- " + p + " -- " + sob1[sob1.length-1]);
        }

        sceneobjects = sob1;
//        SFScreen.addDebug("sceneobject: " + sceneobjects.length);
      }

      var btnStart:SFButton = new SFButton(pnlMain,320,10,100,40,"Start!",onStartClick);
      /* var disp:DisplayProject = new DisplayProject(screen,project,sceneobjects,detailshash);
      screen.removeChild(frmMain); */
    }

    private function bulkOnError(e:IOErrorEvent):void
    {
      SFScreen.addDebug("bulk error " + e.toString());
    }

    private function bulkOnProgress(current:uint,max:uint):void
    {
//      SFScreen.addDebug("bulk progress " + current + "/" + max);
      updatePosition();
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

