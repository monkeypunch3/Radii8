package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.ComponentManager;
	import com.flexcapacitor.managers.DocumentManager;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.managers.LibraryManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.supportClasses.MarqueeSelection;
	import com.flexcapacitor.utils.supportClasses.log;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.containers.TabNavigator;
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.FlexSprite;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.events.SandboxMouseEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.core.IGraphicElement;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.utils.BitmapUtil;
	
	/**
	 * Draws a rectangle used for selection.
	 * */
	public class Marquee extends FlexSprite implements ITool {
		
		public function Marquee()
		{
			
		}
		
		private var _icon:Class = Radii8LibraryToolAssets.Marquee;
		
		public function get icon():Class {
			return _icon;
		}
		
		public var debug:Boolean;
		public var mouseDownPoint:Point = new Point();
		public var marqueeLocalOrigin:Point = new Point();
		public var marqueeGroup:MarqueeSelection;
		public var isOverMarquee:Boolean;
		public var isOverApplication:Boolean;
		public var isOverCanvasBackground:Boolean;
		public var systemManager:SystemManager;
		public var isDragging:Boolean;
		public var isDrawing:Boolean;
		public var isMouseDown:Boolean;
		public var targetApplication:Object;
		public var toolLayer:IVisualElementContainer;
		public var document:IDocument;
		public var canvasBackground:Object;
		public var radiate:Radiate;
		
		public function enable():void {
			
			if (systemManager==null) {
				systemManager = getSystemManager();
			}
			
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			systemManager.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler, false, 0, true);
			
			radiate = Radiate.instance;
			
			if (Radiate.selectedDocument) {
				updateDocument(Radiate.selectedDocument);
			}
			
			
			Mouse.cursor = MouseCursor.AUTO;
			
			addRadiateListeners();
			addCanvasListeners();
			addMarquee();
			addKeyboardListeners();
			
		}
		
		public function disable():void {
			
			if (systemManager==null) {
				systemManager = getSystemManager();
			}
			
			systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			systemManager.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
			
			removeRadiateListeners();
			removeCanvasListeners();
			removeMarquee();
			removeKeyboardListeners();
		}
		
		/**
		 * Add canvas listeners for scrolling
		 * */
		public function addCanvasListeners():void {
			removeCanvasListeners();
			
			if (radiate && DocumentManager.toolLayer) {
				toolLayer = DocumentManager.toolLayer;
			}
			
			if (radiate && DocumentManager.canvasBackground) {
				canvasBackground = DocumentManager.canvasBackground;
			}
		}
		
		/**
		 * Removes canvas listeners
		 * */
		public function removeCanvasListeners():void {
			
		}
		
		public function addMarquee():void {
			if (marqueeGroup==null) {
				marqueeGroup = new MarqueeSelection();
				marqueeGroup.mouseEnabled = true;
				marqueeGroup.mouseEnabledWhereTransparent = true;
			}
			
			toolLayer.addElement(marqueeGroup);
			squeezeMarquee();
		}
		
		public function squeezeMarquee():void {
			if (marqueeGroup==null) return;	
			marqueeGroup.width = 0;
			marqueeGroup.height = 0;
		}
		
		public function removeMarquee():void {
			if (marqueeGroup==null) {
				return;
			}
			
			toolLayer.removeElement(marqueeGroup);
			squeezeMarquee();
		}
		
		public function getMarqueeBounds():Rectangle {
			if (marqueeGroup==null) {
				return null;
			}
			
			var bounds:Rectangle = marqueeGroup.getBounds(marqueeGroup);
			return bounds;
		}
		
		/**
		 * Add event listeners to new document and remove listeners from previous
		 * */
		public function updateDocument(iDocument:IDocument):void {
			
			// remove listeners
			if (iDocument==null || 
				(targetApplication && iDocument && targetApplication!=iDocument.instance)) {
				//removeAllListeners();
			}
			
			document = iDocument;
			targetApplication = iDocument ? iDocument.instance : null;
			
			// add listeners
			if (targetApplication) {
				//addAllListeners();
			}
			
		}
		
		/**
		 * Adds listeners to radiate instance
		 * */
		public function addRadiateListeners():void {
			radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, 		documentChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_CLOSE, 		documentCloseHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
		}
		
		/**
		 * Removes listeners from radiate instance
		 * */
		public function removeRadiateListeners():void {
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, 		documentChangeHandler);
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CLOSE, 		documentCloseHandler);
		}
		
		/**
		 * Handle mouse down on application
		 * 
		 * Three scenarios: 
		 * 
		 * 1. Moving a rectangle
		 * 2. Drawing a rectangle
		 * 3. Deslecting current rectangle
		 * */
		public function mouseDownHandler(event:MouseEvent):void {
			var eventTarget:DisplayObject = event.target as DisplayObject;
			
			isMouseDown = true;
			isOverApplication = false;
			isOverCanvasBackground = false;
			
			mouseDownPoint.x = event.stageX;
			mouseDownPoint.y = event.stageY;
			
			// 1. moving a rectangle
			if (event.target==marqueeGroup) {
				isOverMarquee = true;
			}
			else {
				
				// 2. drawing a rectangle
				// 3. deselecting a rectangle
				isOverMarquee = false;
				
				if (eventTarget==targetApplication || DisplayObjectContainer(targetApplication).contains(eventTarget)) {
					isOverApplication = true;
					isOverCanvasBackground = true;
				}
				else if (DisplayObjectContainer(canvasBackground).contains(eventTarget)){
					isOverCanvasBackground = true;
				}
				
				if (!isOverCanvasBackground) {
					return;
				}
				
				squeezeMarquee();
				
				mouseDownPoint = new Point(event.stageX, event.stageY);
				marqueeLocalOrigin = DisplayObjectUtils.getDisplayObjectPosition(marqueeGroup.parent, event);
				
				marqueeGroup.x = marqueeLocalOrigin.x;
				marqueeGroup.y = marqueeLocalOrigin.y;
				
			}
			
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		/**
		 * Handle mouse move on application
		 * 
		 * Three scenarios: 
		 * 
		 * 1. Moving a rectangle
		 * 2. Drawing a rectangle
		 * 3. Deslecting current rectangle
		 * */
		public function mouseMoveHandler(event:MouseEvent):void {
			var displayObject:DisplayObject = event.currentTarget as DisplayObject;
			
			if (isMouseDown) {
				
				// 1. moving a rectangle
				if (isOverMarquee) {
					
					if (!isDragging) {
						marqueeGroup.startDrag();
						isDragging = true;
					}
					
					return;
				}
				
				// 2. drawing a rectangle
				if (isOverApplication) {
					isDrawing = true;
					updateMarqueeSize(event);
				}
			}
		}
		
		/**
		 * Handles mouse up
		 * 
		 * Three scenarios: 
		 * 
		 * 1. Moving a rectangle
		 * 2. Drawing a rectangle
		 * 3. Deslecting current rectangle
		 * */
		public function mouseUpHandler(event:MouseEvent):void {
			
			if (isMouseDown) {
				systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				
				// 1. moving rectangle
				if (isDragging || isOverMarquee) {
					marqueeGroup.stopDrag();
				}
				
				// 2. drawing a rectangle
				else if (isDrawing && event) {
					//if (isOverApplication && event) || (isOverCanvasBackground && event)) {
					
					updateMarqueeSize(event, true);
				}
				
				// 3. deselecting current rectangle
				else if (isOverApplication || isOverCanvasBackground) {
					squeezeMarquee();
				}
			}
			
			isDrawing				= false;
			isDragging				= false;
			isMouseDown 			= false;
			isOverMarquee 			= false;
			isOverApplication		= false;
			isOverCanvasBackground	= false;
		}
		
		public function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			mouseUpHandler(null);
		}
		
		public function updateMarqueeSize(event:MouseEvent, absolutePath:Boolean = true):void {
			var reversedX:Boolean;
			var reversedY:Boolean;
			var localPoint:Point;
			var width:int;
			var height:int;
			
			width = event.stageX - mouseDownPoint.x;
			height = event.stageY - mouseDownPoint.y;
			
			reversedX = width<0;
			reversedY = height<0;
			
			width = Math.abs(width);
			height = Math.abs(height);
			
			if (absolutePath) {
				
				if (reversedX) {
					marqueeGroup.x = marqueeLocalOrigin.x - width;
				}
				else {
					marqueeGroup.x = marqueeLocalOrigin.x;
				}
				
				if (reversedY) {
					marqueeGroup.y = marqueeLocalOrigin.y - height;
				}
				else {
					marqueeGroup.y = marqueeLocalOrigin.y;
				}
				
				marqueeGroup.width = width;
				marqueeGroup.height = height;
			}
		}
		
		public function getSystemManager():SystemManager {
			var systemManager:SystemManager = FlexGlobals.topLevelApplication.systemManager;
			var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
			var targetCoordinateSpace:SystemManager;
			
			if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
				targetCoordinateSpace = systemManager.getSandboxRoot() as SystemManager;
			}
			
			if (targetCoordinateSpace==null) {
				targetCoordinateSpace = systemManager;
			}
			
			return targetCoordinateSpace;
		}
		
		/*******************
		/* 
		 * Handlers
		 *  
		/*******************/
		
		
		/**
		 * Add keyboard listeners
		 * 
		 * EventPriority.CURSOR_MANAGEMENT; //200
		 * EventPriority.BINDING;//100
		 * EventPriority.EFFECT;//-100
		 * EventPriority.DEFAULT;// 0
		 * EventPriority.DEFAULT_HANDLER;//-50
		 * */
		public function addKeyboardListeners(application:Object = null):void {
			systemManager = getSystemManager();
			
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, true, 0, true);
			FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, true, 0, true);
			systemManager.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, true, 0, true);
			//systemManager.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, true, 0, true);
			//FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, true, 0, true);
		}
		
		/**
		 * Removes keyboard listeners
		 * */
		public function removeKeyboardListeners(application:Object = null):void {
			systemManager = getSystemManager();
			
			//stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, true);
			FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler, true);
			systemManager.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler, true);
			//FlexGlobals.topLevelApplication.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, true);
			//systemManager.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, true);
		}
		
		/**
		 * Handles keyboard position changes. 
		 * Up left right down, etc.
		 * */
		protected function keyUpHandler(event:KeyboardEvent):void {
			if (debug) {
				log("Key: " + event.keyCode);
			}
			
			var constant:int;
			var index:int;
			var applicable:Boolean;
			var systemManager:SystemManager;
			var topApplication:Object;
			var focusedObject:Object;
			var isApplication:Boolean;
			var actionOccured:Boolean;
			var eventTarget:Object;
			var eventCurrentTarget:Object;
			var tabNav:TabNavigator;
			var element:IVisualElement;
			var properties:Array = [];
			var propertiesObject:Object = {};
			
			
			if (radiate==null) {
				return;
			}
			
			systemManager 		= getSystemManager();
			topApplication 		= FlexGlobals.topLevelApplication;
			focusedObject 		= topApplication.focusManager.getFocus();
			eventTarget 		= event.target;
			eventCurrentTarget 	= event.currentTarget;
			tabNav 				= DocumentManager.documentsTabNavigator;
			
			// Z = 90
			// C = 67
			// left = 37
			// right = 39
			// up = 38
			// down = 40 
			// backspace = 8
			// delete = 46
			// enter = 
			//Radiate.info("Key up: " + event.keyCode);
			
			constant = event.shiftKey ? 10 : 1;
			
			// capture key presses when application has focus
			if (eventTarget is SystemManager) {
				if (focusedObject==null) {
					applicable = true;
				}
				else if (targetApplication && targetApplication.contains(focusedObject)) {
					applicable = true;
				}
				else if (canvasBackground && canvasBackground.contains(focusedObject)) {
					applicable = true;
				}
			}
			
			if (focusedObject is Application) {
				isApplication = true;
			}
			
			if (isApplication || 
				(targetApplication && 
					(targetApplication.contains(eventCurrentTarget) || 
						targetApplication.contains(eventTarget)))) {
				applicable = true;
			}
			else if (canvasBackground && 
					(canvasBackground.contains(eventCurrentTarget) || 
						canvasBackground.contains(eventTarget))) {
				applicable = true;
			}
			else if (eventTarget==tabNav) {
				applicable = true;
			}
			else {
				return;
			}
			
			// TODO use new move methods in ComponentManager
			if (event.keyCode==Keyboard.LEFT) {
				if (event.altKey) {
					propertiesObject.width = marqueeGroup.width - constant;
					properties.push(MXMLDocumentConstants.WIDTH);
				}
				else {
					propertiesObject.x = marqueeGroup.x - constant;
					properties.push(MXMLDocumentConstants.X);
				}
				ComponentManager.moveElement2(marqueeGroup, null, properties, propertiesObject);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.RIGHT) {
				if (event.altKey) {
					propertiesObject.width = marqueeGroup.width + constant;
					properties.push(MXMLDocumentConstants.WIDTH);
				}
				else {
					propertiesObject.x = marqueeGroup.x + constant;
					properties.push(MXMLDocumentConstants.X);
				}
				ComponentManager.moveElement2(marqueeGroup, null, properties, propertiesObject);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.UP) {
				if (event.altKey) {
					propertiesObject.height = marqueeGroup.height - constant;
					properties.push(MXMLDocumentConstants.HEIGHT);
				}
				else {
					propertiesObject.y = marqueeGroup.y - constant;
					properties.push(MXMLDocumentConstants.Y);
				}
				ComponentManager.moveElement2(marqueeGroup, null, properties, propertiesObject);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.DOWN) {
				if (event.altKey) {
					propertiesObject.height = marqueeGroup.height + constant;
					properties.push(MXMLDocumentConstants.HEIGHT);
				}
				else {
					propertiesObject.y = marqueeGroup.y + constant;
					properties.push(MXMLDocumentConstants.Y);
				}
				ComponentManager.moveElement2(marqueeGroup, null, properties, propertiesObject);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.Z && event.ctrlKey && !event.shiftKey) {
				HistoryManager.undo(Radiate.selectedDocument, true);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.Z && event.ctrlKey && event.shiftKey) {
				HistoryManager.redo(Radiate.selectedDocument, true);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.Y && event.ctrlKey) {
				HistoryManager.redo(Radiate.selectedDocument, true);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.ENTER) {
				cropSelection();
				actionOccured = true;
			}
			
			if (applicable && actionOccured) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				event.preventDefault();
			}
			
			if (actionOccured) {
				//dispathKeyEvent(event);
			}
		}
		
		/**
		 * Document change
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			clearSelection();
			updateDocument(IDocument(event.selectedItem));
		}
		
		/**
		 * Document close
		 * */
		protected function documentCloseHandler(event:RadiateEvent):void {
			clearSelection();
		}

		public function clearSelection():void {
			
		}
		
		public var drawMarquee:Boolean;
		public var drawImage:Boolean;
		public var drawBitmapData:Boolean;
		public var drawIntersection:Boolean;
		public var clipIntersectionRectangle:Rectangle;
		
		public function getBitmapDataOfSelection(object:Object, container:DisplayObject):BitmapData {
			var bitmapDataIntersection:Rectangle;
			var newBitmapData:BitmapData;
			var marqueeBounds:Rectangle;
			var marqueeSize2:Rectangle;
			var marqueeSpacePoint:Point;
			var marqueeGlobalPoint:Point;
			var marqueeGlobalRectangle:Rectangle;
			var imageSpacePoint:Point;
			var imageGlobalPoint:Point;
			var bitmapDataSpacePoint:Point;
			var bitmapDataGlobalPoint:Point;
			var bitmapDataSpaceRectangle:Rectangle;
			var bitmapDataGlobalRectangle:Rectangle;
			var imageRectangle:Rectangle;
			var workArea:DisplayObject;
			var copyPixels:Boolean = true;
			var offsetX:Number = 0;
			var offsetY:Number = 0;
			var graphics:Graphics;
			var imageBitmapData:BitmapData;
			var imageDisplayMatrix:Matrix;
			var drawAlpha:Number;
			var useExampleData:Boolean;
			var resizedX:Boolean;
			var resizedY:Boolean;
			var image:Image;
			var displayObject:DisplayObject;
			
			workArea = container;
			graphics = Object(workArea).graphics;
			drawAlpha = .5;
			useExampleData = false;
			
			if (object is DisplayObject) {
				displayObject = object as DisplayObject;
			}
			else if (object is GraphicElement) {
				displayObject = (object as GraphicElement).displayObject;
			}
			
			if (object==null) {
				return null;
			}
			
			// get marquee bounds
			// get marquee position relative to work area 
			marqueeBounds = marqueeGroup.getBounds(marqueeGroup);
			marqueeSpacePoint = DisplayObjectUtils.getDisplayObjectPosition(marqueeGroup, workArea);		
			marqueeBounds.x = marqueeSpacePoint.x;// 124
			marqueeBounds.y = marqueeSpacePoint.y;//-18
			
			if (useExampleData) {
				marqueeBounds.width = 300;
				marqueeBounds.height = 300;
				marqueeBounds.x = 125;
				marqueeBounds.y = -61;
			}
			
			if (drawMarquee || drawImage || drawIntersection || drawMarquee) {
				graphics.clear();
			}
			
			// draw marquee in red
			if (drawMarquee) {
				graphics.beginFill(0xFF0000, drawAlpha);
				graphics.drawRect(marqueeBounds.x, marqueeBounds.y, marqueeBounds.width, marqueeBounds.height);
			}
			
			// get image bounds 
			// get image position relative to work area
			imageRectangle = new Rectangle(0, 0, displayObject.width, displayObject.height);
			imageSpacePoint = DisplayObjectUtils.getDisplayObjectPosition(displayObject, workArea);
			imageRectangle.x = imageSpacePoint.x;
			imageRectangle.y = imageSpacePoint.y;
			
			// draw image rectangle
			if (drawImage) {
				graphics.beginFill(0x0000FF, drawAlpha);
				graphics.drawRect(imageRectangle.x, imageRectangle.y, imageRectangle.width, imageRectangle.height);
			}
			
			// get image bitmap data
			if (displayObject is Image) {
				imageBitmapData = (displayObject as Image).bitmapData;
				imageDisplayMatrix = (displayObject as Image).imageDisplay.transform.concatenatedMatrix;
			}
			else if (displayObject is IUIComponent) {
				imageBitmapData = BitmapUtil.getSnapshot(displayObject as IUIComponent);
			}
			else if (object is GraphicElement) {
				imageBitmapData = DisplayObjectUtils.getGraphicElementBitmapData(object as IGraphicElement);
				return null;
			}
			else {
				return null;
			}
			
			bitmapDataSpaceRectangle = imageBitmapData.rect;
			bitmapDataSpaceRectangle.x = imageSpacePoint.x;
			bitmapDataSpaceRectangle.y = imageSpacePoint.y;
			
			// adjust imageRectangle for bitmap data
			if (bitmapDataSpaceRectangle.width!=imageRectangle.width) {
				offsetX = (imageRectangle.width-bitmapDataSpaceRectangle.width)/2;
				resizedX = true;
			}
			
			if (bitmapDataSpaceRectangle.height!=imageRectangle.height) {
				offsetY = (imageRectangle.height-bitmapDataSpaceRectangle.height)/2;
				resizedY = true;
			}
			
			bitmapDataSpaceRectangle.x += offsetX;
			bitmapDataSpaceRectangle.y += offsetY;
			
			// draw bitmap data rectangle
			if (drawBitmapData) {
				graphics.beginFill(0xFF00FF, drawAlpha);
				graphics.drawRect(bitmapDataSpaceRectangle.x, bitmapDataSpaceRectangle.y, bitmapDataSpaceRectangle.width, bitmapDataSpaceRectangle.height);
			}
			
			// remove any part of the selection that is outside the target display object
			bitmapDataIntersection = bitmapDataSpaceRectangle.intersection(marqueeBounds);
			bitmapDataIntersection = marqueeBounds.intersection(bitmapDataSpaceRectangle);
			
			// draw intersection
			if (drawIntersection) {
				graphics.beginFill(0x00FF00, drawAlpha);
				graphics.drawRect(bitmapDataIntersection.x, bitmapDataIntersection.y, bitmapDataIntersection.width, bitmapDataIntersection.height);
			}
			
			// get global difference
			marqueeGlobalPoint = DisplayObjectUtils.getDisplayObjectPosition(marqueeGroup, systemManager);
			imageGlobalPoint = DisplayObjectUtils.getDisplayObjectPosition(displayObject, systemManager);
			bitmapDataGlobalPoint = new Point();
			bitmapDataGlobalPoint.x = imageGlobalPoint.x + offsetX;
			bitmapDataGlobalPoint.y = imageGlobalPoint.y + offsetY;
			
			// bitmapdataintersection must use local space since it's copy pixels expects relative values
			marqueeGlobalRectangle = new Rectangle(marqueeGlobalPoint.x, marqueeGlobalPoint.y, marqueeBounds.width, marqueeBounds.height);
			bitmapDataGlobalRectangle = new Rectangle(bitmapDataGlobalPoint.x, bitmapDataGlobalPoint.y, bitmapDataSpaceRectangle.width, bitmapDataSpaceRectangle.height);
			clipIntersectionRectangle = bitmapDataGlobalRectangle.intersection(marqueeGlobalRectangle);
			clipIntersectionRectangle.x = clipIntersectionRectangle.x - bitmapDataGlobalPoint.x;
			clipIntersectionRectangle.y = clipIntersectionRectangle.y - bitmapDataGlobalPoint.y;
			
			//bitmapPositionLabel.text = clipIntersectionRectangle.x + "x" + clipIntersectionRectangle.y;
			//bitmapPositionLabel.text += "\n" + clipIntersectionRectangle.width + "x" + clipIntersectionRectangle.height;
			
			if (clipIntersectionRectangle.width>0 && clipIntersectionRectangle.height>0) {
				//newBitmapData = new BitmapData(imageBitmapData.width, imageBitmapData.height, true, 0x00000000);
				if (copyPixels) {
					newBitmapData = new BitmapData(clipIntersectionRectangle.width, clipIntersectionRectangle.height, true, 0x00000000);
					newBitmapData.copyPixels(imageBitmapData, clipIntersectionRectangle, new Point());
					//newBitmapData.scroll(rectangle.x, rectangle.y);
				}
				else {
					newBitmapData = new BitmapData(clipIntersectionRectangle.width, clipIntersectionRectangle.height, true, 0x00000000);
					newBitmapData.drawWithQuality(imageBitmapData, imageDisplayMatrix, null, null, clipIntersectionRectangle, false, StageQuality.HIGH_16X16_LINEAR);
				}
				
				//thumbnailBackground.visible = true;
			}
			else {
				//thumbnailBackground.visible = false;
			}
			
			return newBitmapData;
		}
		
		public function cropSelection():void {
			var container:DisplayObject;
			var croppedBitmapData:BitmapData;
			var image:Image;
			var imageLocalPoint:Point;
			
			container = getSystemManager();
			croppedBitmapData = getBitmapDataOfSelection(radiate.target, container);
			image = radiate.target as Image;
			
			if (croppedBitmapData && image) {
				//imageLocalPoint = new Point();
				imageLocalPoint = DisplayObjectUtils.getDisplayObjectPosition(image, image.parent);
				var propertiesObject:Object = {};
				var properties:Array = ["x", "y", "source"];
				var imageData:ImageData;
				var imageName:String = "Cropped"; // should get name from component description
				
				if (image.source is BitmapData) {
					imageData = LibraryManager.getImageDataFromBitmapData(image.source as BitmapData);
				}
				
				propertiesObject.x = imageLocalPoint.x + clipIntersectionRectangle.x;
				propertiesObject.y = imageLocalPoint.y + clipIntersectionRectangle.y;
				propertiesObject.source = croppedBitmapData;
				
				ComponentManager.setProperties(image, properties, propertiesObject, "Crop", true);
				
				// force redraw
				updateScreenEvent = new MouseEvent(MouseEvent.MOUSE_UP);
				updateScreenEvent.updateAfterEvent();
				
				if (imageData) {
					imageName = imageData.name;
				}
				
				LibraryManager.addBitmapDataToDocument(Radiate.selectedDocument, croppedBitmapData, null, imageName, false);
			}
			else {
				Radiate.warn("The selection does not intersect any images. Make sure to select an unscaled image."); 
			}
		}
		
		public var updateScreenEvent:MouseEvent;
	}
}