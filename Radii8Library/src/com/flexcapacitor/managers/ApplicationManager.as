package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controls.AceEditor;
	import com.flexcapacitor.events.HTMLDragEvent;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.events.RedirectEvent;
	import com.flexcapacitor.model.HTMLDragData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.skins.CallOutSkin;
	import com.flexcapacitor.utils.ClassRegistry;
	import com.flexcapacitor.utils.DocumentTranscoder;
	import com.flexcapacitor.utils.HTMLDragManager;
	import com.flexcapacitor.utils.PopUpOverlayManager;
	import com.flexcapacitor.views.MainView;
	import com.google.code.flexiframe.IFrame;
	
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	import mx.events.FlexEvent;
	import mx.managers.IBrowserManager;
	
	import spark.components.Application;

	public class ApplicationManager extends Application {
		
		public function ApplicationManager() {
			
		}
		
		public var applicationDescriptor:XML;
		private var calloutSkin:CallOutSkin;
		private var dragManager:DragManagerImpl;
		private var browserManager:IBrowserManager;
		public var htmlDragAndDrop:HTMLDragManager;
		
		/**
		 * @private
		 * */
		[Bindable]
		public var radiate:Radiate;
		public var BUILD_NUMBER:String;
		public var BUILD_DATE:String;
		public var BUILD_TIME:String;
		
		public var appInfo:Object;
		public var mainView:MainView;
		
		/**
		 * Setup the environment. If remote set WP host and path. 
		 * If running on the desktop or not using remote service
		 * we will need to change the message
		 * */
		public function applicationCompleteHandler(event:FlexEvent):void {
			var path:String;
			var appNamespace:Namespace;
			var versionNumber:String;
			var quality:String;
			
			quality = StageQuality.BEST;
			stage.quality = quality;
			
			radiate = Radiate.instance;
			
			radiate.buildNumber = BUILD_NUMBER;
			radiate.buildDate = BUILD_DATE;
			radiate.buildTime = BUILD_TIME;
			
			applicationDescriptor = new XML(new appInfo());
			appNamespace = applicationDescriptor.namespace();
			versionNumber = applicationDescriptor.appNamespace::versionNumber;
			radiate.versionNumber = versionNumber;
			
			startupBrowser();
			
			if (url.indexOf("http://localhost")==0) {
				path = "http://www.radii8.com"; // when running locally
			}
			
			ExternalInterface.marshallExceptions = true;
			Radiate.startup(this, mainView, path);
			
			listenForDragAndDrop();
			
			var classRegistry:ClassRegistry = ClassRegistry.getInstance();
			var transcoder:DocumentTranscoder = new DocumentTranscoder();
			var mxmlApplicationDocument:XML = transcoder.getDefaultMXMLDocumentXML();
			
			//var walker:Walker = new Walker(startupBrowser);
			
			classRegistry.addNamespaces(mxmlApplicationDocument);
			//componentName = component.@id;
			//componentClass = component.attribute(CLASS);
			//Walker;
			//var className:String = "BlackAndWhiteFilter";
			//var componentClass:String = "com.flexcapacitor.filters.BlackAndWhiteFilter";
			//var componentQName:QName = new QName(MXMLDocumentConstants.fcNamespaceURI, className);
			//classRegistry.registerClass(componentQName, componentClass);
			
			// load snippet
			if (ExternalInterface.available) {
				var string:String;
				var results:String;
				var testURL:Boolean;
				var selectedDocument:IDocument;
				
				string = "function(id) { return document.location.hash; }";
				results = ExternalInterface.call(string, ExternalInterface.objectID);
				testURL = false;
				
				if (testURL) {
					results = "0vOK6vg";
				}
				
				if (results) {
					selectedDocument = Radiate.selectedDocument;
					
					if (!selectedDocument) {
						DocumentManager.createNewDocumentAndSwitchToDesignView();
						Radiate.addEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler, false, 0, true);
						snippetID = results;
					}
					else {
						ViewManager.openImportMXMLWindow("Import Snippet", "", false, results);
					}
				}
			}
		}
		
		private var snippetID:String;
		public var isCreatingDocument:Boolean;
		
		protected function documentOpenedHandler(event:Event):void {
			isCreatingDocument = false;
			radiate.removeEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler);
			ViewManager.openImportMXMLWindow("Import Snippet", "", false, snippetID);
		}
		
		protected function application1_initializeHandler(event:FlexEvent):void {
			//var version:String = LoaderConfig.swfVersion;
			// get pixels of images for drag and drop in 
			//JPEGLoaderContext;
			var sandboxType:String = Security.sandboxType;
			// attempt to allow image access for editing operations - doesn't work
			//Security.allowDomain("*");
			//Security.allowInsecureDomain("*");
			Security.disableAVM1Loading = true;
			var overlayTypes:Array = [IFrame, AceEditor];
			new PopUpOverlayManager(null, overlayTypes);
			//MacMouseWheelHandler.init(systemManager.stage);
			//stage.quality = StageQuality.HIGH_16X16_LINEAR;
		}
		
		private function startupBrowser():void {
			MenuManager.applicationMenu = mainView.mainMenuBar;
		}
		
		private function listenForDragAndDrop():void {
			HTMLDragManager.debug = true;
		}
		
		public function dragHandler(event:HTMLDragEvent):void {
			var type:String = event.type;
			if (type==HTMLDragManager.DRAG_ENTER) {
				mainView.dropImagesLocation.visible = true;
				PopUpOverlayManager.instance.hideAllOverlays();
			}
			else if (type==HTMLDragManager.DRAG_EXIT) {
				mainView.dropImagesLocation.visible = false;
			}
		}
		
		public function dragDropHandler(event:HTMLDragEvent):void {
			var selectedDocument:IDocument;
			
			if (HTMLDragData(event.data).mimeType==HTMLDragManager.INVALID) {
				Radiate.warn("The item you have dropped is invalid. Some supported types include png, jpg, jpeg and gif images");
				PopUpOverlayManager.instance.showAllOverlays();
				mainView.dropImagesLocation.visible = false;
				return;
			}
			
			// not created yet
			if (radiate==null) { return };
			
			selectedDocument = Radiate.selectedDocument;
			PopUpOverlayManager.instance.showAllOverlays();
			mainView.dropImagesLocation.visible = false;
			
			var	isCommandKeyDown:Boolean = "commandKey" in event && event.commandKey;
			var isControlOrCommand:Boolean = event.controlKey || isCommandKeyDown;
			
			Radiate.info("Opening... Hold on...");
			
			DeferManager.callAfter(500, openDraggedItem, event, !event.shiftKey, isControlOrCommand);
		}
		
		public function openDraggedItem(event:HTMLDragEvent, resizeContentIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):void {
			var createDocument:Boolean;
			var createDocumentIfNeeded:Boolean = true;
			
			LibraryManager.dropItemWeb(event, createDocument, createDocumentIfNeeded, resizeContentIfNeeded, resizeDocumentToContent);
		}
		
		protected function preventredirect1_redirectingHandler(event:RedirectEvent):void {
			//event.preventDefault();
			//trace("Redirecting away");
			
			// if no documents are open call event.preventDefault() to suppress popup message
		}
		
		protected function application1_preinitializeHandler(event:FlexEvent):void
		{
			HTMLDragManager.debug = true;
		}
		
	}
}