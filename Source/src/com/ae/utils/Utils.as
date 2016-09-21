package com.ae.utils
{
/**
 * Utility class with static functions
 */
public class Utils
{
	/**
	 * @private
	 */
	private static var _levels:Array = 
		['bytes', 'Kb', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

	/**
	 * This method returns a string based on a file size passed as
	 * parameter to it.
	 */
	public static function bytesToString(bytes:Number):String
	{
	    var index:uint = Math.floor(Math.log(bytes)/Math.log(1024));
	    return (bytes/Math.pow(1024, index)).toFixed(2) + " " + _levels[index];
	}
	
	/**
	 * Method to return a formatted string corresponding to the number
	 * of seconds passed to it
	 * @param	timeInSeconds	Time in seconds to be formatted
	 */
	public static function formatTimeString(timeInSeconds:Number):String
	{
		var date:Date = new Date(null, null, 0, 0, 0, timeInSeconds, 0);
		
		var secs:int 	= date.getSeconds();
		var mins:int 	= date.getMinutes()
		var hours:int 	= date.getHours();			
		
		var hours_str:String = (hours < 10)? "0" + hours : hours.toString();
		var mins_str:String = (mins < 10)? "0" + mins : mins.toString();		
		var secs_str:String = (secs < 10)? "0" + secs : secs.toString();
		var timeString:String = hours_str + ":" + mins_str + ":" + secs_str;
		return timeString;
	}
}
}