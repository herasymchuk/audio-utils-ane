package com.trembit.utils.functions;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.trembit.utils.AudioUtilsExtension;
import com.trembit.utils.monitor.HeadsetStateReciever;

public class InitFunction implements FREFunction {
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		AudioUtilsExtension.extensionContext = context;
		AudioUtilsExtension.appContext = context.getActivity().getApplicationContext();

        IntentFilter receiverFilter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
        AudioUtilsExtension.receiver = new HeadsetStateReciever();
        AudioUtilsExtension.appContext.registerReceiver( AudioUtilsExtension.receiver, receiverFilter );
		
		return null;
	}
}
