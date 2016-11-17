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



package sfw.net
{
  import sfw.*;
  import sfw.net.*;
  import flash.net.*;
  import flash.events.*;
  import flash.display.*;

  public class SFNetObject
  {
    private var variables:Array = null;
    private var dataObject:Object = null;
    private var componentTies:Object = null;

    private var currentLoader:URLLoader = null;
    private var currentOnFinished:Function = null;

    public function SFNetObject()
    {
      variables = new Array();
      dataObject = new Object();
      componentTies = new Object();
    }

    public function setValue(varName:String, value:String):void
    {
      dataObject[varName] = value;
      var name:String = "";
      for(name in variables)
      {
        if(name == varName)
        {
          return;
        }
      }
      var last:uint = variables.length;

      variables[last] = varName;
    }

    public function getValue(varName:String):String
    {
      return String(dataObject[varName]);
    }

    public function tie(varName:String, component:SFComponent):void
    {
      //
    }

    public function pullFromComponents():void
    {
      //
    }

    public function pushToComponents():void
    {
      //
    }

    public function listVariables():Array
    {
      return variables;
    }



    // START STUB FOR JAVA INTERACTION


    private function socketFetchFromServer(serverIP:String, port:uint, onFinished:Function = null):void
    {
      currentOnFinished = onFinished;

      // Do socket comm. Set/call socketFetchComplete 
      // when done

    }

    private function socketPushToServer(serverIP:String, port:uint, readResponse:Boolean = false, onFinished:Function = null):void
    {
      currentOnFinished = onFinished;
      
      // Do socket comm. Set/call socketPushComplete 
      // when done

    }

    private function socketFetchComplete(e:Event):void
    {
      // Tidy up. If called with readResponse = true, initiate
      // second socket communication.

      if(currentOnFinished != null)
      {
        currentOnFinished();
      }
    }

    private function socketPushComplete(e:Event):void
    {
      if(currentOnFinished != null)
      {
        currentOnFinished();
      }
    }

    private function socketError(e:Event):void
    {

    }


    // END STUB FOR JAVA INTERACTION


    private function httpFetchComplete(e:Event):void
    {
      var uvars:URLVariables = currentLoader.data;

      if(uvars != null)
      {
        var name:String;
        var value:String;

        for(var s:String in uvars)
        {
          name = s;
          value = uvars[s];

          name = name.replace(/[^0-9a-zA-Z]/,"");
          value = value.replace(/[\f\n]+$/,"");
          value = value.replace(/^[\f\n]+/,"");

          setValue(name,value);
        }
      }

      if(currentOnFinished != null)
      {
        currentOnFinished();
      }
    }

    private function httpFetchError(e:Event):void
    {
      SFScreen.addDebug("fetch error");
    }

    public function httpFetchFromServer(url:String, onFinished:Function):void
    {
      var request:URLRequest = new URLRequest(url);
      var loader:URLLoader = new URLLoader();

      loader.dataFormat = URLLoaderDataFormat.VARIABLES;
      loader.addEventListener(Event.COMPLETE, httpFetchComplete);
      loader.addEventListener(IOErrorEvent.IO_ERROR, httpFetchError);

      currentOnFinished = onFinished;
      currentLoader = loader;
      
      try
      {
        loader.load(request);
      }
      catch(e:Error)
      {
        SFScreen.addDebug("crash");
      }

    }

    public function httpSendToServer(url:String, onFinished:Function, method:String = "POST"):void
    {
      var vars:URLVariables = new URLVariables();

      for(var s:String in dataObject)
      {
        vars[s] = getValue(s);
      }

      var request:URLRequest = new URLRequest(url);
      request.data = vars;

      if(method == "POST")
      {
        request.method = URLRequestMethod.POST;
      }

      var loader:URLLoader = new URLLoader();

      loader.dataFormat = URLLoaderDataFormat.VARIABLES;
      loader.addEventListener(Event.COMPLETE, httpFetchComplete);
      loader.addEventListener(IOErrorEvent.IO_ERROR, httpFetchError);

      currentOnFinished = onFinished;
      currentLoader = loader;
      
      try
      {
        loader.load(request);
      }
      catch(e:Error)
      {
        SFScreen.addDebug("crash");
      }
    }

    public function readFromFlashVars(container:MovieClip):void
    {
      var name:String;
      var value:String;
      var params:Object = LoaderInfo(container.loaderInfo).parameters;
      for (name in params) {
        value = String(params[name]);
        setValue(name,value);
      }
    }

    public function sendToJavaScript(formName:String):void
    {
      var js:String = "";
      var req:URLRequest = null;

      var name:String = "";
      var value:String = "";

      var reqstr:String = "";

      for(var s:String in dataObject)
      {
        name = s;
        value = getValue(name);
        if(reqstr != "")
        {
          reqstr = reqstr + "&";
        }
        reqstr = reqstr + name + "=" + value;
      }
      js = "javascript:setFormComponent('" + formName + "','" + reqstr + "');";
//      SFScreen.addDebug(js);
      req = new URLRequest(js);
      navigateToURL(req,"_self");        
    }

    public function getAsXML():XML
    {
      var xml:XML = <netobject></netobject>;

      var names:Array = listVariables();
      var name:String = "";
      var value:String = "";

      var i:uint;

      for(i = 0; i < names.length; i++)
      {
        name = names[i];
        value = getValue(name);
        xml.appendChild("<" + name + ">" + value + "</" + name + ">");
      }

      return xml;
    }
  }
}

