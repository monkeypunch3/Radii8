package com.flexcapacitor.managers {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.tools.Hand;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.log;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import mx.containers.TabNavigator;
	import mx.core.FTETextField;
	import mx.core.FlexGlobals;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerGlobals;
	import mx.utils.Platform;
	
	import spark.components.Application;
	import spark.components.ComboBox;
	import spark.components.RichEditableText;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.core.IEditableText;
	
	public class KeyboardManager {
		
		public function KeyboardManager(s:SINGLEDOUBLE) {
			
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():KeyboardManager
		{
			if (!_instance) {
				_instance = new KeyboardManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():KeyboardManager {
			return instance;
		}
		
		private static var _instance:KeyboardManager;
		
		public var radiate:Radiate;
		public var clipboardManager:ClipboardManager;
		public var spaceBarDown:Boolean;
		public var application:Application;
		public var FlexHTMLLoader:Class;
		public var debug:Boolean;
		public var stage:Stage;
		
		public function initialize(application:Application, HTMLClass:* = null):void {
			this.application = application;
			var useCapture:Boolean = true;
			var weakListener:Boolean = true;
			stage = getCurrentStage(application);
			
			application.addEventListener(KeyboardEvent.KEY_UP, application_keyUpHandler, useCapture, 0, weakListener);
			//application.addEventListener(KeyboardEvent.KEY_DOWN, application_keyDownHandler, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, application_keyDownHandler, useCapture, 0, weakListener);
			application.systemManager.addEventListener(KeyboardEvent.KEY_DOWN, application_keyDownHandler, useCapture, 0, weakListener);
			//application.stage.addEventListener(Event.PASTE, application_PasteHandler, false, 0, true);
			
			stage.addEventListener(Event.COPY, copyHandler, useCapture, 0, weakListener);
			stage.addEventListener(Event.PASTE, pasteHandler, useCapture, 0, weakListener);
			
			FlexHTMLLoader = HTMLClass;
		}
		
		protected function application_keyDownHandler(event:KeyboardEvent):void {
			var componentDescription:ComponentDescription;
			var applicable:Boolean;
			var focusedObject:Object;
			var isApplication:Boolean;
			var target:Object;
			var ctrlKey:Boolean;
			var keyCode:int;
			var actionOccurred:Boolean;
			var applicableKeys:Array;
			
			if (debug) {
				log("Key: " + event.keyCode);
			}
			
			ctrlKey = event.ctrlKey || ("commandKey" in event && event.commandKey);
			keyCode = event.keyCode;
			
			if (radiate==null) {
				radiate = Radiate.getInstance();
			}
			
			if (clipboardManager==null) {
				clipboardManager = ClipboardManager.getInstance();
			}
			
			// prevent key repeat
			if (spaceBarDown) {
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
			}
			
			// Z = 90
			// C = 67
			// left = 37
			// right = 39
			// up = 38
			// down = 40 
			// backspace = 8
			// delete = 46
			// minus = 189
			// equal = 187
			// command = 15
			// control = 17
			
			applicableKeys = [	Keyboard.V, 
								Keyboard.Z, 
								Keyboard.I, 
								Keyboard.H, 
								Keyboard.T,
								Keyboard.M, 
								Keyboard.Y, 
								Keyboard.BACKSPACE, 
								Keyboard.DELETE, 
								Keyboard.MINUS, 
								Keyboard.EQUAL, 
								Keyboard.SPACE
							 ];
			
			
			if (applicableKeys.indexOf(keyCode)!=-1) {
				
				// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
				//	at flash.desktop::Clipboard/getObjectReference()
				//	at flash.desktop::Clipboard/convertNativeFormat()
				//	at flash.desktop::Clipboard/getOriginal()
				//	at flash.desktop::Clipboard/getData()
				//	at com.flexcapacitor.managers::ClipboardManager/pasteItem()
				
				//keyCode==Keyboard.X ||
				//keyCode==Keyboard.C ||
				//keyCode==Keyboard.V ||
				
				if (Platform.isAir) {
					if (!ctrlKey) {
						applicable = true;
					}
				}
				else {
					if (!event.ctrlKey) {
						if ("commandKey" in event) {
							if (!event.commandKey) {
								applicable = true;
							}
						}
						else {
							applicable = true;
						}
					}
					
					// copy, cut, paste
					// can't listen for paste in browser bc of security sandbox - see above
					if (keyCode==Keyboard.C || keyCode==Keyboard.X || keyCode==Keyboard.V) {
						if (ctrlKey) {
							//applicable = true;
						}
					}
					
				}
				
				// undo redo
				if (keyCode==Keyboard.Z && ctrlKey && !event.shiftKey) {
					// undo 
					applicable = true;
				}
				else if (keyCode==Keyboard.Z && ctrlKey && event.shiftKey) {
					// redo
					applicable = true;
				}
				else if (keyCode==Keyboard.Y && ctrlKey) {
					// legacy redo
					applicable = true;
				}
				else if (keyCode==Keyboard.MINUS && ctrlKey) {
					// zoom out
					applicable = true;
				}
				else if (keyCode==Keyboard.EQUAL && ctrlKey) {
					// zoom out
					applicable = true;
				}
			}
			
			if (!applicable) return;
			
			focusedObject = application.focusManager.getFocus();
			target = event.target;
			
			if (focusedObject is Application || event.target is Stage) {
				isApplication = true;
			}
			
			//var t:int = getTimer();
			// not sure if this is expensive... todo performance test
			// would like to take out textfield and ftetextfield check
			if (target is RichEditableText ||
				focusedObject is IEditableText ||
				focusedObject is SkinnableTextBase ||
				focusedObject is TextField ||
				focusedObject is FTETextField ||
				focusedObject is ComboBox) {
				applicable = false;
			}
			
			if (FlexHTMLLoader!=null && focusedObject is FlexHTMLLoader) {
				applicable = false;
			}
			
			//trace("time:" + (getTimer() - t)); takes 0 ms
			
			// names are in tools-manifest.xml
			if (applicable) {
				
				
				// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
				//	at flash.desktop::Clipboard/getObjectReference()
				//	at flash.desktop::Clipboard/convertNativeFormat()
				//	at flash.desktop::Clipboard/getOriginal()
				//	at flash.desktop::Clipboard/getData()
				//	at com.flexcapacitor.managers::ClipboardManager/pasteItem()
				
				// copy cut paste
				if (keyCode==Keyboard.C && ctrlKey) {
					//clipboardManager.copyItem(radiate.target, radiate.selectedDocument);
				}
				else if (keyCode==Keyboard.X && ctrlKey) {
					//clipboardManager.cutItem(radiate.target, radiate.selectedDocument);
				}
				else if (keyCode==Keyboard.V && ctrlKey) {
					//clipboardManager.pasteItem(radiate.target, radiate.selectedDocument);
				}
				
				
				// undo 
				if (keyCode==Keyboard.Z && !event.shiftKey && ctrlKey) {
					HistoryManager.undo(radiate.selectedDocument, true);
					actionOccurred = true;
				}
				// redo
				else if (keyCode==Keyboard.Z && event.shiftKey && ctrlKey) {
					HistoryManager.redo(radiate.selectedDocument, true);
					actionOccurred = true;
				}
				// legacy redo
				else if (keyCode==Keyboard.Y && ctrlKey) {
					HistoryManager.redo(radiate.selectedDocument, true);
					actionOccurred = true;
				}
				// delete selected element
				else if (keyCode==Keyboard.BACKSPACE || keyCode==Keyboard.DELETE) {
					Radiate.removeElement(radiate.targets);
					Radiate.callLater(Radiate.updateSelection, [radiate.selectedDocument]);
					actionOccurred = true;
				}
				// zoom in or out
				else if (keyCode==Keyboard.MINUS && ctrlKey) {
					Radiate.instance.decreaseScale();
					actionOccurred = true;
				}
				else if (keyCode==Keyboard.EQUAL && ctrlKey) {
					Radiate.instance.increaseScale();
					actionOccurred = true;
				}
				// switch tools
				else if (keyCode==Keyboard.V) {
					componentDescription = radiate.getToolByName("Selection");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
					
					actionOccurred = true;
				}
				else if (keyCode==Keyboard.Z) {
					componentDescription = radiate.getToolByName("Zoom");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
					
					actionOccurred = true;
				}
				else if (keyCode==Keyboard.T) {
					componentDescription = radiate.getToolByName("Text");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
					
					actionOccurred = true;
				}
				else if (keyCode==Keyboard.I) {
					componentDescription = radiate.getToolByName("EyeDropper");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
					
					actionOccurred = true;
				}
				else if (keyCode==Keyboard.M) {
					componentDescription = radiate.getToolByName("Marquee");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
					
					actionOccurred = true;
				}
				// switching temporarily to move tool
				else if (keyCode==Keyboard.H || keyCode==Keyboard.SPACE) {
					componentDescription = radiate.getToolByName("Hand");
					
					if (componentDescription) {
						if (keyCode==Keyboard.SPACE) {
							spaceBarDown = true;
							//trace("setting temp hand cursor");
							radiate.saveCurrentTool();
							radiate.setTool(componentDescription.instance as ITool);
							Hand(componentDescription.instance).updateMouseCursor(true);
						}
						else {
							radiate.setTool(componentDescription.instance as ITool);
						}
					}
					
					actionOccurred = true;
				}
			}
			
			if (actionOccurred) {
				event.preventDefault();
				event.stopImmediatePropagation();
			}
		}
		
		protected function application_keyUpHandler(event:KeyboardEvent):void {
			var keyCode:int = event.keyCode;
			var componentDescription:ComponentDescription;
			var applicable:Boolean;
			var focusedObject:Object;
			var isApplication:Boolean;
			var target:Object = event.target;
			
			// prevent repeat key events in key down
			spaceBarDown = false;
			
			if (keyCode==Keyboard.SPACE) {
				applicable = true;
			}
			
			if (!applicable) return;
			
			focusedObject = application.focusManager.getFocus();
			
			
			if (target is RichEditableText ||
				focusedObject is IEditableText ||
				focusedObject is SkinnableTextBase ||
				focusedObject is TextField ||
				focusedObject is FTETextField ||
				focusedObject is ComboBox) {
				applicable = false;
			}
			
			if (FlexHTMLLoader && focusedObject is FlexHTMLLoader) {
				applicable = false;
			}
			
			// names are in tools-manifest.xml
			if (applicable) {
				if (keyCode==Keyboard.SPACE) {
					
					radiate.restoreTool();
				}
			}
			
		}
		
		public function copyHandler(event:Event):void {
			var applicable:Boolean;
			applicable = isEventApplicable(event);
			
			if (debug) {
				log("Is applicable: " + applicable);
			}
			
			// this is a hack - if graphic element is selected then we say it's applicable
			// because it does not have focus - need to refactor
			if (applicable) {
				clipboardManager.copyItem(radiate.target, radiate.selectedDocument);
			}
			else {
				//dispatchEditEvent(event, COPY);
			}
		}
		
		public function pasteHandler(event:Event):void {
			var applicable:Boolean = isEventApplicable(event);
			
			if (debug) {
				log("Is applicable: " + applicable);
			}
			
			// this is a hack - if graphic element is selected then we say it's applicable
			// because it will not register as having focus - need to refactor
			if (applicable) {
				clipboardManager.pasteItem(radiate.target, radiate.selectedDocument);
			}
			else {
				//dispatchEditEvent(event, PASTE);
			}
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
			var tabNav:TabNavigator = radiate.documentsTabNavigator;
			var isGraphicElement:Boolean;
			var targetApplication:Object = radiate.selectedDocument ? radiate.selectedDocument.instance : null;
			
			// still working on this
			
			if (focusedObject is Application || event.target is Stage) {
				if (targetApplication) {
					return true;
				}
			}
			
			if (targetApplication && DisplayObjectContainer(targetApplication).contains(event.target as DisplayObject)) {
				return true;
			}
			
			if (eventTarget==tabNav) {
				return true;
			}
			
			return false;
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
	}
}

class SINGLEDOUBLE{}