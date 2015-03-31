package com.trembit.utils;

import android.content.Context;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.trembit.utils.monitor.HeadsetStateReciever;

public class AudioUtilsExtension implements FREExtension {
	
	public static FREContext extensionContext;
	public static Context appContext;
    public static HeadsetStateReciever receiver;
	
	public static void notifyAudioRouteChange(String route) {
        String result = String.valueOf( route );
		String eventName = "audioRouteChanged";
			
		extensionContext.dispatchStatusEventAsync(eventName, result);
	}
	
	@Override
	public FREContext createContext(String contextType) {
		return new AudioUtilsExtensionContext();
	}

	@Override
	public void dispose() {
		
		// Stop watching settings for audioroute changes.
        AudioUtilsExtension.appContext.unregisterReceiver(receiver);
		
		appContext = null;
		extensionContext = null;
		receiver = null;
	}

	@Override
	public void initialize() {
	}
}
