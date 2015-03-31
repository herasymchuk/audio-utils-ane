package com.trembit.utils{	import flash.events.EventDispatcher;	public class AudioUtils extends EventDispatcher	{		private static var _instance:AudioUtils;		public function get route() : Object {			trace("Audio route native extension is not supported on this platform.");			return null;		}				public function isHeadphonesPluggedIn() : Boolean {			return false;		}		
		public static function get instance():AudioUtils {			if ( !_instance ) {				_instance = new AudioUtils( new SingletonEnforcer() );				_instance.init();			}
			return _instance;		}
		/**		 * Cleans up the instance of the native extension. 		 */				public function dispose():void { 
		}
		private function init():void {
		}			public function AudioUtils( enforcer:SingletonEnforcer ) {			super();		}	}}class SingletonEnforcer {
}