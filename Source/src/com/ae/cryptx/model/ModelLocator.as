package com.ae.cryptx.model
{
	import flash.filesystem.File;
	
[Bindable]
public class ModelLocator
{
	//-------------------------------------------------------------------------
	//
	//	Variables
	//
	//-------------------------------------------------------------------------
	
	protected static var _instance:ModelLocator;
	
	public var systemFile:File = null;
	
	//-------------------------------------------------------------------------
	//
	//	Methods
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Constructor
	 */
	public function ModelLocator()
	{
		if(_instance != null)
			throw new Error("Singleton already instantiated!");
	}
	
	/**
	 * This method returns the current model locator instance
	 */
	public static function getInstance():ModelLocator
	{
		if(_instance == null)
			_instance = new ModelLocator();
		return _instance;
	}

}
}