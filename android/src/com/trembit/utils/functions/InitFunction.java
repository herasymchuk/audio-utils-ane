package com.trembit.utils.functions;

import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.trembit.utils.monitor.HeadsetStateReciever;
import com.trembit.utils.AudioUtilsExtension;
import com.trembit.utils.monitor.SettingsContentObserver;
import android.provider.Settings.System;

public class InitFunction implements FREFunction {
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		AudioUtilsExtension.extensionContext = context;
		AudioUtilsExtension.appContext = context.getActivity().getApplicationContext();

        IntentFilter receiverFilter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
        AudioUtilsExtension.receiver = new HeadsetStateReciever();
        AudioUtilsExtension.appContext.registerReceiver( AudioUtilsExtension.receiver, receiverFilter );

        // Start watching settings for volume changes.
        AudioUtilsExtension.mSettingsWatcher = new SettingsContentObserver( new Handler() );
        AudioUtilsExtension.appContext.getContentResolver().registerContentObserver(System.CONTENT_URI, true, AudioUtilsExtension.mSettingsWatcher);

        // Tell AIR what the volume is right now.
        AudioUtilsExtension.notifyVolumeChange();

		return null;
	}
}
