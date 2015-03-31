#import "FlashRuntimeExtensions.h"
#import <AudioToolbox/AudioSession.h>
#import <MediaPlayer/MediaPlayer.h>

FREContext eventContext;

float getVolumeLevel()
{
    MPVolumeView *slide = [MPVolumeView new];
    UISlider *volumeViewSlider;
    
    for (UIView *view in [slide subviews])
    {
        if ([[[view class] description] isEqualToString:@"MPVolumeSlider"])
        {
            volumeViewSlider = (UISlider *) view;
        }
    }
    
    float val = [volumeViewSlider value];
    return val;
}

NSString* getRouteInternal() {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &routeSize, &route);
    //NSLog(@"%@", route);
    return (!error && (route != NULL)) ? (__bridge NSString*)route : @"NULL";
}

void dispatchAudioRouteChangeEvent(NSString* plugedIn) {
    if (eventContext == NULL) {
        return;
    }
    NSString *eventName = @"audioRouteChanged";
    
    const uint8_t* isPlugedIn = (const uint8_t*) [plugedIn UTF8String];
    const uint8_t* eventCode = (const uint8_t*) [eventName UTF8String];
    FREDispatchStatusEventAsync(eventContext, eventCode, isPlugedIn);
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

void dispatchVolumeEvent(float volume)
{
    if (eventContext == NULL)
    {
        return;
    }
    
    NSNumber *numVolume = [NSNumber numberWithFloat:volume];
    NSString *strVolume = [numVolume stringValue];
    NSString *eventName = @"volumeChanged";
    
    const uint8_t* volumeCode = (const uint8_t*) [strVolume UTF8String];
    const uint8_t* eventCode = (const uint8_t*) [eventName UTF8String];
    FREDispatchStatusEventAsync(eventContext, eventCode, volumeCode);
}

void volumeListenerCallback(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData)
{
    const float *volumePointer = inData;
    float volume = *volumePointer;
    
    dispatchVolumeEvent(volume);
}


FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    eventContext = ctx;
    
    // Listen to changes to system volume.
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(YES);
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, NULL);
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioSessionPropertyListener, NULL);
    
    // Go ahead and send back current system volume.
    
    float curVolume = getVolumeLevel();
    dispatchVolumeEvent(curVolume);
    
    return NULL;
}

FREObject setVolume(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    double newVolume;
    FREGetObjectAsDouble(argv[0], &newVolume);
    
    [[MPMusicPlayerController applicationMusicPlayer] setVolume: newVolume];
    
    return NULL;
}

BOOL isPluggedIn() {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &routeSize, &route);
    //NSLog(@"%@", route);
    return (!error && (route != NULL) && ([(__bridge NSString*)route rangeOfString:@"Head"].location != NSNotFound));
}



FREObject getRoute(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    FREObject route = nil;
    NSString *value = getRouteInternal();
    FRENewObjectFromUTF8(strlen((const char*)[value UTF8String]) + 1, (const uint8_t*)[value UTF8String], &route);
    return route;
}

void ARExtContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    *numFunctionsToTest = 3;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "init";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "getRoute";
    func[1].functionData = NULL;
    func[1].function = &getRoute;
    
    func[2].name = (const uint8_t*) "setVolume";
    func[2].functionData = NULL;
    func[2].function = &setVolume;
    
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

