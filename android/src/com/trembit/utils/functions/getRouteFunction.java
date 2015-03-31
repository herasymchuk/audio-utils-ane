package com.trembit.utils.functions;

import android.content.Context;
import android.media.AudioManager;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class getRouteFunction implements FREFunction {
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		Context appContext = context.getActivity().getApplicationContext();
		AudioManager aManager = (AudioManager) appContext.getSystemService(Context.AUDIO_SERVICE);
        try {
            return FREObject.newObject(aManager.isWiredHeadsetOn() ? "Headphones" : "Speaker");
        } catch (FREWrongThreadException e) {
            return null;
        }
	}
}
