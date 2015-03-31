package com.trembit.utils
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	import com.trembit.utils.events.AudioRouteEvent;
	
	public class AudioUtils extends EventDispatcher
	{
		private static var _instance:AudioUtils;
		
		private var extContext:ExtensionContext;
		
		public function get route() : Object {
			return extContext.call("getRoute");
		}
		
		public function isHeadphonesPluggedIn() : Boolean {
			var route : String = extContext.call("getRoute") as String;
			if(route) {
				return (route.indexOf("Head") > -1);
			} 
			return false;
		}
		
		public static function get instance():AudioUtils {
			if ( !_instance ) {
				_instance = new AudioUtils( new SingletonEnforcer() );
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
			extContext.call( "init" );
		}
		
		private function onStatus( event:StatusEvent ):void {
			dispatchEvent( new AudioRouteEvent( AudioRouteEvent.AUDIO_ROUTE_CHANGED, event.level ) );
		}
		
		/**
		 * Constructor. 
		 */		
		public function AudioUtils( enforcer:SingletonEnforcer ) {
			super();
			
			extContext = ExtensionContext.createExtensionContext( "com.trembit.utils", "" );
			
			if ( !extContext ) {
				throw new Error( "Audio route native extension is not supported on this platform." );
			}
			
			extContext.addEventListener( StatusEvent.STATUS, onStatus );
		}
	}
}

class SingletonEnforcer {
	
}