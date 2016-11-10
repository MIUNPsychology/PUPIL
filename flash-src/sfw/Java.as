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


    
    private function javaTest(e:MouseEvent):void
    {
      SFScreen.addDebug("Knapptryckning");

      netobj = new SFNetObject();
      netobj.setValue("test1","heya");
      netobj.setValue("test2","ugga bugga humpa hopp // ; kkk");

      // netobj.socketPushToServer("127.0.0.1",3500,true,javaDone);
    }

    private function javaDone():void
    {
      // lyckat?
      // skriva ut svar från server?
    }
  }
}

