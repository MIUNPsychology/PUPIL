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

  import flash.net.*;
  import flash.events.*;

  public class TestSocket extends MovieClip
  {
    private var screen:SFScreen = null;
    public var netobj:SFNetObject = null;

    public function TestSocket()
    {
      screen = new SFScreen(this,0xFFFFFF,1.0,true,true);
      var javabtn:SFButton = new SFButton(screen,250,50,70,40,"TestSocket",testSocket);
    }

    private var socket:Socket;
    private var currentPort:uint;
    private var toPort:uint;

    private function testSocket(e:MouseEvent):void
    {
      SFScreen.addDebug("Öppna socket");
      createSocket();

      toPort = 3500;
      socket.connect("10.0.0.1", toPort);

      deleteSocket();
    }


    private function createSocket():void
    {
      socket = new Socket();
      socket.addEventListener("connect", socket_connect);
      socket.addEventListener("ioError", socket_ioError);

    }
    private function deleteSocket():void
    {
      socket.removeEventListener("connect",socket_connect);
      socket.removeEventListener("ioError", socket_ioError);
      socket.close ();
    }

    private function socket_connect(event:Event):void
    {
      socket.close();
    }

    private function socket_ioError(event:IOErrorEvent):void
    {
      /* 
	 Not sure, when there is ioError I am not able to reuse same socket object.
	 So deleting current socket object and recreating another socket object...
       */
      deleteSocket();
      createSocket();
    }
  }

}

