//
//  libPd.h
//  phonegap-libpd
//  MIT License
//
//  Created by Alessandro Saccoia And Florian Rey on 14 April 2016.
//
//

#import <Cordova/CDV.h>
#import "PdBase.h"
#import "PdFile.h"
#import "PdDispatcher.h"
#import "PdMidiDispatcher.h"
#import "PdAudioController.h"

@interface libPdListener : NSObject<PdListener>
@end

@interface libPdMidiListener : NSObject<PdMidiListener>
@end

@interface libPd : CDVPlugin
    - (void)init:(CDVInvokedUrlCommand*)command;
    - (void)deinit:(CDVInvokedUrlCommand*)command;
    - (void)openPatch:(CDVInvokedUrlCommand*)command;
    - (void)closePatch:(CDVInvokedUrlCommand*)command;
    - (void)addPath:(CDVInvokedUrlCommand*)command;
    - (void)sendBang:(CDVInvokedUrlCommand*)command;
    - (void)sendSymbol:(CDVInvokedUrlCommand*)command;
    - (void)sendList:(CDVInvokedUrlCommand*)command;
    - (void)sendMessage:(CDVInvokedUrlCommand*)command;
    - (void)addListener:(CDVInvokedUrlCommand*)command;
    - (void)removeListener:(CDVInvokedUrlCommand*)command;
    - (void)removeAllListeners:(CDVInvokedUrlCommand*)command;
    - (void)addMidiListener:(CDVInvokedUrlCommand*)command;
    - (void)removeMidiListener:(CDVInvokedUrlCommand*)command;
    - (void)removeAllMidiListeners:(CDVInvokedUrlCommand*)command;
    - (void)readArray:(CDVInvokedUrlCommand*)command;
    - (BOOL)setupPd;

    @property (nonatomic, retain) PdFile *patch;
    @property (nonatomic, retain) PdAudioController *audioController;
    @property (nonatomic, retain) PdDispatcher *dispatcher;
    @property (nonatomic, retain) PdMidiDispatcher *midiDispatcher;
    @property (nonatomic, retain) NSMutableDictionary *listenerMap;



@end


