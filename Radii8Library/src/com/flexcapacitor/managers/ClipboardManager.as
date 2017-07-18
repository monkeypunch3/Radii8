package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImportOptions;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.core.BitmapAsset;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	
	import spark.components.Application;
	import spark.effects.Animate;
	import spark.effects.Fade;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.IEaser;
	import spark.effects.easing.Sine;
	import spark.primitives.supportClasses.GraphicElement;
	
	import org.as3commons.lang.ObjectUtils;

	public class ClipboardManager {
		
		public function ClipboardManager(s:SINGLEDOUBLE) {
			
		}
		
		public var radiate:Radiate;
		
		/**
		 * Last clipboard action. Either cut or copy;
		 * */
		public var lastClipboardAction:String;
		
		/**
		 * Cut data
		 * */
		public var cutData:Object;
		
		/**
		 * Copy data
		 * */
		public var copiedData:Object;
		
		/**
		 * Reference to the document of the cut or copied data
		 * */
		public var copiedDataDocument:Object;
		
		/**
		 * Reference to the source of the copied or cut data. Useful if reference to copied
		 * item is gone. In other words, user copied an item from their document
		 * and then deleted the document. They could still paste it.
		 * */
		public var copiedDataSource:String;
		
		/**
		 * Cut item
		 * @see copiedData
		 * @see lastClipboardAction
		 * @see pasteItem
		 * */
		public function cutItem(item:Object, selectedDocument:IDocument):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
			cutData = item;
			copiedData = null;
			copiedDataDocument = selectedDocument;
			lastClipboardAction = "cut";
			
			// convert to string and then import to selected target or document
			var options:ExportOptions = new ExportOptions();
			var sourceItemData:SourceData;
			options.useInlineStyles = true;
			
			if (copiedDataDocument && copiedDataDocument.getItemDescription(item)) {
				sourceItemData = CodeManager.getSourceData(item, copiedDataDocument as IDocument, CodeManager.MXML, options);
				
				if (sourceItemData) {
					copiedDataSource = sourceItemData.source;
				}
				
				if (showAnimation) {
					animateShortcut(item);
				}
			}
			
		}
		
		/**
		 * Copy item
		 * @see cutData
		 * @see lastClipboardAction
		 * @see pasteItem
		 * */
		public function copyItem(item:Object, selectedDocument:IDocument, format:String = null, handler:Function = null):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
			cutData = null;
			copiedData = item;
			copiedDataDocument = selectedDocument;
			lastClipboardAction = "copy";
			
			
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var serializable:Boolean = true;
			
			format = format ? format : "Object";
			handler = handler!=null ? handler : setClipboardDataHandler;
			
			if (true) {
				clipboard.clear();
			}
			
			try {
				// convert to string and then import to selected target or document
				var options:ExportOptions = new ExportOptions();
				var sourceItemData:SourceData;
				
				options.useInlineStyles = true;
				options.exportChildDescriptors = true;
				
				if (selectedDocument.getItemDescription(item)) {
					sourceItemData = CodeManager.getSourceData(item, selectedDocument, CodeManager.MXML, options);
					
					if (sourceItemData) {
						copiedDataSource = sourceItemData.source;
					}
				}
				
				
				if (item is String) {
					clipboard.setDataHandler(format, handler, serializable);
				}
				else {
					clipboard.setDataHandler(format, handler, serializable);
				}
				
				if (showAnimation) {
					animateShortcut(item);
				}
			}
			catch (error:ErrorEvent) {
				
			}
		}
		
		/**
		 * Duplicate item
		 * */
		public function duplicateItem(item:Object, selectedDocument:IDocument):void {
			var itemData:SourceData;
			var description:ComponentDescription;
			var destinationIndex:int;
			var destination:Object;
			var importOptions:ImportOptions;
			var exportOptions:ExportOptions;
			
			
			if (item == null || item is Application) {
				return;
			}
			
			destination = item && item.owner ? item.owner : null;
			
			if (destination==null && item && "parent" in item) {
				destination = item && item.parent ? item.parent : null;
			}
			
			// get destination
			if (destination && !(destination is IVisualElementContainer)) {
				destination = destination.owner;
			}
			
			// prevent containers from being pasted into themselves
			if (selectedDocument.instance.contains(destination.owner)) {
				destination = destination.owner;
			}
			
			if (!destination) {
				destination = selectedDocument.instance;
			}
			
			try {
				// convert to string and then import to selected target or document
				exportOptions = new ExportOptions();
				
				exportOptions.useInlineStyles = true;
				exportOptions.exportChildDescriptors = true;
				
				if (selectedDocument.getItemDescription(item)) {
					itemData = CodeManager.getSourceData(item, selectedDocument, CodeManager.MXML, exportOptions);
				}
				
				// duplicate selection
				if (itemData) {
					itemData = CodeManager.setSourceData(itemData.source, destination, selectedDocument, CodeManager.MXML, destinationIndex, importOptions);
				}
				
				// select first target
				if (itemData && itemData.targets && itemData.targets.length) { 
					radiate.setTarget(itemData.targets[0]);
				}
				else {
					radiate.setTarget(destination);
				}
				
				itemData = null;
				
				if (showAnimation) {
					
					if (radiate.target) {
						animateShortcut(radiate.target, true);
					}
					else {
						animateShortcut(destination, true);
					}
				}
			}
			catch (error:ErrorEvent) {
				
			}
		}
		
		/**
		 * Get destination component or application when image files are 
		 * dropped from an external source
		 * */
		public function getDestinationForExternalFileDrop(selectedDocument:IDocument):Object {
			var destination:Object = radiate.target;
			var addToDocumentForNow:Boolean = true;
			
			// get destination of clipboard contents
			if (destination && !(destination is IVisualElementContainer)) {
				if (addToDocumentForNow) {
					destination = null;
				}
				else {
					destination = destination.owner;
				}
			}
			
			if (!destination && selectedDocument) {
				destination = selectedDocument.instance;
			}
			
			return destination;
		}
		
		/**
		 * Paste item
		 * @see cutData
		 * @see copiedData
		 * @see lastClipboardAction
		 * @see pasteItem
		 * */
		public function pasteItem(destination:Object, selectedDocument:IDocument):void {
			var description:ComponentDescription;
			var descriptor:ComponentDescription;
			var useCopyObjectsTechnique:Boolean;
			var importOptions:ImportOptions;
			var exportOptions:ExportOptions;
			var item:ComponentDefinition;
			var useInlineStyles:Boolean;
			var componentFound:Boolean;
			var bitmapData:BitmapData;
			var destinationIndex:int;
			var clipboard:Clipboard;
			var newComponent:Object;
			var itemData:SourceData;
			var numberOfFormats:int;
			var component:Object;
			var formats:Array;
			var format:String;
			var data:Object;
			var actionPerformed:Boolean;
			
			clipboard = Clipboard.generalClipboard;
			formats = clipboard.formats;
			destinationIndex = -1;
			
			// get destination of clipboard contents
			if (destination && !(destination is IVisualElementContainer)) {
				destination = destination.owner;
			}
			
			// prevent containers from being pasted into themselves
			if (cutData==destination || copiedData==destination) {
				if (selectedDocument.instance.contains(destination.owner)) {
					destination = destination.owner;
				}
			}
			
			if (!destination) {
				destination = selectedDocument.instance;
			}
			
			if (descriptor==null) {
				descriptor = selectedDocument.getItemDescription(component);
			}
			
			numberOfFormats = formats.length;
			
			// check for bitmap data, image files, air:rtf, air:text, etc 
			// when multiple formats exist add first forrmat we suport
			for (var i:int;i<numberOfFormats;i++) {
				format = formats[i];
				
				
				if (format=="UIComponent" || format=="Object") {
					// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
					// 	at flash.desktop::Clipboard/getObjectReference()
					//  at flash.desktop::Clipboard/convertNativeFormat()
					//  at flash.desktop::Clipboard/getOriginal()
					//  at flash.desktop::Clipboard/getData()
					
					// if you are debugging, debug after this point to get rid of the error
					
					try {
						component = clipboard.getData(format);
					}
					catch (error:Error) {
						if (error.errorID==2179) {
							component = copiedData;
						}
						
					}
					
					descriptor = component as ComponentDescription;
					
					if (component is Application) {
						//Radiate.error("Cannot copy and paste the document.");
						return;
					}
					
					if (component==null) {
						return;
					}
					
					componentFound = true;
					
					// code is outside of for loop - refactor
					break;
					
				}
				else if (format==ClipboardFormats.FILE_LIST_FORMAT || 
					format==ClipboardFormats.FILE_PROMISE_LIST_FORMAT) {
					data = component;
					
					radiate.addFileListDataToDocument(selectedDocument, data as Array, destination);
					actionPerformed = true;
				}
				else if (format==ClipboardFormats.BITMAP_FORMAT) {
					// format is air:bitmap
					//data = clipboard.getData(ClipboardFormats.BITMAP_FORMAT);
					data = component;
					bitmapData = data as BitmapData;
					
					if (Radiate.isDesktop) {
						// not supported in FP in the browser - might try capturing via JS 
						radiate.addBitmapDataToDocument(selectedDocument, bitmapData, destination);
						actionPerformed = true;
					}
					else {
						Radiate.warn("You cannot paste image data from the clipboard in the browser at this time. Please import the image file.");
					}
				}
				else if (format==ClipboardFormats.TEXT_FORMAT) {
					//data = clipboard.getData(ClipboardFormats.TEXT_FORMAT);
					data = component;
					
					radiate.addTextDataToDocument(selectedDocument, data as String, destination);
					actionPerformed = true;
				}
				else if (format==ClipboardFormats.HTML_FORMAT) {
					// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
					// 	at flash.desktop::Clipboard/getHTML()
					//data = clipboard.getData(ClipboardFormats.HTML_FORMAT);
					data = component;
					
					radiate.addHTMLDataToDocument(selectedDocument, data as String, destination);
					actionPerformed = true;
				}
				
				if (actionPerformed) {
					
					if (showAnimation) {
						
						if (radiate.target) {
							animateShortcut(radiate.target, true);
						}
						else {
							animateShortcut(destination, true);
						}
					}
					
					return;
				}
			}
			
			if (useCopyObjectsTechnique) {
				item = Radiate.getComponentType(component.className);
				newComponent = Radiate.createComponentToAdd(selectedDocument, item, true);
				Radiate.addElement(newComponent, destination, descriptor.propertyNames, descriptor.styleNames, descriptor.eventNames, ObjectUtils.merge(descriptor.properties, descriptor.styles));
				Radiate.updateComponentAfterAdd(selectedDocument, newComponent);
				//setProperties(newComponent, descriptor.propertyNames, descriptor.properties);
				HistoryManager.doNotAddEventsToHistory = true;
				//setStyles(newComponent, descriptor.styleNames, descriptor.styles);
				HistoryManager.doNotAddEventsToHistory = false;
				radiate.setTarget(newComponent);
			}
			else if (component) {
				useInlineStyles = false;
				exportOptions = new ExportOptions();
				exportOptions.useInlineStyles = true;
				exportOptions.exportChildDescriptors = true;
				description = selectedDocument.getItemDescription(component);
				
				// copy selection
				if (description) {
					itemData = CodeManager.getSourceData(component, selectedDocument, CodeManager.MXML, exportOptions);
				}
				
				// paste selection
				if (itemData && description) {
					itemData = CodeManager.setSourceData(itemData.source, destination, selectedDocument, CodeManager.MXML, destinationIndex, importOptions);
				}
				else if (copiedDataSource) {
					itemData = CodeManager.setSourceData(copiedDataSource, destination, selectedDocument, CodeManager.MXML, destinationIndex, importOptions);
				}
				
				// select first target
				if (itemData && itemData.targets && itemData.targets.length) { 
					radiate.setTarget(itemData.targets[0]);
				}
				else {
					radiate.setTarget(destination);
				}
				
				itemData = null;
				
				if (showAnimation) {
					
					if (radiate.target) {
						animateShortcut(radiate.target, true);
					}
					else {
						animateShortcut(destination, true);
					}
				}
			}
		}
		
		/**
		 * Set clipboard data handler
		 * */
		public function setClipboardDataHandler():* {
			/*Format	Return Type
			ClipboardFormats.TEXT_FORMAT	String
			ClipboardFormats.HTML_FORMAT	String
			ClipboardFormats.URL_FORMAT	String (AIR only)
			ClipboardFormats.RICH_TEXT_FORMAT	ByteArray
			ClipboardFormats.BITMAP_FORMAT	BitmapData (AIR only)
			ClipboardFormats.FILE_LIST_FORMAT	Array of File (AIR only)
			ClipboardFormats.FILE_PROMISE_LIST_FORMAT	Array of File (AIR only)
			Custom format name	Non-void*/
			
			// convert to string and then import to selected target or document
			//var options:ExportOptions = new ExportOptions();
			//options.useInlineStyles = true;
			
			//var sourceItemData:SourceData = CodeManager.getSourceData(target, selectedDocument, CodeManager.MXML, options);
			
			
			if (copiedData) {
				return copiedData;
			}
			else if (cutData) {
				return cutData;
			}
			
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
		}
		
		public var showAnimation:Boolean = true; 
		public var fadeAnimation:Fade;
		public var copyAnimation:Animate;
		public var copyAnimationDuration:int = 600;
		public var copyAnimationStartDelay:int = 50;
		public var copyAnimationEaser:IEaser = new Sine(.75);// = new Bounce();
		
		public var copyIconInstance:UIComponent;
		public var pasteIconInstance:UIComponent;
		
		public function animateShortcut(target:Object, paste:Boolean = false):void {
			var iconBitmapData:BitmapAsset;
			var toolLayer:IVisualElementContainer;
			var targetPoint:Point;
			var toolLayerPoint:Point;
			var stagePoint:Point;
			
			if (fadeAnimation==null) {
				fadeAnimation = new Fade();
				fadeAnimation.duration = copyAnimationDuration;
				fadeAnimation.startDelay = copyAnimationStartDelay;
				fadeAnimation.easer = copyAnimationEaser;
				fadeAnimation.alphaFrom = 1;
				fadeAnimation.alphaTo = 0;
			}
			
			if (copyIconInstance==null) {
				copyIconInstance = new UIComponent();
				
				iconBitmapData = new Radii8LibraryAssets.copy();
				copyIconInstance.graphics.beginBitmapFill(iconBitmapData.bitmapData);
				copyIconInstance.graphics.drawRect(0, 0, iconBitmapData.bitmapData.width, iconBitmapData.bitmapData.height);
				copyIconInstance.graphics.endFill();
			}
			
			if (pasteIconInstance==null) {
				pasteIconInstance = new UIComponent();
				
				iconBitmapData = new Radii8LibraryAssets.pasteIcon();
				pasteIconInstance.graphics.beginBitmapFill(iconBitmapData.bitmapData);
				pasteIconInstance.graphics.drawRect(0, 0, iconBitmapData.bitmapData.width, iconBitmapData.bitmapData.height);
				pasteIconInstance.graphics.endFill();
			}
			
			copyIconInstance.alpha = 0;
			
			toolLayer = radiate.toolLayer;
			
			if (paste) {
				if ("contains" in toolLayer && !Object(toolLayer).contains(pasteIconInstance)) {
					toolLayer.addElement(pasteIconInstance);
				}
			}	
			else {
				if ("contains" in toolLayer && !Object(toolLayer).contains(copyIconInstance)) {
					toolLayer.addElement(copyIconInstance);
				}
			}
			
			targetPoint = new Point();
			if (target is GraphicElement) {
				stagePoint = DisplayObject(target.displayObject).localToGlobal(targetPoint);
			}
			else {
				stagePoint = DisplayObject(target).localToGlobal(targetPoint);
			}
			
			toolLayerPoint = DisplayObject(toolLayer).globalToLocal(stagePoint);
	
			if (fadeAnimation.isPlaying) {
				fadeAnimation.end();
			}
			
			fadeAnimation.removeEventListener(EffectEvent.EFFECT_END, fadePasteAnimation_effectEndHandler);
			fadeAnimation.removeEventListener(EffectEvent.EFFECT_END, fadeCopyAnimation_effectEndHandler);
			
			if (paste) {
				fadeAnimation.addEventListener(EffectEvent.EFFECT_END, fadePasteAnimation_effectEndHandler);
			}
			else {
				fadeAnimation.addEventListener(EffectEvent.EFFECT_END, fadeCopyAnimation_effectEndHandler);
			}
			
			if (paste) {
				pasteIconInstance.x = toolLayerPoint.x + 1;
				pasteIconInstance.y = toolLayerPoint.y + 1;
				fadeAnimation.play([pasteIconInstance]);
			}
			else {
				copyIconInstance.x = toolLayerPoint.x + 1;
				copyIconInstance.y = toolLayerPoint.y + 1;
				fadeAnimation.play([copyIconInstance]);
			}
		}
		
		protected function fadePasteAnimation_effectEndHandler(event:Event):void {
			fadeAnimation.removeEventListener(EffectEvent.EFFECT_END, copyAnimation_effectEndHandler);
			
			if (copyIconInstance.owner) {
				IVisualElementContainer(copyIconInstance.owner).removeElement(copyIconInstance);
			}
			
			if (pasteIconInstance.owner) {
				IVisualElementContainer(pasteIconInstance.owner).removeElement(pasteIconInstance);
			}
			
			//Radiate.showToolsLayer();
			//Radiate.updateSelection(Radiate.instance.target);
		}
		
		protected function fadeCopyAnimation_effectEndHandler(event:Event):void {
			fadeAnimation.removeEventListener(EffectEvent.EFFECT_END, copyAnimation_effectEndHandler);
			
			if (copyIconInstance.owner) {
				IVisualElementContainer(copyIconInstance.owner).removeElement(copyIconInstance);
			}
			
			if (pasteIconInstance.owner) {
				IVisualElementContainer(pasteIconInstance.owner).removeElement(pasteIconInstance);
			}
			//Radiate.showToolsLayer();
			//Radiate.updateSelection(Radiate.instance.target);
		}
		
		public function animateCopy2(target:Object):void {
			var motionPaths:Vector.<MotionPath>;
			var alphaFromPath:SimpleMotionPath;
			var alphaToPath:SimpleMotionPath;
			
			copyAnimation = new Animate();
			copyAnimation.addEventListener(EffectEvent.EFFECT_END, copyAnimation_effectEndHandler);
			copyAnimation.duration = copyAnimationDuration;
			copyAnimation.startDelay = copyAnimationStartDelay;
			copyAnimation.easer = copyAnimationEaser;
			
			alphaFromPath = new SimpleMotionPath("alpha", 1, .5);
			alphaToPath = new SimpleMotionPath("alpha", .5, 1);
			
			motionPaths = Vector.<MotionPath>([alphaFromPath, alphaToPath]);
			copyAnimation.motionPaths = motionPaths;
			copyAnimation.play([target]);
			//Radiate.hideToolsLayer();
		}
		
		protected function copyAnimation_effectEndHandler(event:Event):void {
			copyAnimation.removeEventListener(EffectEvent.EFFECT_END, copyAnimation_effectEndHandler);
			//Radiate.showToolsLayer();
			//Radiate.updateSelection(Radiate.instance.target);
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ClipboardManager
		{
			if (!_instance) {
				_instance = new ClipboardManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ClipboardManager {
			return instance;
		}
		
		private static var _instance:ClipboardManager;
	}
}

class SINGLEDOUBLE{}