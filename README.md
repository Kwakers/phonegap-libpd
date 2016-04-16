phonegap-libpd
==============

Cordova-phonegap plug-in for libPd

Dependency: libPd (git@gitorious.org:pdlib/libpd.git)

Add the plug-in with 
phonegap local plugin add https://github.com/kwakers/phonegap-libpd

This version of plugin is a fork of https://github.com/alesaccoia/phonegap-libpd
I add more methods to complete the library.


INSTALLATION
============

Open the xcode project in the platforms directory.

Add the Xcode project for libpd (libpd-master/libpd.xcodeproj) by right-clicking on the
top-level xcode project "TargetName", add files to "TargetName", select libpd.xcodeproj

There are 3 more steps to be done on the target build settings:
- in the "User Header Search Paths" add the path to yourpath/libpd-master/objc
- In the Build Phase "link Binary with Libraries" click on add libpd-ios.a

Now it should build. 


USAGE:
======

On the event device ready:
Initialize with
window.plugins.libPd.init();

To add to the search path use:
window.plugins.libPd.addPath('/www/pd/');
in this way all the abstractions in /www/pd will be loaded.
If you want to have a more elaborate directory structure, use the addPath at will.

Open a patch
window.plugins.libPd.openPatch('pd/sample.pd');

For example, now you can send many type of messages:
window.plugins.libPd.sendBang('toPD');
window.plugins.libPd.sendFloat(3, 'toPD');
window.plugins.libPd.sendSymbol("symbol", "on");
window.plugins.libPd.sendMessage("message", "symbol", ["on"]);
window.plugins.libPd.sendList("list", ["on"]);

you can add a listener for a [r fromPD] object:
window.plugins.libPd.addListener("fromPD","console.log");


You can open/close patches at will:
window.plugins.libPd.openPatch('pd/sample.pd');
window.plugins.libPd.closePatch();

Just remember that init/deinit have to be called just once as they start/stop the audio
window.plugins.libPd.deinit();

TODO:
=====

- Needs a better handling for when the app is put in the background
- Use Javascript function pointer for Callback instead of string.
- Write in array
- UTF8 is ok ?
- For now you can send bangs, floats, symbols, lists, messages, and receive them.
you can read an array too.
- Make a Java version of this plugin for Android


LibPd includes many other features, including receiving Midi messages from PD.

Objective C is a dark langage for me, so i try to do my best.
If you want to help, you're welcome.
