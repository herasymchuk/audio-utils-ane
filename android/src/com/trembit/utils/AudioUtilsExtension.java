package com.trembit.utils;

import android.content.Context;
import android.media.AudioManager;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.trembit.utils.monitor.HeadsetStateReciever;
import com.trembit.utils.monitor.SettingsContentObserver;

public class AudioUtilsExtension implements FREExtension {
	
	public static FREContext extensionContext;
	public static Context appContext;
    public static HeadsetStateReciever receiver;


    public static SettingsContentObserver mSettingsWatcher;

    private static float NO_VALUE = (float)-1.0;
    private static Float lastSystemVolume = NO_VALUE;

    public static void notifyVolumeChange() {
        AudioManager aManager = (AudioManager) appContext.getSystemService(Context.AUDIO_SERVICE);
        Float maxVolume = Float.valueOf(aManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC));
        Float systemVolume = Float.valueOf(aManager.getStreamVolume(AudioManager.STREAM_MUSIC));

        // Only dispatch the event if the volume actually changed.
        // The settings watcher is going to see *any* settings change,
        // so it's possible that we'll get in here but the volume hasn't
        // changed.  We shouldn't tell Flash if that's the case.
        if (systemVolume != lastSystemVolume) {
            lastSystemVolume = systemVolume;

            Float flashVolume = systemVolume / maxVolume;

            String volume = String.valueOf( flashVolume );
            String eventName = "volumeChanged";

            extensionContext.dispatchStatusEventAsync(eventName, volume);
        }
    }


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
        AudioUtilsExtension.appContext.getContentResolver().unregisterContentObserver(mSettingsWatcher);
		
		appContext = null;
		extensionContext = null;
		receiver = null;
        mSettingsWatcher = null;
        lastSystemVolume = NO_VALUE;
	}

	@Override
	public void initialize() {
	}
}
