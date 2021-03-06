/*
* Copyright (c) 2015 Guillaume Piolat
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are
* met:
*
* * Redistributions of source code must retain the above copyright
*   notice, this list of conditions and the following disclaimer.
*
* * Redistributions in binary form must reproduce the above copyright
*   notice, this list of conditions and the following disclaimer in the
*   documentation and/or other materials provided with the distribution.
*
* * Neither the names 'Derelict', 'DerelictSDL', nor the names of its contributors
*   may be used to endorse or promote products derived from this software
*   without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module derelict.carbon.carbon;


import dplug.core.sharedlib;

import derelict.carbon.hitoolbox;

import dplug.core.nogc;

version(OSX)
    enum libNames = "/System/Library/Frameworks/Carbon.framework/Carbon";
else
    enum libNames = "";


class DerelictCarbonLoader : SharedLibLoader
{
    public
    {
        nothrow @nogc:
        this()
        {
            super(libNames);
        }

        override void loadSymbols()
        {
            // hitoolbox
            bindFunc(cast(void**)&GetMainEventLoop, "GetMainEventLoop");
            bindFunc(cast(void**)&InstallEventHandler, "InstallEventHandler");
            bindFunc(cast(void**)&GetControlEventTarget, "GetControlEventTarget");
            bindFunc(cast(void**)&GetWindowEventTarget, "GetWindowEventTarget");

           // Not available in macOS 10.12 in 64-bit
            static if (size_t.sizeof == 4)
                bindFunc(cast(void**)&CreateUserPaneControl, "CreateUserPaneControl");

            bindFunc(cast(void**)&GetWindowAttributes, "GetWindowAttributes");
            bindFunc(cast(void**)&HIViewGetRoot, "HIViewGetRoot");
            bindFunc(cast(void**)&HIViewFindByID, "HIViewFindByID");
            bindFunc(cast(void**)&HIViewSetNeedsDisplayInRect, "HIViewSetNeedsDisplayInRect");
            bindFunc(cast(void**)&HIViewAddSubview, "HIViewAddSubview");

            // Removed for no reason, still here in macOS 10.12
            //bindFunc(cast(void**)&GetRootControl, "GetRootControl");
            //bindFunc(cast(void**)&CreateRootControl, "CreateRootControl");
            //static if (size_t.sizeof == 4)
            //    bindFunc(cast(void**)&EmbedControl, "EmbedControl");

            bindFunc(cast(void**)&SizeControl, "SizeControl");
            bindFunc(cast(void**)&GetEventClass, "GetEventClass");
            bindFunc(cast(void**)&GetEventKind, "GetEventKind");
            bindFunc(cast(void**)&GetEventParameter, "GetEventParameter");
            bindFunc(cast(void**)&RemoveEventLoopTimer, "RemoveEventLoopTimer");
            bindFunc(cast(void**)&RemoveEventHandler, "RemoveEventHandler");
            bindFunc(cast(void**)&InstallEventLoopTimer, "InstallEventLoopTimer");
            bindFunc(cast(void**)&HIPointConvert, "HIPointConvert");
            bindFunc(cast(void**)&HIViewGetBounds, "HIViewGetBounds");
        }
    }
}


private __gshared DerelictCarbonLoader DerelictCarbon;

private __gshared loaderCounterCarbon = 0;

// Call this each time a novel owner uses these functions
// TODO: hold a mutex, because this isn't thread-safe
void acquireCarbonFunctions() nothrow @nogc
{
    if (DerelictCarbon is null)  // You only live once
    {
        DerelictCarbon = mallocNew!DerelictCarbonLoader();
        DerelictCarbon.load();
    }
}

// Call this each time a novel owner releases a Cocoa functions
// TODO: hold a mutex, because this isn't thread-safe
void releaseCarbonFunctions() nothrow @nogc
{
    /*if (--loaderCounterCarbon == 0)
    {
        DerelictCarbon.unload();
        DerelictCarbon.destroyFree();
    }*/
}

unittest
{
    version(OSX)
    {
        acquireCarbonFunctions();
        releaseCarbonFunctions();
    }
}
