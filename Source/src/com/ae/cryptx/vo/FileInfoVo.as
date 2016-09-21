package com.ae.cryptx.vo
{
import flash.filesystem.File;
	
[Bindable]
public class FileInfoVo
{
	/**
	 * fileSize
	 */
	private var _size:int;
	
	public function set size(value:int):void
	{
		_size = value;
	}
	
	public function get size():int
	{
		return _size;
	}
	
	/**
	 * filePath
	 */
	private var _filePath:String;
	
	public function set filePath(value:String):void
	{
		_filePath = value;
	}
	
	public function get filePath():String
	{
		return _filePath;
	}
	
	/**
	 * name
	 */
	private var _name:String
	
	public function set name(value:String):void
	{
		_name = value;
	}
	
	public function get name():String
	{
		return _name;
	}
	
	/**
	 * icon
	 */
	private var _icon:Object
	
	public function set icon(value:Object):void
	{
		_icon = value;
	}
	
	public function get icon():Object
	{
		return _icon;
	}
	
	/**
	 * isRapFile
	 */
	private var _isRapFile:Boolean
	
	public function set isRapFile(value:Boolean):void
	{
		_isRapFile = value;
	}
	
	public function get isRapFile():Boolean
	{
		return _isRapFile;
	}
	
	/**
	 * targetPath
	 */
	private var _fileExtension:String;
	
	/**
	 * fileExtension
	 */
	public function get fileExtension():String
	{
		return _fileExtension;
	}
	
	public function set fileExtension(value:String):void
	{
		_fileExtension = value;
	}
	
	/**
	 * Locations
	 */
	public function get location():String
	{
		if(filePath && filePath != "")
		{
			return filePath.substr(0, filePath.lastIndexOf(File.separator));
		}
		return "";
	} 
	
	public function set location(value:String):void
	{
		
	}
	
	/**
	 * NameWithExtension
	 */
	public function get nameWithExtension():String
	{
		if(fileExtension && fileExtension != "")
			return name + "." + fileExtension;
		return name;
	} 
	
	public function set nameWithExtension(value:String):void
	{
		
	}

}
}