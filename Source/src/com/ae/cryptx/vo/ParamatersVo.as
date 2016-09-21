package com.ae.cryptx.vo
{
public class ParamatersVo
{
	/**
	 * password
	 */
	private var _password:String;
	
	public function set password(value:String):void
	{
		_password = value;
	}
	
	public function get password():String
	{
		return _password;
	}
	
	/**
	 * @mode - The encryption mode to be used 
	 */
	private var _mode:String;
	
	public function set mode(value:String):void
	{
		_mode = value;
	}
	
	public function get mode():String
	{
		return _mode;
	}
}
}