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

  public class SFXMLConversation
  {
    private var currentLoader:URLLoader = null;
    private var currentServerUrl:String = "";

    private var currentOnComplete:Function = null;
    private var currentOnProgress:Function = null;
    private var currentOnIoError:Function = null;
    private var currentOnSecurityError:Function = null;
    private var currentOnOpen:Function = null;
    private var currentOnHTTPStatus:Function = null;

    private var currentOnMalformed:Function = null;

    private var lastSent:XML = null;
    private var lastResponse:XML = null;

    public function SFXMLConversation(serverUrl:String,onComplete:Function = null,onMalformed:Function = null,onProgress:Function = null,onIoError:Function = null, onSecurityError:Function = null, onOpen:Function = null, onHTTPStatus:Function = null)
    {
      currentServerUrl = serverUrl;

      currentOnComplete = onComplete;
      currentOnMalformed = onMalformed;
      currentOnProgress = onProgress;
      currentOnIoError = onIoError;
      currentOnSecurityError = onSecurityError;
      currentOnOpen = onOpen;
      currentOnHTTPStatus = onHTTPStatus;
    }

    public function setOnComplete(func:Function):void
    {
      currentOnComplete = func;
    }

    public function setOnMalformed(func:Function):void
    {
      currentOnMalformed = func;
    }

    public function setOnProgress(func:Function):void
    {
      currentOnProgress = func;
    }

    public function setOnIoError(func:Function):void
    {
      currentOnIoError = func;
    }

    public function setOnSecurityError(func:Function):void
    {
      currentOnSecurityError = func;
    }

    public function setOnOpen(func:Function):void
    {
      currentOnOpen = func;
    }

    public function setOnHTTPStatus(func:Function):void
    {
      currentOnHTTPStatus = func;
    }

    // Event stubs

    private function httpOnComplete(e:Event):void
    {
      //SFScreen.addDebug("httpOnComplete()");

      try
      {        
        var readXML:XML = new XML(currentLoader.data);
        lastResponse = readXML;
        if(currentOnComplete != null)
        {
          currentOnComplete(e);
        }
      }
      catch(error:Error)
      {
        xmlOnMalformed(error);
        SFScreen.addDebug(String(currentLoader.data));
      }
    }

    private function xmlOnMalformed(e:Error):void
    {
      //SFScreen.addDebug("xmlOnMalformed() -- Malformed XML: " + e);

      if(currentOnMalformed != null)
      {
        currentOnMalformed(e);
      }
    }

    private function httpOnProgress(e:Event):void
    {
      //SFScreen.addDebug("httpOnProgress()");
      if(currentOnProgress != null)
      {
        currentOnProgress(e);
      }
    }

    private function httpOnIoError(e:Event):void
    {
      //SFScreen.addDebug("httpOnIoError()");
      if(currentOnIoError != null)
      {
        currentOnIoError(e);
      }
    }

    private function httpOnSecurityError(e:Event):void
    {
      //SFScreen.addDebug("httpOnSecurityError()");
      if(currentOnSecurityError != null)
      {
        currentOnSecurityError(e);
      }
    }

    private function httpOnOpen(e:Event):void
    {
      //SFScreen.addDebug("httpOnOpen()");
      if(currentOnOpen != null)
      {
        currentOnOpen(e);
      }
    }

    private function httpOnHTTPStatus(e:Event):void
    {
      //SFScreen.addDebug("httpOnHTTPStatus()");
      if(currentOnHTTPStatus != null)
      {
        currentOnHTTPStatus(e);
      }
    }


    // --------------

    public function say(xml:XML):void
    {
      var request:URLRequest = new URLRequest(currentServerUrl);
      var vars:URLVariables = new URLVariables();

      if(xml != null)
      {
        vars.xml = xml.toString();
      }
      else
      {
        vars.xml = "";
      }

      request.method = URLRequestMethod.POST;
      request.data = vars;

      lastSent = xml;

      currentLoader = new URLLoader();

      currentLoader.addEventListener(Event.COMPLETE, httpOnComplete);
      currentLoader.addEventListener(Event.OPEN, httpOnOpen);
      currentLoader.addEventListener(ProgressEvent.PROGRESS, httpOnProgress);
      currentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, httpOnSecurityError);
      currentLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpOnHTTPStatus);
      currentLoader.addEventListener(IOErrorEvent.IO_ERROR, httpOnIoError);

      try
      {
        currentLoader.load(request);
      }
      catch(e:Error)
      {
        SFScreen.addDebug("crash");
      }
    }

    public function sayNetObject(obj:SFNetObject):void
    {
      if(obj == null)
      {
        say(<netobject></netobject>);
        return;
      }
      say(obj.getAsXML());
    }

    public function sayNetTable(tbl:SFNetTable):void
    {
      if(tbl == null)
      {
        say(<nettable></nettable>);
        return;
      }

      say(tbl.getTableAsXML());
    }

    public function getLastSay():XML
    {
      return lastSent;
    }

    public function getLastResponse():XML
    {
      return lastResponse;
    }

    public function getLastResponseAsNetObject():SFNetObject
    {
      if(lastResponse == null)
      {
        SFScreen.addDebug("XML is null");
        return null;
      }

      if(lastResponse.localName() == "netobject")
      {
        var netobj:SFNetObject = new SFNetObject();
        var items:XMLList = lastResponse.children();
        var child:XML = null;

        for each (child in items)
        {
          netobj.setValue(child.localName(),child.toString());
        }

        return netobj;
      }
      else
      {
        SFScreen.addDebug("XML does not encapsulate SFNetObject");
      }

      return null;
    }


    public function getLastResponseAsNetTable():SFNetTable
    {
      if(lastResponse == null)
      {
        SFScreen.addDebug("XML is null");
        return null;
      }

      if(lastResponse.localName() == "nettable")
      {
        return SFNetTable.makeTableFromXML(lastResponse);

      }
      else
      {
        SFScreen.addDebug("XML does not encapsulate SFNetTable");
      }

      return null;
    }
  }
}

