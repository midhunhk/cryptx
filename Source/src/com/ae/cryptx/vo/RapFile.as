package com.ae.cryptx.vo
{
import flash.utils.ByteArray;
	
public class RapFile
{
	/**
	 * RAP File Identifier String
	 */
	private var _identifier:String;
	
	public function set identifier(value:String):void
	{
		_identifier = value;
	}
	
	public function get identifier():String
	{
		return _identifier;
	}
	
	/**
	 * The Encrypted File Extension
	 */
	private var _fileExtension:ByteArray;
	
	public function set fileExtension(value:ByteArray):void
	{
		_fileExtension = value;
	}
	
	public function get fileExtension():ByteArray
	{
		return _fileExtension;
	}
	
	/**
	 * Encrypted Cryptx Signature
	 */
	private var _cryptxSignature:ByteArray;
	
	public function set cryptxSignature(value:ByteArray):void
	{
		_cryptxSignature = value;
	}
	
	public function get cryptxSignature():ByteArray
	{
		return _cryptxSignature;
	}
	
	/**
	 * File's CRC32 value
	 */
	private var _fileCRC32:String;

	public function set fileCRC32(value:String):void
	{
		_fileCRC32 = value;
	}
	
	public function get fileCRC32():String
	{
		return _fileCRC32;
	}
	
	/**
	 * payload is the encrypted data as bytearray
	 */
	private var _payload:ByteArray;
	
	public function set payload(value:ByteArray):void
	{
		_payload = value;
	}
	
	public function get payload():ByteArray
	{
		return _payload;
	}

}
}