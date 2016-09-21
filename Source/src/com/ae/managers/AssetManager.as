package com.ae.managers
{

/**
 * This class provedes the management for external assets for the project
 */
public class AssetManager
{
	/**
	 * @private
	 */
	private static var _instance:AssetManager;
	
	//-------------------------------------------------------------------------
	//
	//  Constructor
	//
	//-------------------------------------------------------------------------
    public function AssetManager() 
    {
          if(_instance!=null) {
                throw new Error("Singleton already instantiated");
          }
    }
    
    /**
     * Returns the singleton instance
     */ 
    public static function getInstance():AssetManager
    {
          if(_instance == null)
                _instance = new AssetManager();
          return _instance;
    }
    
    //-------------------------------------------------------------------------
	//
	//  Assets
	//
	//-------------------------------------------------------------------------
    
    [Embed(source="/resources/images/spinner.swf")]
    [Bindable]public  var LoadingAnimation : Class;
    
    [Embed(source="/resources/images/cryptx_header.png")]
    [Bindable]public  var CryptxHeader : Class;
    
    [Embed(source="/resources/images/rap_file_32.png")]
    [Bindable]public  var RapFileIcon_32 : Class;
    
    [Embed(source="/resources/images/selected_icon.png")]
    [Bindable]public  var SelectedIcon : Class;

}
}