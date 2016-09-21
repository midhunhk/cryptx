package com.ae.cryptx.events
{
import com.ae.cryptx.vo.FileInfoVo;
import com.ae.cryptx.vo.ParamatersVo;

import flash.events.Event;

public class CryptxEvent extends Event
{
	//-------------------------------------------------------------------------
	//
	//  Constants
	//
	//-------------------------------------------------------------------------
	
	public static const CRYPTX_EVENT:String = 	"cryptxEvent";
	public static const ENCRYPT:String		= 	"encrypt";
	public static const DECRYPT:String		= 	"decrypt";
	public static const FAULT:String 		= 	"fault";
	public static const COMPLETE:String 	= 	"complete";
	public static const PROGRESS:String		=	"progress";
	
	//-------------------------------------------------------------------------
	//
	//  Variables
	//
	//-------------------------------------------------------------------------
	
	public var errorMessage:String;
	
	public var progress:Number;
	public var parameters:ParamatersVo;
	public var sourceFileInfo:FileInfoVo;
	public var targetFileInfo:FileInfoVo;
	
	//-------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------
	public function CryptxEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
	}
	
}
}