//
//  libPd.m
//  libPd cordova/phonegap plug-in implementation file
//
//  Created by Alessandro Saccoia And Florian Rey on 14 April 2016.
//
//

#import "libPd.h"

#pragma mark - libPdListener implementation

@interface libPdListener (){}

    @property (nonatomic, retain) libPd *engine;
    @property (nonatomic, copy) NSString * callback;

    - initWithEngine:(libPd *)e andCallback:(NSString *)c;
@end

@implementation libPdListener

- (id)initWithEngine:(libPd *)e andCallback:(NSString *)c{
    self = [super init];
    if (self) {
        self.engine = e;
        self.callback = c;
    }
    return self;
}

- (void)receiveBangFromSource:(NSString *)source {
    //NSLog(@"Listener %@: bang\n", source);
    NSString *javascript = [NSString stringWithFormat:@"%@('bang')", self.callback];
    [self.engine.commandDelegate evalJs: javascript];
}

- (void)receiveFloat:(float)val fromSource:(NSString *)source {
    //NSLog(@"Listener %@: float %f\n", source, val);
    NSString *javascript = [NSString stringWithFormat:@"%@(%f)", self.callback, val];
    [self.engine.commandDelegate evalJs: javascript];
}

- (void)receiveSymbol:(NSString *)s fromSource:(NSString *)source {
    //NSLog(@"Listener %@: symbol %@\n", source, s);
    NSString *javascript = [NSString stringWithFormat:@"%@('%@')", self.callback, s];
    [self.engine.commandDelegate evalJs: javascript];
}

- (void)receiveList:(NSArray *)v fromSource:(NSString *)source {
    //NSLog(@"Listener %@: list %@\n", source, v);
    // Convert your array to JSON data
    NSError *error = nil;
    NSData *jsonArray = [NSJSONSerialization dataWithJSONObject:v options:kNilOptions error:&error];
    if (error == nil)
    {
        // Pass the JSON to an UTF8 string
        NSString *jsonString = [[NSString alloc] initWithData:jsonArray encoding:NSUTF8StringEncoding];
        NSString *javascript = [NSString stringWithFormat:@"%@(%@)", self.callback, jsonString];
        [self.engine.commandDelegate evalJs: javascript];
    }
}

- (void)receiveMessage:(NSString *)message withArguments:(NSArray *)arguments fromSource:(NSString *)source {
    //NSLog(@"Listener %@: message %@,  %@\n", source, message, arguments);
    // Convert your array to JSON data
    NSError *error = nil;
    NSData *jsonArray = [NSJSONSerialization dataWithJSONObject:arguments options:kNilOptions error:&error];
    if (error == nil)
    {
        // Pass the JSON to an UTF8 string
        NSString *jsonString = [[NSString alloc] initWithData:jsonArray encoding:NSUTF8StringEncoding];
        NSString *javascript = [NSString stringWithFormat:@"%@('%@',%@)", self.callback, message, jsonString];
        [self.engine.commandDelegate evalJs: javascript];
    }
}

@end



#pragma mark - libPdMidiListener implementation

@interface libPdMidiListener (){}

@property (nonatomic, retain) libPd *engine;
@property (nonatomic, copy) NSString * callback;

- initWithEngine:(libPd *)e andCallback:(NSString *)c;
@end

@implementation libPdMidiListener

- (id)initWithEngine:(libPd *)e andCallback:(NSString *)c{
    self = [super init];
    if (self) {
        self.engine = e;
        self.callback = c;
    }
    return self;
}

- (void)receiveNoteOn:(int)pitch withVelocity:(int)velocity forChannel:(int)channel{

}
- (void)receiveControlChange:(int)value forController:(int)controller forChannel:(int)channel{
    
}
- (void)receiveProgramChange:(int)value forChannel:(int)channel{
    
}
- (void)receivePitchBend:(int)value forChannel:(int)channel{
    
}
- (void)receiveAftertouch:(int)value forChannel:(int)channel{
    
}
- (void)receivePolyAftertouch:(int)value forPitch:(int)pitch forChannel:(int)channel{
    
}

@end


#pragma mark - pdLib plug-in implementation

@implementation libPd
@synthesize audioController = audioController_;
@synthesize patch = patch_;
@synthesize dispatcher = dispatcher_;
@synthesize midiDispatcher = midiDispatcher_;
@synthesize listenerMap = listenerMap_;

#pragma mark - public plug-in methods

- (void)init:(CDVInvokedUrlCommand*)command {

  // run in background : don't block the GUI
  [self.commandDelegate runInBackground:^{
    BOOL retValue = [self setupPd];
    CDVPluginResult* pluginResult = nil;
    if (retValue) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)deinit:(CDVInvokedUrlCommand*)command {
	[PdBase computeAudio:NO];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)openPatch:(CDVInvokedUrlCommand*)command {
  [self.commandDelegate runInBackground:^{
    NSString *patchName = [command.arguments objectAtIndex:0];
    self.patch = [PdFile openFileNamed:patchName path:[NSString stringWithFormat:@"%@/www/", [[NSBundle mainBundle] bundlePath]]];
      
    NSLog(@"%@", self.patch);
    CDVPluginResult* pluginResult = nil;
    if (self.patch) {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)closePatch:(CDVInvokedUrlCommand*)command {
  [self.patch closeFile];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)addPath:(CDVInvokedUrlCommand*)command {
  NSDictionary *args = command.arguments[0];
  NSString *thePath = [args objectForKey:@"path"];
  NSString *pathWithWildcard = @"%@";
  pathWithWildcard = [pathWithWildcard stringByAppendingString:thePath];
	[PdBase addToSearchPath:[NSString stringWithFormat:pathWithWildcard, [[NSBundle mainBundle] bundlePath]]];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

// Interaction with the patch

- (void)sendBang:(CDVInvokedUrlCommand*)command {
  NSDictionary *args = command.arguments[0];
  NSString *receiver = [args objectForKey:@"receiver"];

  int const ret = [PdBase sendBangToReceiver:receiver];
  CDVPluginResult* pluginResult = nil;
  if(ret == 0)    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  else            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error when sending bang"];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendFloat:(CDVInvokedUrlCommand*)command {
  NSDictionary *args = command.arguments[0];
  NSString *receiver = [args objectForKey:@"receiver"];
  float value = [[args objectForKey:@"value"] floatValue];
  
  int const ret = [PdBase sendFloat:value toReceiver:receiver];
  CDVPluginResult* pluginResult = nil;
  if(ret == 0)    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  else            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error when sending float"];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendSymbol:(CDVInvokedUrlCommand*)command {
    NSDictionary *args = command.arguments[0];
    NSString *receiver = [args objectForKey:@"receiver"];
    NSString *symbol   = [args objectForKey:@"symbol"];
    
    int const ret = [PdBase sendSymbol:symbol toReceiver:receiver];
    CDVPluginResult* pluginResult = nil;
    if(ret == 0)    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error when sending symbol"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendList:(CDVInvokedUrlCommand*)command {
    NSDictionary *args = command.arguments[0];
    NSString *receiver = [args objectForKey:@"receiver"];
    NSError *error;
    NSArray *list = [NSJSONSerialization
                     JSONObjectWithData:[[args objectForKey:@"list"] dataUsingEncoding:NSUTF8StringEncoding]
                     options:NSJSONReadingMutableContainers
                     error:&error];
    int const ret = [PdBase sendList:list toReceiver:receiver];
    CDVPluginResult* pluginResult = nil;
    if(ret == 0)    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error when sending list"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sendMessage:(CDVInvokedUrlCommand*)command {
    NSDictionary *args = command.arguments[0];
    NSString *receiver = [args objectForKey:@"receiver"];
    NSString *message  = [args objectForKey:@"message"];
    NSError *error;
    NSArray *list = [NSJSONSerialization
                     JSONObjectWithData:[[args objectForKey:@"list"] dataUsingEncoding:NSUTF8StringEncoding]
                     options:NSJSONReadingMutableContainers
                     error:&error];
    
    int const ret = [PdBase sendMessage:message withArguments:list toReceiver:receiver];
    CDVPluginResult* pluginResult = nil;
    if(ret == 0)    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error when sending message"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - pdLib Listeners methods

- (void)addListener:(CDVInvokedUrlCommand*)command {
    NSDictionary *args = command.arguments[0];
    NSString *callback = [args objectForKey:@"callback"];
    NSString *symbol = [args objectForKey:@"symbol"];
    
    CDVPluginResult* pluginResult = nil;
    if(callback != nil && symbol != nil)
    {
        NSMutableDictionary *callbackMap = [self.listenerMap objectForKey:symbol];
        if (!callbackMap){
            callbackMap = [[NSMutableDictionary alloc] init];
            [self.listenerMap setObject:callbackMap forKey:symbol];
        }
        
        // si un listener existe déjà pour un callback et une méthode donné on ne fait rien
        // sinon on le crée
        libPdListener * listener = [callbackMap objectForKey:callback];
        if (!listener){
            listener = [[libPdListener alloc] initWithEngine:self andCallback:callback];
            [callbackMap setObject:listener forKey:callback];
            [self.dispatcher addListener:listener forSource:symbol];
        }
        
        // return OK
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
        
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error when adding listener. Callback or symbol is null"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeListener:(CDVInvokedUrlCommand*)command {
    NSDictionary *args = command.arguments[0];
    NSString *callback = [args objectForKey:@"callback"];
    NSString *symbol = [args objectForKey:@"symbol"];
    
    NSMutableDictionary *callbackMap = [self.listenerMap objectForKey:symbol];
    BOOL test = FALSE;
    if (callbackMap){
        libPdListener * listener = [callbackMap objectForKey:callback];
        if (listener){
            [self.dispatcher removeListener:listener forSource:symbol];
            [callbackMap removeObjectForKey:callback];
            if ([callbackMap count] == 0) {
                [self.listenerMap removeObjectForKey:symbol];
            }
            test = TRUE;
        }
    }
    
    // return OK if listerner has been removed
    CDVPluginResult* pluginResult = nil;
    if (test)   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    else        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Listener does not exist"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeAllListeners:(CDVInvokedUrlCommand*)command {
    [self.listenerMap removeAllObjects];
    [self.dispatcher removeAllListeners];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

// TODO
- (void)addMidiListener:(CDVInvokedUrlCommand*)command {
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

// TODO
- (void)removeMidiListener:(CDVInvokedUrlCommand*)command {
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

// TODO
- (void)removeAllMidiListeners:(CDVInvokedUrlCommand*)command {
    [self.midiDispatcher removeAllListeners];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}


- (void)readArray:(CDVInvokedUrlCommand*)command {
    NSDictionary *args = command.arguments[0];
    NSString *arrayName = [args objectForKey:@"arrayName"];
    
    int arrayLen = [PdBase arraySizeForArrayNamed:arrayName];
    
    // read array
    float floatArray[arrayLen];
    [PdBase copyArrayNamed:@"untableau" withOffset:0 toArray:floatArray count:arrayLen];
    
    // convert to NSArray
    NSMutableArray * floatNSArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < arrayLen; i++) {
        [floatNSArray addObject:[NSNumber numberWithFloat:floatArray[i]]];
    }
    
    // return array
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:floatNSArray] callbackId:command.callbackId];
}


#pragma mark - pdLib initialization

- (BOOL)setupPd {
    
    self.audioController = [[PdAudioController alloc] init];
    PdAudioStatus status = [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:YES];
	if(status == PdAudioError)
    {
		NSLog(@"Error! Could not configure PdAudioController");
        return FALSE;
	}else if(status == PdAudioPropertyChanged) {
		NSLog(@"Warning: some of the audio parameters were not accceptable.");
        return FALSE;
	}else{
		NSLog(@"Audio Configuration successful.");
	}
	self.audioController.active = YES;

	// log actual settings
	[self.audioController print];
    
    //NSMutableDictionary for store listerners with callback and symbol
    self.listenerMap = [[NSMutableDictionary alloc] init];
    
    // Init dispatcher for receive event from PD
    self.dispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:self.dispatcher];
    
    // Init dispatcher for receive midi event from PD
    self.midiDispatcher = [[PdMidiDispatcher alloc] init];
    [PdBase setMidiDelegate:self.midiDispatcher];
    
	// enable audio
	[PdBase computeAudio:YES];
    
    return TRUE;
}

@end
