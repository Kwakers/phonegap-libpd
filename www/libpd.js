//
//  A plug-in to use libPd with cordova/phonegap
//

var cordovaRef = window.PhoneGap || window.Cordova || window.cordova; // old to new fallbacks

function libPd() {
    this.resultCallback = null; // Function
}

/* The two arguments should be functions callbacks of type "void(void)"
   cbOk: fired if the initialization of libPd succeded
   cbKo (optional): fired if the initialization fails
   
   Note: the init function is asynchronous, so the calling code shouldn't be
   window.plugins.libPd.init(....)
   window.plugins.libPd.openPatch(....)
   This could mess things up, as the initialization does take a while.
   Instead, cbOk should be the function responsible for opening the patch, as it's
   fired upon the completion of the initialization process.
*/ 

libPd.prototype.init = function(cbOk, cbKo) {
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','init',[]);
};
               
               
libPd.prototype.deinit = function(cbOk, cbKo) {
  cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','deinit',[]);
};

/* This works the same as init(). it's called asynchronously.
   the cbOk function is the good place to either:
   - send the first message to pd (i.e. ambiences)
   - stop displaying a loader
*/
libPd.prototype.openPatch = function(patchName, cbOk, cbKo) {
  cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','openPatch',[patchName]);
};

libPd.prototype.closePatch = function(cbOk, cbKo) {
    cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','closePatch',[]);
};

libPd.prototype.addPath = function(path, cbOk, cbKo) {
  var args = {};
  args.path = path;
  cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','addPath',[args]);
};

libPd.prototype.sendBang = function(receiver, cbOk, cbKo) {
  var args = {};
  args.receiver = receiver;
  cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','sendBang',[args]);
};

libPd.prototype.sendFloat = function(receiver, value, cbOk, cbKo) {
  var args = {};
  args.receiver = receiver;
  args.value = value;
  cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','sendFloat',[args]);
};

libPd.prototype.sendSymbol = function(receiver, symbol, cbOk, cbKo) {
   var args = {};
   args.receiver = receiver;
   args.symbol = symbol;
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','sendSymbol',[args]);
};

libPd.prototype.sendList = function(receiver, list, cbOk, cbKo) {
   var args = {};
   args.receiver = receiver;
   args.list = JSON.stringify(list);
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','sendList',[args]);
};
   
libPd.prototype.sendMessage = function(receiver, message, list, cbOk, cbKo) {
   var args = {};
   args.receiver = receiver;
   args.message = message;
   args.list = JSON.stringify(list);
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','sendMessage',[args]);
};
              
libPd.prototype.addListener = function(symbol, callback, cbOk, cbKo) {
  var args = {};
  args.symbol = symbol;
  args.callback = callback;
  cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','addListener',[args]);
};
    
libPd.prototype.removeListener = function(symbol, callback, cbOk, cbKo) {
   var args = {};
   args.symbol = symbol;
   args.callback = callback;
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','removeListener',[args]);
};
               
libPd.prototype.removeAllListeners = function(cbOk, cbKo) {
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKO(err)}},'libPd','removeAllListeners',[]);
};
               
libPd.prototype.readArray = function(arrayName, cbOk, cbKo) {
   var args = {};
   args.arrayName = arrayName;
   cordova.exec(function callback(data){if(cbOk != null){cbOk(data)}},function errorHandler(err){if(cbKo != null){cbKo(err)}},'libPd','readArray',[args]);
};
               
cordova.addConstructor(function()
{
  if(!window.plugins){window.plugins = {};}
  window.plugins.libPd = new libPd();
});
