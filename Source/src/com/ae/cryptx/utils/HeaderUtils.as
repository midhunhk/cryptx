package com.ae.cryptx.utils
{
import com.ae.cryptx.vo.RapFile;

import flash.utils.ByteArray;

/**
 * HeaderUtils has static methods to convert a header object into
 * ByteArray and vice versa
 */
public class HeaderUtils
{
	public static function headerAsByteArray(header:RapFile):ByteArray
	{
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeUTF(header.identifier);
		
		// Write cryptxsignature and its length
		byteArray.writeShort(header.cryptxSignature.length);
		byteArray.writeBytes(header.cryptxSignature);
		
		// Write fileExtension and its length
		byteArray.writeShort(header.fileExtension.length);
		byteArray.writeBytes(header.fileExtension);
		
		// Write Payload
		byteArray.writeBytes(header.payload);
		return byteArray;
	}
	
	/**
	 * Writes the rap file header to a bytearray
	 */
	public static function writeHeader(header:RapFile):ByteArray
	{
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeUTF(header.identifier);
		
		// Write cryptxsignature and its length
		byteArray.writeShort(header.cryptxSignature.length);
		byteArray.writeBytes(header.cryptxSignature);
		
		// Write fileExtension and its length
		byteArray.writeShort(header.fileExtension.length);
		byteArray.writeBytes(header.fileExtension);
		
		return byteArray;
	}
	
	public static function getHeaderSize(byteArray:ByteArray):int
	{
		byteArray.position = 0;
		
		var size:uint;
		var bytes:ByteArray;
		
		// skip the identifier
		byteArray.readUTF();
		
		// read signature
		size = byteArray.readShort();
		bytes = new ByteArray();
		byteArray.readBytes(bytes, 0, size);
		
		// Read fileExtension
		size = byteArray.readShort();
		bytes = new ByteArray();
		byteArray.readBytes(bytes, 0, size);
		
		// return the header offset
		return byteArray.position;
	}
	
	/**
	 * Reads just the header data without the payload from a byetarray
	 */
	public static function readHeader(byteArray:ByteArray):RapFile
	{
		var header:RapFile = new RapFile();
		var size:uint;
		
		// Make sure we read from the start
		byteArray.position = 0;
		
		// Read identifier
		header.identifier = byteArray.readUTF();
		
		// read signature
		size = byteArray.readShort();
		var bytes:ByteArray = new ByteArray();
		byteArray.readBytes(bytes, 0, size);
		header.cryptxSignature = bytes;
		
		// Read fileExtension
		size = byteArray.readShort();
		bytes = new ByteArray();
		byteArray.readBytes(bytes, 0, size);
		header.fileExtension = bytes;
		
		return header;
	}
	
	public static function headerAsObject(byteArray:ByteArray):RapFile
	{
		var header:RapFile = new RapFile();
		var size:uint;
		
		// Make sure we read from the start
		byteArray.position = 0;
		
		// Read identifier
		header.identifier = byteArray.readUTF();
		
		// Read cryptxsignature
		size = byteArray.readShort();
		var bytes:ByteArray = new ByteArray();
		byteArray.readBytes(bytes, 0, size);
		header.cryptxSignature = bytes;
		
		// Read fileExtension
		size = byteArray.readShort();
		bytes = new ByteArray();
		byteArray.readBytes(bytes, 0, size);
		header.fileExtension = bytes;
		
		// Read payload
		bytes = new ByteArray();
		byteArray.readBytes(bytes);
		header.payload = bytes;
		return header;
	}
	
}
}