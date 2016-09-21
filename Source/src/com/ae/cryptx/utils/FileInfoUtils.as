package com.ae.cryptx.utils
{
import com.ae.cryptx.vo.FileInfoVo;

import flash.display.BitmapData;
import flash.filesystem.File;

/**
 * FileInfoUtils is helper class for
 */
public class FileInfoUtils
{
	/**
	 * Creates and returns a fileinfovo based on the file
	 */
	public static function getFileInfo(file:File, defaultIcon:Class = null):FileInfoVo
	{
		var fileName:String = file.name;
		var lastDotPos:int = fileName.lastIndexOf(".");
		var fileInfo:FileInfoVo = new FileInfoVo();
		fileInfo.filePath = file.nativePath;
		fileInfo.name = fileName.substr(0, lastDotPos);
		fileInfo.fileExtension = fileName.substr(lastDotPos + 1);
		fileInfo.size = file.size;
		fileInfo.isRapFile = 
			(file.extension.toLowerCase() == AppConstants.RAP_FILE_EXTENSION);
		var bmp:BitmapData = get32Icon(file);
		fileInfo.icon = bmp;
		if(defaultIcon != null && (bmp == null || fileInfo.isRapFile == true))
		{
			fileInfo.icon = defaultIcon;
		}
		return fileInfo;
	}
	
	/**
	 * Creates a Rap file based on a fileinfovo
	 */
	public static function getFileInfoFromVo(fileInfo:FileInfoVo, 
		defaultIcon:Class = null):FileInfoVo
	{
		var filePath:String = fileInfo.filePath;
		var newFileInfo:FileInfoVo = new FileInfoVo();
		
		if(fileInfo.isRapFile)
		{
			newFileInfo.name = fileInfo.name;
			newFileInfo.filePath = filePath.substr(0, 
				filePath.lastIndexOf(File.separator) + 1);
			newFileInfo.fileExtension = "";
			newFileInfo.size = 0;
			newFileInfo.isRapFile = false;
			newFileInfo.icon = null;
		}
		else
		{
			newFileInfo.name = fileInfo.name;
			newFileInfo.filePath = filePath.substr(0, filePath.lastIndexOf(".")) + 
				"." + AppConstants.RAP_FILE_EXTENSION;
			newFileInfo.fileExtension = AppConstants.RAP_FILE_EXTENSION;
			newFileInfo.size = 0;
			newFileInfo.isRapFile = true;
			if(defaultIcon)
			{
				newFileInfo.icon = defaultIcon;
			}
		}
		return newFileInfo;
	}
	
	/**
	 * This method will update the icon and fileSize of the FileInfoVo
	 * object passed to it.
	 */
	public static function updateFileInfoVo(fileInfo:FileInfoVo):void
	{
		var targetFile:File = new File(fileInfo.filePath);
		if(targetFile.exists && targetFile.isDirectory == false)
		{
			fileInfo.icon = get32Icon(targetFile);
			fileInfo.size = targetFile.size;
		}
	}
	
	/**
	 * 
	 */
	public static function get32Icon(file:File):BitmapData
	{
    	var bmpData:BitmapData = new BitmapData(32, 32);
        for (var i:uint = 0; i < file.icon.bitmaps.length; i++) 
        {
        	if (file.icon.bitmaps[i].height == bmpData.height) 
        	{
            	bmpData = file.icon.bitmaps[i];
            	break;
            }
		}
		return bmpData;
	}

}
}