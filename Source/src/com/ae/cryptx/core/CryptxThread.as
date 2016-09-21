package com.ae.cryptx.core
{
import com.ae.cryptx.events.CryptxEvent;
import com.ae.cryptx.utils.AppConstants;
import com.ae.cryptx.utils.HeaderUtils;
import com.ae.cryptx.vo.FileInfoVo;
import com.ae.cryptx.vo.ParamatersVo;
import com.ae.cryptx.vo.RapFile;
import com.ae.logger.ILogManager;
import com.ae.logger.LogLevel;
import com.ae.logger.LogManager;
import com.ae.utils.FileReadWrite;
import com.ae.utils.Utils;
import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.util.Hex;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;
import flash.utils.getTimer;

import org.generalrelativity.thread.process.AbstractProcess;

/**
 * The CryptxThread class is a Threaded version for the Cryptx
 */
public class CryptxThread extends AbstractProcess implements IEventDispatcher
{
	//-------------------------------------------------------------------------
	//
	//  Constants
	//
	//-------------------------------------------------------------------------	
	
	private const BLOCK_SIZE:uint = 8192;
	private var mode:String = "simple-aes-cbc";
	private var pad:String 	= "pkcs5";
	
	//-------------------------------------------------------------------------
	//
	//  Variables
	//
	//-------------------------------------------------------------------------
	
	private var timeStamp:int;
	private var key:ByteArray;
	private var cipher:ICipher;
	private var isDone:Boolean;
	private var readCount:uint;
	private var readOffset:uint;
	private var fileLength:uint;
	private var operation:String;
	private var _logger:ILogManager;
	private var errorMessage:String;
	private var wrapperData:RapFile;
	private var headerData:ByteArray;
	private var sourceData:ByteArray;
	private var targetData:ByteArray;
	private var currentStep:Function;
	private var parameters:ParamatersVo;
	private var sourceFileInfo:FileInfoVo;
	private var targetFileInfo:FileInfoVo;
	private var cryptxSignature:ByteArray;
	private var sourceFileStream:FileStream;
	private var targetFileStream:FileStream;
	private var encryptedSignature:ByteArray;
	private var encryptedExtension:ByteArray;
	private var eventDispatcher:IEventDispatcher;
	
	//-------------------------------------------------------------------------
	//
	//  Methods
	//
	//-------------------------------------------------------------------------
	
	/**
	 * Constructor for the thread
	 */
	public function CryptxThread(
				operation:String,
				sourceFileInfo:FileInfoVo, 
				targetFileInfo:FileInfoVo, 
				parameters:ParamatersVo, 
				isSelfManaging:Boolean=false)
	{
		super(isSelfManaging);
		
		_logger = LogManager.getInstance();
		cryptxSignature = byteArrayFromString(AppConstants.CRYPTX_SIGNATURE);
		
		this.operation = operation;
		this.sourceFileInfo = sourceFileInfo;
		this.targetFileInfo = targetFileInfo;
		this.parameters = parameters
		
		// Initialize important stuff
		targetData = new ByteArray();
		eventDispatcher = new EventDispatcher(this);
		cryptxSignature = byteArrayFromString(AppConstants.CRYPTX_SIGNATURE);
		
		_logger.writeLog(LogLevel.INFO, " ");
		_logger.writeLog(LogLevel.INFO, "CryptxThread instance created.");
		_logger.writeLog(LogLevel.DEBUG, "Operation : " + operation);
		
		// set the initial function to be invoked
		if(operation == CryptxModes.ENCRYPTION_MODE)
			currentStep = initCipher;
		else
			currentStep = readRapFile;
	}
	
	/**
	 * This method is called on each cycle
	 */
	override public function run() : void
	{
		currentStep();
	}
	
	override public function get percentage() : Number
	{
		return isDone ? 1.0 : 0.33;
	}
	
	/**
	 * This method will perform cleanup operations
	 */
	override public function terminate():void
	{
		trace("terminate");
		sourceFileStream.close();
		targetFileStream.close();
		sourceData = null;
		targetData = null;
		encryptedSignature = null;
		encryptedExtension = null;
		wrapperData = null;
		headerData  = null;
		System.gc();
	}
	
	/**
	 * Initialises the cipher and encrypts the signature with the key
	 * for this instance.
	 */
	private function initCipher():void
	{
		// key is got from the ui
		key = byteArrayFromString(parameters.password);
		
		// Initialize the crypto stuff
		cipher = Crypto.getCipher(mode, key, Crypto.getPad(pad));
		
		// encrypt the signature for this session
		encryptedSignature = new ByteArray();
		encryptedSignature.writeBytes(cryptxSignature);
		cipher.encrypt(encryptedSignature);
		
		if(operation == CryptxModes.ENCRYPTION_MODE)
		{
			// Encrypt the file's extension
			encryptedExtension = 
				byteArrayFromString(sourceFileInfo.fileExtension);
			cipher.encrypt(encryptedExtension);
			currentStep = createWrapper;
		}
		else
		{
			currentStep = validateHeader;
		}
		_logger.writeLog(LogLevel.DEBUG, "initCipher() initialized");
	}
	
	/**
	 * Creates the wrapper Data and assigns the header
	 * info (identifier, encrypted signature and extension) to it.
	 */
	private function createWrapper():void
	{
		_logger.writeLog(LogLevel.DEBUG, "createWrapper()");
		wrapperData = new RapFile();
		wrapperData.identifier = AppConstants.RAP_FILE_IDENTIFIER
		wrapperData.cryptxSignature = encryptedSignature;
		wrapperData.fileExtension = encryptedExtension;
		
		currentStep = readSourceFile;
	}
	
	/**
	 * Sets up file streams for reading the source file
	 * and writing to the target file.
	 */
	private function readSourceFile():void
	{
		_logger.writeLog(LogLevel.DEBUG, 
			"readSourceFile() " + sourceFileInfo.filePath);
		var sourceFile:File = new File(sourceFileInfo.filePath);
		var targetFile:File = new File(targetFileInfo.filePath);
		
		// Setup filestreams
		sourceFileStream = new FileStream();
		sourceFileStream.addEventListener(IOErrorEvent.IO_ERROR, fault, false, 0, true);
		sourceFileStream.open(sourceFile, FileMode.READ);
		
		targetFileStream = new FileStream();
		targetFileStream.addEventListener(IOErrorEvent.IO_ERROR, fault, false, 0, true);
		targetFileStream.open(targetFile, FileMode.WRITE);
		
		// Write the header block
		headerData = HeaderUtils.writeHeader(wrapperData);
		targetFileStream.writeBytes( headerData );
		
		readCount = readOffset = 0;
		fileLength = sourceFile.size;
		
		timeStamp = getTimer();
		currentStep = encryptBlock;
	}
	
	/**
	 * Reads a block of data from the source file.
	 */
	private function readBlock():void
	{
		sourceData = new ByteArray();
		var readSize:uint = Math.min(BLOCK_SIZE, sourceFileStream.bytesAvailable);
			//(sourceFileStream.bytesAvailable < BLOCK_SIZE) ? 0 : BLOCK_SIZE;
		sourceFileStream.readBytes(sourceData, readOffset, readSize);
		trace(stringFromByteArray(sourceData));
	}
	
	private static function fault(error:IOErrorEvent):void
	{
       	trace("FileReadWrite.fault : " + error.toString());
	}
	
	/**
	 * This function encrypts a block of data from the sourceData
	 * variable. Encrypted data is appended to the variable
	 * targetData preceded by the block length.
	 */
	private function encryptBlock():void
	{
		// Read the next block from the file.
		readBlock();
		
		if(sourceData.bytesAvailable > 0)
		{
			// Update the read size 
			readCount += sourceData.bytesAvailable;
			
			// Encrypt the block
			cipher.encrypt(sourceData);
			
			// Write the encrypted block with block length
			targetFileStream.writeShort(sourceData.length);
			targetFileStream.writeBytes(sourceData);
			
			// Notify of progress
			var event:CryptxEvent = new CryptxEvent(CryptxEvent.PROGRESS);
			event.progress = readCount / fileLength;
			dispatchEvent(event);
		}
		else
		{
			currentStep = encryptionComplete;
		}
	}
	
	/**
	 * This function decrypts a block of data from the sourceData
	 * variable. First the block length is read and that much
	 * bytes are read to get the block. Decrypted data is
	 * appended to the targetData variable.
	 */
	private function decryptBlock():void
	{
		if(sourceData.bytesAvailable > 0)
		{
			var block:ByteArray = new ByteArray();
			var readSize:uint = sourceData.readShort();
			sourceData.readBytes(block, 0, readSize);
			
			// Decrypt the block
			cipher.decrypt(block);
			
			// Write the decrypted block
			targetData.writeBytes(block);
			
			// Notify of progress
			var event:CryptxEvent = new CryptxEvent(CryptxEvent.PROGRESS);
			event.progress = sourceData.position / sourceData.length;
			dispatchEvent(event);
		}
		else
		{
			currentStep = decryptionComplete;
		}
	}
	
	/**
	 * This function will be called once the encryption process
	 * is completed. We try to compress the encrypted data and 
	 * then create a ByteArray consisting of the header and the
	 * payload from the wrapperData variable.
	 */
	private function encryptionComplete():void
	{
		var diff:String = Utils.formatTimeString((getTimer() - timeStamp) / 1000);
		var finalLength:Number = targetFileStream.position - headerData.length;
		_logger.writeLog(LogLevel.DEBUG, "encryptionComplete()");
		_logger.writeLog(LogLevel.DEBUG, "Time taken [" + diff + "]");
		_logger.writeLog(LogLevel.DEBUG, "Original Length " + sourceFileInfo.size);
		_logger.writeLog(LogLevel.DEBUG, "Encrypted length " + finalLength);
		
		isDone = true;
		_logger.flush();
	}
	
	/**
	 * This function will be called once the decryption process
	 * is completed. We will write the targetData to the file
	 * based on targetFileInfo.
	 */
	private function decryptionComplete():void
	{
		var diff:String = Utils.formatTimeString((getTimer() - timeStamp) / 1000);
		_logger.writeLog(LogLevel.DEBUG, "decryptionComplete()");
		_logger.writeLog(LogLevel.DEBUG, "Time taken [" + diff + "]");
		_logger.writeLog(LogLevel.DEBUG, "File Length " + targetData.length);
		
		// Write the target file
		var targetFile:File = new File(targetFileInfo.filePath);
		try
		{
			FileReadWrite.writeToBinaryFile(targetFile, targetData);
			_logger.writeLog(LogLevel.DEBUG, targetFile.size + " bytes written.");
		}
		catch(error:Error)
		{
			_logger.writeLog(LogLevel.ERROR, "decryptionComplete()" + error.message);
		}
		isDone = true;
		_logger.flush();
	}
	
	/**
	 * This function is called after encryption process is completed
	 * and tries to create a rap file with the data in headerData.
	 */
	private function writeRapFile():void
	{
		_logger.writeLog(LogLevel.DEBUG, "writeRapFile() " + targetFileInfo.filePath);
		var targetFile:File = new File(targetFileInfo.filePath);
		try
		{
			FileReadWrite.writeToBinaryFile(targetFile, headerData);
			_logger.writeLog(LogLevel.DEBUG, targetFile.size + " bytes written.");
		}
		catch(error:Error)
		{
			_logger.writeLog(LogLevel.ERROR, "writeRapFile()" + error.message);
		}
		isDone = true;
		_logger.flush();
	}
	
	/**
	 * This function will read from a rap file (encrypted file)
	 * and process the header from the read file. A header object
	 * is created from the byteArray and the payload is uncompressed.
	 */
	private function readRapFile():void
	{
		var sourceFile:File = new File(sourceFileInfo.filePath);
		if(sourceFile.exists)
		{
			var temp:ByteArray = FileReadWrite.readAsByteArray(sourceFile);
			if(temp)
			{
				wrapperData = HeaderUtils.headerAsObject(temp);
				
				// set the key and other params from header
				sourceData = wrapperData.payload;
				sourceData.uncompress(CompressionAlgorithm.DEFLATE);
			}
		}
		currentStep = initCipher;
	}
	
	/**
	 * This function will try to validate the header of a read
	 * rap (encrypted) file. It will check for valid Rap file
	 * as well as validate the password based on the encrypted
	 * signature present in the file.
	 */
	private function validateHeader():void
	{
		if(wrapperData)
		{
			if(wrapperData.identifier == AppConstants.RAP_FILE_6_IDENTIFIER)
			{
				// Cryptx 6.0 rap file format
			}
			else if(wrapperData.identifier == AppConstants.RAP_FILE_IDENTIFIER)
			{
				// Cryptx 6.1 rap file format
			}
			else
			{
				// invalid rap file
				_logger.writeLog(LogLevel.ERROR, "validateHeader() Invalid RAP File");
				currentStep = errorOccured;
				errorMessage = "Invalid RAP File.";
				this.yield();
			}
			
			// Decrypt the signature
			var badPassword:Boolean = false;
			var decryptedSignature:ByteArray = wrapperData.cryptxSignature;
			try
			{
				cipher.decrypt(decryptedSignature);
				var signature:String = stringFromByteArray(decryptedSignature);
				if(signature != AppConstants.CRYPTX_SIGNATURE)
				{
					// bad password
					badPassword = true;
				}
			}
			catch(error:Error)
			{
				// bad password
				trace(error.message);
				badPassword = true;
			}
			
			if(badPassword == true)
			{
				_logger.writeLog(LogLevel.ERROR, 
					"validateHeader() Wrong password");
				errorMessage = "The password is wrong.";
				currentStep = errorOccured;
				this.yield();
			}
			else
			{
				//decrypt the fileExtension from the header
				encryptedExtension = wrapperData.fileExtension;
				cipher.decrypt(encryptedExtension);
				var originalExtension:String = 
					stringFromByteArray(encryptedExtension);
				targetFileInfo.fileExtension = originalExtension;
				
				// Update the target filename
				var targetFileName:String = 
					targetFileInfo.location + File.separator + 
					targetFileInfo.nameWithExtension;
				targetFileInfo.filePath = targetFileName;
				
				_logger.writeLog(LogLevel.DEBUG, 
					"validateHeader() Original file extn " + originalExtension);
				// initialize timer data
				timeStamp = getTimer();
				
				currentStep = decryptBlock;
			}
		}
		else
		{
			_logger.writeLog(LogLevel.ERROR, 
				"validateHeader() wrapperData is empty");
			errorMessage = "Invalid RAP File.";
			currentStep = errorOccured;
		}
	}
	
	/**
	 * This function will be called when an error has occured.
	 * It will throw a FAULT event with the errorMessage.
	 */
	private function errorOccured():void
	{
		var event:CryptxEvent = new CryptxEvent(CryptxEvent.FAULT);
		event.errorMessage = errorMessage;
		dispatchEvent(event);
		isDone = true;
	}
	
	//---------------------------------
	// EventDispatcher Methods
	//---------------------------------
	
	/**
	 * Dispatches an event
	 */
	public function dispatchEvent(event:Event):Boolean
	{
		return eventDispatcher.dispatchEvent(event);
	}
	
	/**
	 * Adds an event listner
	 */
	public function addEventListener(type:String, listener:Function, useCapture:Boolean  = false, priority:int = 0, 
		useWeakReference:Boolean  = false):void
	{
		eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	/**
	 * Removes an event listner
	 */
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean  = false):void
	{
		eventDispatcher.removeEventListener(type, listener, useCapture);
	}
	
	/**
	 * Implementation for hasEventListener
	 */
	public function hasEventListener(type:String):Boolean
	{
		return eventDispatcher.hasEventListener(type);
	}
	
	/**
	 * Implementation for willTrigger
	 */
	public function willTrigger(type:String):Boolean
	{
		return eventDispatcher.willTrigger(type);
	}
	
	//---------------------------------
	// Utility Methods
	//---------------------------------
	
	/**
	 * Returns a bytearray from a string
	 */
	private function byteArrayFromString(data:String):ByteArray
	{
		return Hex.toArray(Hex.fromString(data));
	}
	
	/**
	 * Returns a string from a bytearray
	 */
	private function stringFromByteArray(data:ByteArray):String
	{
		return Hex.toString(Hex.fromArray(data));
	}
	
	private function decryptToString(_t:ByteArray):String
	{
		var t:ByteArray = new ByteArray(); 
		t.writeBytes(_t); 
		cipher.decrypt(t); 
		return stringFromByteArray(t);
	}
}
}