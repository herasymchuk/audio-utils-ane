package com.trembit.utils.monitor;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import com.trembit.utils.AudioUtilsExtension;


public class HeadsetStateReciever extends BroadcastReceiver {
    public void onReceive(Context context, Intent intent) {
        if (intent.hasExtra("state")){
            int st = intent.getIntExtra("state" , -1);
            String nm = intent.getStringExtra("name");
            int mic = intent.getIntExtra("microphone", -1);
            String route = (st > 0) ?  "Headphones" : "Speaker";
            if(mic > 0) {
                route += "AndMicrophone";
            }
            AudioUtilsExtension.notifyAudioRouteChange(route);
        }
    }
}
