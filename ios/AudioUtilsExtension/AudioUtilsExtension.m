#import "FlashRuntimeExtensions.h"
#import <AudioToolbox/AudioSession.h>

FREContext eventContext;

void dispatchAudioRouteChangeEvent(NSString* plugedIn) {
    if (eventContext == NULL) {
        return;
    }
    NSString *eventName = @"audioRouteChanged";
    
    const uint8_t* isPlugedIn = (const uint8_t*) [plugedIn UTF8String];
    const uint8_t* eventCode = (const uint8_t*) [eventName UTF8String];
    FREDispatchStatusEventAsync(eventContext, eventCode, isPlugedIn);
}

BOOL isPluggedIn() {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &routeSize, &route);
    //NSLog(@"%@", route);
    return (!error && (route != NULL) && ([(__bridge NSString*)route rangeOfString:@"Head"].location != NSNotFound));
}

NSString* getRouteInternal() {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &routeSize, &route);
    //NSLog(@"%@", route);
    return (!error && (route != NULL)) ? (__bridge NSString*)route : @"NULL";
}

FREObject getRoute(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    FREObject route = nil;
    NSString *value = getRouteInternal();
    FRENewObjectFromUTF8(strlen((const char*)[value UTF8String]) + 1, (const uint8_t*)[value UTF8String], &route);
    return route;
}

void audioSessionPropertyListener(void* inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void* inData) {
    
    // Determines the reason for the route change, to ensure that it is not
    //      because of a category change.
    CFDictionaryRef routeChangeDictionary = inData;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue (routeChangeDictionary,CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable ||
        routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
        dispatchAudioRouteChangeEvent(getRouteInternal());
    }
    return;
}

FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    eventContext = ctx;
    
    // Listen to changes to system volume.
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(YES);
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioSessionPropertyListener, NULL);
    return NULL;
}

void ARExtContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    *numFunctionsToTest = 2;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "init";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "getRoute";
    func[1].functionData = NULL;
    func[1].function = &getRoute;
    
    *functionsToSet = func;
}

void ARExtContextFinalizer(FREContext ctx) {
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, audioSessionPropertyListener, NULL);
}

void AudioUtilsExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ARExtContextInitializer;
    *ctxFinalizerToSet = &ARExtContextFinalizer;
}

