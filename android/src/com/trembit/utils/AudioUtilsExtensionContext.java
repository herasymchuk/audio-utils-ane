package com.trembit.utils;

import java.util.HashMap;
import java.util.Map;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.trembit.utils.functions.InitFunction;
import com.trembit.utils.functions.getRoute;

public class AudioUtilsExtensionContext extends FREContext {
	
	@Override
	public void dispose() {

	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
		
		functions.put("init", new InitFunction());
		functions.put("getRoute", new getRoute());
		
		return functions;
	}
}
