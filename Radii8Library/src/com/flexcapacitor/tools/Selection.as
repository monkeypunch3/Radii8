
package com.flexcapacitor.tools {
	import com.flexcapacitor.components.DocumentContainer;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.DragDropEvent;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.ClipboardManager;
	import com.flexcapacitor.managers.ComponentManager;
	import com.flexcapacitor.managers.DeferManager;
	import com.flexcapacitor.managers.DocumentManager;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.tools.supportClasses.VisualElementHandle;
	import com.flexcapacitor.tools.supportClasses.VisualElementRotationHandle;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.DragManagerUtil;
	import com.flexcapacitor.utils.LayoutDebugHelper;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.NumberUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.ISelectionGroup;
	import com.flexcapacitor.utils.supportClasses.TargetSelectionGroup;
	import com.flexcapacitor.utils.supportClasses.log;
	import com.flexcapacitor.views.SelectionInspector;
	import com.roguedevelopment.DisplayModel;
	import com.roguedevelopment.DragGeometry;
	import com.roguedevelopment.Flex4ChildManager;
	import com.roguedevelopment.Flex4HandleFactory;
	import com.roguedevelopment.IHandle;
	import com.roguedevelopment.ObjectChangedEvent;
	import com.roguedevelopment.ObjectHandles;
	import com.roguedevelopment.ObjectHandlesSelectionManager;
	import com.roguedevelopment.constraints.MaintainProportionConstraint;
	import com.roguedevelopment.constraints.SizeConstraint;
	import com.roguedevelopment.constraints.SnapToGridConstraint;
	import com.roguedevelopment.decorators.AlignmentDecorator;
	import com.roguedevelopment.decorators.DecoratorManager;
	import com.roguedevelopment.decorators.ObjectLinesDecorator;
	import com.roguedevelopment.decorators.OutlineDecorator;
	import com.roguedevelopment.decorators.WebDecorator;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	
	import mx.containers.TabNavigator;
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.FlexSprite;
	import mx.core.IFlexDisplayObject;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerGlobals;
	
	import spark.components.Application;
	import spark.components.DataGrid;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.Scroller;
	import spark.components.TextArea;
	import spark.components.VideoPlayer;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.InvalidatingSprite;
	import spark.components.supportClasses.ItemRenderer;
	import spark.components.supportClasses.ListBase;
	import spark.core.IDisplayText;
	import spark.core.IGraphicElement;
	import spark.primitives.Line;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.skins.spark.ListDropIndicator;
		
	/**
		 Alex Harui Tue, 04 Mar 2008 21:03:35 -0800
	
	For the record, so there is no more guessing:
	
	 
	1)       The Application or WindowedApplication is not the top-level
	window and does not parent popup and thus events from popups do not
	bubble through the application
	
	2)       SystemManager is the top-level window, and all events from all
	display objects bubble through the SM unless their propagation has been
	stopped
	
	3)       Capture phase listeners on the SystemManager should get all
	events for all child display objects
	
	4)       If no display object has focus, but the player does have focus,
	then the Stage dispatches keyboard events which will not be caught by a
	listener on SystemManager
	
	5)       Capture phase listeners on the Stage will not catch events
	dispatched from the Stage, only events dispatched by children of the
	Stage and thus if no display object has focus, there is no place to hook
	a capture-phase listener that will catch the keyboard events dispatched
	from the stage.
	
	 
	
	This is why Rick's suggestion of both a capture and non-capture phase
	listener on stage is correct.
	
	Stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyDn, true );

	Stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyDn, false );
	* */
	
	/**
	 * Dispatched when the selection class handles a key event. 
	 * For example, moving the selected object. 
	 * */
	[Event(name="keyEvent", type="flash.events.Event")]
	
	/**
	 * Finds and selects the item or items under the pointer. 
	 * 
	 * Adds mouse down listener to the system manager. We check
	 * the target and the display objects under the mouse point to find
	 * the item that was clicked on. This happens in mouseDownHandler.  
	 * 
	 * 
	 * To do:
	 * - select item (done)
	 * - select group (done)
	 * - draw selection area (done)
	 * - show resize handles 
	 * - show property inspector (done)
	 * - show selection option 
	 * 
	 * THERE ARE SECTIONS IN THIS CLASS THAT NEED TO BE REFACTORED
	 * 
	 * Getting the correct size: 
	 * http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf633a0-7fff.html
	 * */
	public class Selection extends FlexSprite implements ITool {
		
		
		public function Selection(s:SINGLEDOUBLE) {
			
		}
		
		public static var KEY_EVENT:String = "keyEvent";
		public static var EDIT_EVENT:String = "editEvent";
		
		public static var UNDO:String = "undo";
		public static var REDO:String = "redo";
		
		public static var COPY:String = "copy";
		public static var PASTE:String = "paste";
		
		private var _icon:Class = Radii8LibraryToolAssets.Selection;
		
		public function get icon():Class {
			return _icon;
		}
		
		/**
		 * The radiate instance.
		 * */
		public var radiate:Radiate;
		
		/**
		 * The clipboard manager instance.
		 * */
		public var clipboardManager:ClipboardManager;
		
		public static var debug:Boolean = false;
		
		/**
		 * Drag helper utility.
		 * */
		private var dragManagerInstance:DragManagerUtil;
		
		/**
		 * The document
		 * */
		public var document:IDocument;
		
		/**
		 * The application
		 * */
		public var targetApplication:Object;
		
		/**
		 * The background
		 * */
		public var canvasBackground:Object;
		
		/**
		 * The background parent
		 * */
		public var canvasBackgroundParent:Object;
		
		/**
		 * The background parent scroller
		 * */
		public var canvasScroller:Scroller;
		
		/**
		 * Indicates if the mouse is down
		 * */
		public var isMouseDown:Boolean;
		
		/**
		 * Indicates if target was being dragged
		 * */
		public var isDragging:Boolean;
		
		/**
		 * If true than items can be dragged out of and into other containers 
		 * */
		public var dragAllowedOutside:Boolean = true;
		
		/**
		 * Highlights items that are locked
		 * */
		public var highlightLockedItems:Boolean = true;
		
		/**
		 * Highlights items that are not a group when select groups option is true
		 * */
		public var highlightWhenSelectingOnlyGroups:Boolean = true;
		
		/**
		 * Highlights color
		 * */
		public var highlightColor:Number = 0xAA0000;
		
		/**
		 * Highlights delay
		 * */
		public var highlightDelay:int = 250;
		
		/**
		 * Move increment value when using arrow keys
		 * @see alternateMoveIncrement
		 * */
		public var moveIncrement:int = 1;
		
		/**
		 * Move increment value when using arrow keys and holding shift
		 * @see moveIncrement
		 * */
		public var alternateMoveIncrement:int = 10;
		
		/**
		 * Some graphics like lines are difficult to select. 
		 * Changes the cursor when over a graphic
		 **/
		public var showHandCursorOverGraphics:Boolean = true;
		
		/**
		 * Helps highlights items that are locked
		 * */
		public var layoutDebugHelper:LayoutDebugHelper;
		
		/**
		 * Reference to the current or last target.
		 * */
		public var lastTarget:Object;
		
		/**
		 * Sets to focus for keyboard events. 
		 * */
		public var setFocusOnSelect:Boolean = true;
		
		/**
		 * When an item is deleted or removed the selection is drawn just off stage
		 * Set to true to clear the selection in this case
		 * */
		public var hideSelectionWhenOffStage:Boolean = true;
		public var hideSelectionOnDrag:Boolean = true;
		private var _selectionWasShownBeforeDrag:Boolean;
		
		private var _showSelection:Boolean = true;

		/**
		 * Show selection around target.
		 * */
		public function get showSelection():Boolean {
			return _showSelection;
		}

		/**
		 * @private
		 */
		public function set showSelection(value:Boolean):void {
			_showSelection = value;
			
			if (value) {
				if (lastTarget) {
					drawSelection(lastTarget, toolLayer);
					//updateTransformRectangle(lastTarget);
				}
			}
			else {
				clearSelection();
			}
		}

		
		public var targetSelectionGroup:ItemRenderer;
		public var mouseLocationLines:IFlexDisplayObject = new ListDropIndicator();
		private var _showSelectionLabel:Boolean = true;

		public function get showSelectionLabel():Boolean {
			return _showSelectionLabel;
		}

		/**
		 * Displays a label above the selection rectangle 
		 * with the unqualified class name of the object selected
		 * */
		public function set showSelectionLabel(value:Boolean):void {
			if (_showSelectionLabel==value) return;
			
			_showSelectionLabel = value;
			
			if (lastTarget) {
				updateSelectionAroundTarget(lastTarget);
			}
		}
		
		private var _selectionBorderColor:uint = 0x2da6e9;

		public function get selectionBorderColor():uint {
			return _selectionBorderColor;
		}

		/**
		 * Sets the color used on the selection rectangle
		 * */
		public function set selectionBorderColor(value:uint):void {
			if (_selectionBorderColor==value) return;
			
			_selectionBorderColor = value;
			
			updateSelectionAroundTarget(lastTarget);
		}
		
		private var _showTransformControls:Boolean;

		public function get showTransformControls():Boolean
		{
			return _showTransformControls;
		}

		/**
		 * Shows resize icons on the selection rectangle that you can use to resize the selected object
		 * */
		public function set showTransformControls(value:Boolean):void
		{
			_showTransformControls = value;
			
			updateSelectionAroundTarget(lastTarget);
			updateTransformRectangle(lastTarget);
		}


		public var snapToNearbyElements:Boolean = false;
		public var showSelectionLabelOnDocument:Boolean = false;
		public var showSelectionFill:Boolean = false;
		public var showSelectionFillOnDocument:Boolean = false;
		public var lastTargetCandidate:Object;
		public var enableDrag:Boolean = true;
		public var toolLayer:IVisualElementContainer;
		public var updateOnUpdateComplete:Boolean = false;
		
		public var selectionInspector:SelectionInspector;
		
		public var objectHandles:ObjectHandles;
		
		// add resize handles
		public var manager:Flex4ChildManager;
		public var selectionManager:ObjectHandlesSelectionManager;
		public var decoratorManager:DecoratorManager;
		public var alignmentDecorator:AlignmentDecorator;
		public var webDecorator:WebDecorator;
		public var outlineDecorator:OutlineDecorator;
		public var objectLinesDecorator:ObjectLinesDecorator;
		public var sizeConstraint:SizeConstraint;
		public var snapToGridConstraint:SnapToGridConstraint;
		public var handleFactory:Flex4HandleFactory;
		public var aspectRatioConstraint:MaintainProportionConstraint;
		
		/**
		 * X and Y coordinates of dragged object relative to the target application
		 * */
		[Bindable]
		public var dragLocation:String;
		
		/**
		 * Enable this tool. 
		 * */
		public function enable():void {
			radiate = Radiate.instance;
			clipboardManager = ClipboardManager.getInstance();
			
			removeAllListeners();
			
			if (Radiate.selectedDocument) {
				updateDocument(Radiate.selectedDocument);
			}
			
			addRadiateListeners();
			
			setupObjectHandles();
			
			showCursorForGraphics();
			
			Mouse.cursor = MouseCursor.AUTO;
			
			updateSelectionLater();
		}
		
		/**
		 * Disable this tool.
		 * */
		public function disable():void {
			
			removeAllListeners();
			removeRadiateListeners();
			clearSelection();
			
			hideCursorForGraphics();
		}
		
		/**
		 * Shows cursor over graphics
		 **/
		private function showCursorForGraphics():void {
			var iDocument:IDocument = Radiate.selectedDocument;
			
			if (iDocument && showHandCursorOverGraphics) {
				DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, showCursorHandler);
			}
		}
		
		/**
		 * Hides cursor over graphics
		 **/
		private function hideCursorForGraphics():void {
			var iDocument:IDocument = Radiate.selectedDocument;
			
			if (iDocument && showHandCursorOverGraphics) {
				DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, hideCursorHandler);
			}
		}
		
		/**
		 * Enables a cursor over graphics like Lines and Paths
		 * */
		public function showCursorHandler(component:ComponentDescription):void {
			var instance:Object;
			
			if (component && component.instance && component.isGraphicElement) {
				instance = component.instance;
				
				ComponentManager.makeRuntimeInteractive(instance, !showHandCursorOverGraphics, false);
			}
		}
		
		/**
		 * Enables a cursor over graphics like Lines and Paths
		 * */
		public function hideCursorHandler(component:ComponentDescription):void {
			var instance:Object;
			
			if (component && component.instance && component.isGraphicElement) {
				instance = component.instance;
				
				ComponentManager.makeRuntimeInteractive(instance, true, false);
			}
		}
		
		/**
		 * Remove references to document instance
		 * */
		public function removeObjectHandles():void {
			if (objectHandles) {
				objectHandles.container = null;
			}
		}
		
		/**
		 * Setup object handles for resizing and rotation
		 * */
		public function setupObjectHandles():void {
			var container:Sprite;
			var useToolLayer:Boolean = true;
			var enableRotation:Boolean = false;
			
			if (useToolLayer) {
				container = toolLayer as Sprite;
			}
			else if (document) {
				container = document.instance as Sprite;
			}
			
			
			if (objectHandles==null && DocumentManager.canvasBorder) {
				manager = new Flex4ChildManager();
				handleFactory = new Flex4HandleFactory();
				selectionManager = new ObjectHandlesSelectionManager();
				
				VisualElementHandle.handleLineColor = selectionBorderColor;
				VisualElementHandle.handleFillColor = selectionBorderColor;
				VisualElementRotationHandle.handleFillColor = selectionBorderColor;
				//selectionManager.unselectedModelState();
				
				// CREATE OBJECT HANDLES
				//objectHandles = new ObjectHandles(DocumentManager.canvasBorder as Sprite, null, handleFactory, manager);
				
				
				ObjectHandles.defaultHandleClass = VisualElementHandle;
				
				// ROTATION - to enable rotation uncomment the next line
				if (enableRotation) {
					ObjectHandles.defaultRotationHandleClass = VisualElementRotationHandle;
				}
				
				objectHandles = new ObjectHandles(container, selectionManager, null, manager);
				objectHandles.enableMultiSelect = false;
				objectHandles.snapGrid = true;
				objectHandles.snapNumber = 8;
				objectHandles.snapAngle = false;
				objectHandles.moveEnabled = false;
				
				//selectionManager = objectHandles.selectionManager;
				
				objectHandles.addEventListener(ObjectChangedEvent.OBJECT_MOVED, movedHandler);
				objectHandles.addEventListener(ObjectChangedEvent.OBJECT_MOVING, movingHandler);
				objectHandles.addEventListener(ObjectChangedEvent.OBJECT_RESIZING, resizingHandler);
				objectHandles.addEventListener(ObjectChangedEvent.OBJECT_RESIZED, resizedHandler);
				objectHandles.addEventListener(ObjectChangedEvent.OBJECT_ROTATING, rotatingHandler);
				objectHandles.addEventListener(ObjectChangedEvent.OBJECT_ROTATED, rotatedHandler);
				
				
				//decoratorManager = new DecoratorManager(objectHandles, DocumentManager.toolLayer as Sprite);
				aspectRatioConstraint = new MaintainProportionConstraint();
				aspectRatioConstraint.shiftKeyRequired = true;
				objectHandles.addDefaultConstraint(aspectRatioConstraint);
				
				sizeConstraint = new SizeConstraint();
				sizeConstraint.minHeight = 1;
				sizeConstraint.minWidth = 1;
				objectHandles.addDefaultConstraint(sizeConstraint);
			}
			
			if (objectHandles) {
				objectHandles.container = container;
			}
		}
		
		/**
		 * Add all listeners
		 * */
		public function addAllListeners():void {
			addApplicationListeners();
			addCanvasListeners();
			addKeyboardListeners();
			// add so transparent groups work (they need a listener to be detected)
			addTransparentGroupListeners();
			addTargetListeners(lastTarget); // also added on drag
		}
		
		/**
		 * Remove all listeners
		 * */
		public function removeAllListeners():void {
			removeApplicationListeners();
			removeCanvasListeners();
			removeKeyboardListeners();
			removeTargetListeners();
			removeTransparentGroupListeners();
			removeDragManagerListeners(); // Nov 6
		}
		
		/**
		 * Adds listeners to radiate instance
		 * */
		public function addRadiateListeners():void {
			radiate = Radiate.instance;
			
			// handle events last so that we get correct size
			radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, 		documentChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_CLOSE, 		documentCloseHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.TARGET_CHANGE, 		targetChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.SCALE_CHANGE, 		scaleChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE, scaleChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			
			// with the history change event we can probably get rid of document size change and property
			//radiate.addEventListener(RadiateEvent.PROPERTY_CHANGED, 	propertyChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.HISTORY_CHANGE, 		historyEventHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			// this should be history manager not radiate
			radiate.addEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY, beginningOfUndoHistoryHandler, false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.END_OF_UNDO_HISTORY, 	endOfUndoHistoryHandler, false, EventPriority.DEFAULT_HANDLER, true);
		}
		
		protected function beginningOfUndoHistoryHandler(event:Event):void
		{
			updateSelectionLater(Radiate.selectedDocument);
		}
		
		protected function endOfUndoHistoryHandler(event:Event):void
		{
			
		}
		
		/**
		 * Removes listeners from radiate instance
		 * */
		public function removeRadiateListeners():void {
			radiate = Radiate.instance;
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, 		documentChangeHandler);
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CLOSE, 		documentCloseHandler);
			radiate.removeEventListener(RadiateEvent.TARGET_CHANGE, 		targetChangeHandler);
			radiate.removeEventListener(RadiateEvent.SCALE_CHANGE, 			scaleChangeHandler);
			radiate.removeEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE, 	scaleChangeHandler);
			
			//radiate.removeEventListener(RadiateEvent.PROPERTY_CHANGED, 		propertyChangeHandler);
			radiate.removeEventListener(RadiateEvent.HISTORY_CHANGE, 		historyEventHandler);
			radiate.removeEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY, 	beginningOfUndoHistoryHandler);
			radiate.removeEventListener(RadiateEvent.END_OF_UNDO_HISTORY, 	endOfUndoHistoryHandler);
		}
		
		/**
		 * Add listeners to the application
		 * */
		public function addApplicationListeners():void {
			if (targetApplication) {
				Object(targetApplication).addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler, false, 0, true);
			}
		}
		
		/**
		 * Remove listeners from the application
		 * */
		public function removeApplicationListeners():void {
			if (targetApplication) {
				Object(targetApplication).removeEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
			}
		}
		
		/**
		 * Get stage for keyboard events
		 * */
		public function getCurrentStage(application:Object = null):Stage {
			var systemManager:SystemManager = getCurrentSystemManager(application);
			
			return systemManager.stage;
		}
		
		/**
		 * Get top most system manager or system manager from passed in application
		 * */
		public function getCurrentSystemManager(application:Object = null):SystemManager {
			
			// get system manager from application
			if (application && "systemManager" in application) {
				return application.systemManager;
			}
			
			// get system manager from top level system managers
			return SystemManagerGlobals.topLevelSystemManagers[0];
		}
		
		/**
		 * Add keyboard listeners
		 * 
		 * EventPriority.CURSOR_MANAGEMENT; //200
		 * EventPriority.BINDING;//100
		 * EventPriority.EFFECT;//-100
		 * EventPriority.DEFAULT;// 0
		 * EventPriority.DEFAULT_HANDLER;//-50
		 * 
		 * https://stackoverflow.com/questions/31849/capturing-cmd-c-or-ctrl-c-keyboard-event-from-modular-flex-application-in-brow#32086
		 * */
		public function addKeyboardListeners(application:Object = null):void {
			application = application ? application : targetApplication;
			var systemManager:SystemManager = getCurrentSystemManager(application);
			var stage:Stage = getCurrentStage(application);
			var useCapture:Boolean;
			
			useCapture = true;
			
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerStage, useCapture, 0, true);
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, useCapture, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, useCapture, 0, true);
			
			//stage.addEventListener(Event.COPY, copyHandler, useCapture, 0, true);
			//stage.addEventListener(Event.PASTE, pasteHandler, useCapture, 0, true);
			//Radiate.info("Adding keyboard listeners");
		}
		
		/**
		 * Removes keyboard listeners
		 * */
		public function removeKeyboardListeners(application:Object = null):void {
			application = application ? application : targetApplication;
			var systemManager:SystemManager = getCurrentSystemManager(application);
			var stage:Stage = getCurrentStage(application);
			var useCapture:Boolean;
			
			useCapture = true;
			
			systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerStage, useCapture);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, useCapture);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler, useCapture);
			//stage.removeEventListener(Event.COPY, copyHandler, useCapture);
			//stage.removeEventListener(Event.PASTE, pasteHandler, useCapture);
			//Radiate.info("Removing keyboard listeners");
			
			/*
			if (targetApplication && "systemManager" in targetApplication) {
				Object(targetApplication).systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				Object(targetApplication).systemManager.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				Object(targetApplication).systemManager.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false);
				Object(targetApplication).systemManager.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
			}*/
			/*
				var toppestSystemManager:ISystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				
				var topLevelApplication:Object = FlexGlobals.topLevelApplication;
				var topSystemManager:ISystemManager = ISystemManager(topLevelApplication.systemManager);
				var marshallPlanSystemManager:Object = topSystemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
				
				if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
					var sandBoxRoot:Object = Sprite(topSystemManager.getSandboxRoot());
				}
			*/
		}
		
		/**
		 * Add drag manager listeners
		 * */
		public function addDragManagerListeners():void {
			
			if (dragManagerInstance) {
				dragManagerInstance.addEventListener(DragDropEvent.DRAG_START, handleDragStart, false, 0, true);
				dragManagerInstance.addEventListener(DragDropEvent.DRAG_END, handleDragEnd, false, 0, true);
				dragManagerInstance.addEventListener(DragDropEvent.DRAG_OVER, handleDragOver, false, 0, true);
				dragManagerInstance.addEventListener(DragDropEvent.DRAG_DROP, handleDragDrop, false, 0, true);
				dragManagerInstance.addEventListener(DragDropEvent.DRAG_DROP_COMPLETE, handleDragDropComplete, false, 0, true);
				dragManagerInstance.addEventListener(DragDropEvent.DRAG_DROP_INCOMPLETE, handleDragDropIncomplete, false, 0, true);
			}
			
		}
		
		protected function handleDragDropIncomplete(event:DragDropEvent):void
		{
			
		}
		
		/**
		 * Remove drag manager listeners
		 * */
		public function removeDragManagerListeners():void {
			
			if (dragManagerInstance) {
				dragManagerInstance.removeEventListener(DragDropEvent.DRAG_START, handleDragStart);
				dragManagerInstance.removeEventListener(DragDropEvent.DRAG_END, handleDragEnd);
				dragManagerInstance.removeEventListener(DragDropEvent.DRAG_OVER, handleDragOver);
				dragManagerInstance.removeEventListener(DragDropEvent.DRAG_DROP, handleDragDrop);
				dragManagerInstance.removeEventListener(DragDropEvent.DRAG_DROP_COMPLETE, handleDragDropComplete);
				dragManagerInstance.removeEventListener(DragDropEvent.DRAG_DROP_INCOMPLETE, handleDragDropIncomplete);
			}
		}
		
		/**
		 * Add event listeners to new document and remove listeners from previous
		 * */
		public function updateDocument(iDocument:IDocument):void {
			
			// remove listeners
			if (iDocument==null || 
				(targetApplication && iDocument && targetApplication!=iDocument.instance)) {
				removeAllListeners();
			}
			
			document = iDocument;
			targetApplication = iDocument ? iDocument.instance : null;
			
			// add listeners
			if (targetApplication) {
				addAllListeners();
			}
			
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
			
			if (radiate && DocumentManager.canvasBackground && DocumentManager.canvasBackground.parent) {
				canvasBackgroundParent = DocumentManager.canvasBackground.parent;
				canvasBackgroundParent.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges, false, 1000, true);
			}
			
			if (radiate && DocumentManager.canvasScroller) {
				canvasScroller = DocumentManager.canvasScroller;
				canvasScroller.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges, false, 1000, true);
			}
		}
		
		/**
		 * Removes canvas listeners
		 * */
		public function removeCanvasListeners():void {
			
			if (canvasBackgroundParent) {
				canvasBackgroundParent.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges);
			}
			
			if (canvasScroller) {
				canvasScroller.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges);
			}
		}
		
		/**
		 * Add target drag listeners
		 * */
		public function addTargetListeners(target:Object):void {
			
			// not sure why we are adding to the target
			// should only need to add listeners to the stage
			// reevaluate what we are doing here
			
			if (target) {
				if (target is GraphicElement && target.displayObject) {
					GraphicElement(target).displayObject.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
				}
				else {
					target.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
				}
			}
		}
		
		/**
		 * Remove target event listeners. 
		 * */
		public function removeTargetListeners(target:Object = null):void {
			target = target ? target : lastTarget;
			
			if (target) {
				target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				
				if (target is GraphicElement && target.displayObject) {
					GraphicElement(target).displayObject.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				}
				
				if (target is Image) {
					target.removeEventListener(FlexEvent.READY, setSelectionLaterHandler);
					target.removeEventListener(Event.COMPLETE, setSelectionLaterHandler);
					target.removeEventListener(IOErrorEvent.IO_ERROR, setSelectionLaterHandler);
					target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, setSelectionLaterHandler);
				}
			}
			
		}
		
		/**
		 * Add listeners to enable transparent groups to detect mouse events
		 * */
		public function addTransparentGroupListeners():void {
			
			if (targetApplication) {
				DisplayObjectUtils.enableDragBehaviorOnDisplayList(targetApplication as IVisualElement, true);
			}
		}
		
		/**
		 * Remove listeners to disable transparent groups from detecting mouse events
		 * */
		public function removeTransparentGroupListeners():void {
			
			if (targetApplication) {
				DisplayObjectUtils.enableDragBehaviorOnDisplayList(targetApplication as IVisualElement, false);
			}
		}
		
		/**
		 * Property change
		 * */
		protected function propertyChangeHandler(event:RadiateEvent):void {
			updateSelectionAroundTarget(event.selectedItem);
			updateTransformRectangle(event.selectedItem);
		}
		
		/**
		 * History event 
		 * */
		protected function historyEventHandler(event:RadiateEvent):void {
			if (event.targets && event.targets.length) {
				//updateSelectionAroundTarget(event.targets[0]);
				//updateTransformRectangle(event.targets[0]);
				
				DeferManager.callLater(updateSelectionAroundTarget, null);
				DeferManager.callLater(updateTransformRectangle, null);
			}
			
			if (event.newIndex<0) {
				updateSelectionLater(Radiate.selectedDocument);
			}
		}
		
		public var lastTransformState:String;
		
		/**
		 * Scale change
		 * */
		protected function scaleChangeHandler(event:RadiateEvent):void {
			updateSelectionAroundTarget(event.selectedItem);
			var scaled:Boolean;
			
			if (event.selectedItem==document.instance) {
				scaled = event.scaleX!=1 || event.scaleY!=1;
				
				// if scaled we need to disable transform controls 
				// bc it's not working when scaled right now
				if (scaled && showTransformControls) {
					lastTransformState = "true";
					showTransformControls = false;
					unregisterComponents();
				}
				else if (!scaled) {
					if (lastTransformState =="true") {
						showTransformControls = true;
					}
					updateTransformRectangle(event.selectedItem);
					lastTransformState = null;
				}
			}
			
		}
		
		/**
		 * Target change
		 * */
		protected function targetChangeHandler(event:RadiateEvent):void {
			updateSelectionLater(event.selectedItem);
			//updateSelectionAroundTarget(event.selectedItem);
			//updateTransformRectangle(event.selectedItem);
		}
		
		/**
		 * Document change
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			clearSelection();
			updateDocument(IDocument(event.selectedItem));
			setupObjectHandles();
		}
		
		/**
		 * Document close
		 * */
		protected function documentCloseHandler(event:RadiateEvent):void {
			clearSelection();
			setupObjectHandles();
		}
		
		/**
		 * Handle scroll position changes
		 */
		private function handleScrollChanges(event:PropertyChangeEvent):void {
			 if (event.source == event.target && event.property == "verticalScrollPosition") {
				//trace(e.property, "changed to", e.newValue);
				//drawSelection(radiate.target);
				//Radiate.info("Selection scroll change");
			}
			if (event.source == event.target && event.property == "horizontalScrollPosition") {
				//trace(e.property, "changed to", e.newValue);
				//drawSelection(radiate.target);
				//Radiate.info("Selection scroll change");
			}
		}
		
		/**
		 * Update complete event for target
		 * */
		public function updateCompleteHandler(event:FlexEvent):void {
			
			// this can go into an infinite loop if tool layer is causing update events
			if (updateOnUpdateComplete) {
				updateSelectionAroundTarget(event.currentTarget);
			}
		}
	
		/**
		 * Updates selection around the target
		 * */
		public function updateSelectionAroundTarget(target:Object = null):void {
			if (target==null) {
				target = radiate.targets;
			}
			
			// force single selection for now
			if (target is Array) {
				if (target.length) {
					target = target[0];
				}
				else {
					target = null;
				}
			}
			
			removeTargetListeners();
			
			lastTarget = target;
			
			addTargetListeners(target);
			
			
			if (showSelection && 
				(target is IVisualElement || target is IGraphicElement)) {
				
				if (hideSelectionWhenOffStage && "stage" in target && target.stage==null) {
					clearSelection()
				}
				else {
					drawSelection(target, toolLayer);
				}
				
			}
			else {
				clearSelection();
			}
			
		}
		
		public var currentComponentDescription:ComponentDescription;
		
		/**
		 * Handle mouse down on application
		 * */
		public function mouseDownHandler(event:MouseEvent):void {
			var point:Point = new Point(event.stageX, event.stageY);
			var targetsUnderPoint:Array = FlexGlobals.topLevelApplication.getObjectsUnderPoint(point);
			var componentTree:ComponentDescription;
			var componentDescription:ComponentDescription;
			var firstUnlockedComponentDescription:ComponentDescription;
			var target:Object = event.target;
			var originalTarget:Object = event.target;
			var items:Array = [];
			var targetsLength:int;
			var targetOrAncestorLocked:Boolean;
			var dispatchTargetChange:Boolean;
			
			dispatchTargetChange = true;
			isMouseDown = true;
			isDragging = false;
			
			
			/*radiate = Radiate.instance;
			targetApplication = radiate.document;*/
			
			// test url for remote image: 
			// http://www.google.com/intl/en_com/images/srpr/logo3w.png
			// file:///Users/monkeypunch/Documents/Adobe%20Flash%20Builder%2045/Radii8/src/assets/images/eye.png
			
			// clicked outside of this container. is there a way to prevent hearing
			// events from everywhere? stage sandboxroot?
			if (!targetApplication || !Object(targetApplication).contains(target)) {
				//trace("does not contain");
				return;
			}
			
			if (target is IHandle) {
				return;
			}
			
			// clicked on background area
			if (target==canvasBackground || target==canvasBackgroundParent) {
				radiate.setTarget(targetApplication, true);
				return;
			}
			
			
			// check if target is loader
			if (target is Loader) {
				//Error: Request for resource at http://www.google.com/intl/en_com/images/srpr/logo3w.png by requestor from http://www.radii8.com/debug-build/RadiateExample.swf is denied due to lack of policy file permissions.
				
				//*** Security Sandbox Violation ***
				//	Connection to http://www.google.com/intl/en_com/images/srpr/logo3w.png halted - not permitted from http://www.radii8.com/debug-build/RadiateExample.swf
				targetsUnderPoint.push(target);
			}
			
			if (highlightLockedItems || highlightWhenSelectingOnlyGroups) {
				if (layoutDebugHelper==null) {
					layoutDebugHelper = LayoutDebugHelper.getInstance();
				}
				LayoutDebugHelper.highlightColor = highlightColor;
				LayoutDebugHelper.highlightDuration = highlightDelay;
			}
			
			targetsLength = targetsUnderPoint.length;
			targetsUnderPoint = targetsUnderPoint.reverse();
			
			// loop through items under point until we find one on the *component* tree
			componentTree = Radiate.selectedDocument.componentDescription;
			
			
			componentTreeLoop:
			for (var i:int;i<targetsLength;i++) {
				target = targetsUnderPoint[i];
				
				// check for window application
				if (!targetApplication.contains(DisplayObject(target))) {
					continue;
				}
				
				// if somehow we get here return null so we don't select anything
				if (target is DocumentContainer) {
					return;
				}
				
				//spark.components.supportClasses.InvalidatingSprite - clicked on graphic element
				componentDescription = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(target), componentTree);
				if (componentDescription && componentDescription.isGraphicElement) {
					
				}
				
				if (componentDescription) {
					firstUnlockedComponentDescription = componentDescription.getFirstUnlockedTarget();
					
					if (firstUnlockedComponentDescription!=null && firstUnlockedComponentDescription == componentDescription) {
						target = componentDescription.instance;
						break;
					}
					else if (firstUnlockedComponentDescription!=null && firstUnlockedComponentDescription != componentDescription) {
						
						if (componentDescription.instance is ILayoutElement) {
							
							if (highlightLockedItems) {
								//layoutDebugHelper.enable();
								//DeferManager.callLater(layoutDebugHelper.addElement, componentDescription.instance);
								var rectangle:Rectangle = DisplayObjectUtils.getBounds(componentDescription.instance, toolLayer);
								layoutDebugHelper.addElement(componentDescription.instance as ILayoutElement, rectangle);
								//layoutDebugHelper.addElement(ILayoutElement(target));
								//layoutDebugHelper.render();
							}
							//layoutDebugHelper.enable();
						}
						
						if (firstUnlockedComponentDescription!=null) {
							componentDescription = firstUnlockedComponentDescription;
							target = firstUnlockedComponentDescription.instance;
							break;
						}
						
						if (target==targetApplication) {
							return;
						}
					}
				}
			}
			
			// select only groups or items on the application
			if (selectGroup) {
				
				// if parent is application let user select it
				if (componentDescription.parent==componentTree) {
					// it's on the root so we're good
				}
				else if (componentDescription.instance is IVisualElementContainer) {
					// it's a group so we're good
				}
				else {
					
					if (highlightWhenSelectingOnlyGroups) {
						//layoutDebugHelper.enable();
						DeferManager.callLater(layoutDebugHelper.addElement, componentDescription.instance);
						//layoutDebugHelper.addElement(ILayoutElement(target));
						//layoutDebugHelper.render();
					}
					
					// select group container
					componentDescription = componentDescription.parent;
					target = componentDescription.instance;
				}
			}
			
			if (componentDescription) {
				currentComponentDescription = componentDescription;
			}
			else {
				currentComponentDescription = null;
			}
			
			if (target && enableDrag) {
				
				if (target is IHandle) {
					return;
				}
				//Radiate.info("Selection Mouse down");
				
				// select target on mouse up or drag drop whichever comes first
				addTargetListeners(target);
				
				if (target!=targetApplication) {
					
					// listen for drag
					if (!dragManagerInstance) {
						dragManagerInstance = DragManagerUtil.getInstance();
					}
					
					//target.visible = false;
					//dragManagerInstance.listenForDragBehavior(target as IUIComponent, document, event);
					// for now we can only drag UIComponents bc I don't think drag manager supports
					// dragging graphic elements
					if (target is IVisualElement) {
						dragManagerInstance.listenForDragBehavior(target as IVisualElement, document, event, null, dragAllowedOutside);
						dragManagerInstance.roundToIntegers = roundToIntegers;
						dragManagerInstance.snapToNearbyElements = snapToNearbyElements;
						addDragManagerListeners();
					}
					
				}
				
				// select target right away 
				// this creates a delay when dragging so we are going to try to 
				// not dispatch target change until mouse up
				if (radiate && radiate.target!=target) {
					radiate.setTarget(target, dispatchTargetChange);
				}
				
				// draw selection rectangle
				if (showSelection) {
					updateSelectionAroundTarget(target);
					updateTransformRectangle(target);
				}
			}
			else if (target && !enableDrag) {
				// select target right away
				if (radiate && radiate.target!=target) {
					radiate.setTarget(target, dispatchTargetChange);
				}
				
				// draw selection rectangle
				if (showSelection) {
					updateSelectionAroundTarget(target);
				}
			}
			
			
		}
		
		protected function movedHandler(event:ObjectChangedEvent):void
		{
			//trace("moved");
			var model:Object = event.relatedObjects[0];
			var component:Object = objectHandles.getDisplayForModel(model);
			component.x = model.x;
			component.y = model.y;
		}
		
		public var startValuesDictionary:Object = new Dictionary(true);
		public var startWidth:Number;
		public var startHeight:Number;
		
		protected function resizingHandler(event:ObjectChangedEvent):void {
			//trace("sizing");
			var elements:Array;
			var startValues:Array;
			var model:Object;
			var component:Object;
			var scaleX:Number;
			var scaleY:Number;
			var altKey:Boolean;
			
			altKey = event.mouseEvent.altKey;
			elements = event.relatedObjects;
			
			for (var i:int = 0; i < elements.length; i++) {
				model = elements[i];
				component = objectHandles.getDisplayForModel(model);
				
				if (component is InvalidatingSprite && lastTarget is GraphicElement) {
					component = lastTarget;
				}
				
				if (startValuesDictionary[component]==null) {
					startValues = ComponentManager.captureSizingPropertyValues([component]);
					startValuesDictionary[component] = startValues;
				}
				
				// scale text font if shift key down
				if (component is IDisplayText) {
					
					if (altKey) {
						startValues = startValuesDictionary[component];
						scaleX = model.width/startValues[0].start.width;
						scaleY = model.height/startValues[0].start.height;
						component.scaleX = scaleX;
						component.scaleY = scaleY;
					}
					else {
						component.scaleX = 1;
						component.scaleY = 1;
					}
				}
				
				component.x = model.x;
				component.y = model.y;
				component.width = model.width;
				component.height = model.height;
			}
			
			clearSelection(false);
		}
		
		protected function resizedHandler(event:ObjectChangedEvent):void {
			//trace("resized");
			var elements:Array;
			var model:Object;
			var originalGeometry:DragGeometry;
			var component:Object;
			var uicomponent:UIComponent;
			var graphicElement:GraphicElement;
			var startValues:Array;
			var propertiesObject:Object;
			var manualRestore:Boolean;
			var properties:Array;
			var scaleX:Number;
			var scaleY:Number;
			var altKey:Boolean;
			var shiftKey:Boolean;
			var fontSize:Number;
			var scaleFont:Boolean;
			var setFontStyle:Boolean;
			var resizeScaledValues:Boolean;
			var hasExplicitWidth:Boolean;
			var hasExplicitHeight:Boolean;
			
			manualRestore = true;
			altKey = event.mouseEvent.altKey;
			shiftKey = event.mouseEvent.shiftKey;
			elements = event.relatedObjects;
			
			for (var i:int = 0; i < elements.length; i++) {
				model = elements[i];
				component = objectHandles.getDisplayForModel(model);
				
				if (component is InvalidatingSprite && lastTarget is GraphicElement) {
					component = lastTarget;
				}
				
				originalGeometry = objectHandles.getOriginalGeometryOfModel(model);
				startValues = startValuesDictionary[component];
				
				if (originalGeometry==null) {
					trace("Resizing bug. Not sure of cause. Fix later");
					continue;
				}
				
				uicomponent = component as UIComponent;
				graphicElement = component as GraphicElement;
				
				hasExplicitWidth = startValues[0].start.explicitWidth===undefined ? false : true;
				hasExplicitHeight = startValues[0].start.explicitHeight===undefined ? false : true;
				
				// restore original values so we can use undo history
				// start values are removed by this call so may need to change this
				ComponentManager.restoreCapturedValues(startValues, MXMLDocumentConstants.SIZE_AND_POSITION_PROPERTIES);
				delete startValuesDictionary[component];
				
				
				propertiesObject = ComponentManager.getPropertiesObjectFromBounds(component, model, roundToIntegers);
				properties = ClassUtils.getPropertyNames(propertiesObject);
				
				// set font size if alt + shift key down
				if (component is IDisplayText) {
					
					if (altKey) {
						scaleX = component.scaleX;
						scaleY = component.scaleY;
						component.scaleX = 1;
						component.scaleY = 1;
						fontSize = component.getStyle("fontSize");
						
						if (scaleX!=1 || scaleY!=1) {
							
							if (shiftKey) {
								fontSize = scaleX*fontSize;
								
								fontSize = NumberUtils.toDecimalPoint(fontSize);
								
								
								if (hasExplicitWidth) {
									if (roundToIntegers) {
										propertiesObject.width = Math.ceil(propertiesObject.width/scaleX);
									}
									else {
										propertiesObject.width = NumberUtils.toDecimalPoint(propertiesObject.width/scaleX);
									}
								}
								else {
									propertiesObject.width = undefined;
									//delete propertiesObject.width;
									//properties.splice(properties.indexOf("width"));
								}
								
								if (hasExplicitHeight) {
									if (roundToIntegers) {
										propertiesObject.height = Math.ceil(propertiesObject.height/scaleY);
									}
									else {
										propertiesObject.height = NumberUtils.toDecimalPoint(propertiesObject.height/scaleY);
									}
								}
								else {
									propertiesObject.height = undefined;
									//delete propertiesObject.height;
									//properties.splice(properties.indexOf("height"));
								}
								
								//resizeScaledValues = true;
								setFontStyle = true;
							}
							else {
								scaleFont = true;
							}
						}
					}
				}
				
				if (scaleFont) {
					
					if (scaleX!=1) {
						properties.push("scaleX");
						propertiesObject.scaleX = scaleX;
						resizeScaledValues = true;
					}
					
					if (scaleY!=1) {
						properties.push("scaleY");
						propertiesObject.scaleY = scaleY;
						resizeScaledValues = true;
					}
					
				}
				
				if (resizeScaledValues) {
					
					if (scaleX!=1) {
						
						if (roundToIntegers) {
							propertiesObject.width = Math.round(propertiesObject.width/scaleX);
						}
						else {
							propertiesObject.width = NumberUtils.toDecimalPoint(propertiesObject.width/scaleX);
						}
					}
					
					if (scaleY!=1) {
						
						if (roundToIntegers) {
							propertiesObject.height = Math.round(propertiesObject.height/scaleY);
						}
						else {
							propertiesObject.height = NumberUtils.toDecimalPoint(propertiesObject.height/scaleY);
						}
					}
					
				}
				
				if (component is GraphicElement) {
					ComponentManager.setProperties(component, properties, propertiesObject, "Resized", true);
				}
				else {
					ComponentManager.setProperties(component, properties, propertiesObject, "Resized", true);
				}
				
				if (setFontStyle) {
					ComponentManager.setStyle(component, "fontSize", fontSize);
					HistoryManager.mergeLastHistoryEvent(Radiate.selectedDocument);
				}
			}
			
		}
		
		protected function movingHandler(event:ObjectChangedEvent):void {
			var elements:Array = event.relatedObjects;
			
			for (var i:int = 0; i < elements.length; i++) {
				var model:Object = elements[i];
				var component:Object = objectHandles.getDisplayForModel(model);
				component.x = model.x;
				component.y = model.y;
			}
			
		}
		
		protected function rotatingHandler(event:ObjectChangedEvent):void {
			var elements:Array = event.relatedObjects;
			var startValues:Array;
			
			for (var i:int = 0; i < elements.length; i++) {
				var model:Object = elements[i];
				var component:Object = objectHandles.getDisplayForModel(model);
				
				if (component is InvalidatingSprite && lastTarget is GraphicElement) {
					component = lastTarget;
				}
				
				if (startValuesDictionary[component]==null) {
					startValues = ComponentManager.captureSizingPropertyValues([component]);
					startValuesDictionary[component] = startValues;
				}
				
				if (MXMLDocumentConstants.ROTATION in model) {
					component.rotation = model.rotation;
				}
			}
		}
		
		protected function rotatedHandler(event:ObjectChangedEvent):void {
			//trace("rotated");
			var elements:Array;
			var model:Object;
			var originalGeometry:DragGeometry;
			var component:Object;
			var uicomponent:UIComponent;
			var graphicElement:GraphicElement;
			var startValues:Array;
			var propertiesObject:Object;
			var properties:Array;
			
			elements = event.relatedObjects;
			
			for (var i:int = 0; i < elements.length; i++) {
				model = elements[i];
				component = objectHandles.getDisplayForModel(model);
				
				if (component is InvalidatingSprite && lastTarget is GraphicElement) {
					component = lastTarget;
				}
				
				originalGeometry = objectHandles.getOriginalGeometryOfModel(model);
				startValues = startValuesDictionary[component];
				
				if (originalGeometry==null) {
					trace("Rotating bug. Not sure of cause. Fix later");
					continue;
				}
				
				uicomponent = component as UIComponent;
				graphicElement = component as GraphicElement;
				
				// restore original values so we can use undo history
				// we should use captureStartValues of effect class in Radiate
				// and then create restoreStartValues or get the change object
				
				ComponentManager.restoreCapturedValues(startValues, [MXMLDocumentConstants.ROTATION]);
				delete startValuesDictionary[component];
				
				propertiesObject = {};
				propertiesObject.rotation = model.rotation;
				properties = [MXMLDocumentConstants.ROTATION];
				
				if (component is GraphicElement) {
					ComponentManager.setProperties(component, properties, propertiesObject, "Rotated", true);
				}
				else {
					ComponentManager.setProperties(component, properties, propertiesObject, "Rotated", true);
				}
			}
		}
		
		
		/**
		 * Handles drag start
		 * */
		protected function handleDragStart(event:DragDropEvent):void {
			
			if (hideSelectionOnDrag) {
				clearSelection();
				_selectionWasShownBeforeDrag = _showSelection;
			}
			
			isDragging = true;
		}
		
		/**
		 * Handles drag end
		 * */
		protected function handleDragEnd(event:DragDropEvent):void {
			
			if (hideSelectionOnDrag && _selectionWasShownBeforeDrag) {
				showSelection = _selectionWasShownBeforeDrag;
				_selectionWasShownBeforeDrag = false;
			}
			
			isDragging = false;
			removeDragManagerListeners();
		}
		
		/**
		 * Handles drag over
		 * */
		protected function handleDragOver(event:DragDropEvent):void {
			//Radiate.info("Selection Drag Drop");
			var target:Object = dragManagerInstance.draggedItem;
			// trace("Drag over")
			dragLocation = dragManagerInstance.dropTargetLocation;
			
			// sometimes the selection rectangle is not hidden??
			if (hideSelectionOnDrag && targetSelectionGroup.visible) {
				clearSelection();
			}
			
			if (selectionInspector) {
				selectionInspector.dragLocation = dragLocation;
			}
		}
		
		/**
		 * Handles drag drop event on drag manager
		 * */
		protected function handleDragDrop(event:DragDropEvent):void {
			// select target
			//radiate.target = event.draggedItem;
			//Radiate.info("Selection Drag Drop");
			
			var target:Object = dragManagerInstance.draggedItem;
			
			
			
			// clean up
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.info("3 has event listener");
			}
			
			removeTargetListeners();
			
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.info("4 has event listener");
			}
			else {
				//Radiate.info("listener removed");
			}
			
			//Radiate.info("End Selection Drag Drop");
			
			// select target
			if (radiate.target!=target) {
				radiate.setTarget(target, true);
			}
			
			if (showSelection) {
				updateSelectionAroundTarget(target);
			}
			
			// set focus to component to handle keyboard events
			if (setFocusOnSelect && target is UIComponent){
				target.setFocus();
			}
			
			dragLocation = "";
			
			
			// drag manager removes these because it doesn't know or care what
			// the current tool it has to add group mouse handlers. 
			addTransparentGroupListeners();
		}
		
		/**
		 * Handles drag drop event on drag manager
		 * */
		protected function handleDragDropComplete(event:DragDropEvent):void {
			if (debug) {
				log("drag drop complete");
			}
			
			// drag manager removes these because it doesn't know or care what
			// the current tool is.
			// but we need to have transparent group listeners to select groups  
			addTransparentGroupListeners();
		}
	
		/**
		 * Handle mouse up on the stage
		 * */
		protected function mouseUpHandler(event:MouseEvent):void {
			
			if (debug) {
				log("mouseUpHandler");
			}
			
			var target:Object = event.currentTarget;
			//var target:Object = event.target;
			var componentTree:ComponentDescription;
			var componentDescription:ComponentDescription;
			var firstUnlockedComponentDescription:ComponentDescription;
			var actualTarget:GraphicElement;
			
			componentTree = Radiate.selectedDocument.componentDescription;
			componentDescription = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(target), componentTree);
			//Radiate.info("Selection Mouse up");
			
			if (target is List) {
				//target.dragEnabled = true; // restore drag and drop if it was enabled
			}
			
			if (componentDescription && componentDescription.instance!=target) {
				removeTargetListeners(target);
				target = componentDescription.instance;
			}
			
			target.visible = true;
			
			// clean up
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.info("1 has event listener");
			}
			
			removeTargetListeners(target);
			
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.info("2 has event listener");
			}
			else {
				//Radiate.info("listener removed");
			}
			
			//spark.components.supportClasses.InvalidatingSprite - clicked on graphic element
			//componentDescription = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(target), componentTree);
			if (componentDescription && componentDescription.isGraphicElement) {
				
			}
			
			if (target is InvalidatingSprite) {
				actualTarget = currentComponentDescription && currentComponentDescription.instance ? currentComponentDescription.instance as GraphicElement : null;
				componentDescription = document.getItemDescription(target);
				
				if (componentDescription!=null) {
					target = componentDescription.instance;
				}
				else if (actualTarget is GraphicElement && actualTarget.displayObject==target) {
					target = actualTarget;
				}
			}
			
			if (componentDescription) {
				firstUnlockedComponentDescription = componentDescription.getFirstUnlockedTarget();
				
				if (firstUnlockedComponentDescription!=null && firstUnlockedComponentDescription == componentDescription) {
					target = componentDescription.instance;
					//break;
				}
				else if (firstUnlockedComponentDescription!=null && firstUnlockedComponentDescription != componentDescription) {
					
					if (firstUnlockedComponentDescription!=null) {
						componentDescription = firstUnlockedComponentDescription;
						target = firstUnlockedComponentDescription.instance;
						//break;
					}
					
					if (target==targetApplication) {
						//return;
					}
				}
			}
			
			// select only groups or items on the application
			if (selectGroup) {
				
				// if parent is application let user select it
				if (componentDescription.parent==componentTree) {
					// it's on the root so we're good
				}
				else if (componentDescription.instance is IVisualElementContainer) {
					// it's a group so we're good
				}
				else {
					// select group container
					componentDescription = componentDescription.parent;
					target = componentDescription.instance;
				}
			}
			
			target.visible = true;
			
			removeTargetListeners(target);
			
			//Radiate.info("End Selection Mouse Up");
			
			var dispatchTargetChange:Boolean = true;
			
			// select target
			if (isDragging || radiate.target!=target) {
				radiate.setTarget(target, dispatchTargetChange);
				isDragging = false;
			}
			
			// draw selection rectangle
			if (showSelection) {
				updateSelectionAroundTarget(target);
				updateTransformRectangle(target);
			}
			
			// draw selection rectangle
			if (setFocusOnSelect && target is UIComponent) {
				target.setFocus();
			}
			
			// draw transform controls rectangle
			if (showTransformControls) {
				updateTransformRectangle(target);
			}
			
			removeDragManagerListeners(); // nov 6
		}
		
		/**
		 * Helps us determine if we are interested in this particular event
		 * */
		public function isEventApplicable(event:Event):Boolean {
			var systemManager:SystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
			var topLevelApplication:Object = FlexGlobals.topLevelApplication;
			var focusedObject:Object = topLevelApplication.focusManager.getFocus();
			var eventTarget:Object = event.target;
			var eventCurrentTarget:Object = event.currentTarget;
			var tabNav:TabNavigator = DocumentManager.documentsTabNavigator;
			var isGraphicElement:Boolean;
			
			// still working on this
			
			if (focusedObject is Application || event.target is Stage) {
				if (targetApplication) {
					return true;
				}
			}
			
			if (targetApplication && DisplayObjectContainer(targetApplication).contains(event.target as DisplayObject)) {
				//event.stopImmediatePropagation();
				
				return true;
			}
			
			if (eventTarget==tabNav && 
				currentComponentDescription && 
				currentComponentDescription.isGraphicElement) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Dispatches key event
		 * */
		public function dispatchKeyEvent(event:KeyboardEvent):void {
			keyCode = event.keyCode;
			keyLocation = event.keyLocation;
			dispatchEvent(new Event(KEY_EVENT));
		}
		
		/**
		 * Dispatches edit event
		 * */
		public function dispatchEditEvent(event:Event, type:String):void {
			editType = type;
			dispatchEvent(new Event(EDIT_EVENT));
		}
		
		/**
		 * ?????? NOT USED ??????
		 * Prevent system manager from taking our events
		 * */
		private function keyDownHandler(event:KeyboardEvent):void
		{
			
			// ?????? NOT USED ??????
			switch (event.keyCode)
			{
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.PAGE_UP:
				case Keyboard.PAGE_DOWN:
				case Keyboard.HOME:
				case Keyboard.END:
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
				case Keyboard.ENTER:
				case Keyboard.DELETE:
				{
					// ?????? NOT USED ??????
					if (targetApplication && DisplayObjectContainer(targetApplication).contains(event.target as DisplayObject)) {
						event.stopImmediatePropagation();
					}
					//event.stopImmediatePropagation();
					//Radiate.info("Canceling key down");
				}
			}
		}
		
		/**
		 * Prevent system manager from taking our events. 
		 * This seems to be the only handler that is working for some keyboard events 
		 * besides keyUpHandler
		 * @see #keyUpHandler()
		 * */
	    private function keyDownHandlerStage(event:KeyboardEvent):void {
			var tabNav:TabNavigator;
			var keyCode:uint;
			
			if (debug) {
				log("Key: " + event.keyCode);
			}
			
			keyCode = event.keyCode;
			tabNav = DocumentManager.documentsTabNavigator;
			
			//Radiate.info("Key down: " + event.keyCode);
            switch (event.keyCode)
            {
                case Keyboard.UP:
                case Keyboard.DOWN:
                case Keyboard.LEFT:
                case Keyboard.RIGHT:
                case Keyboard.PAGE_UP:
                case Keyboard.PAGE_DOWN:
                case Keyboard.HOME:
                case Keyboard.END:
                case Keyboard.ENTER:
                case Keyboard.DELETE:
                {
					
					// we want to prevent document scrollers from reacting on keyboard events
					// so we stop the propagation
					if (targetApplication && DisplayObjectContainer(targetApplication).contains(event.target as DisplayObject)) {
	                    event.stopImmediatePropagation();
					}
					
					//Radiate.info("Canceling key down");
					//dispatchKeyEvent(event);
					break;
                }
            }
	    }
		
		/**
		 * Handles keyboard position changes. 
		 * Up left right down, etc.
		 * */
		protected function keyUpHandler(event:KeyboardEvent):void {
			var keyCode:uint;
			var constant:int;
			var index:int;
			var applicable:Boolean;
			var topApplication:Object;
			var focusedObject:Object;
			var isApplication:Boolean;
			var actionOccurred:Boolean;
			var eventTarget:Object;
			var eventCurrentTarget:Object;
			var tabNav:TabNavigator;
			var isGraphicElement:Boolean;
			var targets:Array;
			var element:IVisualElement;
			var properties:Array;
			var propertiesObject:Object;
			var numberOfTargets:int;
			var ctrlKey:Boolean;
			var applicableKeys:Array;
			
			if (debug) {
				log("Key: " + event.keyCode);
			}
			
			keyCode = event.keyCode;
			
			// Z = 90
			// C = 67
			// left = 37
			// right = 39
			// up = 38
			// down = 40 
			// backspace = 8
			// delete = 46
			//Radiate.info("Key up: " + event.keyCode);
			
			applicableKeys = [	Keyboard.LEFT, 
								Keyboard.RIGHT, 
								Keyboard.UP, 
								Keyboard.DOWN 
							 ];
			
			
			if (applicableKeys.indexOf(keyCode)==-1) {
				return;
			}
			
			eventTarget = event.target;
			eventCurrentTarget = event.currentTarget;
			tabNav = DocumentManager.documentsTabNavigator;
			topApplication = FlexGlobals.topLevelApplication;
			focusedObject = topApplication.focusManager.getFocus();
			constant = event.shiftKey ? alternateMoveIncrement : moveIncrement;
			ctrlKey = event.ctrlKey || ("commandKey" in event && event.commandKey);
			
			if (radiate==null) {
				return;
			}
			
			// capture key presses when application has focus
			if (eventTarget is Stage) {
				if (focusedObject==null) {
					applicable = true;
				}
				else if (targetApplication && targetApplication.contains(focusedObject)) {
					applicable = true;
				}
			}
			
			if (focusedObject is Application) {
				isApplication = true;
			}
			
			// check that the target is in the target application
			if (isApplication || 
				(targetApplication && 
				(targetApplication.contains(eventCurrentTarget) || 
					targetApplication.contains(eventTarget)))) {
				applicable = true;
			}
			else if (eventTarget==tabNav && 
				currentComponentDescription && 
				currentComponentDescription.isGraphicElement) {
				applicable = true;
				isGraphicElement = true;
			}
			else {
				return;
			}
			
			targets = radiate.targets;
			numberOfTargets = targets.length;
			
			// Radiate.info("Selection key up");
			if (targets.length>0) {
				applicable = true;
			}
			
			if (keyCode==Keyboard.LEFT) {
				
				for (;index<numberOfTargets;index++) {
					element = targets[index];
					
					if (element == targetApplication) {
						continue;
					}
					
					ComponentManager.moveLeft(element, constant);
				}
				
				actionOccurred = true;
			}
			else if (keyCode==Keyboard.RIGHT) {
				
				for (;index<numberOfTargets;index++) {
					element = targets[index];
					
					if (element == targetApplication) {
						continue;
					}
					
					ComponentManager.moveRight(element, constant);
				}
				
				actionOccurred = true;
			}
			else if (keyCode==Keyboard.UP) {
				
				for (;index<numberOfTargets;index++) {
					element = targets[index];
					
					if (element == targetApplication) {
						continue;
					}
					
					ComponentManager.moveUp(element, constant);
				}
				
				actionOccurred = true;
			}
			else if (keyCode==Keyboard.DOWN) {
				
				for (;index<numberOfTargets;index++) {
					element = targets[index];
					
					if (element == targetApplication) {
						continue;
					}
					
					ComponentManager.moveDown(element, constant);
				}
				
				actionOccurred = true;
			}
			
			if (applicable && actionOccurred) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				event.preventDefault();
				dispatchKeyEvent(event);
			}
			
			if (actionOccurred) {
				//dispathKeyEvent(event);
			}
		}
		
		/**
		 * Show selection box on target change
		 * */
		public var showSelectionRectangle:Boolean = true;
		
		/**
		 * Last key code handled by this class
		 * */
		public var keyCode:uint;
		
		/**
		 * Last key code handled by this class
		 * */
		public var keyLocation:uint;
		
		/**
		 * Last edit event type handled by this class
		 * */
		public var editType:String;
		
		/**
		 * Indicates if the group should be selected
		 * */
		public var selectGroup:Boolean;
		
		/**
		 * Show resize handles
		 * */
		public var showResizeHandles:Boolean = false;
		public var useObjectHandles:Boolean = true;
		public var roundToIntegers:Boolean;
		
		/**
		 * Clears the outline around a target display object
		 * */
		public function clearSelection(clearResizeHandles:Boolean = true):void {
			
			if (targetSelectionGroup) {
				targetSelectionGroup.visible = false;
			}
			
			if (selectionManager && clearResizeHandles) {
				//selectionManager.clearSelection();
				unregisterComponents();
			}
		}
		
		/**
		 * Unregisters components for transform
		 * */
		public function unregisterComponents():void {
			
			if (objectHandles) {
				objectHandles.unregisterAll();
			}
		}
		
		
		/**
		 * Draws outline around target display object. 
		 * Trying to add support to add different types of selection rectangles. 
		 * */
		public function registerComponent(target:Object, selection:Object = null):Object {
			var shapeModel:Object = objectHandles.getModelForDisplay(target);
			var graphicElement:GraphicElement = target as GraphicElement;
			
			if (shapeModel==null) {
				shapeModel = new DisplayModel();
			}
			
			// http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf633a0-7fff.html
			if (target is UIComponent) {
				shapeModel.width 	= target.getLayoutBoundsWidth();
				shapeModel.height 	= target.getLayoutBoundsHeight();
				shapeModel.x 		= target.getLayoutBoundsX();
				shapeModel.y 		= target.getLayoutBoundsY();
				shapeModel.x 		= target.x;
				shapeModel.y 		= target.y;
				shapeModel.rotation = target.rotation;
				shapeModel.selected = false;
				
				//objectHandles.registerComponent(shapeModel, target as IEventDispatcher, null, true, [aspectRatioConstraint]);
				objectHandles.registerComponent(shapeModel, target as IEventDispatcher, null, false);
			}
			
			if (graphicElement) {
				shapeModel.width 	= graphicElement.getLayoutBoundsWidth();
				shapeModel.height 	= graphicElement.getLayoutBoundsHeight();
				shapeModel.x 		= graphicElement.getLayoutBoundsX();
				shapeModel.y 		= graphicElement.getLayoutBoundsY();
				shapeModel.x 		= graphicElement.x;
				shapeModel.y 		= graphicElement.y;
				shapeModel.rotation = target.rotation;
				shapeModel.selected = false;
				
				//objectHandles.registerComponent(shapeModel, target as IEventDispatcher, null, true, [aspectRatioConstraint]);
				objectHandles.registerComponent(shapeModel, graphicElement.displayObject as IEventDispatcher, null, false);
			}
			
			return shapeModel;
		}
		
		/**
		 * Draws transform controls around selected items
		 * */
		public function updateTransformRectangle(target:Object = null, selection:Object = null):void {
			if (target==null) {
				target = radiate.target;
			}
			
			if (useObjectHandles && objectHandles) {
				
				if (showTransformControls) {
					var model:Object;
					var position:Object;
					var graphicElement:GraphicElement;
					
					target = target is Array && target.length ? target[0] : target;
					graphicElement = target as GraphicElement;
					
					// don't select a resize handle
					if (target is IHandle) {
						return;
					}
					
					if (target==targetApplication) {
						objectHandles.unregisterAll();
						return;
					}
					
					if (target is spark.primitives.Line) {
						objectHandles.unregisterAll();
						return;
					}
					
					// register selected component - todo - unregister
					// note should we register the graphic element or only it's display object?
					if (graphicElement) {
						if (!objectHandles.isDisplayRegistered(graphicElement.displayObject)) {
							registerComponent(target, toolLayer);
						}
					}
					else if (!objectHandles.isDisplayRegistered(target as DisplayObject)) {
						registerComponent(target, toolLayer);
					}
					
					if (graphicElement) {
						model = objectHandles.getModelForDisplay(graphicElement.displayObject);
					}
					else {
						model = objectHandles.getModelForDisplay(target as DisplayObject);
					}
					
					if (model && targetSelectionGroup) {
						model.width = targetSelectionGroup.width;
						model.height = targetSelectionGroup.height;
						//model.x = targetSelectionGroup.x;
						//model.y = targetSelectionGroup.y;
					}
					
					if (model && !selectionManager.isSelected(model)) {
						selectionManager.setSelected(model);
					}
					
					if (model) {
						selectionManager.setSelected(model);
						
						if (graphicElement) {
							objectHandles.updateModelForDisplay(graphicElement.displayObject);
						}
						else {
							objectHandles.updateModelForDisplay(target);
						}
						//objectHandles.updateHandlePositions(model);
					}
				}
				else {
					selectionManager.clearSelection();
					unregisterComponents();
				}
			}
		}
		
		/**
		 * Draws outline around target display object. 
		 * Trying to add support to add different types of selection rectangles. 
		 * sizeSelectionGroup() is used to get the size of target object
		 * @see #sizeSelectionGroup()
		 * */
		public function drawSelection(target:Object, selection:Object = null):void {
			var rectangle:Rectangle;
			var selectionGroup:ISelectionGroup;
			
			// sometimes the width and height are zero
			// look into LayoutElementUIComponentUtils class
			
			// creates an instance of the bounding box that will be shown around the drop target
			if (!targetSelectionGroup) {
				targetSelectionGroup = new TargetSelectionGroup();
			}
			
			if (targetSelectionGroup) {
				//targetSelectionGroup.mouseEnabled = false;
				//targetSelectionGroup.mouseChildren = false;
				selectionGroup = targetSelectionGroup as ISelectionGroup;
				
				if (selectionGroup) {
					selectionGroup.showSelectionFill 			= showSelectionFill;
					selectionGroup.showSelectionFillOnDocument	= showSelectionFillOnDocument;
					selectionGroup.showSelectionLabel 			= showSelectionLabel;
					selectionGroup.showSelectionLabelOnDocument = showSelectionLabelOnDocument;
					selectionGroup.selectionBorderColor 		= selectionBorderColor;
					selectionGroup.showResizeHandles 			= showResizeHandles;
					
				}
			}
			
			// get bounds
			if (!target) {
				
				// set values to zero
				if (!rectangle) {
					rectangle = new Rectangle();
				}
				
				// hide selection group
				if (targetSelectionGroup.visible) {
					targetSelectionGroup.visible = false;
				}
			}
			else {
				// add to tools layer	
				if (selection && selection is IVisualElementContainer) {
					IVisualElementContainer(selection).addElement(targetSelectionGroup);
					targetSelectionGroup.validateNow();
				}
				
				
				
				// get and set selection rectangle
				sizeSelectionGroup(target, selection as DisplayObject);
				
				// validate
				if (selection && selection is IVisualElementContainer) {
					//IVisualElementContainer(selection).addElement(targetSelectionGroup);
					targetSelectionGroup.validateNow();
					//targetSelectionGroup.includeInLayout = false;
				}
				
				// draw the selection rectangle only if it's changed
				else if (lastTargetCandidate!=target) {
					var topLevelApplication:Object = FlexGlobals.topLevelApplication;
					// if selection is offset then check if using system manager sandbox root or top level root
					var systemManager:ISystemManager = ISystemManager(topLevelApplication.systemManager);
					
					// no types so no dependencies
					var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
					var targetCoordinateSpace:DisplayObject;
					
					if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
						targetCoordinateSpace = Sprite(systemManager.getSandboxRoot());
					}
					else {
						targetCoordinateSpace = Sprite(topLevelApplication);
					}
					
					/*
					var documentSpace:DisplayObject = Radiate.instance.document as DisplayObject;
					
					if (documentSpace) {
						targetCoordinateSpace = documentSpace;
					}*/
					
					// Error occurs when targetCoordinateSpace is the document (loaded application)
					// Error: removeChild() is not available in this class. 
					// Instead, use removeElement() or modify the skin, if you have one.
					//     at spark.components::Group/removeChild()[E:\dev\4.y\frameworks\projects\spark\src\spark\components\Group.as:2136]
					//
					// Solution:
					// 
					// probably use toplevelapplication
					
					// show selection / bounding box
					PopUpManager.addPopUp(targetSelectionGroup, targetCoordinateSpace);
					targetSelectionGroup.validateNow();
				}
			}
			
		}
		
		/**
		 * Sets the selection rectangle to the size of the target.
		 * 
		 * TODO: 
		 * http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf633a0-7fff.html
		 * */
		public function sizeSelectionGroup(target:Object, targetCoordinateSpace:DisplayObject = null, localTargetSpace:Boolean = true):void {
			var rectangle:Rectangle;
			var showContentSize:Boolean = false;
			var isEmbeddedCoordinateSpace:Boolean;
			var isTargetInvalid:Boolean;
			var pixelBounds:Rectangle;
			var wreck:Rectangle;
			
			
			// get content width and height
			if (target is GroupBase) {
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent;
				//rectangle = GroupBase(target).getBounds(target.parent);
				rectangle = GroupBase(target).getBounds(targetCoordinateSpace);
				wreck = DisplayObjectUtils.getRectangleBounds(target as UIComponent, targetCoordinateSpace);
				
				// size and position fill
				if (rectangle.width==0 && rectangle.height==0) {
					// for some reason rectangle = GroupBase(target).getBounds(targetCoordinateSpace);
					// returns width,height of 0 and x,y of 6710937.2
					targetSelectionGroup.width = wreck.width;
					targetSelectionGroup.height = wreck.height;
				}
				else {
					targetSelectionGroup.width = showContentSize ? GroupBase(target).contentWidth : rectangle.size.x -1;
					targetSelectionGroup.height = showContentSize ? GroupBase(target).contentHeight : rectangle.size.y -1;
				}
				
				if (!localTargetSpace) {
					rectangle = GroupBase(target).getVisibleRect(target.parent);
				}
				
				if (rectangle.x>10000) {
					targetSelectionGroup.x = wreck.x;
					targetSelectionGroup.y = wreck.y;
				}
				else {
					targetSelectionGroup.x = rectangle.x;
					targetSelectionGroup.y = rectangle.y;
				}
				//trace("target is groupbase");
			}
			else if (target is Image) {
				
				if (targetCoordinateSpace && 
					"systemManager" in targetCoordinateSpace && 
					Object(targetCoordinateSpace).systemManager!=target.systemManager) {
					isEmbeddedCoordinateSpace = true;
				}
				
				if (!targetCoordinateSpace ) targetCoordinateSpace = target.parent; 
				
			
				// if target is IMAGE it can be sized to 6711034.2 width or height at times!!! 6710932.2
				// possibly because it is not ready. there is a flag _ready that is false
				// also sourceWidth and sourceHeight are NaN at first
					
				/*trace("targetCoordinateSpace="+Object(targetCoordinateSpace).id);
				trace("targetCoordinateSpace owner="+Object(targetCoordinateSpace).owner.id);
				trace("x=" + target.x);
				trace("y=" + target.y);
				trace("w=" + target.width);
				trace("h=" + target.height);*/
				//if (!localTargetSpace) {
				/*	rectangle = UIComponent(target).getVisibleRect();
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace);
					rectangle = UIComponent(target).getVisibleRect(target.parent);
					rectangle = UIComponent(target).getVisibleRect(targetApplication.parent);
					rectangle = UIComponent(target).getVisibleRect(Object(targetCoordinateSpace).owner);
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace.parent);
				*/
				target.validateNow();
				
				rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
				wreck = DisplayObjectUtils.getRectangleBounds(target, targetCoordinateSpace);
				
				if (rectangle.width==0 || 
					rectangle.height==0 || 
					rectangle.x>100000 || 
					rectangle.y>100000) {
					
					//Radiate.info("Image not returning correct bounds");
					/*
					target.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(IOErrorEvent.IO_ERROR, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, setSelectionLaterHandler, false, 0, true);
					*/
					//target.imageDisplay.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
					//target.imageDisplay.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
					
					// size and position fill
					//targetSelectionGroup.width = 0;//rectangle.width;//UIComponent(target).getLayoutBoundsWidth();
					//targetSelectionGroup.height = 0;//rectangle.height; // UIComponent(target).getLayoutBoundsHeight();
					//targetSelectionGroup.x = 0;//rectangle.x;
					//targetSelectionGroup.y = 0;//rectangle.y;
					
					
					//isTargetInvalid = true;
					
					if (wreck.width==0 || wreck.height==0) {
						targetSelectionGroup.width = wreck.width + 1;
						targetSelectionGroup.height = wreck.height + 1;
					}
					else {
						targetSelectionGroup.width = wreck.width - 1;
						targetSelectionGroup.height = wreck.height - 1;
					}
					targetSelectionGroup.x = wreck.x;
					targetSelectionGroup.y = wreck.y;
					
				}
				else {
					
					/*rectangle = UIComponent(target).getBounds(target.parent);
					rectangle = UIComponent(target).getBounds(target.owner);
					rectangle = UIComponent(target).getBounds(targetCoordinateSpace.parent);
					rectangle = UIComponent(target).getBounds(null);*/
				//}
				//else {
					
					/*rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
					rectangle = UIComponent(target).getBounds(target.parent);
					rectangle = UIComponent(target).getBounds(targetApplication as DisplayObject);
					rectangle = UIComponent(target).getBounds(targetApplication.parent);
					var s:Number = UIComponent(target).getLayoutBoundsWidth();
					s= UIComponent(target).getLayoutBoundsHeight();
					s= UIComponent(target).getLayoutBoundsX();
					s= UIComponent(target).getLayoutBoundsY();*/
				//}
					
					// size and position fill
					targetSelectionGroup.width = rectangle.width -1;//UIComponent(target).getLayoutBoundsWidth();
					targetSelectionGroup.height = rectangle.height-1; // UIComponent(target).getLayoutBoundsHeight();
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = rectangle.x;
					targetSelectionGroup.y = rectangle.y;
				}
				
			}
			// get target bounds
			else if (target is UIComponent) {
				var targetRectangle:Rectangle;
				// systemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent; 
				
				if (!localTargetSpace) {
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace);
				}
				else {
					// if target is IMAGE it can be sized to 6711034.2 width or height at times!!! 6710932.2
					//targetRectangle = DisplayObjectUtils.getRectangleBounds(target, toolLayer);
					targetRectangle = DisplayObjectUtils.getRectangleBounds(target, targetCoordinateSpace);
					rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
				}
				
				// this is working the best so far - possibly use this instead of other code
				if (target is ListBase || target is TextArea || target is DataGrid || target is VideoPlayer) {
					// size and position fill
					targetSelectionGroup.width = targetRectangle.width;
					targetSelectionGroup.height = targetRectangle.height;
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = targetRectangle.x;
					targetSelectionGroup.y = targetRectangle.y;
				}
				else {
					// size and position fill
					targetSelectionGroup.width = rectangle.width -1;
					targetSelectionGroup.height = rectangle.height -1;
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = rectangle.x;
					targetSelectionGroup.y = rectangle.y;
				}
				//trace("target is uicomponent");
			}
			// get visual element bounds
			else if (target is GraphicElement) {
				targetRectangle = DisplayObjectUtils.getRectangleBounds(target, toolLayer);
				
				if (GraphicElement(target).transform && GraphicElement(target).transform.pixelBounds) {
					pixelBounds = GraphicElement(target).transform.pixelBounds;
				}
				
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent; 
				
				
				if (targetRectangle) {
					
					if (pixelBounds) {
						targetSelectionGroup.width = pixelBounds.width;
						targetSelectionGroup.height = pixelBounds.height;
					}
					else {
						targetSelectionGroup.width = targetRectangle.width;
						targetSelectionGroup.height = targetRectangle.height;
					}
					
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = targetRectangle.x;
					targetSelectionGroup.y = targetRectangle.y;
				}
				else {
					// this does not take into account parent sizing
					// size and position fill
					targetSelectionGroup.width = IGraphicElement(target).getLayoutBoundsWidth();
					targetSelectionGroup.height = IGraphicElement(target).getLayoutBoundsHeight();
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = IGraphicElement(target).getLayoutBoundsX();
					targetSelectionGroup.y = IGraphicElement(target).getLayoutBoundsY();
				}
			}
			// get target bounds
			else if (target is IVisualElement) {
				targetRectangle = DisplayObjectUtils.getRectangleBounds(target, toolLayer);
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent; 
				
				/*if (!localTargetSpace) {
				rectangle = IGraphicElement(target).getLayoutBoundsHeight();
				}
				else {
				rectangle = IGraphicElement(target).getBounds(targetCoordinateSpace);
				}*/
				
				
				if (targetRectangle) {
					
					targetSelectionGroup.width = targetRectangle.width;
					targetSelectionGroup.height = targetRectangle.height;
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = targetRectangle.x;
					targetSelectionGroup.y = targetRectangle.y;
				}
				else {
					// this does not take into account parent sizing
					// size and position fill
					targetSelectionGroup.width = IGraphicElement(target).getLayoutBoundsWidth();
					targetSelectionGroup.height = IGraphicElement(target).getLayoutBoundsHeight();
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = IGraphicElement(target).getLayoutBoundsX();
					targetSelectionGroup.y = IGraphicElement(target).getLayoutBoundsY();
				}
			}
			
			else {
				if (!localTargetSpace) {
					rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
				}
				else {
					rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
				}
				
				// size and position fill
				targetSelectionGroup.width = rectangle.width-1;
				targetSelectionGroup.height = rectangle.height-1;
				targetSelectionGroup.x = rectangle.x;
				targetSelectionGroup.y = rectangle.y;
				//trace("target is not uicomponent");
			}
			
			// we set to the target so we can display target name and size in label above selection
			if (currentComponentDescription && currentComponentDescription.instance==target) {
				targetSelectionGroup.data = currentComponentDescription;
			}
			else {
				targetSelectionGroup.data = target;
			}
			
			
			// unhide target selection group
			if (isTargetInvalid) {
				targetSelectionGroup.visible = false;
			}
			
			else if (!targetSelectionGroup.visible) {
				targetSelectionGroup.visible = true;
				targetSelectionGroup.includeInLayout
			}
		}
		
		/**
		 * Sets the selection rectangle to the size of the target.
		 * */
		public function sizeSelectionGroup2(target:Object, targetSpace:DisplayObject = null, localTargetSpace:Boolean = true):void {
			var toolRectangle:Rectangle;
			var showContentSize:Boolean = false;
			var isEmbeddedCoordinateSpace:Boolean;
			var isTargetInvalid:Boolean;
			var toolLayer:DisplayObject = targetSpace;
			var targetCoordinateSpace:DisplayObject = targetSpace;
			var globalRectangle:Rectangle;
			var visibleRectangle:Rectangle;
			var rectangle:Rectangle;
			
			// get content width and height
			if (target is GroupBase) {
				
				var topLevelApplication:Object = FlexGlobals.topLevelApplication;
				// if selection is offset then check if using system manager sandbox root or top level root
				var systemManager:ISystemManager = ISystemManager(topLevelApplication.systemManager);
				
				// no types so no dependencies
				var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
				
				if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
					targetCoordinateSpace = Sprite(systemManager.getSandboxRoot());
				}
				else {
					targetCoordinateSpace = Sprite(topLevelApplication);
				}
				
				
				if (!targetSpace) {
					targetSpace = target.parent;
				}
				
				globalRectangle = GroupBase(target).getBounds(targetCoordinateSpace);
				toolRectangle = GroupBase(target).getBounds(toolLayer);
				
				/*trace("toollayer.x="+targetSpace.x);
				trace("toollayer.y="+targetSpace.y);*/
				/*
				var newPoint:Point = DisplayObject(target).globalToLocal(toolRectangle.topLeft);
				var newPoint2:Point = DisplayObject(target).localToGlobal(toolRectangle.topLeft);
				var newPoint:Point = DisplayObject(target.parent).globalToLocal(toolRectangle.topLeft);
				var newPoint2:Point = DisplayObject(target.parent).localToGlobal(toolRectangle.topLeft);
				var newPoint:Point = DisplayObject(targetSpace).globalToLocal(toolRectangle.topLeft);
				var newPoint2:Point = DisplayObject(targetSpace).localToGlobal(toolRectangle.topLeft);
				var newPoint:Point = DisplayObject(targetSpace).globalToLocal(new Point());
				var newPoint2:Point = DisplayObject(targetSpace).localToGlobal(new Point());
				*/
				//rectangle = GroupBase(target).getBounds(target.parent);
				
				if (true) {
					visibleRectangle = GroupBase(target).getVisibleRect(toolLayer);
				}
				
				var targetWidth:Number;
				var targetHeight:Number;
				
				if (toolRectangle.x<0) {
					targetWidth = toolRectangle.width+toolRectangle.x;
				}
				else {
					targetWidth = toolRectangle.width-1;
				}
				
				if (toolRectangle.y<0) {
					targetHeight = toolRectangle.height+toolRectangle.y;
				}
				else {
					targetHeight = toolRectangle.height-1;
				}
				
				// size and position fill
				targetSelectionGroup.width = showContentSize ? GroupBase(target).contentWidth : toolRectangle.width;
				targetSelectionGroup.height = showContentSize ? GroupBase(target).contentHeight : toolRectangle.height;
				targetSelectionGroup.width = showContentSize ? GroupBase(target).contentWidth : targetWidth;
				targetSelectionGroup.height = showContentSize ? GroupBase(target).contentHeight : targetHeight;
				
				if (!localTargetSpace) {
					visibleRectangle = GroupBase(target).getVisibleRect(toolLayer);
				}
				
				targetSelectionGroup.x = toolRectangle.x<0? -1:toolRectangle.x;
				targetSelectionGroup.y = toolRectangle.y<0? -1:toolRectangle.y;
				//targetSelectionGroup.x = -1;//toolRectangle.x;
				//targetSelectionGroup.y = -1;//toolRectangle.y;
				//trace("target is groupbase");
			}
			else if (target is Image) {
				
				if (targetCoordinateSpace && "systemManager" in targetCoordinateSpace
					&& Object(targetCoordinateSpace).systemManager!=target.systemManager) {
					isEmbeddedCoordinateSpace = true;
				}
				
				if (!targetCoordinateSpace ) targetCoordinateSpace = target.parent; 
				
			
				// if target is IMAGE it can be sized to 6711034.2 width or height at times!!! 6710932.2
				// possibly because it is not ready. there is a flag _ready that is false
				// also sourceWidth and sourceHeight are NaN at first
					
				trace("targetCoordinateSpace="+Object(targetCoordinateSpace).id);
				trace("targetCoordinateSpace owner="+Object(targetCoordinateSpace).owner.id);
				trace("x=" + target.x);
				trace("y=" + target.y);
				trace("w=" + target.width);
				trace("h=" + target.height);
				//if (!localTargetSpace) {
				/*	rectangle = UIComponent(target).getVisibleRect();
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace);
					rectangle = UIComponent(target).getVisibleRect(target.parent);
					rectangle = UIComponent(target).getVisibleRect(targetApplication.parent);
					rectangle = UIComponent(target).getVisibleRect(Object(targetCoordinateSpace).owner);
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace.parent);
				*/
				target.validateNow();
				
				rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
				
				if (rectangle.width==0 || rectangle.height==0
					|| rectangle.x>100000 || rectangle.y>100000) {
					
					//Radiate.info("Image not returning correct bounds");
					/*
					target.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(IOErrorEvent.IO_ERROR, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, setSelectionLaterHandler, false, 0, true);
					*/
					//target.imageDisplay.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
					//target.imageDisplay.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
					
					// size and position fill
					//targetSelectionGroup.width = 0;//rectangle.width;//UIComponent(target).getLayoutBoundsWidth();
					//targetSelectionGroup.height = 0;//rectangle.height; // UIComponent(target).getLayoutBoundsHeight();
					//targetSelectionGroup.x = 0;//rectangle.x;
					//targetSelectionGroup.y = 0;//rectangle.y;
					isTargetInvalid = true;
				}
				else {
					
					/*rectangle = UIComponent(target).getBounds(target.parent);
					rectangle = UIComponent(target).getBounds(target.owner);
					rectangle = UIComponent(target).getBounds(targetCoordinateSpace.parent);
					rectangle = UIComponent(target).getBounds(null);*/
				//}
				//else {
					
					/*rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
					rectangle = UIComponent(target).getBounds(target.parent);
					rectangle = UIComponent(target).getBounds(targetApplication as DisplayObject);
					rectangle = UIComponent(target).getBounds(targetApplication.parent);
					var s:Number = UIComponent(target).getLayoutBoundsWidth();
					s= UIComponent(target).getLayoutBoundsHeight();
					s= UIComponent(target).getLayoutBoundsX();
					s= UIComponent(target).getLayoutBoundsY();*/
				//}
					
					// size and position fill
					targetSelectionGroup.width = rectangle.width;//UIComponent(target).getLayoutBoundsWidth();
					targetSelectionGroup.height = rectangle.height; // UIComponent(target).getLayoutBoundsHeight();
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = rectangle.x;
					targetSelectionGroup.y = rectangle.y;
				}
				
			}
			// get target bounds
			else if (target is UIComponent) {
				if (!targetCoordinateSpace) {
					targetCoordinateSpace = target.parent; 
				}
				
				if (!localTargetSpace) {
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace);
				}
				else {
					// if target is IMAGE it can be sized to 6711034.2 width or height at times!!! 6710932.2
					rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
				}
				
				// size and position fill
				targetSelectionGroup.width = rectangle.width;
				targetSelectionGroup.height = rectangle.height;
				//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
				targetSelectionGroup.x = rectangle.x;
				targetSelectionGroup.y = rectangle.y;
				//trace("target is uicomponent");
			}
			// get target bounds
			else if (target is IGraphicElement) {
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent; 
				
				/*if (!localTargetSpace) {
					rectangle = IGraphicElement(target).getLayoutBoundsHeight();
				}
				else {
					rectangle = IGraphicElement(target).getBounds(targetCoordinateSpace);
				}*/
				
				// size and position fill
				targetSelectionGroup.width = IGraphicElement(target).getLayoutBoundsWidth();
				targetSelectionGroup.height = IGraphicElement(target).getLayoutBoundsHeight();
				//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
				targetSelectionGroup.x = IGraphicElement(target).getLayoutBoundsX();
				targetSelectionGroup.y = IGraphicElement(target).getLayoutBoundsY();
				//trace("target is uicomponent");
			}
			
			else {
				if (!localTargetSpace) {
					rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
				}
				else {
					rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
				}
				
				// size and position fill
				targetSelectionGroup.width = rectangle.width;
				targetSelectionGroup.height = rectangle.height;
				targetSelectionGroup.x = rectangle.x;
				targetSelectionGroup.y = rectangle.y;
				//trace("target is not uicomponent");
			}
			
			// we set to the target so we can display target name and size in label above selection
			targetSelectionGroup.data = target;
			
			
			// unhide target selection group
			if (isTargetInvalid) {
				targetSelectionGroup.visible = false;
			}
			
			else if (!targetSelectionGroup.visible) {
				targetSelectionGroup.visible = true;
			}
		}
		
		/**
		 * When waiting for images to display we need to update the selection after the image loads
		 * */
		public function setSelectionLaterHandler(event:Event):void {
			var targets:Array = radiate.targets;
			//trace("Event:"+event.type);
			// we are referencing the 
			if (targets.indexOf(lastTarget)!=-1 && event.type==Event.COMPLETE) {
				//radiate.target.validateNow();
				updateSelectionAroundTarget(radiate.target);
			}
			
			
			/*if (event.type==FlexEvent.READY) {
				Radiate.info("Removing Ready listener for " + event.currentTarget);
				event.currentTarget.removeEventListener(FlexEvent.READY, setSelectionLaterHandler);
			}
			else if (event.type==Event.COMPLETE) {
				Radiate.info("Removing Complete listener for " + event.currentTarget);
				event.currentTarget.removeEventListener(Event.COMPLETE, setSelectionLaterHandler);
			}*/
		}
		
		public function updateSelectionLater(target:Object = null):void {
			if (target==null) {
				target = radiate.target;
			}
			
			DeferManager.callAfter(5, updateSelectionAroundTarget, target);
			DeferManager.callAfter(5, updateTransformRectangle, target);
		}
		
		public function updateSelection(target:Object = null):void {
			if (target==null) {
				target = radiate.target;
			}
			
			updateSelectionAroundTarget(target);
			updateTransformRectangle(target);
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():Selection
		{
			if (!_instance) {
				_instance = new Selection(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():Selection {
			return instance;
		}
		
		private static var _instance:Selection;
	}
}

class SINGLEDOUBLE{}