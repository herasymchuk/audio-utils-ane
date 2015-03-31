package com.trembit.utils {
import com.trembit.utils.events.AudioRouteEvent;
import com.trembit.utils.events.VolumeEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;

public class AudioUtils extends EventDispatcher {
    private static var _instance:AudioUtils;

    private var extContext:ExtensionContext;

    public function get route():Object {
        return extContext.call("getRoute");
    }

    public function isHeadphonesPluggedIn():Boolean {
        var route:String = extContext.call("getRoute") as String;
        if (route) {
            return (route.indexOf("Head") > -1);
        }
        return false;
    }

    private var _systemVolume:Number = NaN;
    public function get systemVolume():Number {
        return _systemVolume;
    }

    public function set systemVolume(value:Number):void {
        if (_systemVolume == value) {
            return;
        }

        _systemVolume = value;
    }

    /**
     * Changes the device's system volume.
     *
     * @param newVolume The new system volume.  This value should be between 0 and 1.
     */
    public function setVolume(newVolume:Number):void {
        if (isNaN(newVolume)) {
            newVolume = 1;
        }

        if (newVolume < 0) {
            newVolume = 0;
        }

        if (newVolume > 1) {
            newVolume = 1;
        }

        extContext.call("setVolume", newVolume);

        systemVolume = newVolume;
    }

    public static function get instance():AudioUtils {
        if (!_instance) {
            _instance = new AudioUtils(new SingletonEnforcer());
            _instance.init();
        }

        return _instance;
    }

    /**
     * Cleans up the instance of the native extension.
     */
    public function dispose():void {
        extContext.dispose();
    }

    private function init():void {
        extContext.call("init");
    }

    private function onStatus(event:StatusEvent):void {
        switch (event.code) {
            case "audioRouteChanged":
                dispatchEvent(new AudioRouteEvent(AudioRouteEvent.AUDIO_ROUTE_CHANGED, event.level));
                break;
            case "volumeChanged":
                systemVolume = Number(event.level);
                dispatchEvent(new VolumeEvent(VolumeEvent.VOLUME_CHANGED, systemVolume, false, false));
                break;
        }

    }

    /**
     * Constructor.
     */
    public function AudioUtils(enforcer:SingletonEnforcer) {
        super();

        extContext = ExtensionContext.createExtensionContext("com.trembit.utils", "");

        if (!extContext) {
            throw new Error("Audio route native extension is not supported on this platform.");
        }

        extContext.addEventListener(StatusEvent.STATUS, onStatus);
    }
}
}

class SingletonEnforcer {

}