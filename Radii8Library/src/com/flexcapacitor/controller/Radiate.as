/**
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

package com.flexcapacitor.controller {
	import com.flexcapacitor.components.DocumentContainer;
	import com.flexcapacitor.components.IDocumentContainer;
	import com.flexcapacitor.controls.Hyperlink;
	import com.flexcapacitor.controls.RichTextEditorBar;
	import com.flexcapacitor.effects.core.CallMethod;
	import com.flexcapacitor.effects.core.PlayerType;
	import com.flexcapacitor.effects.file.LoadFile;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.events.HTMLDragEvent;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.formatters.HTMLFormatterTLF;
	import com.flexcapacitor.logging.RadiateLogTarget;
	import com.flexcapacitor.managers.ClipboardManager;
	import com.flexcapacitor.managers.CodeManager;
	import com.flexcapacitor.managers.ComponentManager;
	import com.flexcapacitor.managers.CreationManager;
	import com.flexcapacitor.managers.DeviceManager;
	import com.flexcapacitor.managers.FontManager;
	import com.flexcapacitor.managers.HistoryEffect;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.managers.KeyboardManager;
	import com.flexcapacitor.managers.ScaleManager;
	import com.flexcapacitor.managers.ServicesManager;
	import com.flexcapacitor.managers.SettingsManager;
	import com.flexcapacitor.managers.SnippetManager;
	import com.flexcapacitor.managers.ToolManager;
	import com.flexcapacitor.managers.ViewManager;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.Device;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.DocumentDescription;
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.EventMetaData;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.HTMLDragData;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.HistoryEventData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IDocumentMetaData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.IProjectData;
	import com.flexcapacitor.model.ISavable;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.ImportOptions;
	import com.flexcapacitor.model.InspectableClass;
	import com.flexcapacitor.model.InspectorData;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.MenuItem;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.Project;
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.model.SavedData;
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.StyleMetaData;
	import com.flexcapacitor.model.TranscoderDescription;
	import com.flexcapacitor.model.ValuesObject;
	import com.flexcapacitor.model.WarningData;
	import com.flexcapacitor.performance.PerformanceMeter;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPAttachmentService;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.services.WPServiceEvent;
	import com.flexcapacitor.states.AddItems;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Text;
	import com.flexcapacitor.utils.ArrayUtils;
	import com.flexcapacitor.utils.Base64;
	import com.flexcapacitor.utils.ClassLoader;
	import com.flexcapacitor.utils.ClassRegistry;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.DocumentTranscoder;
	import com.flexcapacitor.utils.DragManagerUtil;
	import com.flexcapacitor.utils.FontUtils;
	import com.flexcapacitor.utils.HTMLDragManager;
	import com.flexcapacitor.utils.LayoutDebugHelper;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.MXMLDocumentImporter;
	import com.flexcapacitor.utils.PersistentStorage;
	import com.flexcapacitor.utils.PopUpOverlayManager;
	import com.flexcapacitor.utils.SVGUtils;
	import com.flexcapacitor.utils.SharedObjectUtils;
	import com.flexcapacitor.utils.TextFieldHTMLExporter2;
	import com.flexcapacitor.utils.TypeUtils;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.FileData;
	import com.flexcapacitor.views.IInspector;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.Remote;
	import com.flexcapacitor.views.windows.ImportWindow;
	import com.google.code.flexiframe.IFrame;
	
	import flash.debugger.enterDebugger;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.JointStyle;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.globalization.DateTimeStyle;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ListCollectionView;
	import mx.containers.Canvas;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.TabNavigator;
	import mx.controls.Alert;
	import mx.controls.ColorPicker;
	import mx.controls.LinkButton;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.DeferredInstanceFromFunction;
	import mx.core.DragSource;
	import mx.core.IFlexModuleFactory;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.IEffect;
	import mx.effects.Sequence;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.managers.ISystemManager;
	import mx.managers.LayoutManager;
	import mx.managers.SystemManagerGlobals;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	import mx.styles.IStyleClient;
	import mx.utils.ArrayUtil;
	import mx.utils.NameUtil;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Application;
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.ContentBackgroundAppearance;
	import spark.components.DropDownList;
	import spark.components.Grid;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.NumericStepper;
	import spark.components.RichEditableText;
	import spark.components.RichText;
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	import spark.components.TextSelectionHighlighting;
	import spark.components.supportClasses.DropDownListBase;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.components.supportClasses.SliderBase;
	import spark.components.supportClasses.TextBase;
	import spark.components.supportClasses.ToggleButtonBase;
	import spark.core.ContentCache;
	import spark.core.IGraphicElement;
	import spark.core.IViewport;
	import spark.core.SpriteVisualElement;
	import spark.events.PopUpEvent;
	import spark.events.TextOperationEvent;
	import spark.formatters.DateTimeFormatter;
	import spark.layouts.BasicLayout;
	import spark.primitives.BitmapImage;
	import spark.primitives.Ellipse;
	import spark.primitives.Line;
	import spark.primitives.Path;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.primitives.supportClasses.StrokedElement;
	import spark.skins.spark.DefaultGridItemRenderer;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;
	
	import org.as3commons.lang.DictionaryUtils;
	import org.as3commons.lang.ObjectUtils;
	import com.flexcapacitor.managers.TextEditorManager;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched on history change
	 * */
	[Event(name="historyChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on beginning of undo history
	 * */
	[Event(name=RadiateEvent.BEGINNING_OF_UNDO_HISTORY, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on end of undo history
	 * */
	[Event(name=RadiateEvent.END_OF_UNDO_HISTORY, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when namespaces have loaded
	 * */
	[Event(name=RadiateEvent.NAMESPACES_LOADED, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when register results are received
	 * */
	[Event(name="registerResults", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a print job is cancelled
	 * */
	[Event(name="printCancelled", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is added to the target
	 * */
	[Event(name="addItem", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeItem", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeTarget", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the target is changed
	 * */
	[Event(name="targetChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the documentation url is changed
	 * */
	[Event(name="documentationChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document is changed
	 * */
	[Event(name="documentChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is opening
	 * */
	[Event(name="documentOpening", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is opened
	 * */
	[Event(name="documentOpen", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is closed
	 * */
	[Event(name=RadiateEvent.DOCUMENT_CLOSE, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a console value is changed
	 * */
	[Event(name="consoleValueChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is renamed
	 * */
	[Event(name="documentRename", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is changed
	 * */
	[Event(name="projectChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is deleted
	 * */
	[Event(name="projectDeletedResults", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is created
	 * */
	[Event(name="projectCreated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property on the target is changed. 
	 * Using propertyChanged instead of propertyChange because of error with bindable
	 * tag using propertyChange:
	 * TypeError: Error #1034: Type Coercion failed: cannot convert mx.events::PropertyChangeEvent@11d2187b1 to com.flexcapacitor.events.RadiateEvent.
	 * */
	[Event(name="propertyChanged", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property is selected on the target
	 * */
	[Event(name="propertySelected", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property edit is requested
	 * */
	[Event(name="propertyEdit", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the tool changes
	 * */
	[Event(name="toolChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the scale changes
	 * */
	[Event(name="scaleChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document size or scale changes
	 * */
	[Event(name="documentSizeChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document preview uncaught event occurs
	 * */
	[Event(name="uncaughtExceptionEvent", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Not used yet. 
	 * */
	[Event(name="initialized", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Used when the tools list has been updated. 
	 * */
	[Event(name="toolsUpdated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Used when the components list is updated. 
	 * */
	[Event(name="componentsUpdated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Used when the document canvas is updated. 
	 * */
	[Event(name="canvasChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Event to request a preview if available. Used for HTML preview. 
	 * */
	[Event(name="requestPreview", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the generated code is updated. 
	 * */
	[Event(name="codeUpdated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a color is selected. 
	 * */
	[Event(name="colorSelected", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an object is selected 
	 * */
	[Event(name="objectSelected", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an external asset such as an image is loaded 
	 * */
	[Event(name="assetLoaded", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Main class and API that handles the interactions between the view and the models. <br/><br/>
	 * 
	 * Dispatches events and exposes methods to manipulate the documents.<br/><br/>
	 *  
	 * It contains a list of components, tools, devices, inspectors (panels), assets and 
	 * in the future we should add skins, effects and so on. 
	 * These items are created from an XML file at startup so we can configure what is available
	 * to our user or project. We do this so we can also load in a remote SWF to add 
	 * additional components, sounds, images, skins, inspectors, fonts, etc<br/><br/>
	 * 
	 * Currently we are saving and loading to a remote location or to a local shared object. 
	 * To save to a local file system we will need to modify these functions. <br/><br/>
	 * 
	 * This class supports an Undo / Redo history. The architecture is loosely based on 
	 * the structure found in the Effects classes. We may want to be a proxy to the documents
	 * and call undo and redo on them since we would like to support more than one 
	 * type of document. <br/><br/>
	 * 
	 * This class can be broken up into multiple classes since it is also handling 
	 * saving and loading and services. <br/><br/>
	 * 
	 * To set a property or style call setProperty or setStyle. <br/>
	 * To add a component call addElement. <br/>
	 * To log a message to the console call Radiate.info() or error().<br/><br/>
	 * 
	 * To undo call undo<br/>
	 * To redo call redo<br/><br/>
	 * 
	 * To get the history index access history index<br/>
	 * To check if history exists call the has history<br/>
	 * To check if undo can be performed access has undo<br/>
	 * To check if redo can be performed access has redo <br/><br/>
	 * 
	 * 
	 * */
	public class Radiate extends EventDispatcher {
		
		public static const SAME_OWNER:String = "sameOwner";
		public static const SAME_PARENT:String = "sameParent";
		public static const ADDED:String = "added";
		public static const MOVED:String = "moved";
		public static const REMOVED:String = "removed";
		public static const ADD_ERROR:String = "addError";
		public static const REMOVE_ERROR:String = "removeError";
		public static const RADIATE_LOG:String = "radiate";
		
		public static const USER_STORE:String = "userStore";
		public static const TRANSFER_STORE:String = "transferStore";
		public static const RELEASE_DIRECTORY_STORE:String = "releaseDirectoryStore";
		
		public function Radiate(s:SINGLEDOUBLE) {
			super(target as IEventDispatcher);
			
			// initialize - maybe call on startup() instead
			if (!initialized) {
				initialize();
			}
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		private static var _instance:Radiate;

		private static var initialized:Boolean;
		
		/**
		 * Attempt to support a console part 2
		 * */
		public static function get log():ILogger {
			
			if (_log) {
				return _log;
			}
			else {
				setLoggingTarget(defaultLogTarget);
				return _log;
			}
		}

		/**
		 * @private
		 */
		public static function set log(value:ILogger):void {
			_log = value;
		}

		/**
		 * Attempt to support a console part 3
		 * */
		public static function get console():Object {
			return _console;
		}

		/**
		 * @private
		 */
		public static function set console(value:Object):void {
			_console = value;
			
			if ("console" in logTarget) {
				logTarget["console"] = value;
			}
		}

		public static function get instance():Radiate
		{
			if (!_instance) {
				_instance = new Radiate(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():Radiate {
			return instance;
		}
		
		private static var historyManager:HistoryManager;
		private static var popUpOverlayManager:PopUpOverlayManager;
		private static var serviceManager:ServicesManager;
		private static var clipboardManager:ClipboardManager;
		private static var snippetManager:SnippetManager;
		private static var keyboardManager:KeyboardManager;
		
		[Bindable]
		public static var fontsArray:Array;
		
		public var bitmapDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Create references for classes we need.
		 * */
		public static var radiateReferences:RadiateReferences;
		
		/**
		 * Is running on desktop
		 * */
		public static function get isDesktop():Boolean
		{
			return Capabilities.playerType == PlayerType.DESKTOP;
		}
		
		/**
		 * If true then importing document
		 * */
		public static var importingDocument:Boolean;
		
		/**
		 * Editor source data
		 * */
		public var editorSource:SourceData;
		
		/**
		 * Export file location if one is selected
		 * */
		public var exportFileLocation:FileReference;
		
		/**
		 * Upload attachment
		 * */
		public var uploadAttachmentService:WPAttachmentService;
		
		/**
		 * Service to get list of attachments
		 * */
		public var getAttachmentsService:WPService;
		
		/**
		 * Service to get list of projects
		 * */
		public var getProjectsService:WPService;
		
		/**
		 * Service to delete attachments
		 * */
		public var deleteAttachmentsService:WPService;
		
		/**
		 * Service to delete attachment
		 * */
		public var deleteAttachmentService:WPService;
		
		/**
		 * Service to delete document
		 * */
		public var deleteDocumentService:WPService;
		
		/**
		 * Service to delete project
		 * */
		public var deleteProjectService:WPService;
		
		/**
		 * Set to true when a document is being saved to the server
		 * */
		[Bindable]
		public var saveDocumentInProgress:Boolean;
		
		/**
		 * Set to true when project is being saved to the server
		 * */
		[Bindable]
		public var saveProjectInProgress:Boolean;
		
		/**
		 * Set to true when deleting a project
		 * */
		[Bindable]
		public var deleteProjectInProgress:Boolean;
		
		/**
		 * Set to true when deleting a document
		 * */
		[Bindable]
		public var deleteDocumentInProgress:Boolean;
		
		/**
		 * When deleting a document this is the id of the project it was part of
		 * since you need to save the project after a delete.
		 * */
		[Bindable]
		public var deleteDocumentProjectId:int;
		
		/**
		 * When deleting a document 
		 * you need to save the project after. Set this to true to save 
		 * after results are in from document delete call.
		 * */
		[Bindable]
		public var saveProjectAfterDelete:Boolean;
		
		/**
		 * Set to true when deleting an attachment
		 * */
		[Bindable]
		public var deleteAttachmentInProgress:Boolean;
		
		/**
		 * Set to true when deleting attachments
		 * */
		[Bindable]
		public var deleteAttachmentsInProgress:Boolean;
		
		/**
		 * Set to true when getting list of attachments
		 * */
		[Bindable]
		public var getAttachmentsInProgress:Boolean;
		
		/**
		 * Set to true when uploading an attachment
		 * */
		[Bindable]
		public var uploadAttachmentInProgress:Boolean;
		
		/**
		 * Set to true when getting list of projects
		 * */
		[Bindable]
		public var getProjectsInProgress:Boolean;
		
		/**
		 * Is user logged in
		 * */
		[Bindable]
		public var isUserLoggedIn:Boolean;
		
		/**
		 * Default storage location for save and load. 
		 * */
		[Bindable]
		public var defaultStorageLocation:String;
		
		/**
		 * Application menu
		 * */
		[Bindable]
		public var applicationMenu:Object;
		
		/**
		 * Application window menu
		 * */
		[Bindable]
		public var applicationWindowMenu:Object;
		
		/**
		 * Can user connect to the service
		 * */
		[Bindable]
		public var isUserConnected:Boolean;
		
		/**
		 * Is the user online
		 * */
		[Bindable]
		public var isUserOnline:Boolean;
		
		/**
		 * Avatar of user
		 * */
		[Bindable]
		public var userAvatar:String = "assets/images/icons/gravatar.png";
		
		/**
		 * Path to default avatar of user (from Gravatar)
		 * Gravatars icons don't work locally so using path. 
		 * Default - http://0.gravatar.com/avatar/ad516503a11cd5ca435acc9bb6523536?s=96
		 * local - assets/images/icons/gravatar.png
		 * */
		[Bindable]
		public var defaultUserAvatarPath:String = "assets/images/icons/gravatar.png";
		
		/**
		 * User info
		 * */
		[Bindable]
		public var user:Object;
		
		/**
		 * User email
		 * */
		[Bindable]
		public var userEmail:String;
		
		/**
		 * User id
		 * */
		[Bindable]
		public var userID:int = -1;
		
		/**
		 * User name
		 * */
		[Bindable]
		public var username:String;
		
		/**
		 * Home page id
		 * */
		[Bindable]
		public var projectHomePageID:int = -1;
		
		/**
		 * User sites
		 * */
		[Bindable]
		public var userSites:Array = [];
		
		/**
		 * User site path
		 * */
		[Bindable]
		public var userSitePath:String;
		
		/**
		 * User display name
		 * */
		[Bindable]
		public var userDisplayName:String = "guest";
		
		/**
		 * Last save date formatted
		 * */
		[Bindable]
		public var lastSaveDateFormatted:String;
		
		/**
		 * Last save date 
		 * */
		[Bindable]
		public var lastSaveDate:Date;
		
		/**
		 * Last save date difference
		 * */
		[Bindable]
		public var lastSaveDateDifference:String;
		
		/**
		 * Last clipboard action. Either cut or copy;
		 * */
		public var lastClipboardAction:String;
		
		/**
		 * The different statuses a document can have
		 * Based on WordPress posts status, "draft", "publish", etc
		 * */
		[Bindable]
		public static var documentStatuses:ArrayCollection = new ArrayCollection();
		
		/**
		 * Auto save locations
		 * */
		[Bindable]
		public var autoSaveLocations:String;
		
		/**
		 * Open the design view at startup
		 * */
		public static var startInDesignView:Boolean;
		
		/**
		 * HTML Class
		 * */
		public static var htmlClass:Object;
		
		private var _enableAutoSave:Boolean;

		[Bindable]
		/**
		 * Auto save enabled
		 * */
		public function get enableAutoSave():Boolean {
			return _enableAutoSave;
		}

		/**
		 * @private
		 */
		public function set enableAutoSave(value:Boolean):void {
			_enableAutoSave = value;
			
			
			if (value) {
				if (!autoSaveEffect) {
					autoSaveEffect =  new CallMethod();
					autoSaveEffect.method = autoSaveHandler;
					autoSaveEffect.repeatCount = 0;
					autoSaveEffect.repeatDelay = autoSaveInterval;
				}
				if (!autoSaveEffect.isPlaying) {
					autoSaveEffect.play();
				}
			}
			else {
				autoSaveEffect.stop();
			}
		}
		
		/**
		 * Interval to check to save project. Default 2 minutes.
		 * */
		public var autoSaveInterval:int = 120000;
		
		/**
		 * Effect to auto save
		 * */
		public var autoSaveEffect:CallMethod;
		
		/**
		 * Handle auto saving 
		 * */
		public function autoSaveHandler():void {
			var numberOfAssets:int;
			var numberOfProjects:int;
			var iProject:IProject;
			var iDocumentData:IDocumentData;
			var iAttachmentData:AttachmentData;
			var imageData:ImageData;
			var i:int;
			
			// save documents
			/*length = documents.length;
			for (i=0;i<length;i++) {
				iDocumentData = documents[i] as IDocumentData;
				if (iDocumentData.isChanged && !iDocumentData.saveInProgress && iDocumentData.isOpen) {
					iDocumentData.save();
				}
			}*/
			
			// save projects
			numberOfProjects = projects.length;
			for (i=0;i<numberOfProjects;i++) {
				iDocumentData = projects[i] as IDocumentData;
				//if (iDocumentData.isChanged && !iDocumentData.saveInProgress && iDocumentData.isOpen) {
				if (!iDocumentData.saveInProgress && iDocumentData.isOpen) {
					iDocumentData.save();
				}
			}
			
			// do not autosave now
			return;
			
			if (uploadAttachmentInProgress) {
				return;
			}
			
			// save attachments
			numberOfAssets = assets.length;
			
			for (i=0;i<numberOfAssets;i++) {
				iAttachmentData = assets[i] as ImageData;
				
				if (iAttachmentData) {
					imageData = iAttachmentData as ImageData;
					
					if (!imageData.saveInProgress && imageData.id==null) {
						//imageData.save();
						if (imageData.byteArray==null) {
							uploadAttachment(imageData.bitmapData, selectedProject.id, imageData.name, null, imageData.contentType);
						}
						else {
							uploadAttachment(imageData.byteArray, selectedProject.id, imageData.name, null, imageData.contentType);
						}
					}
				}
			}
		}

		/**
		 * Build number
		 * */
		[Bindable]
		public var buildNumber:String;
		
		/**
		 * Build date
		 * */
		[Bindable]
		public var buildDate:String;
		
		/**
		 * Build time
		 * */
		[Bindable]
		public var buildTime:String;
		
		/**
		 * Version number
		 * */
		[Bindable]
		public var versionNumber:String;
		
		/**
		 * Reference to the application main view importPopUp
		 */
		[Bindable]
		public static var openImportPopUp:OpenPopUp;
		
		//----------------------------------
		//
		//  Events Management
		// 
		//----------------------------------
		
		/**
		 * Dispatch example projects list received results event
		 * */
		public function dispatchGetExampleProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent = new RadiateEvent(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED);
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch projects list received results event
		 * */
		public function dispatchGetProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent = new RadiateEvent(RadiateEvent.PROJECTS_LIST_RECEIVED);
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch print cancelled event
		 * */
		public function dispatchPrintCancelledEvent(data:Object, printJob:FlexPrintJob):void {
			var printCancelledEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PRINT_CANCELLED)) {
				printCancelledEvent = new RadiateEvent(RadiateEvent.PRINT_CANCELLED);
				printCancelledEvent.data = data;
				printCancelledEvent.selectedItem = printJob;
				dispatchEvent(printCancelledEvent);
			}
		}
		
		/**
		 * Dispatch print complete event
		 * */
		public function dispatchPrintCompleteEvent(data:Object, printJob:FlexPrintJob):void {
			var printCompleteEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PRINT_COMPLETE)) {
				printCompleteEvent = new RadiateEvent(RadiateEvent.PRINT_COMPLETE);
				printCompleteEvent.data = data;
				printCompleteEvent.selectedItem = printJob;
				dispatchEvent(printCompleteEvent);
			}
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchAttachmentsResultsEvent(successful:Boolean, attachments:Array):void {
			var attachmentsReceivedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_RECEIVED)) {
				attachmentsReceivedEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_RECEIVED, false, false, attachments);
				attachmentsReceivedEvent.successful = successful;
				attachmentsReceivedEvent.status = successful ? "ok" : "fault";
				attachmentsReceivedEvent.targets = ArrayUtil.toArray(attachments);
				dispatchEvent(attachmentsReceivedEvent);
			}
		}
		
		/**
		 * Dispatch upload attachment received event
		 * */
		public function dispatchUploadAttachmentResultsEvent(successful:Boolean, attachments:Array, data:Object, error:Object = null):void {
			var uploadAttachmentEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ATTACHMENT_UPLOADED)) {
				uploadAttachmentEvent = new RadiateEvent(RadiateEvent.ATTACHMENT_UPLOADED, false, false);
				uploadAttachmentEvent.successful = successful;
				uploadAttachmentEvent.status = successful ? "ok" : "fault";
				uploadAttachmentEvent.data = attachments;
				uploadAttachmentEvent.selectedItem = data;
				uploadAttachmentEvent.error = error;
				dispatchEvent(uploadAttachmentEvent);
			}
		}
		
		/**
		 * Dispatch feedback results event
		 * */
		public function dispatchFeedbackResultsEvent(successful:Boolean, data:Object):void {
			var feedbackResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.FEEDBACK_RESULT)) {
				feedbackResultsEvent = new RadiateEvent(RadiateEvent.FEEDBACK_RESULT);
				feedbackResultsEvent.data = data;
				feedbackResultsEvent.successful = successful;
				dispatchEvent(feedbackResultsEvent);
			}
		}
		
		/**
		 * Dispatch login results event
		 * */
		public function dispatchLoginResultsEvent(successful:Boolean, data:Object):void {
			var loginResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.LOGIN_RESULTS)) {
				loginResultsEvent = new RadiateEvent(RadiateEvent.LOGIN_RESULTS);
				loginResultsEvent.data = data;
				loginResultsEvent.successful = successful;
				dispatchEvent(loginResultsEvent);
			}
		}
		
		/**
		 * Dispatch logout results event
		 * */
		public function dispatchLogoutResultsEvent(successful:Boolean, data:Object):void {
			var logoutResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.LOGOUT_RESULTS)) {
				logoutResultsEvent = new RadiateEvent(RadiateEvent.LOGOUT_RESULTS);
				logoutResultsEvent.data = data;
				logoutResultsEvent.successful = successful;
				dispatchEvent(logoutResultsEvent);
			}
		}
		
		/**
		 * Dispatch register results event
		 * */
		public function dispatchRegisterResultsEvent(successful:Boolean, data:Object):void {
			var registerResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.REGISTER_RESULTS)) {
				registerResultsEvent = new RadiateEvent(RadiateEvent.REGISTER_RESULTS);
				registerResultsEvent.data = data;
				registerResultsEvent.successful = successful;
				dispatchEvent(registerResultsEvent);
			}
		}
		
		/**
		 * Dispatch change password results event
		 * */
		public function dispatchChangePasswordResultsEvent(successful:Boolean, data:Object):void {
			var changePasswordResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CHANGE_PASSWORD_RESULTS)) {
				changePasswordResultsEvent = new RadiateEvent(RadiateEvent.CHANGE_PASSWORD_RESULTS);
				changePasswordResultsEvent.data = data;
				changePasswordResultsEvent.successful = successful;
				dispatchEvent(changePasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch lost password results event
		 * */
		public function dispatchLostPasswordResultsEvent(successful:Boolean, data:Object):void {
			var lostPasswordResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.LOST_PASSWORD_RESULTS)) {
				lostPasswordResultsEvent = new RadiateEvent(RadiateEvent.LOST_PASSWORD_RESULTS);
				lostPasswordResultsEvent.data = data;
				lostPasswordResultsEvent.successful = successful;
				dispatchEvent(lostPasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch project deleted results event
		 * */
		public function dispatchProjectDeletedEvent(successful:Boolean, data:Object):void {
			var deleteProjectResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_DELETED)) {
				deleteProjectResultsEvent = new RadiateEvent(RadiateEvent.PROJECT_DELETED);
				deleteProjectResultsEvent.data = data;
				deleteProjectResultsEvent.successful = successful;
				deleteProjectResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteProjectResultsEvent);
			}
		}
		
		/**
		 * Dispatch document deleted results event
		 * */
		public function dispatchDocumentDeletedEvent(successful:Boolean, data:Object):void {
			var deleteDocumentResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_DELETED)) {
				deleteDocumentResultsEvent = new RadiateEvent(RadiateEvent.DOCUMENT_DELETED);
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteDocumentResultsEvent);
			}
		}
		
		/**
		 * Dispatch attachments deleted results event
		 * */
		public function dispatchAttachmentsDeletedEvent(successful:Boolean, data:Object):void {
			var deleteDocumentResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_DELETED)) {
				deleteDocumentResultsEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_DELETED);
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteDocumentResultsEvent);
			}
		}
		
		/**
		 * Dispatch component definition added 
		 * */
		public function dispatchComponentDefinitionAddedEvent(data:ComponentDefinition):void {
			var assetAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.COMPONENT_DEFINITION_ADDED)) {
				assetAddedEvent = new RadiateEvent(RadiateEvent.COMPONENT_DEFINITION_ADDED);
				assetAddedEvent.data = data;
				dispatchEvent(assetAddedEvent);
			}
		}
		
		/**
		 * Dispatch asset added event
		 * */
		public function dispatchAssetAddedEvent(data:Object):void {
			var assetAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSET_ADDED)) {
				assetAddedEvent = new RadiateEvent(RadiateEvent.ASSET_ADDED);
				assetAddedEvent.data = data;
				dispatchEvent(assetAddedEvent);
			}
		}
		
		/**
		 * Dispatch asset loaded event
		 * */
		public function dispatchAssetLoadedEvent(asset:Object, document:IDocument, resized:Boolean, successful:Boolean = true):void {
			var assetLoadedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSET_LOADED)) {
				assetLoadedEvent = new RadiateEvent(RadiateEvent.ASSET_LOADED);
				assetLoadedEvent.data = asset;
				assetLoadedEvent.selectedItem = document;
				assetLoadedEvent.resized = resized;
				assetLoadedEvent.successful = successful;
				dispatchEvent(assetLoadedEvent);
			}
		}
		
		/**
		 * Dispatch asset removed event
		 * */
		public function dispatchAssetRemovedEvent(data:IDocumentData, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSET_REMOVED)) {
				assetRemovedEvent = new RadiateEvent(RadiateEvent.ASSET_REMOVED);
				assetRemovedEvent.data = data;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		/**
		 * Dispatch assets removed event
		 * */
		public function dispatchAssetsRemovedEvent(attachments:Array, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSETS_REMOVED)) {
				assetRemovedEvent = new RadiateEvent(RadiateEvent.ASSETS_REMOVED);
				assetRemovedEvent.data = attachments;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		public static var SET_TARGET_TEST:String = "setTargetTest";
		/**
		 * Dispatch target change event
		 * */
		public function dispatchTargetChangeEvent(target:*, multipleSelection:Boolean = false, propertyName:String = null, propertyIndex:int = -1, subTarget:Object = null):void {
			if (importingDocument) return;
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE, false, false, target);
				targetChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				targetChangeEvent.subSelectedItem = subTarget;
				targetChangeEvent.targets = ArrayUtil.toArray(target);
				targetChangeEvent.property = propertyName;
				targetChangeEvent.propertyIndex = propertyIndex;
				PerformanceMeter.start(SET_TARGET_TEST, true, false);
				dispatchEvent(targetChangeEvent);
				PerformanceMeter.stop(SET_TARGET_TEST, false);
			}
		}
		
		/**
		 * Dispatch namespaces loaded event
		 * */
		public function dispatchNamespacesLoadedEvent(successful:Boolean = true):void {
			var assetLoadedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.NAMESPACES_LOADED)) {
				assetLoadedEvent = new RadiateEvent(RadiateEvent.NAMESPACES_LOADED);
				assetLoadedEvent.successful = successful;
				dispatchEvent(assetLoadedEvent);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public function dispatchHistoryChangeEvent(document:IDocument, newIndex:int, oldIndex:int, historyEvent:HistoryEventData = null):void {
			var event:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.HISTORY_CHANGE)) {
				event = new RadiateEvent(RadiateEvent.HISTORY_CHANGE);
				event.newIndex = newIndex;
				event.oldIndex = oldIndex;
				event.historyEvent = historyEvent ? historyEvent : null;
				event.targets = historyEvent ? historyEvent.targets : [];
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public function dispatchDocumentRebuiltEvent(document:IDocument):void {
			var event:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REBUILT)) {
				event = new RadiateEvent(RadiateEvent.DOCUMENT_REBUILT);
				//event.target = document;
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch scale change event
		 * */
		public function dispatchScaleChangeEvent(target:*, scaleX:Number = NaN, scaleY:Number = NaN):void {
			var scaleChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.SCALE_CHANGE)) {
				scaleChangeEvent = new RadiateEvent(RadiateEvent.SCALE_CHANGE, false, false, target);
				scaleChangeEvent.scaleX = scaleX;
				scaleChangeEvent.scaleY = scaleY;
				dispatchEvent(scaleChangeEvent);
			}
		}
		
		/**
		 * Dispatch document size change event
		 * */
		public function dispatchDocumentSizeChangeEvent(target:*):void {
			var sizeChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE)) {
				sizeChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SIZE_CHANGE, false, false, target);
				dispatchEvent(sizeChangeEvent);
			}
		}
		
		/**
		 * Dispatch document updated event
		 * */
		public function dispatchDocumentUpdatedEvent(target:*):void {
			var documentUpdatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_UPDATED)) {
				documentUpdatedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_UPDATED, false, false, target);
				dispatchEvent(documentUpdatedEvent);
			}
		}
		
		/**
		 * Dispatch preview event
		 * */
		public function dispatchPreviewEvent(sourceData:SourceData, type:String):void {
			var previewEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.REQUEST_PREVIEW)) {
				previewEvent = new RadiateEvent(RadiateEvent.REQUEST_PREVIEW);
				previewEvent.previewType = type;
				previewEvent.value = sourceData;
				dispatchEvent(previewEvent);
			}
		}
		
		
		/**
		 * Dispatch code updated event. Type is usually "HTML". 
		 * */
		public function dispatchCodeUpdatedEvent(sourceData:SourceData, type:String, openInWindow:Boolean = false):void {
			var codeUpdatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CODE_UPDATED)) {
				codeUpdatedEvent = new RadiateEvent(RadiateEvent.CODE_UPDATED);
				codeUpdatedEvent.previewType = type;
				codeUpdatedEvent.value = sourceData;
				codeUpdatedEvent.openInBrowser = openInWindow;
				dispatchEvent(codeUpdatedEvent);
			}
		}
		
		/**
		 * Dispatch color selected event
		 * */
		public function dispatchColorSelectedEvent(color:uint, invalid:Boolean = false):void {
			var colorSelectedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.COLOR_SELECTED)) {
				colorSelectedEvent = new RadiateEvent(RadiateEvent.COLOR_SELECTED);
				colorSelectedEvent.color = color;
				colorSelectedEvent.invalid = invalid;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch property selected event
		 * */
		public function dispatchPropertySelectedEvent(property:String, node:MetaData = null):void {
			var colorSelectedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_SELECTED);
			
			if (hasEventListener(RadiateEvent.PROPERTY_SELECTED)) {
				colorSelectedEvent.property = property;
				colorSelectedEvent.selectedItem = node;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch color preview event
		 * */
		public function dispatchColorPreviewEvent(color:uint, invalid:Boolean = false):void {
			var colorPreviewEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.COLOR_PREVIEW)) {
				colorPreviewEvent = new RadiateEvent(RadiateEvent.COLOR_PREVIEW);
				colorPreviewEvent.color = color;
				colorPreviewEvent.invalid = invalid;
				dispatchEvent(colorPreviewEvent);
			}
		}
		
		/**
		 * Dispatch canvas change event
		 * */
		public function dispatchCanvasChangeEvent(canvas:*, canvasBackgroundParent:*, scroller:Scroller):void {
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CANVAS_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.CANVAS_CHANGE);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch tool change event
		 * */
		public function dispatchToolChangeEvent(value:ITool):void {
			var toolChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TOOL_CHANGE)) {
				toolChangeEvent = new RadiateEvent(RadiateEvent.TOOL_CHANGE);
				toolChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				toolChangeEvent.targets = targets;
				toolChangeEvent.tool = value;
				dispatchEvent(toolChangeEvent);
			}
		}
		
		/**
		 * Dispatch target change event with a null target. 
		 * Target change to nothing.
		 * */
		public function dispatchTargetClearEvent():void {
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch property change event
		 * */
		public function dispatchPropertyChangeEvent(localTarget:*, changes:Array, properties:Array, styles:Array, events:Array = null):void {
			if (importingDocument) return;
			var propertyChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROPERTY_CHANGED)) {
				propertyChangeEvent = new RadiateEvent(RadiateEvent.PROPERTY_CHANGED, false, false, localTarget);
				propertyChangeEvent.property = properties && properties.length ? properties[0] : null;
				propertyChangeEvent.properties = properties;
				propertyChangeEvent.styles = styles;
				propertyChangeEvent.events = events;
				propertyChangeEvent.propertiesAndStyles = com.flexcapacitor.utils.ArrayUtils.join(properties, styles);
				propertyChangeEvent.propertiesStylesEvents = com.flexcapacitor.utils.ArrayUtils.join(properties, styles, events);
				propertyChangeEvent.changes = changes;
				propertyChangeEvent.selectedItem = localTarget && localTarget is Array ? localTarget[0] : localTarget;
				propertyChangeEvent.targets = ArrayUtil.toArray(localTarget);
				dispatchEvent(propertyChangeEvent);
			}
		}
		
		/**
		 * Dispatch object selected event
		 * */
		public function dispatchObjectSelectedEvent(target:*):void {
			var objectSelectedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.OBJECT_SELECTED)) {
				objectSelectedEvent = new RadiateEvent(RadiateEvent.OBJECT_SELECTED, false, false, target);
				dispatchEvent(objectSelectedEvent);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public function dispatchAddEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var event:RadiateEvent;
			var numberOfChanges:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.ADD_ITEM)) {
				event = new RadiateEvent(RadiateEvent.ADD_ITEM, false, false, target);
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				
				for (var i:int;i<numberOfChanges;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch move items event
		 * */
		public function dispatchMoveEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var moveEvent:RadiateEvent;
			var numOfChanges:int;
			
			if (hasEventListener(RadiateEvent.MOVE_ITEM)) {
				moveEvent = new RadiateEvent(RadiateEvent.MOVE_ITEM, false, false, target);
				moveEvent.properties = properties;
				moveEvent.changes = changes;
				moveEvent.multipleSelection = multipleSelection;
				moveEvent.selectedItem = target && target is Array ? target[0] : target;
				moveEvent.targets = ArrayUtil.toArray(target);
				numOfChanges = changes ? changes.length : 0;
				
				for (var i:int;i<numOfChanges;i++) {
					if (changes[i] is AddItems) {
						moveEvent.addItemsInstance = changes[i];
						moveEvent.moveItemsInstance = changes[i];
					}
				}
				
				dispatchEvent(moveEvent);
			}
		}
		
		/**
		 * Dispatch remove items event
		 * */
		public function dispatchRemoveItemsEvent(target:*, changes:Array, properties:*):void {
			var removeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REMOVE_ITEM, false, false, target);
			var numOfChanges:int;
			
			if (hasEventListener(RadiateEvent.REMOVE_ITEM)) {
				removeEvent.changes = changes;
				removeEvent.properties = properties;
				removeEvent.selectedItem = target && target is Array ? target[0] : target;
				removeEvent.targets = ArrayUtil.toArray(target);
				
				numOfChanges = changes ? changes.length : 0;
				
				for (var i:int;i<numOfChanges;i++) {
					if (changes[i] is AddItems) {
						removeEvent.addItemsInstance = changes[i];
						removeEvent.moveItemsInstance = changes[i];
					}
				}
				
				dispatchEvent(removeEvent);
			}
		}
		
		/**
		 * Dispatch to invoke property edit event
		 * */
		public function dispatchTargetPropertyEditEvent(target:Object, changes:Array, properties:Array, styles:Array, events:Array=null):void {
			var propertyEditEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROPERTY_EDIT)) {
				propertyEditEvent = new RadiateEvent(RadiateEvent.PROPERTY_EDIT, false, false, target);
				propertyEditEvent.changes = changes;
				propertyEditEvent.properties = properties;
				dispatchEvent(propertyEditEvent);
			}
		}
		
		/**
		 * Dispatch document change event
		 * */
		public function dispatchDocumentChangeEvent(document:IDocument):void {
			var documentChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CHANGE)) {
				documentChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CHANGE, false, false, document);
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document rename event
		 * */
		public function dispatchDocumentRenameEvent(document:IDocument, name:String):void {
			var documentRenameEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_RENAME)) {
				documentRenameEvent = new RadiateEvent(RadiateEvent.DOCUMENT_RENAME, false, false, document);
				dispatchEvent(documentRenameEvent);
			}
		}
		
		/**
		 * Dispatch project rename event
		 * */
		public function dispatchProjectRenameEvent(project:IProject, name:String):void {
			var projectRenameEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_RENAME)) {
				projectRenameEvent = new RadiateEvent(RadiateEvent.PROJECT_RENAME, false, false, project);
				dispatchEvent(projectRenameEvent);
			}
		}
		
		/**
		 * Dispatch documents set
		 * */
		public function dispatchDocumentsSetEvent(documents:Array):void {
			var documentChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENTS_SET)) {
				documentChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENTS_SET, false, false, documents);
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document opening event
		 * */
		public function dispatchDocumentOpeningEvent(document:IDocument, isPreview:Boolean = false):Boolean {
			var documentOpeningEvent:RadiateEvent;
			var dispatched:Boolean;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPENING)) {
				documentOpeningEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPENING, false, true, document);
				dispatched = dispatchEvent(documentOpeningEvent);
			}
			
			return dispatched;
		}
		
		/**
		 * Dispatch document open event
		 * */
		public function dispatchDocumentOpenEvent(document:IDocument):void {
			var documentOpenEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPEN)) {
				documentOpenEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPEN, false, false);
				documentOpenEvent.selectedItem = document;
				dispatchEvent(documentOpenEvent);
			}
		}
		
		/**
		 * Dispatch document closed event
		 * */
		public function dispatchDocumentCloseEvent(document:IDocument, documentClosed:Boolean = true, previewClosed:Boolean = false):void {
			var documentOpenEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CLOSE)) {
				documentOpenEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CLOSE, false, false);
				documentOpenEvent.selectedItem = document;
				documentOpenEvent.previewClosed = previewClosed;
				documentOpenEvent.documentClosed = documentClosed;
				dispatchEvent(documentOpenEvent);
			}
		}
		
		/**
		 * Dispatch document removed event
		 * */
		public function dispatchDocumentRemovedEvent(document:IDocument, successful:Boolean = true):void {
			var documentRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REMOVED)) {
				documentRemovedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_REMOVED, false, false);
				documentRemovedEvent.successful = successful;
				documentRemovedEvent.selectedItem = document;
				dispatchEvent(documentRemovedEvent);
			}
		}
		
		/**
		 * Dispatch project saved event
		 * */
		public function dispatchProjectSavedEvent(project:IProject):void {
			var projectSaveEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_SAVED)) {
				projectSaveEvent = new RadiateEvent(RadiateEvent.PROJECT_SAVED, false, false);
				projectSaveEvent.selectedItem = project;
				dispatchEvent(projectSaveEvent);
			}
		}
		
		/**
		 * Dispatch document save complete event
		 * */
		public function dispatchDocumentSaveCompleteEvent(document:IDocument):void {
			var documentSaveAsCompleteEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_COMPLETE)) {
				documentSaveAsCompleteEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_COMPLETE, false, false, document);
				dispatchEvent(documentSaveAsCompleteEvent);
			}
		}
		
		/**
		 * Dispatch HTML preview uncaught exceptions
		 * */
		public function dispatchExceptionEvent(event:Event):void {
			var uncaughtExceptionEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.UNCAUGHT_EXCEPTION_EVENT)) {
				uncaughtExceptionEvent = new RadiateEvent(RadiateEvent.UNCAUGHT_EXCEPTION_EVENT, false, false);
				uncaughtExceptionEvent.data = event;
				dispatchEvent(uncaughtExceptionEvent);
			}
		}
		
		/**
		 * Dispatch document not saved event
		 * */
		public function dispatchDocumentSaveFaultEvent(document:IDocument):void {
			var documentSaveFaultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_FAULT)) {
				documentSaveFaultEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_FAULT, false, false, document);
				dispatchEvent(documentSaveFaultEvent);
			}
		}
		
		/**
		 * Dispatch document save as cancel event
		 * */
		public function dispatchDocumentSaveAsCancelEvent(document:IDocument):void {
			var documentSaveAsCancelEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL)) {
				documentSaveAsCancelEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL, false, false, document);
				dispatchEvent(documentSaveAsCancelEvent);
			}
		}
		
		/**
		 * Dispatch console value change event
		 * */
		public function dispatchConsoleValueChangeEvent(value:String):void {
			var consoleValueChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CONSOLE_VALUE_CHANGE)) {
				consoleValueChangeEvent = new RadiateEvent(RadiateEvent.CONSOLE_VALUE_CHANGE, false, false);
				consoleValueChangeEvent.data = value;
				dispatchEvent(consoleValueChangeEvent);
			}
		}
		
		/**
		 * Dispatch documentation change event
		 * */
		public function dispatchDocumentationChangeEvent(url:String):void {
			var documentationChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENTATION_CHANGE)) {
				documentationChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENTATION_CHANGE, false, false);
				documentationChangeEvent.data = url;
				dispatchEvent(documentationChangeEvent);
			}
		}
		
		/**
		 * Dispatch document add event
		 * */
		public function dispatchDocumentAddedEvent(document:IDocument):void {
			var documentAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_ADDED)) {
				documentAddedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_ADDED, false, false, document);
				dispatchEvent(documentAddedEvent);
			}
		}
		
		/**
		 * Dispatch document reverted event
		 * */
		public function dispatchDocumentRevertedEvent(document:IDocument):void {
			var documentRevertedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REVERTED)) {
				documentRevertedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_REVERTED, false, false, document);
				dispatchEvent(documentRevertedEvent);
			}
		}
		
		/**
		 * Dispatch project closing event
		 * */
		public function dispatchProjectClosingEvent(project:IProject):void {
			var projectClosingEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSING)) {
				projectClosingEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSING, false, false, project);
				dispatchEvent(projectClosingEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public function dispatchProjectOpenedEvent(project:IProject):void {
			var projectOpenedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_OPENED)) {
				projectOpenedEvent = new RadiateEvent(RadiateEvent.PROJECT_OPENED, false, false, project);
				dispatchEvent(projectOpenedEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public function dispatchProjectClosedEvent(project:IProject):void {
			var projectClosedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSED)) {
				projectClosedEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSED, false, false, project);
				dispatchEvent(projectClosedEvent);
			}
		}
		
		/**
		 * Dispatch project removed event
		 * */
		public function dispatchProjectRemovedEvent(project:IProject):void {
			var projectRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_REMOVED)) {
				projectRemovedEvent = new RadiateEvent(RadiateEvent.PROJECT_REMOVED, false, false, project);
				projectRemovedEvent.data = project;
				dispatchEvent(projectRemovedEvent);
			}
		}
		
		/**
		 * Dispatch project change event
		 * */
		public function dispatchProjectChangeEvent(project:IProject, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CHANGE)) {
				projectChangeEvent = new RadiateEvent(RadiateEvent.PROJECT_CHANGE, false, false, project);
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch projects set event
		 * */
		public function dispatchProjectsSetEvent(projects:Array, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECTS_SET)) {
				projectChangeEvent = new RadiateEvent(RadiateEvent.PROJECTS_SET, false, false, projects);
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public function dispatchProjectAddedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_ADDED)) {
				projectCreatedEvent = new RadiateEvent(RadiateEvent.PROJECT_ADDED, false, false, project);
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public function dispatchProjectCreatedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CREATED)) {
				projectCreatedEvent = new RadiateEvent(RadiateEvent.PROJECT_CREATED, false, false, project);
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Sets the logging target
		 * */
		public static function setLoggingTarget(target:AbstractTarget = null, category:String = null, consoleObject:Object = null):void {
			
			// Log only messages for the classes in the mx.rpc.* and 
			// mx.messaging packages.
			//logTarget.filters=["mx.rpc.*","mx.messaging.*"];
			//var filters:Array = ["mx.rpc.*", "mx.messaging.*"];
			//var filters:Array = ["mx.rpc.*", "mx.messaging.*"];
			
			// Begin logging.
			if (target) {
				logTarget = target;
				//logTarget.filters = filters;
				logTarget.level = LogEventLevel.ALL;
				Log.addTarget(target);
			}
			
			// set reference to logger
			if (category) {
				log = Log.getLogger(category);
			}
			else {
				log = Log.getLogger(RADIATE_LOG);
			}
			
			if (consoleObject) {
				console = consoleObject;
			}
			
		}
		
		/**
		 * Creates the list of components and tools.
		 * */
		public static function initialize():void {
			var componentsXML:XML 	= new XML(new Radii8LibrarySparkAssets.componentsManifestDefaults());
			var sparkXML:XML	 	= new XML(new Radii8LibraryTranscodersAssets.sparkManifest());
			var mxmlXML:XML	 		= new XML(new Radii8LibraryTranscodersAssets.mxmlManifest());
			var toolsXML:XML 		= new XML(new Radii8LibraryToolAssets.toolsManifestDefaults());
			var inspectorsXML:XML 	= new XML(new Radii8LibraryInspectorAssets.inspectorsManifestDefaults());
			var devicesXML:XML		= new XML(new Radii8LibraryDeviceAssets.devicesManifestDefaults());
			var exportersXML:XML	= new XML(new Radii8LibraryTranscodersAssets.transcodersManifestDefaults());
			//var documentsXML:XML	= new XML(new Radii8LibraryTranscodersAssets.transcodersManifestDefaults());
			
			setLoggingTarget(defaultLogTarget);
			
			SettingsManager.createSettingsData();

			SettingsManager.createSavedData();
			
			//createDocumentTypesList(documentsXML);
			
			ComponentManager.createComponentList(componentsXML);
			//createComponentList(sparkXML);
			//createComponentList(mxmlXML);
			
			createDocumentTranscoders(exportersXML);
			
			createInspectorsList(inspectorsXML);
			
			ToolManager.createToolsList(toolsXML);
			
			DeviceManager.createDevicesList(devicesXML);
			
			FontManager.createFontsList();
			
			documentStatuses.source = [WPService.STATUS_NONE, WPService.STATUS_DRAFT, WPService.STATUS_PUBLISH];
			
			initialized = true;
		}
		
		/**
		 * Startup 
		 * */
		public static function startup(applicationReference:Application, 
									   mainViewReference:MainView, 
									   host:String = null, 
									   path:String = null):void {
			
			
			var screenshotPath:String;
			
			SettingsManager.applySettings();
			
			ViewManager.application = applicationReference;
			ViewManager.mainView 	= mainViewReference;
			
			// add support to enable this and send error reports
			CreationManager.showMeWhatsActivatedSoFar = false;
			CreationManager.showMeWhatsCreatedSoFar = false;
			
			serviceManager 			= ServicesManager.getInstance();
			historyManager 			= HistoryManager.getInstance();
			popUpOverlayManager 	= PopUpOverlayManager.getInstance();
			keyboardManager			= KeyboardManager.getInstance();
			clipboardManager		= ClipboardManager.getInstance();
			snippetManager			= SnippetManager.getInstance();
			
			htmlClass = ClassUtils.getDefinition("mx.core.FlexHTMLLoader");
			
			keyboardManager.initialize(applicationReference, htmlClass);
			
			serviceManager.radiate 	= instance;
			HistoryManager.radiate 	= instance;
			clipboardManager.radiate= instance;
			
			// set debugging options here
			HistoryManager.debug 	= false;
			DragManagerUtil.debug 	= false;
			Text.debug 				= false;
			Selection.debug			= false;
			LayoutDebugHelper.debug	= false;
			MainView.debug 			= false;
			ClassLoader.debug 		= false;
			TextEditorManager.debug = false;
			
			// testing for why layout is invalid when disconnected from network - no longer needed
			//var layoutManager:ILayoutManager;
			//UIComponentGlobals.catchCallLaterExceptions = true;
			//layoutManager = UIComponentGlobals.layoutManager;
			//layoutManager.usePhasedInstantiation;
			
			ViewManager.application.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, instance.uncaughtErrorHandler, false, 0, true);
			//application.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, instance.uncaughtErrorHandler2, false, 0, true);
			
			//ExternalInterface.call("Radiate.getInstance");
			if (ExternalInterface.available) {
				ExternalInterface.call("Radiate.instance.setFlashInstance", ExternalInterface.objectID);
			}
			
			if (!firstRun && PersistentStorage.isSupported) {
				host = PersistentStorage.read(WP_HOST_NAME);
				path = PersistentStorage.read(WP_PATH_NAME);
				screenshotPath = PersistentStorage.read(SCREENSHOT_PATH_NAME);
			}
			
			if (host) {
				WP_HOST = host;
			}
			else {
				WP_HOST = defaultHost;
			}
			
			if (path && !firstRun) {
				WP_PATH = path;
			}
			else {
				WP_PATH = defaultPath;
			}
			
			if (screenshotPath) {
				SCREENSHOT_PATH = screenshotPath;
			}
			else {
				SCREENSHOT_PATH = defaultScreenshotPath;
			}
			
			snippetManager.initialize(WP_SNIPPET_HOST);
			
			contentCache.maxCacheEntries = 200;
			
			CodeManager.setTranscodersVersion(instance.versionNumber);
			CodeManager.setComponentDefinitions(ComponentManager.componentDefinitions.source);
			
			setUpdatedHTMLImporterAndExporter();
			
			DisplayObjectUtils.Base64Encoder2 = Base64;
			
			XMLUtils.initialize();
			SVGUtils.initialize();
			
			instance.createOpenImportPopUp();
			
			ViewManager.mainView.startup();
			
			TextEditorManager.createCallOut();
			
			// we use this to prevent hyperlinks from opening web pages when in design mode
			// we don't know what changes this causes with other components 
			// so it was disabled for a while
			// caused some issues with hyperlinks opening so disabling 
			//UIComponentGlobals.designMode = true;
			
			//radiate.openInitialProjects();
			//LayoutManager.getInstance().usePhasedInstantiation = false;
			
			registerClasses();
			
		}
		
		protected static function registerClasses():void {
			classRegistry = ClassRegistry.getInstance();
			classRegistry.targetNamespace = new Namespace("s", "library://ns.adobe.com/flex/spark");
			
			classLoader = new ClassLoader();
			classLoader.configPath = "assets/manifest/";
			classLoader.configFileName = "flex-config-template.xml";
			classLoader.addEventListener(ClassLoader.NAMESPACE_LOADED, namespaceLoaded, false, 0, true);
			classLoader.addEventListener(ClassLoader.NAMESPACES_LOADED, namespacesLoaded, false, 0, true);
			classLoader.addEventListener(IOErrorEvent.IO_ERROR, namespacesIOErrorEvent, false, 0, true);
			classLoader.load();
			
			
			var transcoder:DocumentTranscoder = new DocumentTranscoder();
			var defaultMXMLApplication:XML = transcoder.getDefaultMXMLDocumentXML();
			
			classRegistry.addNamespaces(defaultMXMLApplication);
		}
		
		protected static function namespaceLoaded(event:Event):void {
			var uri:String = classLoader.lastNamespaceURI;
		}
		
		protected static function namespacesLoaded(event:Event):void {
			loadingClasses = false;
			classesLoaded = true;
			
			instance.dispatchNamespacesLoadedEvent();
		}
		
		protected static function namespacesIOErrorEvent(event:Event):void {
			//if (debug) {
				error("Namespace files were not loaded", event);
			//}
		}
		
		protected function uncaughtErrorHandler2(event:UncaughtErrorEvent):void
		{
			//trace("Uncaught error: " + event);
			if ("text" in event && event.text!="") {
				error(event.text, event);
			}
			else if ("error" in event && event.error && "message" in event.error) {
				error(event.error.message, event);
			}
		}
		
		/**
		 * Configure updated HTML exporter from TLF text flow
		 * */
		protected static function setUpdatedHTMLImporterAndExporter():void {
			textFieldHTMLFormatImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			textfieldHTMLFormatConfiguration = textFieldHTMLFormatImporter.configuration;
			
			TextConverter.removeFormat(TextConverter.TEXT_FIELD_HTML_FORMAT);
			TextConverter.addFormat(TextConverter.TEXT_FIELD_HTML_FORMAT, flashx.textLayout.conversion.TextFieldHtmlImporter, TextFieldHTMLExporter2, null);
			
			textFieldHTMLFormatImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			textFieldHTMLFormatImporter.configuration = textfieldHTMLFormatConfiguration;			
		}
		
		public static var textFieldHTMLFormatImporter:ITextImporter;
		public static var textfieldHTMLFormatConfiguration:IConfiguration;
		
		protected function loginStatusChange(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			if (event.hasError) {
				isUserConnected = false;
			}
			else {
				isUserConnected = true;
			}
			
			updateUserInfo(data);
			
		}
		
		/**
		 * Reference to mechanism used to update the application
		 * */
		public var updater:IEffect;
		
		/**
		 * Checks for update on the desktop version 
		 * */
		public function checkForUpdate():void {
			if (updater) {
				updater.play();
			}
		}
		
		/**
		 * Create the list of document view types.
		 * */
		public static function createDocumentTypesList(xml:XML):void {
			var hasDefinition:Boolean;
			var items:XMLList;
			var item:XML;
			var numberOfItems:uint;
			var classType:Object;
			 
			// get list of transcoder classes 
			items = XML(xml).transcoder;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				var documentDescription:DocumentDescription = new DocumentDescription();
				documentDescription.importXML(item);
				
				hasDefinition = ClassUtils.hasDefinition(documentDescription.classPath);
				
				if (hasDefinition) {
					//classType = ClassUtils.getDefinition(transcoder.classPath);
					
					//CodeManager.registerTranscoder(documentDescription);
				}
				else {
					error("Document transcoder class for " + documentDescription.name + " not found: " + documentDescription.classPath);
					// we need to add it to Radii8LibraryExporters
					// such as Radii8LibraryExporters
				}
			}
			
		}
		
		/**
		 * Create the list of document transcoders.
		 * var languages:Array = CodeManager.getLanguages();
		 * var sourceData:SourceData = CodeManager.getSourceData(target, iDocument, language, options);	
		 * */
		public static function createDocumentTranscoders(xml:XML):void {
			var hasDefinition:Boolean;
			var items:XMLList;
			var item:XML;
			var numberOfItems:uint;
			var classType:Object;
			var transcoder:TranscoderDescription;
			 
			// get list of transcoder classes 
			items = XML(xml).transcoder;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				transcoder = new TranscoderDescription();
				transcoder.importXML(item);
				
				hasDefinition = ClassUtils.hasDefinition(transcoder.classPath);
				
				if (hasDefinition) {
					//classType = ClassUtils.getDefinition(transcoder.classPath);
					addTranscoder(transcoder);
				}
				else {
					error("Document transcoder class for " + transcoder.type + " not found: " + transcoder.classPath);
					// we need to add it to Radii8LibraryExporters
					// such as Radii8LibraryExporters
				}
			}
			
		}
		
		/**
		 * Adds a transcoder to the Code Manager and adds the current component definitions
		 * */
		public static function addTranscoder(transcoder:TranscoderDescription):void {
			
			CodeManager.registerTranscoder(transcoder);
			CodeManager.setComponentDefinitions(ComponentManager.componentDefinitions.source);
		}
		
		/**
		 * Creates the list of inspectors.
		 * */
		public static function createInspectorsList(xml:XML):void {
			var numberOfItems:uint;
			var inspectorsLength:uint;
			var items:XMLList;
			var className:String;
			var alternativeClassName:String;
			var alternativeClasses:XMLList;
			var skinClassName:String;
			var inspectorClassName:String;
			var hasDefinition:Boolean;
			var classType:Object;
			var includeItem:Boolean;
			var attributes:XMLList;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
			var item:XML;
			var altItem:XML;
			var inspectorItems:XMLList;
			var inspector:XML;
			var inspectableClass:InspectableClass;
			var inspectorData:InspectorData;
			
			
			// get list of inspector classes 
			items = XML(xml).item;
			
			numberOfItems = items.length();
			
			// add inspectable classes to the dictionary
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				inspectableClass = new InspectableClass(item);
				className = inspectableClass.className;
				alternativeClasses = item..alternative;
				
				if (inspectableClassesDictionary[className]==null) {
					inspectableClassesDictionary[className] = inspectableClass;
					
					// get other classes that can use the same inspectors
					for (var k:int = 0; k < alternativeClasses.length(); k++)  {
						altItem = alternativeClasses[k];
						alternativeClassName = altItem.attribute("className");
						
						if (inspectableClassesDictionary[alternativeClassName]==null) {
							inspectableClassesDictionary[alternativeClassName] = inspectableClass;
						}
						else {
							warn("Inspectable alternative class, '" + alternativeClassName + "', was listed more than once during import.");
						}
					}
					
				}
				else {
					warn("Inspectable class, '" + className + "', was listed more than once during import.");
				}
					
			}
			
			// check that definitions exist in domain
			for each (inspectableClass in inspectableClassesDictionary) {
			
				numberOfItems = inspectableClass.inspectors.length;
				j = 0;
				
				for (var j:int;j<numberOfItems;j++) {
					inspectorData = inspectableClass.inspectors[j];
					className = inspectorData.className;
					
					if (inspectorsDictionary[className]==null) {
						
						hasDefinition = ClassUtils.hasDefinition(className);
						
						if (hasDefinition) {
							classType = ClassUtils.getDefinition(className);
						}
						else {
							error("Inspector class not found: " + className + " Add a reference to RadiateReferences. Also check the spelling.");
						}
						
						// not passing in classType now since we may load it in later dynamically
						addInspectorType(inspectorData.name, className, null, inspectorData.icon, defaults);
					}
					else {
						//warn("Inspector class: " + className + ", is already in the dictionary");
					}
				}
			}
			
			// inspectorsInstancesDictionary should now be populated
		}
		
		/**
		 * Helper method to get the ID of the mouse cursor by name.
		 * */
		public function getMouseCursorID(tool:ITool, name:String = "Cursor"):String {
			var component:ComponentDescription = ToolManager.getToolDescription(tool);
			
			
			if (component.cursors && component.cursors[name]) {
				return component.cursors[name].id;
			}
			
			return null;
		}
		
		//----------------------------------
		//  target
		//----------------------------------
		
		/**
		 * Use setTarget() or setTargets() method to set the target. 
		 * */
		public function get target():Object {
			if (_targets.length > 0) {
				return _targets[0];
			}
			else {
				return null;
			}
		}
		
		/**
		 * When the target is set we sometimes want to work with a property on that target.
		 * If that property is an array we must also set the property index
		 * 
		 * @see target
		 * @see setTarget
		 * @see setTargetProperties
		 * @see propertyIndex
		 * */
		public var property:String;
		
		/**
		 * When the target is set we sometimes want to work with a property on that target.
		 * If that property is an array we must also set the property index
		 * 
		 * @see target
		 * @see setTarget
		 * @see setTargetProperties
		 * @see propertyIndex
		 * */
		public var propertyIndex:int;
		
		/**
		 * When working with an object related to the target
		 * */
		public var subTarget:Object;
		
		/**
		 *  @private
		 */
		/*[Bindable]
		public function set target(value:Object):void {
			if (_targets.length == 1 && target==value) return;
			
			_targets.splice(0);
			
			if (value) {
				_targets[0] = value;
			}
		}*/

		
		//----------------------------------
		//  targets
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the targets property.
		 */
		private var _targets:Array = [];
		
		/**
		 * Selected targets
		 * */
		public function get targets():Array {
			return _targets;
		}
		
		/**
		 * Use setTargets() to set the targets
		 *  @private
		 * */
		/*public function set targets(value:Array):void {
			// remove listeners from previous targets
			var n:int = _targets.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_targets[i] == null) {
					continue;
				}
				
				//removeHandlers(_targets[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null targets are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_targets = value;
			
		}*/
		
		//----------------------------------
		//  project
		//----------------------------------
		
		private var _selectedProject:IProject;
		
		/**
		 * Reference to the current project
		 * */
		public function get selectedProject():IProject {
			return _selectedProject;
		}
		
		/**
		 *  @private
		 */
		[Bindable(event="projectChange")]
		public function set selectedProject(value:IProject):void {
			if (value==_selectedProject) return;
			_selectedProject = value;
			
		}
		
		//----------------------------------
		//  document
		//----------------------------------
		
		private var _documentsTabNavigator:TabNavigator;

		/**
		 * Reference to the tab navigator that creates documents
		 * */
		public function get documentsTabNavigator():TabNavigator {
			return _documentsTabNavigator;
		}

		/**
		 * @private
		 */
		public function set documentsTabNavigator(value:TabNavigator):void {
			_documentsTabNavigator = value;
		}
		
		/**
		 * Reference to the tab that the document belongs to
		 * */
		public var documentsContainerDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Reference to the tab that the document preview belongs to
		 * */
		public var documentsPreviewDictionary:Dictionary = new Dictionary(true);
		
		private var _selectedDocument:IDocument;
		
		/**
		 * Get the current document.
		 * */
		public function get selectedDocument():IDocument {
			return _selectedDocument;
		}
		
		/**
		 *  @private
		 */
		[Bindable]
		public function set selectedDocument(value:IDocument):void {
			if (value==_selectedDocument) return;
			_selectedDocument = value;
		}
		
		/**
		 * Templates for creating new projects or documents
		 * */
		[Bindable]
		public var templates:Array;
		
		//----------------------------------
		//  documents
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the documents property.
		 */
		private var _documents:Array = [];
		
		/**
		 * Selected documents
		 * */
		public function get documents():Array {
			return _documents;
		}
		
		/**
		 * Selected documents
		 *  @private
		 * */
		[Bindable]
		public function set documents(value:Array):void {
			// the following comments are old possibly irrelevant...
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
		}
		
		
		//----------------------------------
		//  projects
		//----------------------------------
		
		
		/**
		 * Reference to the projects belongs to
		 * */
		public var projectsDictionary:Dictionary = new Dictionary(true);
		
		/**
		 *  @private
		 *  Storage for the projects property.
		 */
		private var _projects:Array = [];
		
		/**
		 * Selected projects
		 * */
		public function get projects():Array {
			return _projects;
		}
		
		/**
		 * Selected projects
		 *  @private
		 * */
		[Bindable]
		public function set projects(value:Array):void {
			_projects = value;
			
		}
		
		private var _attachments:Array = [];

		/**
		 * Attachments
		 * */
		[Bindable]
		public function get attachments():Array {
			return _attachments;
		}

		public function set attachments(value:Array):void {
			_attachments = value;
		}
		
		private var _assets:ArrayCollection = new ArrayCollection();

		/**
		 * Assets of the current document
		 * */
		[Bindable]
		public function get assets():ArrayCollection {
			return _assets;
		}

		public function set assets(value:ArrayCollection):void {
			_assets = value;
		}

		
		private var _toolLayer:IVisualElementContainer;

		/**
		 * Container that tools can draw too
		 * */
		public function get toolLayer():IVisualElementContainer {
			return _toolLayer;
		}

		/**
		 * @private
		 */
		public function set toolLayer(value:IVisualElementContainer):void {
			_toolLayer = value;
		}

		
		private var _editorComponent:RichTextEditorBar;

		/**
		 * Text editor component that has formatting tools on it
		 * */
		public function get editorComponent():RichTextEditorBar {
			return _editorComponent;
		}

		/**
		 * @private
		 */
		public function set editorComponent(value:RichTextEditorBar):void {
			_editorComponent = value;
		}

		
		/**
		 * Default log target
		 * */
		public static var defaultLogTarget:AbstractTarget = new RadiateLogTarget();
		
		/**
		 * Attempt to support a console
		 * */
		public static var logTarget:AbstractTarget;
		
		private static var _log:ILogger;
		
		private static var _console:Object;
		
		public static var componentsIconPath:String = "assets/icons/components/";
		public static var componentsIconNotFoundPath:String = componentsIconPath + "/BorderContainer.png";
		
		public static var WP_HOST_NAME:String = "wpHostName";
		public static var WP_PATH_NAME:String = "wpPathName";
		public static var CONTACT_FORM_URL:String = "http://www.radii8.com/support.php";
		public static var WP_HOST:String = "https://www.radii8.com";
		public static var WP_PATH:String = "/r8m/";
		public static var WP_USER_PATH:String = "";
		public static var WP_EXAMPLES_PATH:String = "/r8m/";
		public static var WP_NEWS_PATH:String = "/r8m/";
		public static var WP_LOGIN_PATH:String = "/wp-admin/";
		public static var WP_PROFILE_PATH:String = "/wp-admin/profile.php";
		public static var WP_EDIT_POST_PATH:String = "/wp-admin/post.php";
		public static var WP_SNIPPET_HOST:String = "https://www.radii8.com/snippets/";
		public static var WP_SNIPPET_EDITOR:String = "https://www.radii8.com/mxml/";
		public static var WP_SNIPPET_VIEWER:String = "https://www.radii8.com/viewer/";
		public static var APPLICATION_PATH:String = "/online/";
		public static var EDITOR_PATH:String = "/mxml/";
		public static var VIEWER_PATH:String = "/viewer/";
		public static var DEFAULT_DOCUMENT_WIDTH:int = 800;
		public static var DEFAULT_DOCUMENT_HEIGHT:int = 500;//792;
		public static var DEFAULT_NAVIGATION_WINDOW:String = "userNavigation";
		public static var SCREENSHOT_PATH:String = "https://dev.windows.com/en-us/microsoft-edge/tools/screenshots/?url=";
		public static var SCREENSHOT_PATH_NAME:String = "screenshotPathName";
		public static var SITE_SCANNER_PATH:String = "https://dev.windows.com/en-us/microsoft-edge/tools/staticscan/?url=";
		public static var SITE_SCANNER_PATH_NAME:String = "siteScannerPathName";
		
		public static var defaultHost:String = "https://www.radii8.com";
		public static var defaultPath:String = "/r8m/";
		public static var defaultScreenshotPath:String = "https://dev.windows.com/en-us/microsoft-edge/tools/screenshots/?url=";
		public static var defaultSiteScannerPath:String = "https://dev.windows.com/en-us/microsoft-edge/tools/staticscan/?url=";
		public static var firstRun:Boolean;
		
		/**
		 * Gets the URL to the examples site
		 * */
		public static function getExamplesWPURL():String {
			return WP_HOST + WP_EXAMPLES_PATH;
		}
		
		/**
		 * Gets the URL to the examples site
		 * */
		public static function getNewsWPURL():String {
			return WP_HOST + WP_NEWS_PATH;
		}
		
		/**
		 * Get's the root path to the single or multiuser wordpress site
		 * Wp_host + WP_Path
		 * */
		public static function getWPHostURL():String {
			return WP_HOST + WP_PATH;
		}
		
		/**
		 * Get's the path to the single or multiuser wordpress site
		 * Wp_host + WP_Path + WP_USER_Path. 
		 * When a user logs into a multiuser site the first time
		 * they can and usually do log into wp_host + wp_path.
		 * After they log in, future calls are made to 
		 * wp_host + wp_path + wp_user_path. 
		 * */
		public static function getWPURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH;
		}
		
		/**
		 * Get's the URL to the login page for users to login manually
		 * */
		public static function getWPLoginURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH + WP_LOGIN_PATH;
		}
		
		/**
		 * Get's the URL to the profile page for the user
		 * */
		public static function getWPProfileURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH + WP_PROFILE_PATH;
		}
		
		/**
		 * Get's the URL to edit the current post
		 * */
		public static function getWPEditPostURL(documentData:IDocumentData):String {
			//http://www.radii8.com/r8m/wp-admin/post.php?post=5227&action=edit
			return WP_HOST + WP_PATH + WP_USER_PATH + WP_EDIT_POST_PATH + "?post=" + documentData.id + "&action=edit";
		}
		
		/**
		 * Gets the URL to open this snippet
		 * */
		public static function getSnippetApplicationURL(snippedID:String):String {
			return WP_HOST + APPLICATION_PATH + "#" + snippedID;
		}
		
		/**
		 * Gets the URL to edit this snippet in the text editor
		 * */
		public static function getSnippetEditorURL(snippedID:String):String {
			return WP_HOST + EDITOR_PATH + "#" + snippedID;
		}
		
		/**
		 * Gets the URL to view this snippet
		 * */
		public static function getSnippetViewerURL(snippedID:String):String {
			return WP_HOST + VIEWER_PATH + "#" + snippedID;
		}
		
		/**
		 * Is true when preview is visible. This is manually set. 
		 * Needs refactoring. 
		 * */
		public var isPreviewVisible:Boolean;
		
		/**
		 * Registers and maps classes with namespaces 
		 * */
		public static var classRegistry:ClassRegistry;
		
		/**
		 * Loads flex config and component manifests
		 * */
		public static var classLoader:ClassLoader;
		
		/**
		 * Indicates classes are loading
		 * */
		public static var loadingClasses:Boolean;
		
		/**
		 * Indicates all classes have loaded
		 * */
		public static var classesLoaded:Boolean;
		
		/**
		 * Collection of mouse cursors that can be added or removed to 
		 * */
		[Bindable]
		public static var mouseCursors:Dictionary = new Dictionary(true);
		
		//----------------------------------
		//
		//  Device Management
		// 
		//----------------------------------
		
		/**
		 * Collection of devices
		 * */
		[Bindable]
		public static var deviceCollections:ArrayCollection = new ArrayCollection();
		
		
		//----------------------------------
		//
		//  Tools Management
		// 
		//----------------------------------
		
		public var _selectedTool:ITool;
		
		/**
		 * Get selected tool.
		 * */
		public function get selectedTool():ITool {
			return _selectedTool;
		}
		
		/**
		 * Set selected tool.
		 * */
		public function set selectedTool(value:ITool):void {
			_selectedTool = value;
		}
		
		/**
		 * Collection of tools that can be added or removed to 
		 * */
		[Bindable]
		public static var toolsDescriptions:ArrayCollection = new ArrayCollection();
		
		private var _previousSelectedTool:ITool;

		public function get previousSelectedTool():ITool
		{
			return _previousSelectedTool;
		}

		public function set previousSelectedTool(value:ITool):void
		{
			_previousSelectedTool = value;
		}

		
		//----------------------------------
		//
		//  Inspector Management
		// 
		//----------------------------------
		
		/**
		 * Collection of inspectors that can be added or removed to 
		 * */
		[Bindable]
		public static var inspectorsDescriptions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Dictionary of classes that have inspectors
		 * */
		[Bindable]
		public static var inspectableClassesDictionary:Dictionary = new Dictionary();
		
		/**
		 * Dictionary of instances of inspectors searched by class name
		 * */
		[Bindable]
		public static var inspectorsDictionary:Dictionary = new Dictionary();
		
		/**
		 * Add the named inspector class to the list of available inspectors
		 * */
		public static function addInspectorType(name:String, className:String, classType:Object, icon:Object = null, defaults:Object=null):Boolean {
			var inspectorData:InspectorData;
			
			if (inspectorsDictionary[className]==null) {
				inspectorData = new InspectorData();
				inspectorData.name = name==null ? className : name;
				inspectorData.className = className;
				inspectorData.classType = classType;
				inspectorData.icon = icon;
				inspectorData.defaults = defaults;
				inspectorsDictionary[className] = inspectorData;
			}
			
			
			return true;
		}
		
		/**
		 * Gets inspector classes or null if the definition is not found.
		 * */
		public function getInspectableClassData(className:String):InspectableClass {
			var inspectableClass:InspectableClass = inspectableClassesDictionary[className];
			
			return inspectableClass;
		}
		
		/**
		 * Gets an instance of the inspector class or null if the definition is not found.
		 * */
		public function getInspectorInstance(className:String):IInspector {
			var inspectorData:InspectorData = inspectorsDictionary[className];
			
			if (inspectorData) {
				if (inspectorData.instance) {
					return inspectorData.instance;
				}
				
				var instance:IInspector = inspectorData.getInstance();
				
				return instance;
			
			}

			return null;
		}
		
		/**
		 * Gets an instance of the inspector class or null if the definition is not found.
		 * */
		public function getInspector(target:Object, domain:ApplicationDomain = null):IInspector {
			var className:String;
			
			if (target) {
				className = ClassUtils.getQualifiedClassName(target);
				
				var instance:IInspector = getInspectorInstance(className);
				
				return instance;
			}

			return null;
		}
		
		/**
		 * Gets array of inspector data for the given fully qualified class or object
		 * */
		public function getInspectors(target:Object, fallBackOnSuperClasses:Boolean = false):Array {
			var className:String;
			var inspectors:Array;
			var inspectorDataArray:Array;
			var inspectableClass:InspectableClass;
			
			if (target==null) return [];
			
			if (target is Object) {
				className = ClassUtils.getQualifiedClassName(target);
				
				if (target is Application) {
					className = ClassUtils.getSuperClassName(target);
				}
			}
			
			if (target is String) {
				className = String(target);
			}
			
			className = className ? className.split("::").join(".") : className;
			
			inspectableClass = getInspectableClassData(className);
			
			if (inspectableClass) {
				return inspectableClass.inspectors;
			}

			return [];
		}
		
		//----------------------------------
		//
		//  Documentation Utility
		// 
		//----------------------------------
		
		public static var docsURL:String = "https://flex.apache.org/asdoc/";
		public static var docsURL2:String = "https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/";
		public static var w3URL:String = "https://www.w3.org/TR/DOM-Level-3-Events/events.html#event-DOMSubtreeModified";
		public static var mozillaURL:String = "https://developer.mozilla.org/en-US/";
		
		/**
		 * Returns the URL to the help document online based on MetaData passed to it. 
		 * 
		 * For HTML, check out W3C 
		 * */
		public static function getURLToHelp(metadata:Object, useBackupURL:Boolean = true):String {
			var path:String = "";
			var currentClass:String;
			var sameClass:Boolean;
			var prefix:String = "";
			var url:String;
			var packageName:String;
			var declaredBy:String;
			var backupURLNeeded:Boolean;
			
			if (metadata=="application") {
				metadata = "spark.components::Application";
			}
			
			if (metadata && metadata is MetaData && metadata.declaredBy) {
				declaredBy = metadata.declaredBy;
				currentClass = declaredBy.replace(/::|\./g, "/");
				
				if (declaredBy.indexOf(".")!=-1) {
					packageName = declaredBy.split(".")[0];
					if (packageName=="flash") {
						backupURLNeeded = true;
					}
				}
				
				if (metadata is StyleMetaData) {
					prefix = "style:";
				}
				else if (metadata is EventMetaData) {
					prefix = "event:";
				}
				
				
				path = currentClass + ".html#" + prefix + metadata.name;
			}
			else if (metadata is String) {
				currentClass = metadata.replace(/::|\./g, "/");
				path = currentClass + ".html";
			}
			
			if (useBackupURL && backupURLNeeded) {
				url  = docsURL2 + path;
			}
			else {
				url  = docsURL + path;
			}
			
			return url;
		}
		
		/**
		 * Cache for component icons
		 * */
		[Bindable]
		public static var contentCache:ContentCache = new ContentCache();
		
		/**
		 * Add multiple assets to a document or project
		 * */
		public function addAssetsToDocument(assetsToAdd:Array, documentData:DocumentData, dispatchEvents:Boolean = true):void {
			var numberOfAssets:int;
			var added:Boolean;
			
			numberOfAssets = assetsToAdd ? assetsToAdd.length : 0;
			
			for (var i:int;i<numberOfAssets;i++) {
				addAssetToDocument(assetsToAdd[i], documentData, dispatchEvents);
			}
			
		}
		
		/**
		 * Add an asset to the document assets collection
		 * Should be renamed to something like addAssetToGlobalResourcesAndAssociateWithDocument
		 * */
		public function addAssetToDocument(attachmentData:DocumentData, documentData:IDocumentData, dispatchEvent:Boolean = true):void {
			var numberOfAssets:int = assets ? assets.length : 0;
			var found:Boolean;
			var addedAttachmentData:DocumentData;
			var reparented:Boolean;
			
			for (var i:int;i<numberOfAssets;i++) {
				addedAttachmentData = assets.getItemAt(i) as DocumentData;
				
				if (attachmentData.id==addedAttachmentData.id && addedAttachmentData.id!=null) {
					found = true;
					break;
				}
			}

			
			if (documentData) {
				if (attachmentData.parentId != documentData.id) {
					attachmentData.parentId = documentData.id;
					reparented = true;
				}
			}
			
			if (!found) {
				assets.addItem(attachmentData);
			}
			
			if ((!found || reparented) && dispatchEvent) {
				dispatchAssetAddedEvent(attachmentData);
			}
		}
		
		/**
		 * Remove an asset from the documents assets collection
		 * */
		public function removeAssetFromDocument(assetData:IDocumentData, documentData:DocumentData, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var index:int = assets.getItemIndex(assetData);
			var removedInternally:Boolean;
			
			if (index!=-1) {
				assets.removeItemAt(index);
				removedInternally = true;
			}
			
			if (remote && assetData && assetData.id) { 
				// we need to create service
				if (deleteAttachmentService==null) {
					deleteAttachmentService = new WPService();
					deleteAttachmentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteAttachmentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteAttachmentService.host = getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteAttachmentService.deleteAttachment(int(assetData.id), true);
			}
			/*else if (remote) { // document not saved yet because no ID
				
				if (dispatchEvents) {
					dispatchAssetRemovedEvent(iDocumentData, removedInternally);
					return removedInternally;
				}
			}
			else {
	
				if (dispatchEvents) {
					dispatchAssetRemovedEvent(iDocumentData, removedInternally);
					return removedInternally;
				}

			}*/
			
			dispatchAssetRemovedEvent(assetData, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * Remove assets from the documents assets collection
		 * */
		public function removeAssetsFromDocument(attachments:Array, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var removedInternally:Boolean;
			var attachmentData:AttachmentData;
			var attachmentIDs:Array = [];
			var numberOfAttachments:int;
			var index:int;
			
			numberOfAttachments = attachments ? attachments.length : 0;
			
			for (var i:int; i < numberOfAttachments; i++) {
				attachmentData = attachments[i];
				index = assets.getItemIndex(attachmentData);
				
				if (index>-1) {
					assets.removeItemAt(index);
					removedInternally = true;
				}
			}
			
			
			if (remote && attachments && attachments.length) { 
				// we need to create service
				if (deleteAttachmentsService==null) {
					deleteAttachmentsService = new WPService();
					deleteAttachmentsService.addEventListener(WPService.RESULT, deleteAttachmentsResultsHandler, false, 0, true);
					deleteAttachmentsService.addEventListener(WPService.FAULT, deleteAttachmentsFaultHandler, false, 0, true);
				}
				
				deleteAttachmentsService.host = getWPURL();
				
				deleteAttachmentsInProgress = true;
				
				for (var j:int = 0; j < attachments.length; j++) {
					attachmentData = attachments[j];
					
					if (attachmentData.id!=null) {
						attachmentIDs.push(attachmentData.id);
					}
				}
				
				if (attachmentIDs.length) {
					deleteAttachmentsService.deleteAttachments(attachmentIDs, true);
				}
				else {
					dispatchAttachmentsDeletedEvent(true, {localDeleted:true});
				}
			}
			
			// dispatch assets removed 
			// later dispatch attachment deleted event when result comes back from server 
			dispatchAssetsRemovedEvent(attachments, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * Adds PSD to the document. <br/>
		 * Adds assets to the library and document<br/>
		 * Missing support for masks, shapes and text (text is shown as image)<br/>
		 * Can take quite a while to import. <br/>
		 * Could use performance testing.
		 * */
		public function addPSDToDocument(psdFileData:ByteArray, iDocument:IDocument, matchDocumentSizeToPSD:Boolean = true, addToAssets:Boolean = true):void {
			
			if (documentThatPasteOfFilesToBeLoadedOccured==null) {
				documentThatPasteOfFilesToBeLoadedOccured = iDocument;
			}
			
			PSDImporter.addPSDToDocument(documentThatPasteOfFilesToBeLoadedOccured, psdFileData, iDocument, matchDocumentSizeToPSD, addToAssets, pasteFileLoader, dropFileLoader);
			
		}
		
		/**
		 * Adds bitmap data to the document
		 * */
		public function addBase64ImageDataToDocument(iDocument:IDocument, fileData:FileData, destination:Object = null, name:String = null, addComponent:Boolean = true, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):void {
			var bitmapData:BitmapData = DisplayObjectUtils.getBitmapDataFromBase64(fileData.dataURI, null, true, fileData.type);
			if (destination==null) destination = getDestinationForExternalFileDrop();
			var imageData:ImageData = addBitmapDataToDocument(iDocument, bitmapData, destination, fileData.name, addComponent, resizeIfNeeded, resizeDocumentToContent);
			
			// it's possible we weren't able to determine the dimensions of the image
			// so we add a listener to check after loading it with a loader
			var contentLoaderInfo:LoaderInfo = DisplayObjectUtils.loader.contentLoaderInfo;
			// save a reference to the loader info so it doesn't get garbage collected
			bitmapDictionary[contentLoaderInfo] = lastCreatedComponent;
			contentLoaderInfo.addEventListener(Event.INIT, handleLoadingImages, false, 0, true);
		}
		
		public function handleLoadingImages(event:Event):void {
			var newBitmapData:BitmapData;
			var bitmap:Bitmap;
			var contentLoaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			var componentInstance:Object = bitmapDictionary[contentLoaderInfo];
			
			if (contentLoaderInfo.loader.content) {
				bitmap = contentLoaderInfo.loader.content as Bitmap;
				newBitmapData = bitmap ? bitmap.bitmapData : null;
			}
			
			if (newBitmapData && componentInstance) {
				
				if (newBitmapData.compare(componentInstance.bitmapData)!=0) {
					
					const WIDTH:String = "width";
					const HEIGHT:String = "height";
					
					var properties:Array = [];
					var propertiesObject:Object;
					var documentProperties:Array = [];
					var documentPropertiesObject:Object;
					var imageData:ImageData;
					var originalBitmapData:BitmapData;
					
					//originalBitmapData = componentInstance.bitmapData; returns a clone use image.source 
					originalBitmapData = componentInstance.source;
					imageData = getImageDataFromBitmapData(originalBitmapData);
					
					if (imageData.resizeDocumentToFit) {
						documentPropertiesObject = {};
						documentPropertiesObject[WIDTH] = newBitmapData.width;
						documentPropertiesObject[HEIGHT] = newBitmapData.height;
						documentProperties.push(WIDTH);
						documentProperties.push(HEIGHT);
						
						setProperties(selectedDocument.instance, documentProperties, documentPropertiesObject, "Document resized to image");
					}
					else if (imageData.resizeToFitDocument) {
						propertiesObject = getConstrainedImageSizeObject(selectedDocument, newBitmapData);
					}
					
					if (propertiesObject==null) {
						setProperty(componentInstance, "source", newBitmapData, "Source loaded");
					}
					else {
						propertiesObject.source = newBitmapData;
						properties.push(WIDTH);
						properties.push(HEIGHT);
						properties.push("source");
				
						setProperties(componentInstance, properties, propertiesObject, "Source loaded");
					}
					
					if (imageData) {
						imageData.bitmapData = newBitmapData;
					}
				}
			}
			
			if (contentLoaderInfo) {
				contentLoaderInfo.removeEventListener(Event.INIT, handleLoadingImages);
			}
			
			bitmapDictionary[contentLoaderInfo] = null;
			delete bitmapDictionary[contentLoaderInfo];
		}
		
		/**
		 * Adds an asset to the document
		 * */
		public function addImageDataToDocument(imageData:ImageData, iDocument:IDocument, constrainImageToDocument:Boolean = true, smooth:Boolean = true, constrainDocumentToImage:Boolean = false):Boolean {
			var item:ComponentDefinition;
			var application:Application;
			var componentInstance:Object;
			var path:String;
			var bitmapData:BitmapData;
			var resized:Boolean;
			
			item = ComponentManager.getComponentType("Image");
			
			
			application = iDocument && iDocument.instance ? iDocument.instance as Application : null;
			
			if (!application) {
				warn("No document instance was available to add image into. Create a new document and add the image to it manually");
				return false;
			}
			
			// set to true so if we undo it has defaults to start with
			componentInstance = ComponentManager.createComponentToAdd(iDocument, item, true);
			bitmapData = imageData.bitmapData;
			
			
			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			var styles:Array = [];
			var properties:Array = [];
			var propertiesObject:Object;
			var documentProperties:Array = [];
			var documentPropertiesObject:Object;
			
			if (constrainDocumentToImage) {
				documentPropertiesObject = {};
				documentPropertiesObject[WIDTH] = bitmapData.width;
				documentPropertiesObject[HEIGHT] = bitmapData.height;
				documentProperties.push(WIDTH);
				documentProperties.push(HEIGHT);
				setProperties(iDocument.instance, documentProperties, documentPropertiesObject, "Document resized to image");
			}
			else if (constrainImageToDocument) {
				propertiesObject = getConstrainedImageSizeObject(iDocument, bitmapData);
			}
			
			if (propertiesObject==null) {
				propertiesObject = {};
			}
			else {
				resized = true;
				properties.push(WIDTH);
				properties.push(HEIGHT);
			}
			
			propertiesObject.scaleMode = "stretch";
			properties.push("scaleMode");
			
			if (smooth) {
				properties.push("smooth");
				propertiesObject.smooth = true;
				
				// the bitmap is all white when smoothing quality is enabled (safari mac fp 25.0.0.171(
				// changing any settings such as smooth enable or disable then shows the image correctly
				// so disabling for now
				//styles.push("smoothingQuality");
				//propertiesObject.smoothingQuality = "high";
			}
			
			if (imageData is ImageData) {
				path = imageData.url;
				
				if (path) {
					propertiesObject.width = undefined;
					propertiesObject.height = undefined;
					propertiesObject.source = path;
					properties.push(WIDTH);
					properties.push(HEIGHT);
				}
				else if (imageData.bitmapData) {
					propertiesObject.source = imageData.bitmapData;
				}
				
				properties.push("source");
			}
			
			addElement(componentInstance, iDocument.instance, properties, styles, null, propertiesObject);
			
			updateComponentAfterAdd(iDocument, componentInstance);
			
			return resized;
		}
		
		/**
		 * Get the image data object that is contains this bitmap data.
		 * Note: Getting image.bitmapData returns a clone, bitmapdata.clone(). 
		 * Use image.source if it is bitmapData. 
		 * */ 
		public static function getImageDataFromBitmapData(bitmapData:BitmapData):ImageData {
			var assets:ArrayCollection = instance.assets;
			var numberOfAssets:int = assets.length;
			var imageData:ImageData;
			
			for (var i:int = 0; i < numberOfAssets; i++) {
				imageData = assets.getItemAt(i) as ImageData;
				
				if (imageData && imageData.bitmapData===bitmapData) {
					return imageData;
				}
			}
			
			return null;
		}
		
		/**
		 * Get bitmap data matching ImageData.uid.
		 * */
		public static function getBitmapDataFromImageDataID(uid:String):BitmapData {
			var assets:ArrayCollection = instance.assets;
			var numberOfAssets:int = assets.length;
			var imageData:ImageData;
			
			for (var i:int = 0; i < numberOfAssets; i++) {
				imageData = assets.getItemAt(i) as ImageData;
				
				if (imageData && imageData.uid===uid) {
					return imageData.bitmapData;
				}
			}
			
			return null;
		}
		
		public static function getConstrainedImageSizeObject(iDocument:IDocument, bitmapData:Object):Object {
			var properties:Array = [];
			var propertiesObject:Object = {};
			var aspectRatio:Number = 1;
			var constraintNeeded:Boolean;
			var resized:Boolean;

			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				aspectRatio = iDocument.instance.width/iDocument.instance.height;
				
				if (bitmapData.width>iDocument.instance.width) {
					//aspectRatio = bitmapData.width / iDocument.instance.width;
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "width", iDocument.instance.width);
					properties = [WIDTH, HEIGHT];
					constraintNeeded = true;
					resized = true;
				}
				
				if (constraintNeeded && propertiesObject.height>iDocument.instance.height) {
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "height", iDocument.instance.height);
					resized = true;
				}
				else if (!constraintNeeded && bitmapData.height>iDocument.instance.height) {
					// check height is not larger than document width
					// and document height is not larger than width
					//aspectRatio = bitmapData.height / iDocument.instance.height;
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "height", iDocument.instance.height);
					properties = [WIDTH, HEIGHT];
					resized = true;
				}
				
			}
			
			if (!resized) {
				return null; 
			}
			
			return propertiesObject; 
		}
		
		/**
		 * The canvas border.
		 * */
		public var canvasBorder:Object;
		
		/**
		 * The canvas background.
		 * */
		public var canvasBackground:Object;
		
		/**
		 * The canvas scroller.
		 * */
		public var canvasScroller:Scroller;
		
		/**
		 * Sets the canvas and canvas parent. Not sure if going to be used. 
		 * May use canvas property on document.
		 * */
		public function setCanvas(canvasBorder:Object, canvasBackground:Object, canvasScroller:Scroller, dispatchEvent:Boolean = true, cause:String = ""):void {
			//if (this.canvasBackground==canvasBackground) return;
			
			this.canvasBorder = canvasBorder;
			this.canvasBackground = canvasBackground;
			this.canvasScroller = canvasScroller;
			
			if (dispatchEvent) {
				instance.dispatchCanvasChangeEvent(canvasBackground, canvasBorder, canvasScroller);
			}
			
		}
		
		/**
		 * Sets the document
		 * */
		public function setProject(value:IProject, dispatchEvent:Boolean = true, cause:String = ""):void {
			selectedProject = value;
			/*if (_projects.length == 1 && projects==value) return;
			
			_projects = null;// without this, the contents of the array would change across all instances
			_projects = [];
			
			if (value) {
				_projects[0] = value;
			}*/
			
			if (dispatchEvent) {
				instance.dispatchProjectChangeEvent(selectedProject);
			}
			
		}
		
		/**
		 * Selects the target
		 * */
		public function setProjects(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _projects.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_projects[i] == null) {
					continue;
				}
				
				//removeHandlers(_projects[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null projects are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_projects = value;
			
			if (dispatchEvent) {
				instance.dispatchProjectsSetEvent(projects);
			}
			
		}
		
		/**
		 * Get document container for document
		 **/
		public function getDocumentContainer(value:IDocument):IDocumentContainer {
			return documentsContainerDictionary[value] as IDocumentContainer;
		}
		
		/**
		 * Selects the current document
		 * */
		public function selectDocument(value:IDocument, dispatchEvent:Boolean = true, cause:String = ""):void {
			var iDocumentContainer:IDocumentContainer;
			
			if (selectedDocument != value) {
				selectedDocument = value;
			}
			
			iDocumentContainer = documentsContainerDictionary[value] as IDocumentContainer;
			
			if (iDocumentContainer) {
				toolLayer = iDocumentContainer.toolLayer;
				canvasBorder = iDocumentContainer.canvasBorder;
				canvasBackground= iDocumentContainer.canvasBackground;
				canvasScroller = iDocumentContainer.canvasScroller;
				editorComponent = iDocumentContainer.editorComponent;
			}
			
			HistoryManager.history = selectedDocument ? selectedDocument.history : null;
			HistoryManager.history ? HistoryManager.history.refresh() : void;
			HistoryManager.updateUndoRedoBindings(selectedDocument, HistoryManager.getHistoryPosition(selectedDocument));
			
			if (dispatchEvent) {
				instance.dispatchDocumentChangeEvent(selectedDocument);
			}
			
		}
		
		/**
		 * Selects the documents
		 * */
		public function selectDocuments(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
			if (dispatchEvent) {
				instance.dispatchDocumentsSetEvent(documents);
			}
			
			
		}
		
		/**
		 * Selects the target
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setTarget(value:*, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = value && value is Array && value.length ? value[0] : value;
			
			if (target is IDocument) {
				//enterDebugger();
			}
			
			if (_targets.length == 1 && target==_tempTarget && reselect==false) {
				//return;
			}
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (value is Array) {
				//_targets = (value as Array).slice();
				_targets[0] = _tempTarget;
			}
			else {
				_targets[0] = value;
			}
			
			subTarget = null;
			property = null;
			propertyIndex = -1;
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(target);
			}
			
		}
		
		/**
		 * Selects the target
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setSubTarget(target:*, subTarget:*, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = target && target is Array && target.length ? target[0] : target;
			
			if (_targets.length == 1 && target==_tempTarget && reselect==false) {
				//return;
			}
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (target is Array) {
				//_targets = (value as Array).slice();
				_targets[0] = _tempTarget;
			}
			else {
				_targets[0] = target;
			}
			
			this.subTarget = subTarget;
			property = null;
			propertyIndex = -1;
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(target, false, null, -1, subTarget);
			}
			
		}
		
		/**
		 * Selects the target
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setTargetProperties(target:*, propertyName:*, propertyIndex:int = -1, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = target && target is Array && target.length ? target[0] : target;
			
			if (_targets.length == 1 && target==_tempTarget && reselect==false) {
				//return;
			}
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (target is Array) {
				//_targets = (value as Array).slice();
				_targets[0] = _tempTarget;
			}
			else {
				_targets[0] = target;
			}
			
			property = propertyName;
			propertyIndex = propertyName;
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(target, false, propertyName, propertyIndex);
			}
			
		}
		
		/**
		 * Selects the target
		 * 
		 * @see setTarget
		 * @see target
		 * @see targets
		 * */
		public function setTargets(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous targets
			var n:int = _targets.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_targets[i] == null) {
					continue;
				}
				
				//removeHandlers(_targets[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null targets are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_targets = value;
			
			subTarget = null;
			property = null;
			propertyIndex = -1;
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(_targets, true);
			}
			
		}
		
		/**
		 * Deselects the passed in targets
		 * */
		public function desetTargets(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			throw new Error("not done");
			
			// go through current targets and remove any that match the ones in the values
			
			// remove listeners from previous targets
			var targetsLength:int = _targets.length;
			var valuesLength:int = value ? value.length : 0;
			
			for (var i:int=0;i<targetsLength;i++) {
				for (var j:int=0;j<valuesLength;j++) {
					if (value[j]==_targets[i]) {
						_targets.splice(i,1);
						continue;
					}
				}
			}
			
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(_targets, true);
			}
		}
		
		/**
		 * Deselects the target
		 * */
		public function deselectedTarget(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			// go through current targets and remove any that match the ones in the values
			setTarget(null, dispatchEvent, cause);
			
		}
		
		/**
		 * Deselects the target
		 * */
		public static function clearTarget(dispatchEvent:Boolean = true, cause:String = ""):void {
			setTarget(null, dispatchEvent, cause);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTarget(value:Object, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			instance.setTarget(value, dispatchEvent, cause, reselect);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTargets(value:Object, dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setTargets(value, dispatchEvent, cause);
		}
		
		/**
		 * Selects the document
		 * */
		public static function setDocuments(value:Object, dispatchEvent:Boolean = false, cause:String = ""):void {
			instance.selectDocuments(value, dispatchEvent, cause);
		}
		
		/**
		 * Deselects the documents
		 * */
		public static function desetDocuments(dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.selectDocuments(null, dispatchEvent, cause);
		}
		
		/**
		 * Gets the display list of the current document
		 * */
		public static function getComponentDisplayList():ComponentDescription {
			return IDocumentContainer(instance.selectedDocument).componentDescription;
		}
	
		/**
		 * Get MXML source of the document 
		 * */
		public static function getMXML(iDocument:IDocument, target:Object = null, options:ExportOptions = null):SourceData {
			var options:ExportOptions;
			var sourceItemData:SourceData;

			if (options==null) {
				options = new ExportOptions();
				options.useInlineStyles = true;
				options.exportChildDescriptors = true;
			}
			
			if (target==null) {
				target = iDocument.componentDescription.instance;
			}
			
			if (iDocument.getItemDescription(target)) {
				sourceItemData = CodeManager.getSourceData(target, iDocument, CodeManager.MXML, options);
				
				if (sourceItemData) {
					return sourceItemData;
				}
			}
			
			return null;
		}
		
		/**
		 * Get destination component or application when image files are 
		 * dropped from an external source
		 * */
		public function getDestinationForExternalFileDrop():Object {
			var destination:Object = target;
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
		
		public function dropItemWeb(object:Object, createNewDocument:Boolean = false, createDocumentIfNeeded:Boolean = true, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):void {
			var fileData:FileData;
			var byteArray:ByteArray;
			var destination:Object;
			var htmlDragData:HTMLDragData;
			var extension:String;
			var hasPSD:Boolean;
			var hasMXML:Boolean;
			var hasFXG:Boolean;
			var hasSVG:Boolean;
			var hasImage:Boolean;
			var fileSafeList:Array;
			var value:String;
			var smooth:Boolean = true;
			fileSafeList = [];
			
			if (object is HTMLDragEvent) {
				htmlDragData = object.data as HTMLDragData;
			}
			else if (object is HTMLDragData) {
				htmlDragData = object as HTMLDragData;
			}
			
			if (htmlDragData.mimeType==HTMLDragManager.INVALID) {
				warn("The dropped file was not valid.");
				return;
			}
			
			fileData = new FileData(htmlDragData);
			ViewManager.mainView.dropImagesLocation.visible = false;
			extension = htmlDragData.getExtension();
			
			if (extension=="png" || 
				extension=="jpg" || 
				extension=="jpeg" || 
				extension=="gif") {
				hasImage = true;
				fileSafeList.push(fileData);
			}
			else if (extension=="psd") {
				fileSafeList.push(fileData);
				hasPSD = true;
			}
			else if (extension=="mxml") {
				fileSafeList.push(fileData);
				hasMXML = true;
			}
			else if (extension=="fxg") {
				fileSafeList.push(fileData);
				hasFXG = true;
			}
			else if (extension=="svg") {
				fileSafeList.push(fileData);
				hasSVG = true;
			}
			else {
				//path_txt = "Not a recognised file format";  
			}
			
			if (createNewDocument || (createDocumentIfNeeded && selectedDocument==null)) {
				createNewDocumentAndSwitchToDesignView(htmlDragData, selectedProject, resizeIfNeeded, resizeDocumentToContent);
			}
			else {
				if (hasImage) {
					addBase64ImageDataToDocument(selectedDocument, fileData, destination, fileData.name, true, resizeIfNeeded, resizeDocumentToContent);
				}
				else if (hasPSD) {
					byteArray = htmlDragData.getByteArray();
					addPSDToDocument(byteArray, selectedDocument);
				}
				else if (hasMXML) {
					value = htmlDragData.getString();
					importMXMLDocument(selectedProject, selectedDocument, value, selectedDocument.instance);
				}
				else if (hasFXG) {
					value = htmlDragData.getString();
					importFXGDocument(selectedProject, selectedDocument, value, selectedDocument.instance);
				}
				else if (hasSVG) {
					value = htmlDragData.getString();
					importSVGDocument(selectedProject, selectedDocument, value, selectedDocument.instance);
				}
			}
		}
		
		public function dropItem(event:DragEvent, createNewDocument:Boolean = false):void {
			var dragSource:DragSource;
			var hasFileListFormat:Boolean;
			var hasFilePromiseListFormat:Boolean;
			var hasURLFormat:Boolean;
			var isSelf:Boolean;
			var AIR_URL:String = "air:url";
			var isHTMLPreviewOpen:Boolean;
			
			AIR_URL = ClipboardFormats.URL_FORMAT;
			
			dragSource = event.dragSource;
			hasFileListFormat = dragSource.hasFormat(ClipboardFormats.FILE_LIST_FORMAT);
			hasFilePromiseListFormat = dragSource.hasFormat(ClipboardFormats.FILE_PROMISE_LIST_FORMAT);
			hasURLFormat = dragSource.hasFormat(AIR_URL);
			
			isHTMLPreviewOpen = instance.isDocumentPreviewOpen(instance.selectedDocument);
			
			
			var destination:Object;
			var droppedFiles:Array;
			
			if (isAcceptableDragAndDropFormat(dragSource)) {
				
				if (hasFileListFormat) {
					droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				}
				else if (hasFilePromiseListFormat) {
					droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_PROMISE_LIST_FORMAT) as Array;
				}
				
				// not handling URL format. need to load it and check the file type
				else if (hasURLFormat) {
					
					// if internal html preview is visible we should return false since
					if (isHTMLPreviewOpen) {
						
						// dragged images are triggering the drop panel
					}
					
					return;
				}
				
				if (droppedFiles) {
					
					if (selectedDocument==null || createNewDocument) {
						createNewDocumentAndSwitchToDesignView(droppedFiles, selectedProject);
					}
					else if (selectedDocument) {
						destination = getDestinationForExternalFileDrop();
						addFileListDataToDocument(selectedDocument, droppedFiles as Array, destination);
					}
					else {
						
					}
				}
				
			}
			
			// Error: Attempt to access a dead clipboard
			//  at flash.desktop::Clipboard/checkAccess()
			//  at flash.desktop::Clipboard/getData()
			// Occurs when accessing a dragSource at a later time than the drop event
			// droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_LIST_FORMAT) as Array;
		}
		
		public function dropInBitmapData(bitmapData:BitmapData, createNewDocument:Boolean = false, createDocumentIfNeeded:Boolean = true):void {
			var fileData:FileData;
			var destination:Object;
			var imageData:ImageData;
			
			if (createNewDocument || (createDocumentIfNeeded && selectedDocument==null)) {
				createNewDocumentAndSwitchToDesignView(bitmapData, selectedProject);
			}
			else {
				destination = getDestinationForExternalFileDrop();
				imageData = addBitmapDataToDocument(selectedDocument, bitmapData, destination, null, true);
			}
		}
		
		/**
		 * Duplicates the selected items
		 * */
		public function duplicateItem(component:Object, destination:Object = null):Array {
			var exportOptions:ExportOptions;
			var sourceData:SourceData;
			var componentDescription:ComponentDescription;
			var newTargets:Array;
			var containerIndex:int = -1;
			
			exportOptions = new ExportOptions();
			exportOptions.useInlineStyles = true;
			exportOptions.exportChildDescriptors = true;
			
			if (selectedDocument) {
				if (component is ComponentDescription) {
					componentDescription = component as ComponentDescription;
				}
				else {
					componentDescription = selectedDocument.getItemDescription(component);
				}
			}
			else {
				warn("Please open a document before attempting to duplicate");
				return null;
			}
			
			// copy selection
			if (componentDescription) {
				sourceData = CodeManager.getSourceData(componentDescription, selectedDocument, CodeManager.MXML, exportOptions);
			}
			else {
				warn("Could not find item to duplicate in the selected document");
				return null;
			}
			
			// get destination
			if (destination && !(destination is IVisualElementContainer)) {
				destination = destination.owner;
			}
			
			// prevent containers from being duplicated into themselves
			if (componentDescription.instance==destination) {
				if (selectedDocument.instance.contains(destination.owner)) {
					destination = destination.owner;
				}
			}
			
			if (!destination) {
				if (componentDescription.parent) {
					destination = componentDescription.parent.instance;
				}
				
				if (!destination) {
					destination = selectedDocument.instance;
				}
			}
			
			// add duplicate
			sourceData = CodeManager.setSourceData(sourceData.source, destination, selectedDocument, CodeManager.MXML, containerIndex, null);
			
			// dispatch added items
			dispatchAddEvent(sourceData.targets, null, null);
			
			// select first target
			if (sourceData && sourceData.targets && sourceData.targets.length) { 
				setTarget(sourceData.targets[0], true, null, true);
			}
			else {
				setTarget(destination);
			}
			
			newTargets = sourceData.targets.slice();
			
			sourceData = null;
			
			return newTargets;
		}
		
		/**
		 * Used on select event when browsing for file
		 * */
		public function selectItem(files:Object):void {
			var destination:Object;
			var filesToAdd:Array = [];
			
			if (files is FileReferenceList) {
				filesToAdd = FileReferenceList(files).fileList;
			}
			else if (files is FileReference) {
				filesToAdd = [files];
			}
			else if (files is Array) {
				filesToAdd = (files as Array).slice();
			}
			
			if (filesToAdd && filesToAdd.length) {
				destination = getDestinationForExternalFileDrop();
				documentThatPasteOfFilesToBeLoadedOccured = selectedDocument;
				addFileListDataToDocument(selectedDocument, filesToAdd, destination);
			}
			else {
				warn("No files were selected.");
			}
				
		}
		
		/**
		 * Add file list data to a document
		 * */
		public function addFileListDataToDocument(iDocument:IDocument, fileList:Array, destination:Object = null, operation:String = "drop"):void {
			var createDocument:Boolean = false;
			
			if (fileList==null) {
				error("Not a valid file list");
				return;
			}
			
			if (fileList && fileList.length==0) {
				error("No files in the file list");
				return;
			}
			
			if (iDocument==null) {
				
				if (createDocument) {
					iDocument = createNewDocumentAndSwitchToDesignView(fileList);
				}
				else {
					error("No document is open. Create a new document first. ");
					return;
				}
			}
			
			var urlFormatData:Object;
			var path_txt:String;
			var extension:String;
			var fileSafeList:Array;
			var hasPSD:Boolean;
			var hasMXML:Boolean;
			var hasFXG:Boolean;
			var hasSVG:Boolean;
			var extensionIndex:int;
			
			fileSafeList = [];
			
			// only accepting image files at this time
			for each (var file:FileReference in fileList) {
				if ("extension" in file) {
					extension = file.extension.toLowerCase();
				}
				else {
					extensionIndex = file.name.lastIndexOf(".");
					extension = extensionIndex!=-1 ? file.name.substring(extensionIndex+1) : null;
				}
				
				if (extension=="png" || 
					extension=="jpg" || 
					extension=="jpeg" || 
					extension=="gif") {
					fileSafeList.push(file);
				}
				else if (extension=="psd") {
					fileSafeList.push(file);
					hasPSD = true;
				}
				else if (extension=="mxml") {
					fileSafeList.push(file);
					hasMXML = true;
				}
				else if (extension=="fxg") {
					fileSafeList.push(file);
					hasFXG = true;
				}
				else if (extension=="svg") {
					fileSafeList.push(file);
					hasSVG = true;
				}
				else {
					path_txt = "Not a recognised file format";  
				}
			}
			
			var fileLoader:LoadFile;
			
			const PASTE:String = "paste";
			const DROP:String = "drop";
			
			if (operation==PASTE) {
				setupPasteFileLoader();
				fileLoader = pasteFileLoader;
			}
			else if (operation==DROP) {
				setupDropFileLoader();
				fileLoader = dropFileLoader;
			}
			
			
			fileLoader.removeReferences(true);
			
			
			if (!hasPSD && !hasMXML && !hasSVG && !hasFXG) {
				fileLoader.loadIntoLoader = true;
			}
			else {
				fileLoader.loadIntoLoader = false;
			}
			
			if (fileSafeList.length>0) {
				
				if (fileSafeList.length>1 && hasPSD) {
					warn("You cannot load a PSD and image files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasMXML) {
					warn("You cannot load a MXML file and other files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasFXG) {
					warn("You cannot load a FXG file and other files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasSVG) {
					warn("You cannot load a SVG file and other files at the same time. Select one or the other");
					return;
				}
				
				if (hasPSD) {
					loadingPSD = true;
				}
				else 
				if (hasMXML) {
					loadingMXML = true;
				}
				else 
				if (hasFXG) {
					loadingFXG = true;
				}
				else 
				if (hasSVG) {
					loadingSVG = true;
				}
				else {
					loadingPSD = false;
				}
				
				documentThatPasteOfFilesToBeLoadedOccured = iDocument;
				
				fileLoader.filesArray = fileSafeList;
				fileLoader.play();
			}
			else {
				documentThatPasteOfFilesToBeLoadedOccured = null;
				info("No files of the acceptable type were found. Acceptable files are PNG, JPEG, GIF, PSD");
			}
		}
		
		public var pasteFileLoader:LoadFile;
		public var dropFileLoader:LoadFile;
		public var documentThatPasteOfFilesToBeLoadedOccured:IDocument;
		public var loadingMXML:Boolean;
		public var loadingFXG:Boolean;
		public var loadingSVG:Boolean;
		public var loadingPSD:Boolean;
		
		protected function setupPasteFileLoader():void {
			if (pasteFileLoader==null) {
				pasteFileLoader = new LoadFile();
				//pasteFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, pasteFileCompleteHandler, false, 0, true);
				//pasteFileLoader.addEventListener(LoadFile.COMPLETE, pasteFileCompleteHandler, false, 0, true);
				pasteFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, dropFileCompleteHandler, false, 0, true);
				pasteFileLoader.addEventListener(LoadFile.COMPLETE, dropFileCompleteHandler, false, 0, true);
			}
		}
		
		// mostly a duplicate of setup paste file loader but haven't had chance to test it 
		protected function setupDropFileLoader():void {
			if (dropFileLoader==null) {
				dropFileLoader = new LoadFile();
				dropFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, dropFileCompleteHandler, false, 0, true);
				dropFileLoader.addEventListener(LoadFile.COMPLETE, dropFileCompleteHandler, false, 0, true);
			}
		}
		
		/**
		 * Occurs after files are dropped into the document are fully loaded 
		 * */
		protected function dropFileCompleteHandler(event:Event):void {
			var resized:Boolean;
			var imageData:ImageData;
			
			// if we need to load the images ourselves then skip complete event
			// and wait until loader complete event
			if (dropFileLoader.loadIntoLoader && event.type!=LoadFile.LOADER_COMPLETE) {
				return;
			}
			
			if (!documentThatPasteOfFilesToBeLoadedOccured) {
				error("No document was found to add a file into");
				return;
			}
			
			if (loadingPSD) {
				loadingPSD = false;
				info("Importing PSD");
				callAfter(250, addPSDToDocument, dropFileLoader.data, documentThatPasteOfFilesToBeLoadedOccured);
				return;
			}
			
			if (loadingMXML) {
				loadingMXML = false;
				info("Importing MXML");
				callAfter(250, importMXMLDocument, selectedProject, documentThatPasteOfFilesToBeLoadedOccured, dropFileLoader.dataAsString, documentThatPasteOfFilesToBeLoadedOccured.instance);
				return;
			}
			
			if (loadingFXG) {
				loadingFXG = false;
				info("Importing FXG");
				callAfter(250, importFXGDocument, selectedProject, documentThatPasteOfFilesToBeLoadedOccured, dropFileLoader.dataAsString, documentThatPasteOfFilesToBeLoadedOccured.instance);
				return;
			}
			
			if (loadingSVG) {
				loadingSVG = false;
				info("Importing SVG");
				callAfter(250, importSVGDocument, selectedProject, documentThatPasteOfFilesToBeLoadedOccured, dropFileLoader.dataAsString, documentThatPasteOfFilesToBeLoadedOccured.instance);
				return;
			}
			
			imageData = new ImageData();
			imageData.bitmapData = dropFileLoader.bitmapData;
			imageData.byteArray = dropFileLoader.data;
			imageData.name = dropFileLoader.currentFileReference.name;
			imageData.contentType = dropFileLoader.loaderContentType;
			imageData.file = dropFileLoader.currentFileReference;
			
			addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured);
			resized = addImageDataToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured);
			//list.selectedItem = data;
			
			//uploadAttachment(fileLoader.fileReference);
			
			if (resized) {
				info("An image was added to the library and the document and resized to fit");
			}
			else {
				info("An image was added to the library");
			}
			
			setTarget(lastCreatedComponent);
			
			dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, resized, true);
		}
		
		/**
		 * Add bitmap data to a document
		 * */
		public function addBitmapDataToDocument(iDocument:IDocument, bitmapData:BitmapData, destination:Object = null, name:String = null, addComponent:Boolean = false, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):ImageData {
			if (bitmapData==null) {
				error("Not valid bitmap data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (bitmapData==null || iDocument==null) {
				return null;
			}
			
			var imageData:ImageData = new ImageData();
			var resized:Boolean;
			var smooth:Boolean = true;
			
			imageData.bitmapData = bitmapData;
			imageData.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(bitmapData);
			
			if (name==null) {
				if (destination) {
					name = ClassUtils.getIdentifierNameOrClass(destination) + ".png";
				}
				else {
					name = ClassUtils.getIdentifierNameOrClass(bitmapData) + ".png";
				}
			}
			
			imageData.name = name;
			imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
			imageData.file = null;
			
			imageData.resizeToFitDocument = resizeIfNeeded;
			imageData.resizeDocumentToFit = resizeDocumentToContent;
			
			if (addComponent) {
				resized = addImageDataToDocument(imageData, iDocument, resizeIfNeeded, smooth, resizeDocumentToContent);
				
				//uploadAttachment(fileLoader.fileReference);
				if (resized) {
					info("Image was added to the library and the document and resized to fit");
				}
				else {
					info("Image was added to the library and the document");
				}
				
				setTarget(lastCreatedComponent);
				
				//dispatchAssetLoadedEvent(imageData, iDocument, resized, true);
			}
			
			addAssetToDocument(imageData, iDocument);
			
			return imageData;
			//info("An image from the clipboard was added to the library");
		}
		
		/**
		 * Add text data to a document
		 * */
		public function addTextDataToDocument(iDocument:IDocument, text:String, destination:Object = null, useRichText:Boolean = true):void {
			if (text==null || text=="") {
				error("Not valid text data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (text==null || iDocument==null) {
				return;
			}
			var componentType:String = useRichText ? "spark.components.RichText" : "spark.components.Label";
			var definition:ComponentDefinition =  ComponentManager.getDynamicComponentType(componentType, true);
			var component:Object = ComponentManager.createComponentToAdd(iDocument, definition, false);
			
			if (useRichText) {
				var textFlow:TextFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);
				addElement(component, destination, ["textFlow"], null, null, {textFlow:textFlow});
			}
			else {
				addElement(component, destination, ["text"], null, null, {text:text});
			}
			
			updateComponentAfterAdd(iDocument, component);
			
			//info("Text from the clipboard was added to the document");
		}
		
		/**
		 * Add html data to a document. The importer is awful 
		 * */
		public function addHTMLDataToDocument(iDocument:IDocument, text:String, destination:Object = null):void {
			if (text==null || text=="") {
				error("Not valid text data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (text==null || iDocument==null) {
				return;
			}
			
			var definition:ComponentDefinition =  ComponentManager.getDynamicComponentType("spark.components.RichText", true);
			
			if (!definition) {
				return;
			}
			
			var componentInstance:RichText = ComponentManager.createComponentToAdd(iDocument, definition, false) as RichText;
			var formatter:HTMLFormatterTLF = HTMLFormatterTLF.staticInstance;
			var translatedHTMLText:String;
			var textFlow:TextFlow;
			
			formatter.replaceLinebreaks = true;
			formatter.replaceMultipleBreaks = true;
			formatter.replaceEmptyBlockQoutes = true;
			translatedHTMLText = formatter.format(text);
			textFlow = TextConverter.importToFlow(translatedHTMLText, TextConverter.TEXT_FIELD_HTML_FORMAT);
			
			componentInstance.textFlow = textFlow;
			
			addElement(componentInstance, destination, ["textFlow"], null, null, {textFlow:textFlow});
			
			updateComponentAfterAdd(iDocument, componentInstance);
			
			//info("HTML from the clipboard was added to the library");
		}
		
		public static var acceptablePasteFormats:Array = ["Object", "UIComponent", "air:file list", 
														"air:url", "air:bitmap", "air:text"];
		public static var acceptableDropFormats:Array = ["UIComponent", "air:file list", "air:url", "air:bitmap"];
		
		/**
		 * Returns true if it's a type of content we can accept to be pasted in
		 * */
		public static function isAcceptablePasteFormat(formats:Array):Boolean {
			if (formats==null || formats.length==0) return false;
			
			if (ArrayUtils.containsAny(formats, acceptablePasteFormats)) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if it's a type of content we can accept to be dragged and dropped.
		 * If we are dragging a UIComponent we don't want to accept it by default because
		 * it could be us dragging a component around the design view
		 * */
		public static function isAcceptableDragAndDropFormat(dragSource:DragSource, includeUIComponents:Boolean = false):Boolean {
			if (dragSource==null) return false;
			
			if ((dragSource.hasFormat("UIComponent") && includeUIComponents) || 
				dragSource.hasFormat("air:file list") || 
				dragSource.hasFormat("air:url") || 
				dragSource.hasFormat("air:bitmap")) {
				var url:String;
				
				// if internal html preview is visible we should return false since
				// dragged images are triggering the drop panel
				if (instance.isDocumentPreviewOpen(instance.selectedDocument) && 
					dragSource.hasFormat("air:url")) {
					// http://www.radii8.com/.../image.jpg
					//url = dragSource.dataForFormat(ClipboardFormats.URL_FORMAT) as String;
					return false;
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Creates a new project and document and if a file is 
		 * provided then it imports the file and sizes the document to the fit. 
		 * 
		 * This is to support drag and drop of file onto application icon
		 * and open with methods. 
		 * */
		public function createNewDocumentAndSwitchToDesignView(file:Object = null, iProject:Object = null, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):IDocument {
			var documentName:String = "Document";
			var iDocument:IDocument;
			
			fileToBeLoaded = file;
			resizeNewFileIfNeeded = resizeIfNeeded;
			resizeDocumentToNewFileIfNeeded = resizeDocumentToContent;
			
			ViewManager.goToDesignScreen();
			
			if (fileToBeLoaded) {
				addEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler, false, 0, true);
			}
			
			iDocument = createBlankDemoDocument(iProject, documentName);
			
			
			if (isUserLoggedIn && iDocument) {
				saveProjectOnly(iDocument.project);
			}
			
			return iDocument
		}
		
		public var fileToBeLoaded:Object;
		public var resizeNewFileIfNeeded:Boolean;
		public var resizeDocumentToNewFileIfNeeded:Boolean;
		
		public function documentOpenedHandler(event:RadiateEvent):void {
			var iDocument:IDocument = event.selectedItem as IDocument;
			var newFileData:Object = fileToBeLoaded;
			var fileData:FileData;
			var destination:Object;
			
			if (newFileData is FileReference) {
				if (newFileData.exists && newFileData.isDirectory==false) {
					addEventListener(RadiateEvent.ASSET_LOADED, fileLoadedHandler, false, 0, true);
					addFileListDataToDocument(iDocument, [newFileData]);
				}
			}
			else if (newFileData is DragEvent) {
				dropItem(newFileData as DragEvent);
			}
			else if (newFileData is HTMLDragData) {
				dropItemWeb(newFileData, false, true, resizeNewFileIfNeeded, resizeDocumentToNewFileIfNeeded);
			}
			else if (newFileData is FileData) {
				fileData = newFileData as FileData;
				addBase64ImageDataToDocument(selectedDocument, fileData, null, fileData.name, true, resizeNewFileIfNeeded, resizeDocumentToNewFileIfNeeded);
			}
			else if (newFileData is Array && newFileData.length) {
				//destination = getDestinationForExternalFileDrop();
				addFileListDataToDocument(selectedDocument, fileToBeLoaded as Array);
			}
			else if (newFileData is BitmapData) {
				addBitmapDataToDocument(selectedDocument, newFileData as BitmapData, null, null, true, resizeNewFileIfNeeded, resizeDocumentToNewFileIfNeeded);
			}
			
			removeEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler);
			
			resizeNewFileIfNeeded = false;
		}
		
		protected function fileLoadedHandler(event:RadiateEvent):void {
			var successful:Boolean = event.successful;
			var imageData:ImageData = event.data as ImageData;
			var iDocument:IDocument = event.selectedItem as IDocument;
			var importedImageResized:Boolean = event.resized;
			var bitmapData:BitmapData = imageData && imageData.bitmapData ? imageData.bitmapData : null;
			var fileReference:FileReference;
			
			removeEventListener(RadiateEvent.ASSET_LOADED, fileLoadedHandler);
			
			if (!successful) {
				warn("File was not imported.");
				return;
			}
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				RadiateUtilities.sizeDocumentToBitmapData(iDocument, bitmapData);
				
				if (importedImageResized && target) {
					RadiateUtilities.sizeSelectionToDocument();
				}
				
				ScaleManager.scaleToFit(false);
				RadiateUtilities.centerApplication();
			}
			
		}
		
		/**
		 * Get values object from attributes and child tags on a component from XML node
		 * */
		public static function getPropertiesStylesEventsFromNode(elementInstance:Object, 
																 node:XML, 
																 item:ComponentDefinition = null):ValuesObject {
			var attributeName:String;
			var attributes:Array;
			var childNodeNames:Array;
			var qualifiedChildNodeNames:Array;
			var childNodeNamespaces:Array;
			var propertiesStylesEvents:Array;
			var attributePropertiesStylesEvents:Array;
			var childNodePropertiesStylesEvents:Array;
			var properties:Array;
			var styles:Array;
			var events:Array;
			var childProperties:Array;
			var childStyles:Array;
			var childEvents:Array;
			var attributesValueObject:Object;
			var childNodeValueObject:Object = {};
			var qualifiedChildNodeValueObject:Object = {};
			var defaultPropertyObject:Object;
			var values:Object = {};
			var valuesObject:ValuesObject;
			var failedToImportStyles:Object = {};
			var failedToImportProperties:Object = {};
			var qualifiedAttributes:Array;
			var defaultPropertyMetaData:MetaData;
			var defaultPropertyName:String;
			var styleClient:IStyleClient;
			var errors:Array = [];
			var handledChildNodeNames:Array = [];
			var elementName:String;
			var skipChildNodes:Boolean;
			var simpleContent:Boolean = true;
			var includeQualifiedNames:Boolean = true;
			var ignoreWhitespace:Boolean = true;
			
			styleClient = elementInstance as IStyleClient;
			elementName = node.localName();
			
			
			// Step 1. Get applicable attributes
			
			// get properties from attributes first
			attributes 				= XMLUtils.getAttributeNames(node);
			qualifiedAttributes 	= XMLUtils.getQualifiedAttributeNames(node);
			
			attributePropertiesStylesEvents = attributes.slice();
			
			properties 				= ClassUtils.getObjectsPropertiesFromArray(elementInstance, attributePropertiesStylesEvents, true);
			styles 					= ClassUtils.getObjectsStylesFromArray(elementInstance, attributePropertiesStylesEvents);
			events 					= ClassUtils.getObjectsEventsFromArray(elementInstance, attributePropertiesStylesEvents);
			
			attributePropertiesStylesEvents = properties.concat(styles).concat(events);
			
			// get concrete values from attribute string values
			if (attributePropertiesStylesEvents.length) {
				attributesValueObject 	= XMLUtils.getAttributesValueObject(node);
				attributesValueObject	= ClassUtils.getTypedStyleValueObject(styleClient, attributesValueObject, styles, failedToImportStyles);
				attributesValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, attributesValueObject, properties, failedToImportProperties);
				
				values					= attributesValueObject;
			}
			
			
			// Step 2. Get applicable child nodes
			
			// next get properties from child nodes 
			childNodeNames 			= XMLUtils.getChildNodeNames(node);
			childNodeNamespaces		= XMLUtils.getChildNodeNamesNamespace(node, true);
			qualifiedChildNodeNames	= XMLUtils.getQualifiedChildNodeNames(node);
			
			childProperties 		= ClassUtils.getObjectsPropertiesFromArray(elementInstance, childNodeNames, true);
			childStyles 			= ClassUtils.getObjectsStylesFromArray(elementInstance, childNodeNames);
			childEvents 			= ClassUtils.getObjectsEventsFromArray(elementInstance, childNodeNames);
			
			childNodePropertiesStylesEvents = childProperties.concat(childStyles).concat(childEvents);
			
			if (childNodePropertiesStylesEvents.length) {
				childNodeValueObject 	= XMLUtils.getChildNodesValueObject(node, includeQualifiedNames, simpleContent, false);
				qualifiedChildNodeValueObject 	= XMLUtils.getChildNodesValueObject(node, includeQualifiedNames, !simpleContent, false);
				
				// get concrete values from child node string values
				childNodeValueObject	= ClassUtils.getTypedStyleValueObject(styleClient, childNodeValueObject, childStyles, failedToImportStyles);
				childNodeValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, childNodeValueObject, childProperties, failedToImportProperties);
				//childNodeValueObject	= ClassUtils.getTypedEventValueObject(elementInstance, childNodeValueObject, childProperties, failedToImportProperties);
				
				values 					= ObjectUtils.merge(values, childNodeValueObject);
			}
			
			
			// Step 3. Get default property from child nodes
			
			// get default property if one is set
			defaultPropertyMetaData = ClassUtils.getMetaDataOfMetaData(elementInstance, MXMLDocumentConstants.DEFAULT_PROPERTY);
			
			defaultPropertyMetaData = null;
   			if (defaultPropertyMetaData!=null) {
				defaultPropertyName = defaultPropertyMetaData.value;
				defaultPropertyObject 	= XMLUtils.getDefaultPropertyValueObject(elementInstance, node, defaultPropertyName, includeQualifiedNames, ignoreWhitespace, [MXMLDocumentConstants.MXML_CONTENT_FACTORY, MXMLDocumentConstants.MXML_CONTENT]);
			
				if (defaultPropertyObject is Error) {
					errors.push(defaultPropertyObject);
				}
				else if (!ClassUtils.isEmptyObject(defaultPropertyObject)) {
					
					// get concrete values from default property string values
					defaultPropertyObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, defaultPropertyObject, [defaultPropertyName], failedToImportProperties);
					
					if (childProperties.indexOf(defaultPropertyName)==-1) {
						childProperties.push(defaultPropertyName);
					}
					
					if (childNodePropertiesStylesEvents.indexOf(defaultPropertyName)==-1) {
						childNodePropertiesStylesEvents.push(defaultPropertyName);
					}
					
					childNodeValueObject = ObjectUtils.merge(childNodeValueObject, defaultPropertyObject);
					
					childNodeNames.push(defaultPropertyMetaData.value);
					
					values = ObjectUtils.merge(values, defaultPropertyObject);
					
					skipChildNodes = true;
				}
			}
			
			propertiesStylesEvents = attributePropertiesStylesEvents.concat(childNodePropertiesStylesEvents);
			
			for (var property:String in values) {
				if (childNodeNames.indexOf(property)!=-1) {
					if (childNodePropertiesStylesEvents.indexOf(property)!=-1) {
						handledChildNodeNames.push(property);
					}
				}
			}
			
			valuesObject 							= new ValuesObject();
			valuesObject.values 					= values;

			valuesObject.styles 					= styles;
			valuesObject.properties 				= properties;
			valuesObject.events		 				= events;
			valuesObject.attributes 				= attributes;
			valuesObject.qualifiedAttributes		= qualifiedAttributes;
			
			valuesObject.childStyles	 			= childStyles;
			valuesObject.childProperties 			= childProperties;
			valuesObject.childEvents		 		= childEvents;
			valuesObject.childNodeNames 			= childNodeNames;
			valuesObject.qualifiedChildNodeNames 	= qualifiedChildNodeNames;
			valuesObject.childNodeValues 			= childNodeValueObject;
			valuesObject.qualifiedChildNodeValues 	= qualifiedChildNodeValueObject;
			
			valuesObject.defaultPropertyObject		= defaultPropertyObject;
			
			valuesObject.errors						= errors;
			valuesObject.stylesErrorsObject 		= failedToImportStyles;
			valuesObject.propertiesErrorsObject 	= failedToImportProperties;
			
			valuesObject.attributesNotFound			= ArrayUtils.removeAllItems(attributes, attributePropertiesStylesEvents);
			valuesObject.childNodesNotFound			= ArrayUtils.removeAllItems(childNodeNames, childNodePropertiesStylesEvents);
			
			valuesObject.attributePropertiesStylesEvents	= attributePropertiesStylesEvents;
			valuesObject.childNodePropertiesStylesEvents	= childNodePropertiesStylesEvents;
			valuesObject.propertiesStylesEvents				= propertiesStylesEvents;
			
			valuesObject.handledChildNodeNames				= handledChildNodeNames;
			valuesObject.skipChildNodes						= skipChildNodes;
			
			//valuesObject.nonNsAttributesNotFound	= ArrayUtils.removeAllItems(qualifiedAttributes, valuesObject.propertiesStylesEvents);
			
			/*
			var a:Object = node.namespace().prefix;     //returns prefix i.e. rdf
			var b:Object = node.namespace().uri;        //returns uri of prefix i.e. http://www.w3.org/1999/02/22-rdf-syntax-ns#
			
			var c:Object = node.inScopeNamespaces();   //returns all inscope namespace as an associative array like above
			
			//returns all nodes in an xml doc that use the namespace
			var nsElement:Namespace = new Namespace(node.namespace().prefix, node.namespace().uri);
			
			var usageCount:XMLList = node..nsElement::*;*/
			
			return valuesObject;
		}
		
		/**
		 * Get value object on a component from a properties object
		 * */
		public static function getPropertiesStylesFromObject(elementInstance:Object, dataObject:Object, item:ComponentDefinition = null):ValuesObject {
			var properties:Array;
			var styles:Array;
			var aValueObject:Object;
			var childNodeValueObject:Object;
			var valuesObject:ValuesObject;
			var values:Object = {};
			var failedToImportStyles:Object = {};
			var failedToImportProperties:Object = {};
			
			properties 				= ClassUtils.getPropertiesFromObject(elementInstance, dataObject, true);
			styles 					= ClassUtils.getStylesFromObject(elementInstance, dataObject);
			
			values					= ClassUtils.getTypedPropertyValueObject(elementInstance, dataObject, properties, failedToImportProperties);
			values					= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, dataObject, styles, failedToImportStyles);
			
			
			valuesObject 						= new ValuesObject();
			valuesObject.values 				= values;
			valuesObject.styles 				= styles;
			valuesObject.properties 			= properties;
			valuesObject.stylesErrorsObject 	= failedToImportStyles;
			valuesObject.propertiesErrorsObject = failedToImportProperties;
			valuesObject.propertiesStylesEvents	= properties.concat(styles);
			
			
			return valuesObject;
		}
		
		/**
		 * Removes explict size on a component object because 
		 * we are setting default width and height when creating the component.
		 * I don't know a better way to do this. Maybe use setActualSize but I 
		 * don't think the size stays if you go back and forth in history???
		 * */
		public static function removeExplictSizeOnComponent(elementInstance:Object, node:XML, item:ComponentDefinition = null, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			
			var hasWidthAttribute:Boolean = ("@width" in node);
			var hasHeightAttribute:Boolean = ("@height" in node);
			var hasWidthDefault:Boolean = item.defaultProperties && item.defaultProperties.width;
			var hasHeightDefault:Boolean = item.defaultProperties && item.defaultProperties.height;
			
			
			// a default height was set but the user removed it so we need to remove it
			// flex doesn't support a height="auto" or height="content" type of value 
			// flex just removes the height attribute in XML altogether 
			// so if it is not in the mxml then we have to set the size to undefined 
			if (hasHeightDefault && !hasHeightAttribute) {
				//setProperty(elementInstance, "height", undefined, null, true, dispatchEvents);
				elementInstance["height"] = undefined;
			}
			
			if (hasWidthDefault && !hasWidthAttribute) {
				//setProperty(elementInstance, "width", undefined, null, true, dispatchEvents);
				elementInstance["width"] = undefined;
			}
		}
		
		/**
		 * Set attributes on a component object
		 * */
		public static function setAttributesOnComponent(elementInstance:Object, node:XML, item:ComponentDefinition = null, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			//var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			//var componentDefinition:ComponentDefinition = Radiate.getComponentType(elementName);
			//var className:String =componentDefinition ? componentDefinition.className :null;
			//var classType:Class = componentDefinition ? componentDefinition.classType as Class :null;
			//var elementInstance:Object = componentDescription.instance;
			
			var properties:Array = [];
			var styles:Array = [];
			var valueObject:Object = {};
			
			for each (var attribute:XML in node.attributes()) {
				attributeName = attribute.name().toString();
				//Radiate.info(" found attribute: " + attributeName); 
				
				
				// TODO we should check if an attribute is an property, style or event using the component definition
				// We can do it this way now since we are only working with styles and properties
				
				
				// check if property 
				if (attributeName in elementInstance) {
					
					//Radiate.info(" setting property: " + attributeName);
					//setProperty(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
				 	properties.push(attributeName);
					valueObject[attributeName] = attribute.toString();
				}
				
				// could be style or event
				else {
					if (elementInstance is IStyleClient) {
						//Radiate.info(" setting style: " + attributeName);
						//setStyle(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
						styles.push(attributeName);
						valueObject[attributeName] = attribute.toString();
					}
				}
			}
			
			if (styles.length || properties.length) {
				var propertiesStyles:Array = styles.concat(properties);
				setPropertiesStylesEvents(elementInstance, propertiesStyles, valueObject);
			}
			
			
			removeExplictSizeOnComponent(elementInstance, node, item);
		}
		
		/**
		 * Returns true if the style was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearStyle(myButton, "fontFamily");</pre>
		 * */
		public static function clearStyle(target:Object, style:String, description:String = null, dispatchEvents:Boolean = true):Boolean {
			
			return setStyle(target, style, undefined, description, true, dispatchEvents);
		}
		
		/**
		 * Clears the styles of the target.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearStyles(myButton, ["fontFamily", "fontWeight"]);</pre>
		 * */
		public static function clearStyles(target:Object, styles:Array, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var object:Object = {};
			var numberOfStyles:uint = styles.length;
			
			for (var i:int;i<numberOfStyles;i++) {
				object[styles[i]] = undefined;
			}
			
			return setStyles(target, styles, object, description, true, dispatchEvents);
		}
		
		/**
		 * Returns true if the property was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearProperty(myButton, "width");</pre>
		 * */
		public static function clearProperty(target:Object, property:String, defaultValue:* = undefined, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var successful:Boolean;
			
			if (description==null) {
				description = "Reset " + property;
			}
			
			if (defaultValue!==undefined && defaultValue!==null) {
				removeComponentProperties([target], [property]);
				successful = setProperty(target, property, defaultValue, description, true, dispatchEvents);
				// undefined values automatically get removed but nonundefined do not so we remove them manually 
			}
			else {
				successful = setProperty(target, property, undefined, description, true, dispatchEvents);
			}
			
			return successful;
		}
		
		/**
		 * Returns true if the property was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearProperties(myButton, ["width", "percentWidth"]);</pre>
		 * */
		public static function clearProperties(target:Object, properties:Array, defaultValue:* = undefined, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var propertiesObject:Object = {};
			var numberOfProperties:uint = properties.length;
			var successful:Boolean;
			
			if (description==null) {
				description = "Reset " + properties;
			}
			
			for (var i:int;i<numberOfProperties;i++) {
				if (defaultValue!==undefined && defaultValue!==null) {
					propertiesObject[properties[i]] = defaultValue;
				}
				else {
					propertiesObject[properties[i]] = undefined;
				}
			}
			
			if (defaultValue!==undefined && defaultValue!==null) {
				removeComponentProperties([target], properties);
				successful = setProperties(target, properties, propertiesObject, description, true, dispatchEvents);
			}
			else {
				successful = setProperties(target, properties, propertiesObject, description, true, dispatchEvents);
			}
			
			return successful;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setStyle(target:Object, style:String, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var styleChanges:Array;
			var historyEvents:Array;
			
			styleChanges = createPropertyChange(targets, null, style, null, value, description);
			
			
			if (!removeUnchangedValues) {
				styleChanges = stripUnchangedValues(styleChanges);
			}
			
			if (changesAvailable(styleChanges)) {
				applyChanges(targets, styleChanges, null, style, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, styleChanges, null, style, null, value, description);
				
				updateComponentStyles(targets, styleChanges, [style]);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, styleChanges, null, ArrayUtil.toArray(style), null);
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Checks if changes are available. 
		 * */
		public static function changesAvailable(changes:Array):Boolean {
			var numberOfChanges:int = changes.length;
			var changesAvailable:Boolean;
			var item:PropertyChanges;
			var name:String;
			
			for (var i:int;i<numberOfChanges;i++) {
				if (!(changes[i] is PropertyChanges)) continue;
				
				item = changes[i];
				
				for (name in item.start) {
					changesAvailable = true;
					return true;
				}
				
				for (name in item.end) {
					changesAvailable = true;
					return true;
				}
			}
			
			return changesAvailable;
		}
		
		/**
		 * Restores captured values in changes array.
		 * Some values are removed by this call so may need to change this. 
		 * */
		public static function restoreCapturedValues(changes:Array, property:Array, style:Array = null, event:Array = null, validateLayout:Boolean = true, stripUnchanged:Boolean = true):Boolean {
			var numberOfChanges:int = changes ? changes.length : 0;
			var effect:HistoryEffect = new HistoryEffect();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			var change:PropertyChanges;
			var targets:Array = [];
			
			for (var i:int;i<numberOfChanges;i++) {
				change = changes[i] as PropertyChanges;
				
				if (change) { 
					onlyPropertyChanges.push(change);
					
					if (targets.indexOf(change.target)==-1) {
						targets.push(change.target);
					}
				}
			}
			
			onlyPropertyChanges = captureSizingPropertyValues(targets, ArrayUtil.toArray(property), false, onlyPropertyChanges);
			onlyPropertyChanges = stripUnchanged ? stripUnchangedValues(onlyPropertyChanges) : onlyPropertyChanges;
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			
			effect.relevantEvents = ArrayUtil.toArray(event);
			effect.relevantProperties = ArrayUtil.toArray(property);
			effect.relevantStyles = ArrayUtil.toArray(style);
			
			// this works for styles and properties
			// note: the property applyActualDimensions is used to enable width and height values to stick
			if (directApply) {
				effect.applyEndValuesWhenDone = false;
				effect.applyActualDimensions = false;
				
				//if (setStartValues) {
					effect.applyStartValues(onlyPropertyChanges, targets);
				//}
				//else {
				//	effect.applyEndValues(onlyPropertyChanges, targets);
				//}
				
				// Revalidate after applying
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
			
			return true;
		}
		
		/**
		 * Apply changes to targets. You do not call this. Set properties through setProperties method. 
		 * 
		 * @param setStartValues applies the start values rather 
		 * than applying the end values
		 * 
		 * @param property string or array of strings containing the 
		 * names of the properties to set or null if setting styles
		 * 
		 * @param style string or array of strings containing the 
		 * names of the styles to set or null if setting properties
		 * 
		 * @param event string or array of strings containing the 
		 * names of the events to set
		 * */
		public static function applyChanges(targets:Array, changes:Array, property:*, style:*, event:*, setStartValues:Boolean=false, validateLayout:Boolean = false):Boolean {
			var numberOfChanges:int = changes ? changes.length : 0;
			var effect:HistoryEffect = new HistoryEffect();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			// note: i think the Animation effect has an example of using this that verify we are doing it right - nov 27,16
			for (var i:int;i<numberOfChanges;i++) {
				if (changes[i] is PropertyChanges) { 
					onlyPropertyChanges.push(changes[i]);
				}
			}
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			
			
			effect.relevantEvents = ArrayUtil.toArray(event);
			effect.relevantProperties = ArrayUtil.toArray(property);
			effect.relevantStyles = ArrayUtil.toArray(style);
			
			// this works for styles and properties
			// note: the property applyActualDimensions is used to enable width and height values to stick
			if (directApply) {
				effect.applyEndValuesWhenDone = false;
				effect.applyActualDimensions = false;
				
				if (setStartValues) {
					effect.applyStartValues(onlyPropertyChanges, targets);
				}
				else {
					effect.applyEndValues(onlyPropertyChanges, targets);
				}
				
				// Revalidate after applying
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
				
			// this works for properties but not styles
			// the style value is restored at the end 
			// update: are you sure?
			else {
				
				effect.applyEndValuesWhenDone = false;
				effect.play(targets, setStartValues);
				effect.playReversed = false;
				effect.end();
				
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
			
			return true;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setProperty(target:Object, property:String, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var propertyChanges:Array;
			var historyEventItems:Array;
			
			propertyChanges = createPropertyChange(targets, property, null, null, value, description);
			
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, property, null, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				//addHistoryItem(propertyChanges, description);
				
				updateComponentProperties(targets, propertyChanges, [property]);
				
				historyEventItems = HistoryManager.createHistoryEventItems(targets, propertyChanges, property, null, null, value, description);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEventItems, description, false, dispatchEvents);
				}
				
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(target, propertyChanges, ArrayUtil.toArray(property), null, null);
				}
				
				if (dispatchEvents) {
					if (targets.indexOf(instance.selectedDocument.instance)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, [property])) {
						instance.dispatchDocumentSizeChangeEvent(target);
					}
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Properties on the application to listen for for document size change event
		 * */
		public static var notableApplicationProperties:Array = ["width","height","scaleX","scaleY"];
		
		/**
		 * Returns true if the property(s) were changed.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setProperties([myButton,myButton2], ["x","y"], {x:40,y:50});</pre>
		 * <pre>setProperties(myButton, "x", 40);</pre>
		 * <pre>setProperties(button, ["x", "left"], {x:50,left:undefined});</pre>
		 * 
		 * @see setStyle()
		 * @see setStyles()
		 * @see setProperty()
		 * */
		public static function setProperties(target:Object, properties:Array, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			properties = ArrayUtil.toArray(properties);
			propertyChanges = createPropertyChanges(targets, properties, null, null, value, description, false);
			
			if (!removeUnchangedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, null, null);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, propertyChanges, properties, null, null, value, description);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				updateComponentProperties(targets, propertyChanges, properties);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties, null, null);
				}
				
				if (targets.indexOf(instance.selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, properties)) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Sets the style on the target object.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setStyles([myButton,myButton2], ["fontSize","fontFamily"], {fontSize:20,fontFamily:"Arial"});</pre>
		 * <pre>setStyles(button, ["fontSize", "fontFamily"], {fontSize:10,fontFamily:"Arial"});</pre>
		 * 
		 * @see setStyle()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setStyles(target:Object, styles:Array, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var stylesChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			styles = ArrayUtil.toArray(styles);
			stylesChanges = createPropertyChanges(targets, null, styles, null, value, description, false);
			
			if (!removeUnchangedValues) {
				stylesChanges = stripUnchangedValues(stylesChanges);
			}
			
			if (changesAvailable(stylesChanges)) {
				applyChanges(targets, stylesChanges, null, styles, null);
				//LayoutManager.getInstance().validateNow();
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, stylesChanges, null, styles, null, value, description);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				updateComponentStyles(targets, stylesChanges, styles);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, stylesChanges, null, styles, null);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Sets the properties or styles of target or targets. Returns true if the properties or styles were changed.<br/><br/>
		 * 
		 * Usage:<br/>
<pre>
setPropertiesStyles([myButton,myButton2], ["x","y","color"], {x:40,y:50,color:"0xFF0000"});
setPropertiesStyles(myButton, "x", 40);
setPropertiesStyles(button, ["x", "left"], {x:50,left:undefined});
</pre>
		 * 
		 * @see setStyle()
		 * @see setStyles()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setPropertiesStylesEvents(target:Object, propertiesStylesEvents:Array, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			var properties:Array;
			var styles:Array;
			var events:Array;
			
			targets = ArrayUtil.toArray(target);
			propertiesStylesEvents = ArrayUtil.toArray(propertiesStylesEvents);
			
			// TODO: Add support for multiple targets
			styles = ClassUtils.getObjectsStylesFromArray(target, propertiesStylesEvents);
			properties = ClassUtils.getObjectsPropertiesFromArray(target, propertiesStylesEvents, true);
			events = ClassUtils.getObjectsEventsFromArray(target, propertiesStylesEvents);
			
			propertyChanges = createPropertyChanges(targets, properties, styles, events, value, description, false);
			
			if (!removeUnchangedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, styles, events);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					historyEvents = HistoryManager.createHistoryEventItems(targets, propertyChanges, properties, styles, events, value, description);
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description, false, dispatchEvents);
				}
				
				updateComponentProperties(targets, propertyChanges, properties);
				updateComponentStyles(targets, propertyChanges, styles);
				updateComponentEvents(targets, propertyChanges, events);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties, styles, events);
				}
				
				if (targets.indexOf(instance.selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, propertiesStylesEvents)) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Capture property values. Use to save the current values of the properties, styles or events of an object.
		 * */
		public static function capturePropertyValues(targets:Array, properties:Array, styles:Array = null, events:Array = null):Array {
			var tempEffect:HistoryEffect = new HistoryEffect();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertStyleEvent:String;
			
			tempEffect.targets = targets;
			tempEffect.relevantEvents = events;
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			return changes;
		}
		
		/**
		 * Capture sizing property values. Skips height and width unless explicitly set. 
		 * */
		public static function captureSizingPropertyValues(targets:Array, properties:Array = null, startValues:Boolean = true, previousChanges:Array = null):Array {
			var propertyChanges:PropertyChanges;
			var previousChange:PropertyChanges;
			var change:PropertyChanges;
			var effect:HistoryEffect;
			var changes:Array;
			
			if (properties==null) {
				properties = MXMLDocumentConstants.explicitSizeAndPositionRotationProperties.slice();
			}
			
			effect = new HistoryEffect();
			effect.targets = targets;
			effect.relevantProperties = properties;
			
			// get start values for undo
			changes = effect.captureValues(null, startValues);
			
			if (startValues) {
				for each (change in changes) {
					
					// if explicit size is not set then do not use size value
					if (change.start[MXMLDocumentConstants.EXPLICIT_WIDTH]===undefined) {
						change.start[MXMLDocumentConstants.WIDTH] = undefined;
					}
					
					if (change.start[MXMLDocumentConstants.EXPLICIT_HEIGHT]===undefined) {
						change.start[MXMLDocumentConstants.HEIGHT] = undefined;
					}
					
					// if the percent is set then to do not use size value
					if (!isNaN(change.start[MXMLDocumentConstants.PERCENT_WIDTH])) {
						change.start[MXMLDocumentConstants.WIDTH] = undefined;
					}
					
					if (!isNaN(change.start[MXMLDocumentConstants.PERCENT_HEIGHT])) {
						change.start[MXMLDocumentConstants.HEIGHT] = undefined;
					}
					
					change.start[MXMLDocumentConstants.EXPLICIT_WIDTH] = undefined;
					change.start[MXMLDocumentConstants.EXPLICIT_HEIGHT] = undefined;
				}
			}
			else if (previousChanges) {
				// if we pass in another change group and we are not start values
				// we are getting end values and so we match the targets and then 
				// return the previous changes array
				for each (previousChange in previousChanges) {
					for each (change in changes) {
						if (change.target==previousChange.target) {
							previousChange.end = change.end;
							//previousChange.start = change.start;
						}
					}
				}
				
				return previousChanges;
			}
			
			return changes;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function getPropertiesObjectFromBounds(element:Object, model:Object, roundToWhole:Boolean = true):Object {
			var leftValue:Object;
			var rightValue:Object;
			var topValue:Object;
			var bottomValue:Object;
			var horizontalCenter:Object;
			var verticalCenter:Object;
			var properties:Array;
			var propertiesObject:Object;
			var verticalDifference:int;
			var horizontalDifference:int;
			var widthDifference:Number;
			var heightDifference:Number;
			var width:Number;
			var height:Number;
			var elementX:Number;
			var elementY:Number;
			var changes:Array;
			var movedDown:Boolean;
			var movedLeft:Boolean;
			var movedRight:Boolean;
			var movedUp:Boolean;
			
			changes = [];
			properties = [];
			propertiesObject = {};
			
			width = model.width;
			height = model.height;
			
			elementX = element.x;
			elementY = element.y;
			
			if (model.y>elementY) {
				movedDown = true;
			}
			else if (model.y<elementY) {
				movedUp = true;
			}
			
			if (model.x>elementX) {
				movedRight = true;
			}
			else if (model.x<elementX) {
				movedLeft = true;
			}
			
			// get size
			propertiesObject.width = width;
			propertiesObject.height = height;
			properties.push(MXMLDocumentConstants.WIDTH, MXMLDocumentConstants.HEIGHT);
			
			// get vertical changes
			if (movedUp) {
				verticalDifference = (elementY - model.y);
				
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) - verticalDifference;
					propertiesObject.bottom = Number(element.bottom) + verticalDifference;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (topValue!=null) {
					propertiesObject.top = Number(element.top) - verticalDifference;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) + verticalDifference;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) - verticalDifference;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y - verticalDifference;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			else if (movedDown) {
				verticalDifference = (model.y - elementY);
				
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) + verticalDifference;
					propertiesObject.bottom = Number(element.bottom) - verticalDifference;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (leftValue!=null) {
					propertiesObject.top = Number(element.top) + verticalDifference;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) - verticalDifference;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) + verticalDifference;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y + verticalDifference;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			
			// get horizontal changes
			if (movedLeft) {
				horizontalDifference = (elementX - model.x);
				
				/**
				 * If left is set then set x to nothing
				 * If left and right are set then set width to nothing
				 * If horizontalCenter is set than set left and right to nothing
				 * Otherwise set left to nothing
				 * */
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) - horizontalDifference;
					propertiesObject.right = Number(element.right) + horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) - horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) + horizontalDifference;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) - horizontalDifference;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x - horizontalDifference;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			else if (movedRight) {
				horizontalDifference = (model.x - elementX);
				
				leftValue = element.left;
				rightValue = element.right;
				horizontalCenter = element.horizontalCenter;
				
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) + horizontalDifference;
					propertiesObject.right = Number(element.right) - horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) + horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) - horizontalDifference;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) + horizontalDifference;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x + horizontalDifference;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			
			if (roundToWhole) {
				for (var i:int = 0; i < properties.length; i++)  {
					propertiesObject[properties[i]] = Math.ceil(propertiesObject[properties[i]]);
				}
				
			}

			return propertiesObject;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function createPropertyChanges(targets:Array, properties:Array, styles:Array, events:Array, value:Object, description:String = "", storeInHistory:Boolean = true):Array {
			var tempEffect:HistoryEffect = new HistoryEffect();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertStyleEvent:String;
			
			tempEffect.targets = targets;
			tempEffect.relevantEvents = events;
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			// This may be hanging on to bindable objects
			// set the values to be set to the property 
			// ..later - what??? give an example
			for each (propertyChanges in changes) {
				
				// for properties 
				for each (propertStyleEvent in properties) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						// BUG - this will assign the value object if property is not found in the value object - fix
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
				
				// for styles
				for each (propertStyleEvent in styles) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
				
				// for event
				for each (propertStyleEvent in events) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
			}
			
			// we should move this out
			// add property changes array to the history dictionary
			if (storeInHistory) {
				return HistoryManager.createHistoryEventItems(targets, changes, properties, styles, events, value, description);
			}
			
			return [propertyChanges];
		}
		
		/**
		 * Given a target or targets, property name and value
		 * returns an array of PropertyChange objects.
		 * Points to createPropertyChanges()
		 * 
		 * @see createPropertyChanges()
		 * */
		public static function createPropertyChange(targets:Array, property:String, style:String, event:String, value:*, description:String = ""):Array {
			var values:Object = {};
			var changes:Array;
			
			if (property) {
				values[property] = value;
			}
			else if (style) {
				values[style] = value;
			}
			else if (event) {
				values[event] = value;
			}
			
			changes = createPropertyChanges(targets, ArrayUtil.toArray(property), ArrayUtil.toArray(style), ArrayUtil.toArray(event), values, description, false);
			
			return changes;
		}
		
		/**
		 * Removes properties changes for null or same value targets
		 * @private
		 */
		public static function stripUnchangedValues(propChanges:Array):Array {
			
			// Go through and remove any before/after values that are the same.
			for (var i:int = 0; i < propChanges.length; i++) {
				if (propChanges[i].stripUnchangedValues == false)
					continue;
				
				for (var prop:Object in propChanges[i].start) {
					if ((propChanges[i].start[prop] ==
						propChanges[i].end[prop]) ||
						(typeof(propChanges[i].start[prop]) == "number" &&
							typeof(propChanges[i].end[prop])== "number" &&
							isNaN(propChanges[i].start[prop]) &&
							isNaN(propChanges[i].end[prop])))
					{
						delete propChanges[i].start[prop];
						delete propChanges[i].end[prop];
					}
				}
			}
			
			return propChanges;
		}
		
		/**
		 * Updates the properties on a component description
		 * */
		public static function updateComponentProperties(localTargets:Array, propertyChanges:Array, properties:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var propertyChange:Object;
			var localTarget:Object;
			var property:String;
			var selectedDocument:IDocument = instance.selectedDocument;
			var value:*;
			var numberOfProperties:int = properties ? properties.length : 0;
			
			
			if (numberOfProperties==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.getItemDescription(localTarget);
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfProperties; k++) {
							property = properties[k];
							
							if (undo) {
								value = propertyChange.start[property];
							}
							else {
								value = propertyChange.end[property];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								//isNaN(value)) {
								delete componentDescription.properties[property];
							}
							else {
								componentDescription.properties[property] = value;
							}
						}
						
						//componentDescriptor.properties = ObjectUtils.merge(propertyChange.end, componentDescriptor.properties);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Updates the styles on a component description
		 * */
		public static function updateComponentStyles(localTargets:Array, propertyChanges:Array, styles:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var selectedDocument:IDocument = instance.selectedDocument;
			var propertyChange:Object;
			var localTarget:Object;
			var numberOfStyles:int = styles ? styles.length : 0;
			var style:String;
			var value:*;
			
			if (numberOfStyles==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.descriptionsDictionary[localTarget];
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfStyles; k++) {
							style = styles[k];
							
							if (undo) {
								value = propertyChange.start[style];
							}
							else {
								value = propertyChange.end[style];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								// || isNaN(value)
								delete componentDescription.styles[style];
							}
							else {
								componentDescription.styles[style] = value;
							}
						}
						
						//componentDescription.styles = ObjectUtils.merge(propertyChange.end, componentDescription.styles);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Updates the events on a component description
		 * */
		public static function updateComponentEvents(localTargets:Array, propertyChanges:Array, events:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var selectedDocument:IDocument = instance.selectedDocument;
			var propertyChange:Object;
			var localTarget:Object;
			var numberOfEvents:int = events ? events.length : 0;
			var eventName:String;
			var value:*;
			
			if (numberOfEvents==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.descriptionsDictionary[localTarget];
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfEvents; k++) {
							eventName = events[k];
							
							if (undo) {
								value = propertyChange.start[eventName];
							}
							else {
								value = propertyChange.end[eventName];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								// || isNaN(value)
								delete componentDescription.events[eventName];
							}
							else {
								componentDescription.events[eventName] = value;
							}
						}
						
						//componentDescription.styles = ObjectUtils.merge(propertyChange.end, componentDescription.styles);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		
		
		/**
		 * Updates the properties on a component description
		 * */
		public static function removeComponentProperties(localTargets:Array, properties:Array):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int;
			var localTarget:Object;
			var property:String;
			var selectedDocument:IDocument;
			var numberOfProperties:int;
			
			numberOfTargets = localTargets.length;
			selectedDocument = instance.selectedDocument;
			numberOfProperties = properties ? properties.length : 0;
			
			if (numberOfProperties==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.getItemDescription(localTarget);
				
				if (componentDescription) {
					for (var k:int = 0; k < numberOfProperties; k++) {
						property = properties[k];
						
						delete componentDescription.properties[property];
					}
				}
			}
		}
		
		/**
		 * Gets the value translated into a type. 
		 * */
		public static function getTypedValue(value:*, valueType:*):* {
			
			return TypeUtils.getTypedValue(value, valueType);
		}
		
		/**
		 * Gets the value translated into a type. 
		 * */
		public static function getTypedPropertyValue(target:Object, property:String, value:*):* {
			var propertyType:String;
			propertyType = ClassUtils.getTypeOfProperty(target, property) as String;
			
			return TypeUtils.getTypedValue(value, propertyType);
		}
		
		/**
		 * Gets the value translated into a type from the styles object. 
		 * */
		public static function getTypedValueFromProperty(target:Object, propertiesObject:Object, properties:Array):Object {
			var typedValuesObject:Object;
			var propertyType:Object;
			
			for (var property:String in properties) {
				propertyType = ClassUtils.getTypeOfProperty(target, property);
				typedValuesObject[property] = getTypedValue(propertiesObject[property], propertyType);
			}
			
			return typedValuesObject;
		}
		
		/**
		 * Gets the value translated into a type from the styles object.
		 * Might be duplicate of 
attributesValueObject	= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, attributesValueObject, styles); 
		 * */
		public static function getTypedValueFromStyles(target:Object, values:Object, styles:Array):Object {
			var typedValuesObject:Object = {};
			var styleType:Object;
			
			for each (var style:String in styles) {
				styleType = ClassUtils.getTypeOfStyle(target, style);
				typedValuesObject[style] = getTypedValue(values[style], styleType);
			}
			
			return typedValuesObject;
		}
		
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning. Ensures properties, styles and events are 
		 * all valid.<br/><br/>
		 * 
		 * Usage:
<pre>
Radiate.moveElement(new Button(), container, ["width","color","click"], {width:50,color:red,click:"alert('click')"});
</pre>
		 * Usage:
<pre>
Radiate.moveElement(radiate.target, document.instance, ["x"], 15);
</pre>
		 * */
		public static function moveElement2(targetItems:*, 
										   destination:Object, 
										   propertiesStylesEvents:Array,
										   values:Object, 
										   description:String 	= null, 
										   position:String		= AddItems.LAST, 
										   relativeTo:Object	= null, 
										   index:int			= -1, 
										   propertyName:String	= null, 
										   isArray:Boolean		= false, 
										   isStyle:Boolean		= false, 
										   vectorClass:Class	= null,
										   keepUndefinedValues:Boolean = true):String {
			
			var items:Array;
			var item:Object;
			var styles:Array;
			var events:Array;
			var properties:Array;
			
			items = ArrayUtil.toArray(targetItems);
			
			propertiesStylesEvents = ArrayUtil.toArray(propertiesStylesEvents);
			
			for (var i:int = 0; i < items.length; i++)  {
				item = items[i];
				
				if (item) {
					styles = ClassUtils.getObjectsStylesFromArray(item, propertiesStylesEvents);
					properties = ClassUtils.getObjectsPropertiesFromArray(item, propertiesStylesEvents, true);
					events = ClassUtils.getObjectsEventsFromArray(item, propertiesStylesEvents);
				}
			}
			
			return moveElement(targetItems, destination, properties, styles, events, values, description, position, relativeTo, index, propertyName, isArray, isStyle);
			
		}
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.moveElement(new Button(), parentComponent, [], null);</pre>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.moveElement(radiate.target, null, ["x"], 15);</pre>
		 * */
		public static function moveElement(targetItems:*, 
										   destination:Object, 
										   properties:Array, 
										   styles:Array,
										   events:Array,
										   values:Object, 
										   description:String 	= null, 
										   position:String		= AddItems.LAST, 
										   relativeTo:Object	= null, 
										   index:int			= -1, 
										   propertyName:String	= null, 
										   isArray:Boolean		= false, 
										   isStyle:Boolean		= false, 
										   vectorClass:Class	= null,
										   removeUnchangedValues:Boolean = true, 
										   setPrimitiveDefaults:Boolean = false):String {
			
			var visualElement:IVisualElement;
			var moveItems:AddItems;
			var childIndex:int;
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEventItems:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			var targetItem:Object;
			var itemOwner:Object;
			var visualElementParent:Object;
			var visualElementOwner:IVisualElementContainer;
			var applicationGroup:GroupBase;
			
			targetItems = ArrayUtil.toArray(targetItems);
			
			targetItem = targetItems ? targetItems[0] : null;
			itemOwner = targetItem ? targetItem.owner : null;
			
			visualElement = targetItem as IVisualElement;
			visualElementParent = visualElement ? visualElement.parent : null;
			visualElementOwner = itemOwner as IVisualElementContainer;
			applicationGroup = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = HistoryManager.getMoveDescription(targetItem);
			}
			
			// if it's a basic layout then don't try to add it
			// NO DO ADD IT bc we may need to swap indexes
			if (destination is IVisualElementContainer) {
				//destinationGroup = destination as GroupBase;
				
				if (destination is Container) {
					
					if (destination is Canvas) {
						// does not support multiple items?
						if (targetItem && itemOwner==destination) {
							isSameOwner = true;
						}
						
						// check if group parent and destination are the same
						if (targetItem && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
							isSameParent = true;
						}
					}
					
				}
				else 
				if (destination.layout is BasicLayout) {
					
					// does not support multiple items?
					// check if group parent and destination are the same
					if (targetItem && itemOwner==destination) {
						//trace("can't add to the same owner in a basic layout");
						isSameOwner = true;
						
						//return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					// NOTE: if the item is an element on application this will fail
					if (targetItem && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
						//trace("can't add to the same parent in a basic layout");
						isSameParent = true;
						//return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (targetItems && destination is IVisualElementContainer 
						&& destination.numElements==1
						&& visualElementParent
						&& (visualElementParent==destination || visualElementParent==applicationGroup)) {
					
					isSameParent = true;
					isSameOwner = true;
					//trace("can't add to the same parent in a basic layout");
					//return SAME_PARENT;
					
				}
			}
			
			// if destination is null then we assume we are moving in same container 
			// or should null mean remove
			else {
				//isSameParent = true;
				//isSameOwner = true;
			}
			
			
			// set default
			if (!position) {
				position = AddItems.LAST;
			}
			
			// if destination is not a basic layout Group and the index is set 
			// then find and override position and set the relative object 
			// so we can position the target in the drop location point index
			if (destination is IVisualElementContainer 
				&& !relativeTo 
				&& index!=-1
				&& destination.numElements>0) {
				
				// add as first item
				if (index==0) {
					position = AddItems.FIRST;
				}
					
					// get relative to object
				else if (index<=destination.numElements) {
					visualElement = targetItems is Array && (targetItems as Array).length>0 ? targetItems[0] as IVisualElement : targetItems as IVisualElement;
					
					// if element is already child of container account for removal of element before add
					if (visualElement && visualElement.parent == destination) {
						childIndex = destination.getElementIndex(visualElement);
						index = childIndex < index ? index-1: index;
						
						if (index<=0) {
							position = AddItems.FIRST;
						}
						else {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
						// add as last item
					else if (index>=destination.numElements) {
						
						// we need to remove first or we get an error in AddItems
						// or we can set relativeTo item and set AFTER
						if (isSameParent && destination.numElements>1) {
							removeBeforeAdding = true;
							relativeTo = destination.getElementAt(destination.numElements-1);
							position = AddItems.AFTER;
						}
						else if (isSameParent) {
							removeBeforeAdding = true;
							position = AddItems.LAST;
						}
						else {
							position = AddItems.LAST;
						}
					}
						// add after first item
					else if (index>0) {
						relativeTo = destination.getElementAt(index-1);
						position = AddItems.AFTER;
					}
				}
				
				
				// check if moving to another index within the same parent 
				if (visualElementOwner && visualElement) {
					currentIndex = visualElementOwner.getElementIndex(visualElement);
					
					if (currentIndex!=index) {
						movingIndexWithinParent = true;
					}
				}
			}
			
			
			// create a new AddItems instance and add it to the changes
			moveItems = new AddItems();
			moveItems.items = targetItems;
			moveItems.destination = destination;
			moveItems.position = position;
			moveItems.relativeTo = relativeTo;
			moveItems.propertyName = propertyName;
			moveItems.isArray = isArray;
			moveItems.isStyle = isStyle;
			moveItems.vectorClass = vectorClass;
			
			// if we want to check for property facades
			var items:Array;
			var item:Object;
			var propertiesStylesEvents:Array;
			var verifyValidProperties:Boolean;
			
			if (verifyValidProperties) {
				items = ArrayUtil.toArray(targetItems);
				
				propertiesStylesEvents = ArrayUtil.toArray(properties);
				
				for (var i:int = 0; i < items.length; i++)  {
					item = items[i];
					
					if (item) {
						styles = ClassUtils.getObjectsStylesFromArray(properties, propertiesStylesEvents);
						properties = ClassUtils.getObjectsPropertiesFromArray(item, propertiesStylesEvents, true);
						events = ClassUtils.getObjectsEventsFromArray(item, propertiesStylesEvents);
					}
				}
			}
			
			var removeConstraintsFromProperties:Boolean = true;
			var constraintStyles:Array;
			
			// remove constraints from properties array
			if (removeConstraintsFromProperties && properties && properties.length) {
				constraintStyles = ClassUtils.removeConstraintsFromArray(properties);
				
				if (constraintStyles.length) {
					if (styles==null) styles = [];
					ArrayUtils.addMissingItems(styles, constraintStyles);
				}
			}
			
			// add properties that need to be modified
			if ((properties && properties.length) || (styles && styles.length) || (events && events.length)) {
				changes = createPropertyChanges(targetItems, properties, styles, events, values, description, false);
				
				// get the property change part
				propertyChangeChange = changes[0];
			}
			else {
				changes = [];
			}
			
			// constraints use undefined values 
			// so if we use constraints do not strip out values
			if (!removeUnchangedValues) {
				changes = stripUnchangedValues(changes);
			}
			
			
			// attempt to add or move and set the properties
			try {
				
				// insert moving of items before it
				// if it's the same owner we don't want to run add items 
				// but if it's a vgroup or hgroup does this count
				if ((!isSameParent && !isSameOwner) || movingIndexWithinParent) {
					changes.unshift(moveItems); //add before other changes 
				}
				
				if (changes.length==0) {
					//info("Move: Nothing to change or add");
					return "Nothing to change or add";
				}
				
				// store changes
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					historyEventItems = HistoryManager.createHistoryEventItems(targetItems, changes, properties, styles, events, values, description, RadiateEvent.MOVE_ITEM);
				}
				
				// try moving
				if ((!isSameParent && !isSameOwner) || movingIndexWithinParent) {
					
					// this is to prevent error in AddItem when adding to the last position
					// and we get an index is out of range. 
					// 
					// for example, if an element is at index 0 and there are 3 elements 
					// then addItem will get the last index. 
					// but since the parent is the same the addElement call removes 
					// the element. the max index is reduced by one and previously 
					// determined last index is now out of range. 
					// AddItems was not meant to add an element that has already been added
					// so we remove it before hand so addItems can add it again. 
					if (removeBeforeAdding) {
						visualElementOwner.removeElement(visualElement);// validate now???
						visualElementOwner is IInvalidating ? IInvalidating(visualElementOwner).validateNow() : void;
					}
					
					moveItems.apply(moveItems.destination as UIComponent);
					
					if (moveItems.destination is SkinnableContainer && !SkinnableContainer(moveItems.destination).deferredContentCreated) {
						//Radiate.error("Not added because deferred content not created.");
						var factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
						SkinnableContainer(moveItems.destination).mxmlContentFactory = factory;
						SkinnableContainer(moveItems.destination).createDeferredContent();
						SkinnableContainer(moveItems.destination).removeAllElements();
						moveItems.apply(moveItems.destination as UIComponent);
					}
					
					LayoutManager.getInstance().validateNow();
				}
				
				// try setting properties
				if (changesAvailable([propertyChangeChange])) {
					applyChanges(targetItems, [propertyChangeChange], properties, styles, events);
					LayoutManager.getInstance().validateNow();
					
					properties 	&& properties.length ? updateComponentProperties(targetItems, [propertyChangeChange], properties) :-1;
					styles 		&& styles.length ? updateComponentStyles(targetItems, [propertyChangeChange], styles) :-(1);
					events 		&& events.length ? updateComponentEvents(targetItems, [propertyChangeChange], events) :-1;
				}
				
				
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEventItems);
				}
				
				if (Radiate.importingDocument==false) {
					// check for changes before dispatching
					if (changes.indexOf(moveItems)!=-1) {
						instance.dispatchMoveEvent(targetItems, changes, properties);
					}
					
					//setTargets(items, true);
					
					if (properties) {
						instance.dispatchPropertyChangeEvent(targetItems, changes, properties, styles, events);
					}
				}
				
				return MOVED; // we assume moved if it got this far - needs more checking
			}
			catch (errorEvent:Error) {
				// this is clunky - needs to be upgraded
				
				// Move error: Error #1069: Property null not found on com.flexcapacitor.model.Document and there is no default value.
				// Solution: you are passing in the document not the instance of the document
				error("Move error: " + errorEvent.message);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.removeHistoryEvent(changes);
					HistoryManager.removeHistoryItem(instance.selectedDocument, changes);
				}
				
				return String(errorEvent.message);
			}
			
			
			return ADD_ERROR;
			
		}
		
		/**
		 * Prevent log messages
		 * */
		public static var preventDefaultMessages:Boolean;
			
		/**
		 * Adds a component to the display list.
		 * It should not have a parent or owner! If it does
		 * it will return an error message
		 * Returns true if the component was added
		 * 
		 * Usage:
		 * Radiate.addElement(new Button(), event.targetCandidate);
		 * */
		public static function addElement(items:*, 
										  destination:Object, 
										  properties:Array 		= null, 
										  styles:Array			= null,
										  events:Array			= null,
										  values:Object			= null, 
										  description:String 	= null, 
										  position:String		= AddItems.LAST, 
										  relativeTo:Object		= null, 
										  index:int				= -1, 
										  propertyName:String	= null, 
										  isArray:Boolean		= false, 
										  isStyle:Boolean		= false, 
										  vectorClass:Class		= null,
										  keepUndefinedValues:Boolean = true, 
										  setPrimitiveDefaults:Boolean = false):String {
			
			
			if (!description) {
				description = HistoryManager.getAddDescription(items);
			}
			
			var results:String = moveElement(items, destination, properties, styles, events, values, 
								description, position, relativeTo, index, propertyName, 
								isArray, isStyle, vectorClass, keepUndefinedValues, setPrimitiveDefaults);
			
			var component:Object;
			
			var itemsArray:Array;
			
			itemsArray = ArrayUtil.toArray(items);
			
			for (var i:int; i < itemsArray.length; i++) {
				component = itemsArray[0];
				// should remove this when we can refactor
				updateComponentAfterAdd(instance.selectedDocument, component, false, false, setPrimitiveDefaults);
			}
			
			return results;
		}
		
		
		/**
		 * Removes an element from the display list.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.removeElement(radiate.targets);</pre>
		 * */
		public static function removeElement(items:*, description:String = null):String {
			var visualElement:IVisualElement;
			var removeItems:AddItems;
			var childIndex:int;
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEvents:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			var destination:Object;
			var index:int;
			var position:String;
			var item:Object;
			var itemOwner:Object;
			var visualElementParent:Object;
			var visualElementOwner:IVisualElementContainer;
			var applicationGroup:GroupBase;
			
			items = ArrayUtil.toArray(items);
			
			item = items ? items[0] : null;
			itemOwner = item ? item.owner : null;
			
			visualElement = item as IVisualElement;
			visualElementParent = visualElement ? visualElement.parent : null;
			visualElementOwner = itemOwner as IVisualElementContainer;
			applicationGroup = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = HistoryManager.getRemoveDescription(item);
			}
			
			if (visualElement is Application) {
				//info("You can't remove the document");
				return REMOVE_ERROR;
			}
			

			destination = item.owner;
			index = destination ? destination.getElementIndex(visualElement) : -1;
			changes = [];
			
			
			// attempt to remove
			try {
				removeItems = HistoryManager.createReverseAddItems(items[0]);
				changes.unshift(removeItems);
				
				// store changes
				historyEvents = HistoryManager.createHistoryEventItems(items, changes, null, null, null, null, description, RadiateEvent.REMOVE_ITEM);
				
				// try moving
				//removeItems.apply(destination as UIComponent);
				//removeItems.apply(null);
				visualElementOwner.removeElement(visualElement);
				//removeItems.remove(destination as UIComponent);
				LayoutManager.getInstance().validateNow();
				
				
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents);
				}
				
				// check for changes before dispatching
				instance.dispatchRemoveItemsEvent(items, changes, null);
				// select application - could be causing errors - should select previous targets??
				setTargets(instance.selectedDocument.instance, true);
				
				return REMOVED; // we assume moved if it got this far - needs more checking
			}
			catch (errorEvent:Error) {
				// this is clunky - needs to be upgraded
				error("Remove error: " + errorEvent.message);
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.removeHistoryEvent(changes);
					HistoryManager.removeHistoryItem(instance.selectedDocument, changes);
				}
				return String(errorEvent.message);
			}
			
			return REMOVE_ERROR;
		}
		
		/**
		 * Last created component
		 * */
		public static var lastCreatedComponent:Object;
		
		
		/**
		 * Required for creating BorderContainers
		 * */
		protected static function deferredInstanceFromFunction():Array {
			var label:Label = new Label();
			return [label];
		}
		
		/**
		 * Sets the default properties. We may need to use setActualSize type of methods here or when added. 
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * */
		public static function setDefaultProperties(componentDescription:ComponentDescription):void {
			
			var valuesObject:ValuesObject = getPropertiesStylesFromObject(componentDescription.instance, componentDescription.defaultProperties);
			
			// maybe do not add to history
			setPropertiesStylesEvents(componentDescription.instance, valuesObject.propertiesStylesEvents, valuesObject.values, "Setting defaults");
			//HistoryManager.mergeLastHistoryEvent(instance.selectedDocument);
		}
		
		/**
		 * Updates the component with any additional settings for it to work 
		 * after it's been added to the document.
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * 
		 * @see #createComponentToAdd()
		 * */
		public static function updateComponentAfterAdd(iDocument:IDocument, target:Object, setDefaults:Boolean = false, interactive:Boolean = false, setPrimitiveDefaults:Boolean = true):void {
			var componentDescription:ComponentDescription = iDocument.getItemDescription(target);
			var componentInstance:Object = componentDescription ? componentDescription.instance : null;
			
			// set defaults
			if (componentDescription && setDefaults) {
				setDefaultProperties(componentDescription);
			}
			
			iDocument.updateComponentTree();
			
			// need to add so we can listen for click events on transparent areas of groups
			if (componentInstance is GroupBase) {
				DisplayObjectUtils.addGroupMouseSupport(componentInstance as GroupBase);
			}
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			if (target is BorderContainer) {
				/*var factory:DeferredInstanceFromFunction;
				factory = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
				BorderContainer(component).mxmlContentFactory = factory;
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).removeAllElements();*/
				
				// we could probably also do this: 
				BorderContainer(target).addElement(new Label());
				BorderContainer(target).removeAllElements();
				
				// we do this to get rid of the round joints. this skin joints default to miter
				// UPDATE - this causes an infinite loop somewhere when deleting an element
				// so let's just remove it for now
				//BorderContainer(target).setStyle("skinClass", com.flexcapacitor.skins.BorderContainerSkin);
				BorderContainer(target).setStyle("cornerRadius", 0);
			}
			
			// add fill and stroke to graphic elements
			if (componentInstance is GraphicElement && setPrimitiveDefaults) {
				var fill:SolidColor;
				var stroke:SolidColorStroke;
				var object:Object = {};
				var properties:Array = [];
				
				if (componentInstance is FilledElement && componentInstance.fill==null) {
					fill = new SolidColor();
					fill.color = 0xf6f6f6;
					object.fill = fill;
				}
				
				if (componentInstance is StrokedElement && componentInstance.stroke==null) {
					
					// not adding stroke to rectangle, path, ellipse
					if (componentInstance is Rect || componentInstance is Path || componentInstance is Ellipse) {
						
					}
					else {
						stroke = new SolidColorStroke();
						stroke.color = 0xA6A6A6;
						stroke.joints = JointStyle.MITER;
						object.stroke = stroke;
					}
				}
				
				if (componentInstance is Path && componentInstance.data==null) {
					object.data = "L 80 80 V 0 L 0 80 V 0";
				}
				
				
				for (var property:String in object) {
					//setProperty(component, property, [item.defaultProperties[property]]);
					properties.push(property);
					//componentDescription.defaultProperties[property] = object[property];
				}
				
				if (properties.length) {
					setProperties(componentInstance, properties, object, "Setting graphic element properties");
				}
				//HistoryManager.mergeLastHistoryEvent(instance.selectedDocument);
			}
			
			makeInteractive(componentInstance, interactive);
			
			// prevent components from interacting with design view
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			if ("eventListeners" in target && !(target is GroupBase)) {
				target.removeAllEventListeners();
			}
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			/*if ("eventListeners" in component) {
			component.removeAllEventListeners();
			}*/
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			/*if (component is BorderContainer) {
				BorderContainer(component).creationPolicy = ContainerCreationPolicy.ALL;
				BorderContainer(component).initialize();
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).initialize();
			}*/
		}
		
		/**
		 * When set to true, makes a component interactive as in a normal app. 
		 * When false makes component behave as if it was on the design view
		 * */
		public static function makeInteractive(componentInstance:Object, interactive:Boolean = false, showEditor:Boolean = true):void {
			
			// graphic elements
			// when we say interactive we mean what the user will interact with
			// do not make graphic elements interactive for user
			if (componentInstance is GraphicElement) {
				GraphicElement(componentInstance).alwaysCreateDisplayObject = !interactive;
				
				// button mode may be preventing keyboard events from reaching the application
				// turning it off seems to fix the problem but if the height or width are
				// but button mode shows a hand cursor so small elements are easier to select 
				if (GraphicElement(componentInstance).displayObject) {
					Sprite(GraphicElement(componentInstance).displayObject).mouseEnabled = !interactive;
					Sprite(GraphicElement(componentInstance).displayObject).buttonMode = !interactive;
					//Sprite(GraphicElement(componentInstance).displayObject).mouseChildren = false;
				}
			}
			
			// if text based or combo box we need to prevent 
			// interaction with cursor
			if (componentInstance is TextBase || componentInstance is SkinnableTextBase) {
				componentInstance.mouseChildren = interactive;
				
				if ("textDisplay" in componentInstance && componentInstance.textDisplay) {
					componentInstance.textDisplay.enabled = interactive;
				}
				
				
				// if show editor on double click then continue to be interactive 
				if (showEditor) {
					if (componentInstance is Label || componentInstance is RichText || componentInstance is Hyperlink) {
						componentInstance.doubleClickEnabled = true;
						
						componentInstance.addEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler, false, 0, true);
					}
					else {
						componentInstance.doubleClickEnabled = false;
						componentInstance.removeEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler);
					}
					
					if (componentInstance is Hyperlink) {
						componentInstance.useHandCursor = true;
					}
				}
				else {
					if (componentInstance is Label || componentInstance is RichText) {
						componentInstance.doubleClickEnabled = interactive;
						
						if (interactive) {
							componentInstance.addEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler, false, 0, true);
						}
						else {
							componentInstance.removeEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler);
						}
					}
					
					if (componentInstance is Hyperlink) {
						componentInstance.useHandCursor = interactive;
					}
				}
			}
			
			var sparkColorPicker:Class = ClassUtils.getDefinition("spark.components.ColorPicker") as Class;
			
			// spark or mx ColorPicker
			if ((sparkColorPicker && componentInstance is sparkColorPicker) || componentInstance is mx.controls.ColorPicker) {
				Object(componentInstance).mouseChildren = interactive;
				IStyleClient(componentInstance).setStyle("focusThickness", 0);
			}
			
			// NumericStepper
			if (componentInstance is NumericStepper) {
				NumericStepper(componentInstance).mouseChildren = interactive;
			}
			
			// dropdown or combobox
			if (componentInstance is ComboBox || componentInstance is DropDownList) {
				if ("textInput" in componentInstance && componentInstance.textInput && 
					componentInstance.textInput.textDisplay) {
					ComboBox(componentInstance).textInput.textDisplay.enabled = interactive;
				}
				
				DropDownListBase(componentInstance).mouseChildren = interactive;
			}
			
			// Vertical or Horizontal Slider
			if (componentInstance is SliderBase) {
				SliderBase(componentInstance).mouseChildren = interactive;
			}
			
			
			if (componentInstance is LinkButton) {
				LinkButton(componentInstance).useHandCursor = interactive;
			}
			
			if (componentInstance is Hyperlink) {
				// prevent links from clicking use UIGlobals...designMode
				Hyperlink(componentInstance).useHandCursor = !interactive;
				Hyperlink(componentInstance).preventLaunching = interactive;
			}
			
			// checkbox or radio button or toggle button
			if (componentInstance is ToggleButtonBase) {
				
				if (!interactive) {
					IEventDispatcher(componentInstance).addEventListener(MouseEvent.CLICK, disableToggleButtonHandler, false, 0, true);
				}
				else {
					IEventDispatcher(componentInstance).removeEventListener(MouseEvent.CLICK, disableToggleButtonHandler);
				}
				
			}
			
			// test on spark grid
			if (false && componentInstance is spark.components.Grid) {
				spark.components.Grid(componentInstance).itemRenderer= new ClassFactory(DefaultGridItemRenderer);
				spark.components.Grid(componentInstance).dataProvider = new ArrayCollection(["item 1", "item 2", "item 3"]);
			}
			
			// test on mx grid
			if (false && componentInstance is mx.containers.Grid) {
				mx.containers.Grid(componentInstance)
				var grid:mx.containers.Grid = componentInstance as mx.containers.Grid;
				var gridRow:GridRow	= new GridRow();
				var gridItem:GridItem = new GridItem();
				var gridItem2:GridItem = new GridItem();
				
				var gridButton:Button = new Button();
				gridButton.width = 100;
				gridButton.height = 100;
				gridButton.label = "hello";
				var gridButton2:Button = new Button();
				gridButton2.width = 100;
				gridButton2.height = 100;
				gridButton2.label = "hello2";
				
				gridItem.addElement(gridButton);
				gridItem2.addElement(gridButton2);
				gridRow.addElement(gridItem);
				gridRow.addElement(gridItem2);
				grid.addElement(gridRow);
			}
			
		}
		
		/**
		 * Rebuilds the component tree structure
		 * */
		public function updateComponentTree(iDocument:IDocument):void {
			if (iDocument is Document) {
				Document(iDocument).updateComponentTree();
			}
		}
		
		/**
		 * Disables toggle button base classes
		 * */
		public static function disableToggleButtonHandler(event:Event):void {
			ToggleButtonBase(event.currentTarget).selected = !ToggleButtonBase(event.currentTarget).selected;
			event.stopImmediatePropagation();
			event.preventDefault();
		}
		
		/**
		 * Exports an XML string for a project
		 * */
		public function exportProject(project:IProject, format:String = "String"):String {
			var projectString:String = project.toString();
			
			return projectString;
		}
		
		/**
		 * Creates a project
		 * */
		public function createProject(name:String = null):IProject {
			var newProject:IProject = new Project();
			
			newProject.name = name ? name : "Project "  + Project.nameIndex;
			newProject.host = getWPURL();
			
			return newProject;
		}
		
		
		// Error #1047: Parameter initializer unknown or is not a compile-time constant.
		// Occassionally a 1047 error shows up. 
		// This is from using a static var in the parameter as the default 
		// and is an error in FB - run clean and it will go away
		
		/**
		 * Adds a project to the projects array. We should remove open project behavior. 
		 * */
		public function addProject(newProject:IProject, open:Boolean = false, locations:String = null, dispatchEvents:Boolean = true):IProject {
			var found:Boolean = doesProjectExist(newProject.uid);
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			if (!found) {
				projects.push(newProject);
			}
			else {
				return newProject;
			}
			
			// if no projects exist select the first one
			/*if (!selectedProject) {
				setProject(newProject, dispatchEvents);
			}*/
			
			if (dispatchEvents) {
				dispatchProjectAddedEvent(newProject);
			}

			if (open) {
				openProject(newProject, locations, dispatchEvents);// TODO project opened or changed
			}

			return newProject;
		}
		
		/**
		 * Opens project from main view
		 * */
		public function openProjectFromMainView(project:IProject):void {
			
			if (project && project is IProject && !project.isOpen) {
				ViewManager.mainView.currentState = MainView.DESIGN_STATE;
				ViewManager.mainView.validateNow();
				addProject(project, false);
				openProjectFromMetaData(project, DocumentData.REMOTE_LOCATION, true);
				setProject(project, true);
			}
			else if (project && project is IProject && project.isOpen) {
				ViewManager.mainView.currentState = MainView.DESIGN_STATE;
				ViewManager.mainView.validateNow();
				setProject(project, true);
			}
		}
		
		/**
		 * Opens the project. Right now this does not do much. 
		 * */
		public function openProject(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Object {
			var isAlreadyOpen:Boolean;
			
			if (iProject==null) {
				error("No project to open");
				return null;
			}
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			isAlreadyOpen = isProjectOpen(iProject);
			
			/*
			if (dispatchEvents) {
				dispatchProjectChangeEvent(iProject);
			}*/
			
			if (iProject as EventDispatcher) {
				EventDispatcher(iProject).addEventListener(Project.PROJECT_OPENED, projectOpenResultHandler, false, 0, true);
			}
			
			if (isAlreadyOpen) {
				//setProject(iProject, dispatchEvents);
				return true;
			}
			else {
				// TODO open project documents
				iProject.open(locations);
				iProject.isOpen = true;
			}
			
			
			// show project
			//setProject(iProject, dispatchEvents);
			
			return true;
		}
		
		/**
		 * Project opened result handler
		 * */
		public function projectOpenResultHandler(event:Event):void {
			var iProject:IProject = event.currentTarget as IProject;
			
			// add assets
			addAssetsToDocument(iProject.assets, iProject as DocumentData);
			
			if (iProject is EventDispatcher) {
				EventDispatcher(iProject).removeEventListener(Project.PROJECT_OPENED, projectOpenResultHandler);
			}
			
			dispatchProjectOpenedEvent(iProject);
		}
		
		/**
		 * Opens the project. Right now this does not do much. 
		 * */
		public function openProjectFromMetaData(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Object {
			var isAlreadyOpen:Boolean;
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			isAlreadyOpen = isProjectOpen(iProject);
			
			/*
			if (dispatchEvents) {
				dispatchProjectChangeEvent(iProject);
			}*/
			
			if (iProject as EventDispatcher) {
				EventDispatcher(iProject).addEventListener(Project.PROJECT_OPENED, projectOpenResultHandler, false, 0, true);
			}
			
			// TODO open project documents
			iProject.openFromMetaData(locations);
			
			if (isAlreadyOpen) {
				//setProject(iProject, dispatchEvents);
				return true;
			}
			else {
				iProject.isOpen = true;
			}
			
			
			// show project
			//setProject(iProject, dispatchEvents);
			
			return true;
		}
		
		/**
		 * Checks if project is open.
		 * */
		public function isProjectOpen(iProject:IProject):Boolean {
			
			return iProject.isOpen;
		}
		
		/**
		 * Closes project if open.
		 * */
		public function closeProject(iProject:IProject, dispatchEvents:Boolean = true):Boolean {
			if (iProject==null) {
				error("No project to close");
				return false;
			}
			
			var numOfDocuments:int = iProject.documents.length;
			//info("Close project");
			if (dispatchEvents) {
				dispatchProjectClosingEvent(iProject);
			}
			
			for (var i:int=numOfDocuments;i--;) {
				closeDocument(IDocument(iProject.documents[i]));
				//removeDocument(IDocument(iProject.documents[i]));
			}
			
			iProject.close();
			
			if (dispatchEvents) {
				dispatchProjectClosedEvent(iProject);
			}
			
			return false;			
		}
		
		/**
		 * Removes a project from the projects array. TODO Remove from server
		 * */
		public function removeProject(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			// 1047: Parameter initializer unknown or is not a compile-time constant.
			// Occassionally a 1047 error shows up. 
			// This is from using a static var in the parameter as the default 
			// and is an error in FB - run clean and it will go away
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			var projectIndex:int = projects.indexOf(iProject);
			var removedProject:IProject;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfDocuments:int;
			var removedProjects:Array;
			
			if (projectIndex!=-1) {
				removedProjects = projects.splice(projectIndex, 1);
				
				if (removedProjects[0]==iProject) {
					info("Project removed successfully");
					
					numberOfDocuments = iProject.documents.length;
					
					for (var i:int=numberOfDocuments;i--;) {
						removeDocument(IDocument(iProject.documents[i]), locations, dispatchEvents);
					}
				}
				
			}
		
			if (remote && iProject && iProject.id) { 
				// we need to create service
				if (deleteProjectService==null) {
					deleteProjectService = new WPService();
					deleteProjectService.addEventListener(WPService.RESULT, deleteProjectResultsHandler, false, 0, true);
					deleteProjectService.addEventListener(WPService.FAULT, deleteProjectFaultHandler, false, 0, true);
				}
				
				deleteProjectService.host = getWPURL();
				
				deleteProjectInProgress = true;
				
				deleteProjectService.id = iProject.id;
				deleteProjectService.deletePost();
			}
			else if (remote) {
				if (dispatchEvents) {
					dispatchProjectRemovedEvent(iProject);
					dispatchProjectDeletedEvent(true, iProject);
				}
				return false;
			}
			
			// get first or last open document and select the project it's part of
			if (!selectedProject) {
				// to do
			}

			if (!remote && dispatchEvents) {
				dispatchProjectRemovedEvent(iProject);
			}
			

			return true;
		}
		
		/**
		 * Create project from project data
		 * */
		public function createProjectFromData(projectData:IProjectData):IProject {
			var newProject:IProject = createProject();
			newProject.unmarshall(projectData);
			
			return newProject;
		}
		
		/**
		 * Create project from project XML data
		 * */
		public function createProjectFromXML(projectData:XML):IProject {
			var newProject:IProject = createProject();
			newProject.unmarshall(projectData);
			
			return newProject;
		}
		
		/**
		 * Create document from document data
		 * */
		public function createDocumentDataFromMetaData(documentData:IDocumentMetaData, overwrite:Boolean = false):IDocumentData {
			var newDocument:IDocumentData = new DocumentData();
			newDocument.unmarshall(documentData);
			
			return newDocument;
		}
		
		/**
		 * Create document from document data
		 * */
		public function createDocumentFromData(documentData:IDocumentData, overwrite:Boolean = false):IDocument {
			var newDocument:IDocument = createDocument(documentData.name, documentData.type);
			newDocument.unmarshall(documentData);
			
			return newDocument;
		}
		
		/**
		 * Create document from document meta data
		 * */
		public function createDocumentFromMetaData(documentMetaData:IDocumentMetaData, overwrite:Boolean = false):IDocument {
			var documentData:IDocumentData = createDocumentDataFromMetaData(documentMetaData, overwrite);
			var iDocument:IDocument = createDocumentFromData(documentData, overwrite);
			
			return iDocument;
		}
		
		/**
		 * Open saved documents if they exist or open a blank document
		 * */
		public function openInitialProjects():void {
			/*
			if (savedData && (savedData.projects.length>0 || savedData.documents.length>0)) {
				restoreSavedData(savedData);
			}
			else {
				createBlankDemoDocument();
			}
			*/
			var savedData:SavedData = SettingsManager.savedData;
			
			if (!isUserLoggedIn) {
				if (savedData && (savedData.projects.length>0 || savedData.documents.length>0)) {
					openLocalProjects(savedData);
				}
				else {
					createBlankDemoDocument();
				}
			}
			else {
				serviceManager.getProjects();
				serviceManager.getAttachments();
			}
		}
		
		/**
		 * Creates a blank document and creates a new project if not supplied.
		 * 
		 * @param project if string then creates a new project. if an IProject then does not create a new project.
		 * */
		public function createBlankDemoDocument(project:Object = null, documentName:String = null, type:Class = null, open:Boolean = true, dispatchEvents:Boolean = false, select:Boolean = true):IDocument {
			var newProject:IProject;
			var newDocument:IDocument;
			
			if (project is String || project==null) {
				newProject = createProject(project as String); // create project
				addProject(newProject, false);       // add to projects array - shows up in application
			}
			else if (project is IProject) {
				newProject = project as IProject;
			}
			
			newDocument = createDocument(documentName); // create document
			addDocument(newDocument, newProject); // add to project and documents array - shows up in application
			
			openProject(newProject, DocumentData.INTERNAL_LOCATION); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true, true); // add to application and parse source code if any
			
			setProject(newProject, true); // selects project 
			
			return newDocument;
		}
		
		/**
		 * Creates a document
		 * */
		public function createDocument(name:String = null, Type:Object = null, project:IProject = null):IDocument {
			var hasDefinition:Boolean;
			var DocumentType:Object;
			var iDocument:IDocument;
			
			if (Type is String && Type!="null" && Type!="") {
				hasDefinition = ClassUtils.hasDefinition(String(Type));
				DocumentType = Document;
				
				if (hasDefinition) {
					DocumentType = ClassUtils.getDefinition(String(Type));
					iDocument = new DocumentType();
				}
				else {
					throw new Error("Type specified, '" + String(Type) + "' to create document is not found");
				}
			}
			else if (Type is Class) {
				iDocument = new Type();
			}
			else {
				iDocument = new Document();
			}
			
			iDocument.name = name ? name : "Document";
			iDocument.host = getWPURL();
			//document.documentData = document.marshall();
			return iDocument;
		}
		
		/**
		 * Adds a document to a project if set and adds it to the documents array
		 * */
		public function addDocument(iDocument:IDocument, project:IProject = null, overwrite:Boolean = false, dispatchEvents:Boolean = true):IDocument {
			var documentAlreadyExists:Boolean;
			var documentAdded:Boolean;
			var documentToRemove:IDocument;
			
			documentAlreadyExists = doesDocumentExist(iDocument.uid);
			
			// if not added already add to documents array
			if (!documentAlreadyExists) {
				documents.push(iDocument);
				documentAdded = true;
			}
			
			if (documentAlreadyExists && overwrite) {
				// check dates
				// remove from documents
				// remove from projects
				// add to documents
				// add to projects
				documentToRemove = getDocumentByUID(iDocument.uid);
				removeDocument(documentToRemove, DocumentData.LOCAL_LOCATION);// this is deleting the document
				// should there be a remove (internally) and delete method?
				
				//throw new Error("Document overwrite is not implemented yet");
				documentAdded = true;
			}
			
			if (project) {
				project.addDocument(iDocument, overwrite);
			}
			
			if (documentAdded && dispatchEvents) {
				dispatchDocumentAddedEvent(iDocument);
			}
			
			return iDocument;
		}
		
		/**
		 * Reverts a document to its open state
		 * */
		public function revertDocument(iDocument:IDocument, dispatchEvents:Boolean = true):Boolean {
			if (iDocument==null) {
				error("No document to revert");
				return false;
			}
			
			if ("revert" in iDocument) {
				Object(iDocument).revert();
				dispatchDocumentRevertedEvent(iDocument);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Removes a document from the documents array
		 * */
		public function removeDocument(iDocument:IDocument, locations:String = null, dispatchEvents:Boolean = true, saveProjectAfter:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var parentProject:IProject = iDocument.project;
			var documentsIndex:int = parentProject.documents.indexOf(iDocument);
			var removedDocument:IDocument;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			deleteDocumentProjectId = parentProject && parentProject.id!=null ? int(parentProject.id) : -1;
			saveProjectAfterDelete = saveProjectAfter;
			
			if (documentsIndex!=-1) {
				// add remove document to project
				var removedDocuments:Array = parentProject.documents.splice(documentsIndex, 1);
				
				if (removedDocuments[0]==iDocument) {
					//info("Document removed successfully");
				}
			}
			
			closeDocument(iDocument);
			// check if document is open in tab navigator
			/*if (isDocumentOpen(iDocument)) {
				var closed:Boolean = closeDocument(iDocument);
				info("Closed " + iDocument.name);
			}*/
			
			if (remote && iDocument && iDocument.id) { 
				// we need to create service
				if (deleteDocumentService==null) {
					deleteDocumentService = new WPService();
					deleteDocumentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteDocumentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteDocumentService.host = getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteDocumentService.id = iDocument.id
				deleteDocumentService.deletePost();
			}
			else if (remote) { // document not saved yet
				
				if (dispatchEvents) {
					dispatchDocumentRemovedEvent(iDocument);
					
					if (deleteDocumentProjectId!=-1 && saveProjectAfter) {
						parentProject.saveOnlyProject(locations);
					}
					
					setTarget(null);
					return true;
				}
			}
			else {
	
				if (dispatchEvents) {
					dispatchDocumentRemovedEvent(iDocument);
				}

			}
			
			// get first or last open document and select the project it's part of
			if (!this.selectedDocument) {

			}
			
			setTarget(null);
			
			return true;
		}
		
		/**
		 * Opens the document from it's document data. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public function openDocumentByData(data:IDocumentData, createIfNotFound:Boolean, showDocument:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var iDocument:IDocument = getDocumentByUID(data.uid);
			
			if (!iDocument && createIfNotFound) {
				iDocument = createDocumentFromData(data);
			}
			
			var newDocument:IDocument = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, showDocument, dispatchEvents);
			
			return newDocument;
		}
		
		/**
		 * Duplicates the document 
		 * 
		 * It returns the document container. 
		 * */
		public function duplicateDocument(iDocument:IDocument, showDocument:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var newDocument:IDocument;
			
			if (iDocument) {
				newDocument = createDocumentFromData(iDocument);
				removeUniqueDocumentData(newDocument);
			}
			else {
				error("No document to duplicate");
				return null;
			}
			
			newDocument = openDocument(newDocument, DocumentData.INTERNAL_LOCATION, showDocument, dispatchEvents);
			
			return newDocument;
		}
		
		/**
		 * Removes unique document data such as remote ID and UID. 
		 * Used for duplicating documents and importing example projects
		 * */
		public function removeUniqueDocumentData(iDocument:Object):void {
			if (iDocument is IDocumentData) {
				IDocument(iDocument).id = null;
				IDocument(iDocument).uid = null;
			}
		}
		
		/**
		 * Import FXG code
		 * */
		public function importFXGDocument(project:IProject, iDocument:IDocument, code:String, container:Object = null, containerIndex:int = -1, name:String = null, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			
			if (!iDocument) {
				iDocument = createDocument(name);
				newDocument = true;
				
				if (project) {
					addDocument(iDocument, project);
				}
			}
			
			if (!newDocument) {
				sourceData = parseSource(iDocument, code, container, containerIndex, options, dispatchEvents, reportErrors);
				
				return sourceData;
			}
			else {
				iDocument.originalSource = code;
				iDocument.source = code;
				// we load a blank application (swf), once it's loaded, 
				// in DocumentContainer we call Radiate.parseSource(iDocument);
				result = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, true, dispatchEvents);
			}
			
			return sourceData;
		}
		
		/**
		 * Import SVG code
		 * */
		public function importSVGDocument(project:IProject, iDocument:IDocument, code:String, container:Object = null, containerIndex:int = -1, name:String = null, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			var fxgCode:String;
			
			try {
				fxgCode = SVGUtils.convert(code);
			}
			catch (error:Error) {
				warn("Could not import SVG. " + error);
				
			}
			
			if (fxgCode) {
				sourceData = importFXGDocument(project, iDocument, fxgCode, container, containerIndex, name, options, dispatchEvents, reportErrors);
			}
			
			
			return sourceData;
		}
		
		/**
		 * Import MXML code
		 * */
		public function importMXMLDocument(project:IProject, iDocument:IDocument, code:String, container:Object = null, containerIndex:int = -1, name:String = null, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			
			if (!iDocument) {
				iDocument = createDocument(name);
				newDocument = true;
				
				if (project) {
					addDocument(iDocument, project);
				}
			}
			
			if (!newDocument) {
				sourceData = parseSource(iDocument, code, container, containerIndex, options, dispatchEvents, reportErrors);
				
				return sourceData;
			}
			else {
				iDocument.originalSource = code;
				iDocument.source = code;
				// we load a blank application (swf), once it's loaded, 
				// in DocumentContainer we call Radiate.parseSource(iDocument);
				result = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, true, dispatchEvents);
			}
			
			return sourceData;
		}
		
		/**
		 * Opens the document. If the document is already open it selects it. 
		 * When the document loads (it's a blank application swf) then the mxml is parsed. Check the DocumentContainer class.  
		 * 
		 * It returns the document container. 
		 * */
		public function openDocument(iDocument:IDocument, locations:String = null, showDocumentInTab:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var openingEventDispatched:Boolean;
			var containerTypeInstance:Object;
			var isAlreadyOpen:Boolean;
			var container:Object;
			var documentIndex:int;
			var previewName:String;
			var index:int;
			
			if (iDocument==null || documentsTabNavigator==null) {
				error("No document to open");
				return null;
			}
			
			// NOTE: If the document is empty or all of the components are in the upper left hand corner
			// and they have no properties then my guess is that the application was never fully loaded 
			// or activated. this happens with multiple documents opening too quickly where some 
			// do not seem to activate. you see them activate when you select their tab for the first time
			// so then later if it hasn't activated, when the document is exported none of the components have
			// their properties or styles set possibly because Flex chose to defer applying them.
			// the solution is to make sure the application is fully loaded and activated
			// and also store a backup of the document MXML. 
			// that could mean waiting to open new documents until existing documents have 
			// loaded. listen for the application complete event (or create a parse and import event) 
			// ...haven't had time to do any of this yet
			// UPDATE OCT 4, 2015 - try calling activate() on the application - see Radii8Desktop.mxml menu item
			
			isAlreadyOpen = isDocumentOpen(iDocument);
			
			if (dispatchEvents) {
				openingEventDispatched = dispatchDocumentOpeningEvent(iDocument);
				
				if (!openingEventDispatched) {
					//return false;
				}
			}
			
			if (isAlreadyOpen) {
				index = getDocumentTabIndex(iDocument);
				
				if (showDocumentInTab) {
					//showDocument(iDocument, false, false); // the next call will dispatch events
					showDocument(iDocument, false, dispatchEvents); // the next call will dispatch events
					selectDocument(iDocument, dispatchEvents);
				}
				return iDocument;
			}
			else {
				iDocument.open(locations);
			}
			
			// TypeError: Error #1034: Type Coercion failed: cannot convert 
			// com.flexcapacitor.components::DocumentContainer@114065851 to 
			// mx.core.INavigatorContent
			navigatorContent = new NavigatorContent();
			navigatorContent.percentWidth = 100;
			navigatorContent.percentHeight = 100;
			
			navigatorContent.label = iDocument.name ? iDocument.name : "Untitled";
			
			
			if (iDocument.containerType==null) {
				documentContainer = new DocumentContainer();
				documentContainer.percentWidth = 100;
				documentContainer.percentHeight = 100;
				
				documentsContainerDictionary[iDocument] = documentContainer;
				navigatorContent.addElement(documentContainer);
				documentContainer.iDocument = IDocument(iDocument);
			}
			else {
				// custom container
				containerTypeInstance = new iDocument.containerType();
				//containerTypeInstance.id = document.name ? document.name : "";
				containerTypeInstance.percentWidth = 100;
				containerTypeInstance.percentHeight = 100;
				
				documentsContainerDictionary[iDocument] = containerTypeInstance;
				navigatorContent.addElement(containerTypeInstance as IVisualElement);
				containerTypeInstance.iDocument = IDocument(iDocument);
			}
		
			if (documentsTabNavigator) {
				//documentIndex = !isPreview ? 0 : getDocumentIndex(document) + 1;
				documentsTabNavigator.addElement(navigatorContent);
			}
			documentIndex = getDocumentTabIndex(iDocument);
			
			// show document
			if (showDocumentInTab) {
				showDocument(iDocument, false, dispatchEvents);
				selectDocument(iDocument, dispatchEvents);
			}
			
			return iDocument;
		}
		
		/**
		 * Opens a preview of the document. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public function openDocumentPreview(iDocument:IDocument, showDocument:Boolean = false, dispatchEvents:Boolean = true):Object {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var isAlreadyOpen:Boolean;
			var index:int;
			var iframe:IFrame;
			var html:UIComponent;
			var containerTypeInstance:Object;
			var container:Object;
			var openingEventDispatched:Boolean;
			var documentIndex:int;
			var previewName:String;
			var elementId:String;
			
			isAlreadyOpen = isDocumentPreviewOpen(iDocument);
			
			if (dispatchEvents) {
				openingEventDispatched = dispatchDocumentOpeningEvent(iDocument, true);
				if (!openingEventDispatched) {
					//return false;
				}
			}
			
			if (isAlreadyOpen) {
				index = getDocumentPreviewIndex(iDocument);
				
				if (showDocument) {
					showDocumentAtIndex(index, false); // the next call will dispatch events
					selectDocument(iDocument, dispatchEvents);
				}
				return documentsPreviewDictionary[iDocument];
			}
			else {
				iDocument.isPreviewOpen = true;
			}
			
			// TypeError: Error #1034: Type Coercion failed: cannot convert 
			// com.flexcapacitor.components::DocumentContainer@114065851 to 
			// mx.core.INavigatorContent
			navigatorContent = new NavigatorContent();
			navigatorContent.percentWidth = 100;
			navigatorContent.percentHeight = 100;
			
			navigatorContent.label = iDocument.name ? iDocument.name : "Untitled";
			
			previewName = iDocument.name + " HTML";
			navigatorContent.label = previewName;
			
			// should we be setting id like this?
			elementId = iDocument.name ? iDocument.name : NameUtil.createUniqueName(iDocument);
			elementId = elementId.replace(/ /g, "");
			
			if (iDocument.containerType) {
				containerTypeInstance = new iDocument.containerType();
				containerTypeInstance.id = elementId;
				containerTypeInstance.percentWidth = 100;
				containerTypeInstance.percentHeight = 100;
				
				navigatorContent.addElement(containerTypeInstance as IVisualElement);
				documentsPreviewDictionary[iDocument] = containerTypeInstance;
			}
			else if (isDesktop) {
				
				// we should add an option to use stage web instead of 
				// internal webkit browser
				
				// show HTML page
				var htmlClass:Object = ApplicationDomain.currentDomain.getDefinition(desktopHTMLClassName);
				html = new htmlClass();
				//html.id = elementId;
				html.percentWidth = 100;
				html.percentHeight = 100;
				html.top = -10; // get rid of spacing navigator adds
				html.left = 0;
				//html.setStyle("backgroundColor", "#666666");
				
				// not sure how to get the parsing errors 
				html.addEventListener("uncaughtScriptException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("uncaughtException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("scriptException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("htmlError", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("error", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				
				navigatorContent.addElement(html);
				documentsPreviewDictionary[iDocument] = html;
			}
			else {
				// show HTML page
				iframe = new IFrame();
				iframe.id = NameUtil.createUniqueName(iframe);
				iframe.percentWidth = 100;
				iframe.percentHeight = 100;
				iframe.top = -10;
				iframe.left = 0;
				iframe.setStyle("backgroundColor", "#666666");
				
				popUpOverlayManager = PopUpOverlayManager.getInstance();
				popUpOverlayManager.addOverlay(iframe);
				
				navigatorContent.addElement(iframe);
				documentsPreviewDictionary[iDocument] = iframe;
			}
			
			
			// if preview add after original document location
			documentIndex = getDocumentTabIndex(iDocument) + 1; // add after
			documentsTabNavigator.addElementAt(navigatorContent, documentIndex);
			
			// show document
			if (showDocument) {
				showDocumentAtIndex(documentIndex, dispatchEvents);
				selectDocument(iDocument, dispatchEvents);
			}
			
			return documentsPreviewDictionary[iDocument];
		}
		
		/**
		 * Checks if a document preview is open.
		 * @see isDocumentSelected
		 * */
		public function isDocumentPreviewOpen(document:IDocument):Boolean {
			var openTabs:Array = documentsTabNavigator && documentsTabNavigator.getChildren() ? documentsTabNavigator.getChildren() : [];
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			
			if (tabCount==0) {
				return false;
			}
			
			var documentContainer:Object = documentsPreviewDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Checks if document is open.
		 * @see isDocumentSelected
		 * */
		public function isDocumentOpen(iDocument:IDocument, isPreview:Boolean = false):Boolean {
			var openTabs:Array;
			var tabCount:int;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object;
			
			if (!documentsTabNavigator) {
				return false;
			}
			
			openTabs = documentsTabNavigator.getChildren();
			tabCount = openTabs.length;
			documentContainer = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return true;
				}
			}
			
			return false;
			
		}
		
		/**
		 * Closes the current visible document regardless if it is a preview or not. 
		 * @see isDocumentSelected
		 * */
		public function closeVisibleDocument():Boolean {
			
			var selectedDocument:IDocument = getDocumentAtIndex(documentsTabNavigator.selectedIndex);
			var isPreview:Boolean = isPreviewDocumentVisible();
			
			return closeDocument(selectedDocument, isPreview, true);
			
		}
		
		/**
		 * Closes document if open.
		 * @see isDocumentSelected
		 * */
		public function closeDocument(iDocument:IDocument, isPreview:Boolean = false, selectOtherDocument:Boolean = false):Boolean {
			if (iDocument==null || documentsTabNavigator==null) {
				error("No document to close");
				return false;
			}
			
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var navigatorContent:NavigatorContent;
			var navigatorContentDocumentContainer:Object;
			var documentContainer:Object;
			var wasDocumentClosed:Boolean;
			var wasPreviewClosed:Boolean;
			var index:int;
			var isIFrame:Boolean;
			
			documentContainer = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			if (documentContainer is IFrame) {
				popUpOverlayManager.removeOverlay(documentContainer as DisplayObject);
			}
			
			if (documentContainer && documentContainer.owner) {
				// ArgumentError: Error #2025: The supplied DisplayObject must be a child of the caller.
				// 	at flash.display::DisplayObjectContainer/getChildIndex()
				//var index:int = documentsTabNavigator.getChildIndex(documentContainer.owner as DisplayObject);
				var contains:Boolean = documentsTabNavigator.contains(documentContainer.owner as DisplayObject);
				
				if (contains) {
					index = documentsTabNavigator.getChildIndex(documentContainer.owner);
					documentsTabNavigator.removeChild(documentContainer.owner);
					
					// close previews when the main document is closed
					if (!isPreview) {
						documentContainer = documentsPreviewDictionary[iDocument];
						
						if (documentContainer) {
							wasPreviewClosed = true;
							documentsTabNavigator.removeChild(documentContainer.owner);
						}
						
						iDocument.close();
						//removeDocument(iDocument);
						
						//var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsDictionary[iDocument];
						
						delete documentsContainerDictionary[iDocument];
						delete documentsPreviewDictionary[iDocument];
						wasDocumentClosed = true;
					}
					else {
						delete documentsPreviewDictionary[iDocument];
						wasPreviewClosed = true;
					}
					
					if (isPreview) {
						// TODO we must remove HTML from IFrame (inline css from previous iframes previews affects current preview)
					}
					else {
						selectDocument(null);
					}
					
					documentsTabNavigator.validateNow();
					
					dispatchDocumentCloseEvent(iDocument, wasDocumentClosed, wasPreviewClosed);
				}
			}
			
			var otherDocument:IDocument;
			
			if (selectOtherDocument && wasDocumentClosed && tabCount>1) {
				otherDocument = getVisibleDocument();
				openTabs = documentsTabNavigator.getChildren();
				tabCount = openTabs.length;
				
				if (otherDocument==null) {
					//index = index==0 ? 1 : index-1;
					isPreviewDocumentVisible()
					otherDocument = documents && documents.length ? documents[0] : null;
				}
				if (otherDocument) {
					selectDocument(otherDocument);
					showDocument(otherDocument);
				}
			}
			else {
				openTabs = documentsTabNavigator.getChildren();
				tabCount = openTabs.length;
				
				if (tabCount==0) {
					setTarget(null);
				}
			}
			
			return true;
			
			// first attempt
			//info("Closing " + iDocument.name);
			for (var i:int;i<tabCount;i++) {
				navigatorContent = NavigatorContent(documentsTabNavigator.getChildAt(i));
				navigatorContentDocumentContainer = navigatorContent.numElements ? navigatorContent.getElementAt(0) : null;
				//info(" Checking tab " + tab.label);
				
				if (iDocument.name==navigatorContent.label) {
					//info(" Name Match " + iDocument.name);
					if (IDocumentContainer(navigatorContentDocumentContainer).iDocument==iDocument) {
						documentsTabNavigator.removeChild(navigatorContent);
						documentsTabNavigator.validateNow();
						
						return true;
					}
				}
				
				
				// oddly enough after we remove one child using the code below (note: see update)
				// the documentContainer in the documentsDictionary is no longer 
				// connected with the correct document data 
				// if we do this one at a time and remove one per second 
				// then it works but not many documents at a time (see removeProject)
				// so instead we are checking by name and then document reference 
				// in the code above this
				
				// Update: May have spoken too soon - could be problem because document 
				// was used as a variable name and it scoped to document on the UIComponent class :(
				
				if (navigatorContentDocumentContainer && navigatorContentDocumentContainer==documentContainer) {
					documentsTabNavigator.removeChild(navigatorContent);
					documentsTabNavigator.validateNow();
					return true;
				}
			}
			
			return false;
			
		}
		
		/**
		 * Checks if document is open and selected
		 * */
		public function isDocumentSelected(document:Object, isPreview:Boolean = false):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentIndex:int = -1;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					documentIndex = i;
					break;
				}
			}
			

			if (documentsTabNavigator.selectedIndex==documentIndex) {
				return true;
			}
			
			return false;
			
		}
		
		/**
		 * Get visible document in documents tab navigator
		 * */
		public function getVisibleDocument():IDocument {
			var selectedTab:NavigatorContent = documentsTabNavigator ? documentsTabNavigator.selectedChild as NavigatorContent : null;
			var tabContent:Object = selectedTab && selectedTab.numElements ? selectedTab.getElementAt(0) : null;
			
			if (tabContent is IDocumentContainer) {
				var iDocument:IDocument = IDocumentContainer(tabContent).iDocument;
				return iDocument;
			}
			
			
			var selectedDocument:IDocument = getDocumentAtIndex(documentsTabNavigator.selectedIndex);
			var isPreview:Boolean = isPreviewDocumentVisible();
			
			return selectedDocument;
		}
		
		/**
		 * Get the index of the document in documents tab navigator
		 * 
		 * */
		public function getDocumentTabIndex(document:Object, isPreview:Boolean = false):int {
			//TypeError: Error #1009: Cannot access a property or method of a null object reference.
			//	at com.flexcapacitor.controller::Radiate/getDocumentTabIndex()[/Users/monkeypunch/Documents/ProjectsGithub/Radii8/Radii8Library/src/com/flexcapacitor/controller/Radiate.as:5649]
			if (documentsTabNavigator==null) {
				info("Documents tab navigator is not created yet so for now you must open the document manually. Close and then open the document.");
				if (document && document is IDocument) {
					closeDocument(IDocument(document));
				}
				return -1;
			}
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			var tabContent:Object;
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * Get the index of the document preview in documents tab navigator
		 * */
		public function getDocumentPreviewIndex(document:Object):int {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var documentContainer:Object = documentsPreviewDictionary[document];
			var tabContent:Object;
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * Get the document for the given application
		 * */
		public function getDocumentForApplication(application:Application):IDocument {
			var document:IDocument;
			
			for each (document in documentsContainerDictionary) {
				if (document.instance === application) {
					return document;
					break;
				}
			}
			return null;
		}
		
		/**
		 * Gets the document container for the document preview. 
		 * For example, a document can be previewed as an HTML page. 
		 * If we want to get the document that is previewing HTML then 
		 * we need to get the container of the preview.
		 * */
		public function getDocumentPreview(document:Object):Object {
			var documentContainer:Object = documentsPreviewDictionary[document];
			return documentContainer;
		}
		
		public static var htmlOptions:HTMLExportOptions;
		
		/**
		 * Returns if the visible document is a preview
		 * */
		public function isPreviewDocumentVisible():Boolean {
			var tabContainer:NavigatorContent = documentsTabNavigator.selectedChild as NavigatorContent;
			var tabContent:Object = tabContainer && tabContainer.numElements ? tabContainer.getElementAt(0) : null;
			var isPreview:Boolean;
			
			isPreview = DictionaryUtils.containsValue(documentsPreviewDictionary, tabContent);
			
			//if (!isDocument) {
			//	isDocument = DictionaryUtils.containsValue(documentsPreviewDictionary, tabContainer);
			//}
			
			return isPreview;
		}
		
		/**
		 * Parses data into an array of usable objects 
		 * Should be in a ServicesManager class?
		 * */
		public function parseProjectsData(data:Object):Array {
			var dataLength:int;
			var post:Object;
			var project:IProject
			var xml:XML;
			var isValid:Boolean;
			var firstProject:IProject;
			var potentialProjects:Array = [];
			var source:String;
			
			dataLength = data && data is Object ? data.count : 0;
			
			for (var i:int;i<dataLength;i++) {
				post = data.posts[i];
				//isValid = XMLUtils.isValidXML(post.content);
				source = post.custom_fields.source;
				isValid = XMLUtils.isValidXML(source);
				
				if (isValid) {
					xml = new XML(source);
					// should have an unmarshall from data method
					project = createProjectFromXML(xml);
					
					// maybe we should keep an array of the projects we just loaded
					// then we can unmarshall them rather than creating them from xml
					if (post.attachments) {
						project.parseAttachments(post.attachments);
					}
					
					// if id is not set in the XML set it manually
					// we need id for  delete
					if (project.id==null || project.id=="") {
						project.id = post.id;
					}
					
					// let's enforce url 
					project.uri = post.url;
					if (project.uri==null || project.uri=="") {
						project.uri = post.url;
					}
					//addProject(project);
					potentialProjects.push(project);
				}
				else {
					Radiate.info("Could not import project:" + post.title);
				}
			}
			
			var sort:Sort = new Sort();
			var sortField:SortField = new SortField("dateSaved");
			sort.fields = [sortField];
			
			return potentialProjects;
		}
		
		/**
		 * Parses the code and builds a document. 
		 * If code is null and source is set then parses source.
		 * If parent is set then imports code to the parent
		 * */
		public static function parseSource(document:IDocument, code:String = null, parent:Object = null, containerIndex:int = -1, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = false):SourceData {
			var codeToParse:String;
			var currentChildren:XMLList;
			var nodeName:String;
			var child:XML;
			var xml:XML;
			var root:String;
			var isValid:Boolean;
			var rootNodeName:String;
			var updatedCode:String;
			var mxmlDocumentImporter:MXMLDocumentImporter;
			var componentDescription:ComponentDescription;
			var sourceDataLocal:SourceData;
			var transcoder:TranscoderDescription;
			var importer:DocumentTranscoder;
			var message:String;
			var openPopUpOnError:Boolean;
			
			rootNodeName = MXMLDocumentConstants.ROOT_NODE_NAME;
			codeToParse = code ? code : document.source;
			
			// I don't like this here - should move or dispatch events to handle import
			transcoder = CodeManager.getImporter(CodeManager.MXML);
			importer = transcoder.importer;
			
			if (codeToParse=="" || codeToParse=="null") {
				message = "No code to parse for document, \"" + document.name + "";
				error(message);
				return null;
			}
			
			isValid = XMLUtils.isValidXML(codeToParse);
			
			if (!isValid) {
				root = "<" + rootNodeName + " " + MXMLDocumentConstants.getDefaultNamespaceDeclarations() + ">";
				updatedCode = root + codeToParse + "</"+rootNodeName+">";
				
				isValid = XMLUtils.isValidXML(updatedCode);
				
				if (isValid) {
					codeToParse = updatedCode;
				}
			}
			
			// check for valid XML
			try {
				xml = new XML(codeToParse);
			}
			catch (errorError:Error) {
				message = "Could not parse code for document, \"" + document.name + "\". Fix the code before you import.";
				error("Could not parse code for document, \"" + document.name + "\". \n" + errorError.message + " \nCode: \n" + codeToParse);
				
				if (openImportPopUp && openPopUpOnError) {
					openImportPopUp.popUpOptions = {title:message, code:codeToParse};
					openImportPopUp.play();
				}
			}
			
			
			if (xml) {
				// loop through each item and create an instance 
				// and set the properties and styles on it
				/*currentChildren = xml.children();
				while (child in currentChildren) {
				nodeName = child.name();
				
				}*/
				//Radiate.info("Importing document: " + name);
				//var mxmlLoader:MXMLImporter = new MXMLImporter( "testWindow", new XML( inSource ), canvasHolder  );
				
				var container:IVisualElement = parent ? parent as IVisualElement : instance as IVisualElement;
				
				if (container is Application && "activate" in container) {
					Object(container).activate();
				}
				
				if (document && document.instance is Application && "activate" in document.instance) {
					Object(document.instance).activate();
				}
				
				if (parent) {
					componentDescription = document.getItemDescription(parent);
				}
				
				if (componentDescription==null) {
					componentDescription = document.componentDescription;
				}
				
				sourceDataLocal = importer.importare(codeToParse, document, componentDescription, containerIndex, options, dispatchEvents);
				
				if (container && dispatchEvents) {
					instance.setTarget(container);
				}
				
				if (sourceDataLocal.errors && sourceDataLocal.errors.length && reportErrors) {
					outputMXMLErrors("", sourceDataLocal.errors);
				}
			}
			
			
			/*_toolTipChildren = new SystemChildrenList(this,
			new QName(mx_internal, "topMostIndex"),
			new QName(mx_internal, "toolTipIndex"));*/
			//return true;
			
			return sourceDataLocal;
		}
		
		/**
		 * Open import MXML window
		 * */
		public function openImportMXMLWindow(title:String, code:String = "", showRevisions:Boolean = false, snippet:String = ""):void {
			
			if (openImportPopUp==null) {
				createOpenImportPopUp();
			}
			
			if (!openImportPopUp.isOpen) {
				openImportPopUp.popUpOptions = {title:title, code:code, showRevisions:showRevisions, snippetID:snippet};
				openImportPopUp.play();
			}
		}
		
		public function createOpenImportPopUp():void {
			if (openImportPopUp==null) {
				openImportPopUp = new OpenPopUp();
				openImportPopUp.popUpType = ImportWindow; 
				openImportPopUp.modalDuration = 150;
				openImportPopUp.percentWidth = 80;
				openImportPopUp.percentHeight = 76;
				openImportPopUp.useHardPercent = true;
				openImportPopUp.parent = ViewManager.application;
				openImportPopUp.closeOnMouseDownOutside = false;
				openImportPopUp.closeOnMouseDownInside = false;
				openImportPopUp.closeOnEscapeKey = false;
				openImportPopUp.addEventListener(OpenPopUp.CLOSE, closeImportWindowHandler);
			}
		}
		
		/**
		 * Opens a new document with MXML specified
		 * */
		public function openMXMLDocument(name:String, mxml:String):void {
			name = name.lastIndexOf(".")!=-1 ? name.substr(0, name.lastIndexOf(".")) : name;
			importMXMLDocument(selectedProject, null, mxml, null, -1, name);
		}
		
		/**
		 * When import MXML window is closed we check for requested action 
		 * and import if necessary 
		 * */
		public function closeImportWindowHandler(event:Event):void {
			var selectedDocument:IDocument = selectedDocument;
			var popUp:ImportWindow = ImportWindow(openImportPopUp.popUp);
			var type:String = popUp.importLocation.selectedValue as String;
			var action:String = popUp.action;
			var code:String = popUp.code;
			
			if (action==ImportWindow.IMPORT) {
				if (type==ImportWindow.NEW_DOCUMENT) {
					importMXMLDocument(selectedProject, null, code);
				}
				else if (type==ImportWindow.CURRENT_DOCUMENT && selectedDocument) {
					importMXMLDocument(selectedProject, selectedDocument, code);
				}
				else if (type==ImportWindow.CURRENT_SELECTION && target is IVisualElement) {
					if (target is IVisualElement) {
						importMXMLDocument(selectedProject, selectedDocument, code, IVisualElement(target));
					}
					Alert.show("Please select a visual element");
				}
				else {
					Alert.show("Please select a document");
				}
			}
			
			popUp.action = null;
			popUp.code = null;
		}
		
		/**
		 * Selects the document in the tab navigator
		 * */
		public function showDocument(iDocumentData:IDocumentData, isPreview:Boolean = false, dispatchEvent:Boolean = true):Boolean {
			var documentIndex:int = getDocumentTabIndex(iDocumentData, isPreview);
			var result:Boolean;
			
			if (documentIndex!=-1) {
				result = showDocumentAtIndex(documentIndex, dispatchEvent);
			}
			
			return result;
		}
		
		
		/**
		 * Selects the document at the specifed index
		 * */
		public function showDocumentAtIndex(index:int, dispatchEvent:Boolean = true):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var document:IDocument;
			
			documentsTabNavigator.selectedIndex = index;
			
			tab = NavigatorContent(documentsTabNavigator.selectedChild);
			tabContent = tab && tab.numElements ? tab.getElementAt(0) : null;
			
			if (tabContent && tabContent is DocumentContainer && dispatchEvent) {
				document = getDocumentAtIndex(index);
				dispatchDocumentChangeEvent(DocumentContainer(tabContent).iDocument);
			}
			
			return documentsTabNavigator.selectedIndex == index;
		}
		
		/**
		 * Get the document at the index in the tab navigator
		 * */
		public function getDocumentAtIndex(index:int):IDocument {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var document:IDocument;
			
			if (index<0) {
				return null;
			}
			
			tab = index < openTabs.length ? openTabs[index] : null;
			tabContent = tab.numElements ? tab.getElementAt(0) : null;
	
			for (var key:* in documentsContainerDictionary) {
				if (documentsContainerDictionary[key] === tabContent) {
					return key;
				}
			}
			
	
			for (key in documentsPreviewDictionary) {
				if (documentsPreviewDictionary[key] === tabContent) {
					return key;
				}
			}
			
			return null;
			
		}
		
		/**
		 * Get document by UID
		 * */
		public function getDocumentByUID(id:String):IDocument {
			var numberOfDocuments:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<numberOfDocuments;i++) {
				iDocument = IDocument(documents[i]);
				
				if (id==iDocument.uid) {
					return iDocument;
				}
			}
			
			return null;
		}
		
		/**
		 * Check if document exists in documents array
		 * */
		public function doesDocumentExist(id:String):Boolean {
			var numberOfDocuments:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<numberOfDocuments;i++) {
				iDocument = IDocument(documents[i]);
				
				if (id==iDocument.uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Check if project exists in projects array. Pass in the UID not ID.
		 * */
		public function doesProjectExist(uid:String):Boolean {
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = IProject(projects[i]);
				
				if (iProject.uid==uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Get project by UID
		 * */
		public function getProjectByUID(id:String):IProject {
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = IProject(projects[i]);
				
				if (id==iProject.uid) {
					return iProject;
				}
			}
			
			return null;
		}
		
		/**
		 * Get project by ID
		 * */
		public function getProjectByID(id:int):IProject {
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = IProject(projects[i]);
				
				if (iProject.id!=null && id==int(iProject.id)) {
					return iProject;
				}
			}
			
			return null;
		}
		
		/**
		 * Get first project that owns this document
		 * */
		public function getDocumentProject(iDocument:IDocument):IProject {
			var projectsList:Array = getDocumentProjects(iDocument);
			var iProject:IProject;
			
			if (projectsList.length>0) {
				iProject = projectsList.shift();
			}
			
			return iProject;
		}
		
		/**
		 * Get a list of projects that own this document
		 * */
		public function getDocumentProjects(iDocument:IDocument):Array {
			var numberOfDocuments:int;
			var projectDocument:IDocument;
			var projectLength:int = projects.length;
			var iProject:IProject;
			var projectDocuments:Array;
			var projectsList:Array = [];
			
			for (var A:int;A<length;A++) {
				iProject = IProject(projects[A]);
				projectDocuments = iProject.documents;
				numberOfDocuments = projectDocuments ? projectDocuments.length : 0;
				
				for (var B:int;B<numberOfDocuments;B++) {
					projectDocument = IDocument(projectDocuments[B]);
					
					if (projectDocuments.uid==iDocument.uid) {
						projectsList.push(iProject);
					}
				}
			}
			
			return projectsList;
		}
		
		
		/**
		 * Rename document
		 * */
		public function renameDocument(iDocument:IDocument, name:String):void {
			var tab:NavigatorContent;
			
			// todo check if name already exists
			iDocument.name = name;
			tab = getNavigatorByDocument(iDocument);
			
			if (iDocument.instance is Application) {
				setProperty(iDocument.instance, "pageTitle", name);
			}
			
			if (tab) {
				tab.label = iDocument.name;
			}
			
			dispatchDocumentRenameEvent(iDocument, name);
		}
		
		/**
		 * 
		 * */
		public function getNavigatorByDocument(iDocument:IDocument, isPreview:Boolean = false):NavigatorContent {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return tab;
				}
			}
			
			return null;
		}
		
		/**
		 * Create new document. 
		 * */
		public function createNewDocument(name:String = null, type:Object = null, project:IProject = null):void {
			var newDocument:IDocument;
			
			newDocument = createDocument(name, type);
			addDocument(newDocument, selectedProject, true, true);
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true);
			/*
			
			if (project) {
				project.addDocument(iDocument, overwrite);
			}
			
			if (documentAdded && dispatchEvents) {
				dispatchDocumentAddedEvent(iDocument);
			}
			
			if (!selectedProject) {
				project = createProject(); // create project
				addProject(project);       // add to projects array - shows up in application
			}
			else {
				project = selectedProject;
			}
			
			newDocument = createDocument(name, type); // create document
			addDocument(newDocument, project); // add to project and documents array - shows up in application
			
			//openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, true, true); // add to application and parse source code if any
			
			setProject(project); // selects project 
			setDocument(newDocument);*/
		}
		
		/**
		 * Create new project. 
		 * */
		public function createNewProject(name:String = null, type:Object = null, project:IProject = null):void {
			var newProject:IProject;
			
			newProject = createProject(); // create project
			addProject(newProject);       // add to projects array - shows up in application
			
			openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			
			setProject(newProject); // selects project 
			
		}
		
		/**
		 * Create and add saved documents of array of type IDocumentData. 
		 * */
		public function createAndAddDocumentsData(documentsData:Array, add:Boolean = true):Array {
			var potentialDocuments:Array = [];
			var iDocumentMetaData:IDocumentMetaData;
			var iDocumentData:IDocumentData;
			var iDocument:IDocument;
			var numberOfDocuments:int;
				
			// get documents and add them to the documents array
			
			// TRYING TO NOT create documents until they are needed
			// but then we have issues when we want to save
			if (documentsData && documentsData.length>0) {
				numberOfDocuments = documentsData.length;
				
				for (var i:int;i<numberOfDocuments;i++) {
					// TypeError: Error #1034: Type Coercion failed: cannot convert com.flexcapacitor.model::DocumentMetaData
					// to com.flexcapacitor.model.IDocumentData. check export and marshall options
					// saved as wrong data type
					iDocumentData = IDocumentData(documentsData[i]);
					
					// document doesn't exist - add it
					if (getDocumentByUID(iDocumentData.uid)==null) {
						iDocument = createDocumentFromData(iDocumentData);
						potentialDocuments.push(iDocument);
						
						if (add) {
							addDocument(iDocument);
						}
					}
					else {
						log.info("Document " + iDocumentData.name + " is already open.");
					}
				}
			}
			
			return potentialDocuments;
		}
		
		/**
		 * Create projects from array of type IProjectData
		 * */
		public function createAndAddProjectsData(projectsData:Array, add:Boolean = true):Array {
			var iProjectData:IProjectData;
			var potentialProjects:Array = [];
			var numberOfProjects:int;
			var iProject:IProject;
			
			// get projects and add them to the projects array
			if (projectsData && projectsData.length>0) {
				numberOfProjects = projectsData.length;
				
				for (var i:int;i<numberOfProjects;i++) {
					iProjectData = IProjectData(projectsData[i]);
					
					// project doesn't exist - add it
					if (getProjectByUID(iProjectData.uid)==null) {
						iProject = createProjectFromData(iProjectData);
						potentialProjects.push(iProject);
						
						if (add) {
							addProject(iProject);
						}
					}
					else {
						log.info("Project " + iProjectData.name + " is already open.");
					}
					
				}
			}
			
			return potentialProjects;
		}
		
		/**
		 * Restores projects and documents from local store
		 * Add all saved projects to projects array
		 * Add all saved documents to documents array
		 * Add documents to projects
		 * Open previously open projects
		 * Open previously open documents
		 * Select previously selected project
		 * Select previously selected document
		 * */
		public function openLocalProjects(data:SavedData):void {
			var projectsDataArray:Array;
			var potentialProjects:Array  = [];
			var potentialDocuments:Array = [];
			var savedDocumentsDataArray:Array;
			var numberOfPotentialProjects:int;
			var iProject:IProject;
			
			/*
			var iProjectData:IProjectData;
			var iDocumentData:IDocumentData;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			var iProjectDocument:IDocument;
			var iProjectDocumentsArray:Array;
			var iProjectDocumentsLength:int;
			var potentialDocumentsLength:int;
			var documentsDataArrayLength:int;*/
			
			// get list of projects and list of documents
			if (data) {
				
				// get projects and add them to the projects array
				projectsDataArray = data.projects;
				potentialProjects = createAndAddProjectsData(data.projects);
				
				// get documents and add them to the documents array
				// TRYING TO NOT create documents until they are needed
				// but then we have issues when we want to save or export
				createAndAddDocumentsData(data.documents);
				//savedDocumentsDataArray = data.documents; // should be potential documents?
				

				// go through projects and add documents to them
				if (potentialProjects.length>0) {
					numberOfPotentialProjects = potentialProjects.length;
					
					// loop through potentialProjectsLength objects
					for (var i:int;i<length;i++) {
						iProject = IProject(potentialProjects[i]);
						
						iProject.importDocumentInstances(documents);
					}
				}
				
				
				openPreviouslyOpenProjects();
				openPreviouslyOpenDocuments();
				showPreviouslyOpenProject();
				showPreviouslyOpenDocument();
				
			}
			else {
				// no saved data
				log.info("No saved data to restore");
			}
			
		}
		
		/**
		 * Show previously opened project
		 * */
		public function showPreviouslyOpenProject():void {
			var settings:Settings = SettingsManager.settings;
			var iProject:IProject;
			
			// Select last selected project
			if (settings.selectedProject) {
				iProject = getProjectByUID(settings.selectedProject.uid);
				
				if (iProject && iProject.isOpen) {
					log.info("Opening selected project " + iProject.name);
					setProject(iProject);
				}
			}
			else {
				if (selectedProject==null && projects && projects.length>0) {
					setProject(projects[0]);
				}
			}
		}
		
		/**
		 * Show previously opened document
		 * */
		public function showPreviouslyOpenDocument():void {
			var settings:Settings = SettingsManager.settings;
			var openDocuments:Array = settings.openDocuments;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			
			// Showing previously selected document
			if (settings.selectedDocument) {
				iDocument = getDocumentByUID(settings.selectedDocument.uid);
				
				if (iDocument && iDocument.isOpen) {
					log.info("Showing previously selected document " + iDocument.name);
					showDocument(iDocument);
					selectDocument(iDocument);
				}
			}
		}
		
		/**
		 * Open previously opened documents
		 * */
		public function openPreviouslyOpenDocuments(project:IProject = null):void {
			var settings:Settings = SettingsManager.settings;
			var openDocuments:Array = settings.openDocuments;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			
			// open previously opened documents
			for (var i:int;i<openDocuments.length;i++) {
				iDocumentMetaData = IDocumentMetaData(openDocuments[i]);
				
				iDocument = getDocumentByUID(iDocumentMetaData.uid);
				
				if (iDocument) {
					
					if (project && project.documents.indexOf(iDocument)!=-1) {
						log.info("Opening project document " + iDocument.name);
						openDocument(iDocument, DocumentData.INTERNAL_LOCATION, false, true);
					}
					else if (project==null) {
						log.info("Opening document " + iDocument.name);
						openDocument(iDocument, DocumentData.INTERNAL_LOCATION, false, true);
					}
				}
				
			}
		}
		
		/**
		 * Open previously opened projects
		 * */
		public function openPreviouslyOpenProjects(locations:String = null):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var settings:Settings = SettingsManager.settings;
			var openProjects:Array = settings.openProjects;
			var iProject:IProject;
			var iProjectData:IProjectData;
			var numberOfOpenItems:int = openProjects.length;
			
			// open previously opened projects
			for (var i:int;i<numberOfOpenItems;i++) {
				iProjectData = IProjectData(openProjects[i]);
				iProject = getProjectByUID(iProjectData.uid);
				
				if (iProject) {
					log.info("Opening project " + iProject.name);
					openProject(iProject, locations, true);
				}
			}
		}
		
		/**
		 * Save all projects and documents locally and remotely.
		 * Eventually, we will want to create a file options class that
		 * contains information on saving locally, to file, remotely, etc
		 * NOT FINISHED
		 * */
		public function save(locations:String = null, options:Object = null):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var localResult:Boolean;
			
			if (local) {
				local = saveProject(selectedProject, DocumentData.LOCAL_LOCATION);
			}
			
			if (remote) {
				if (remote && selectedProject is ISavable) {
					saveProjectInProgress = true
					
					if (selectedProject is Project) {
						Project(selectedProject).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
					}
					
					ISavable(selectedProject).save(DocumentData.REMOTE_LOCATION, options);
				}
			}
			
			if (local) {
				// saved local successful
				if (localResult) {
					
				}
				else {
					// unsuccessful
				}
			}
			
			
			if (remote) {
				if (remote) {
					
				}
				else {
					
				}
			}
			
		}

		
		/**
		 * Project saved handler
		 * */
		public function projectSaveResults(event:IServiceEvent):void {
			var project:IProject = IProject(Event(event).currentTarget);
			
			saveProjectInProgress = false;
			
			if (project is EventDispatcher) {
				EventDispatcher(project).removeEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults);
			}
			
			if (event is SaveResultsEvent && SaveResultsEvent(event).successful) {
				setLastSaveDate();
			}
			
			dispatchProjectSavedEvent(IProject(Event(event).currentTarget));
		}
		
		/**
		 * Formatter for dates
		 * */
		public var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
		
		/**
		 * Sets the last save date 
		 * */
		public function setLastSaveDate(date:Date = null):void {
			dateFormatter.dateStyle = DateTimeStyle.MEDIUM;
			var diff:int;
			if (!date) date = new Date();
			//if (lastSaveDate) {
			//	updateLastSavedDifference(date);
			//}
			lastSaveDateFormatted = dateFormatter.format(date);
			
			//updateLastSavedDifference(date);
			
			lastSaveDate = date;
		}
		
		public function updateLastSavedDifference(date:Date):void {
			var diff:int = (new Date().valueOf() - date.valueOf())/1000;
			
			if (diff>60) {
				lastSaveDateDifference = int(diff/60) + " min ago";
			}
			else {
				lastSaveDateDifference = "Less than a min ago";
			}
		}

		/**
		 * Save project
		 * */
		public function saveProject(project:IProject, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var locallySaved:Boolean;
			
			if (project==null) {
				error("No project to save");
				return false;
			}
			
			//if (isUserLoggedIn && isUserConnected) {
			
			if (!isUserLoggedIn) {
				error("You must be logged in to save a project.");
				return false;
			}
			
			
			if (project is EventDispatcher && remote) {
				EventDispatcher(project).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
				//EventDispatcher(project).addEventListener(Project.PROJECT_SAVED, projectSaveResults, false, 0, true);
			}
			
			if (!local) {
				saveProjectInProgress = true;
			}
			
			project.save(locations, options);
			
			if (local) {
				// TODO add support to save after response from server 
				// because ID's may have been added from new documents
				// UPDATE not saving locally bc it is not managed yet (no delete)
				//locallySaved = saveProjectLocally(project);
				//project.saveCompleteCallback = saveData;
			}
			
			return true;
		}
		
		/**
		 * Save project only. Save project saves the project and all documents
		 * while save project only saves only the project.
		 * */
		public function saveProjectOnly(project:IProject, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var locallySaved:Boolean;
			
			if (project==null) {
				error("No project to save");
				return false;
			}
			
			
			if (!isUserLoggedIn) {
				error("You must be logged in to save a project.");
				return false;
			}
			
			
			if (project is EventDispatcher && remote) {
				EventDispatcher(project).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
			}
			
			saveProjectInProgress = false;
			project.saveOnlyProject(locations, options);
			
			if (local) { 
				// TODO add support to save after response from server 
				// because ID's may have been added from new documents
				locallySaved = SettingsManager.saveProjectLocally(project);
				//project.saveCompleteCallback = saveData;
			}
			
			return true;
		}
		
		/**
		 * Save example projects usually called after login
		 * */
		public function saveExampleProject(projectData:IProject, locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var url:String = getWPURL();
			var exampleDocuments:Array;
	
			projectData.host = url;
			
			if (projectData.uid=="null" || projectData.uid=="" || projectData.uid==null) {
				projectData.uid = projectData.createUID();
				projectData.name += " Copy";
			}
			
			exampleDocuments = IProjectData(projectData).documents;
			numberOfDocuments = exampleDocuments ? exampleDocuments.length : 0;
			j=0;
			
			for (var j:int; j < numberOfDocuments; j++) {
				documentData = IDocumentData(exampleDocuments[j]);
				
				if (documentData) {
					documentData.host = url;
					
					if (documentData.uid=="null" || documentData.uid=="" || documentData.uid==null) {
						documentData.uid = documentData.createUID();
						documentData.name += " Copy";
					}
				}
			}
			
			projectData.save(locations);
			
			return true;
		}
		
		/**
		 * Save example projects usually called after login
		 * */
		public function saveExampleProjects(locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			var numberOfProjects:int = projects ? projects.length : 0;
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var projectData:IProjectData;
			var url:String = getWPURL();
			var documents:Array;
			
			for (var i:int; i < numberOfProjects; i++) {
				projectData = IProjectData(projects[i]);
				
				if (IProject(projectData).isExample) {
					projectData.host = url;
					
					if (projectData.uid=="null" || projectData.uid==null) {
						projectData.uid = projectData.createUID();
						projectData.name += " Copy";
					}
					
					documents = IProjectData(projectData).documents;
					numberOfDocuments = documents ? documents.length : 0;
					j=0;
					
					for (var j:int; j < numberOfDocuments; j++) {
						documentData = IDocumentData(documents[j]);
						
						if (documentData) {
							documentData.host = url;
							
							if (documentData.uid=="null" || documentData.uid==null || documentData.uid=="") {
								documentData.uid = documentData.createUID();
								documentData.name += " Copy";
							}
						}
					}
					
					projectData.save();
				}
			}
			
			return true;
		}

		/**
		 * Save target as image.
		 * */
		public function saveAsImage(target:Object, options:Object = null):Boolean {
			var bitmapData:BitmapData;
			var fileName:String;
			var componentDescription:ComponentDescription;
			var result:Object;
			
			if (target==null) {
				error("No document to save");
				return false;
			}
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
				target = componentDescription.instance;
			}
			else {
				componentDescription = selectedDocument.getItemDescription(target);
			}
			
			if (componentDescription) {
				fileName = componentDescription.name;
			}
			else {
				fileName = selectedDocument.name;
			}
			
			if (target) {
				if (target is IDocument || target is Application) {
					if (target is IDocument) {
						target = IDocument(target).instance;
					}
					
					//target = DisplayObjectUtils.getAnyTypeBitmapData(IDocument(target).instance);
					// we are using StageQuality to BEST since using anything higher shrinks the text (.75 / 1.25) if the font is
					// not embedded (currently found up to FP 25)
					
					// also, if we are taking a snapshot of the document we need to clip the edges
					// and not include anything outside of the visible rectangle
					// using getSnapshot which clips the UIComponent 
					result = RadiateUtilities.getSnapshot(target as UIComponent, 1, StageQuality.BEST);
					
					if (result is Error) {
						Radiate.warn("An error occurred. " + (result as SecurityError));
					}
					else {
						bitmapData = result as BitmapData;
					}
				}
				else {
					try {
						bitmapData = DisplayObjectUtils.getAnyTypeBitmapData(target, StageQuality.BEST);
					}
					catch (errorEvent:ErrorEvent) {
						error(errorEvent.text, errorEvent);
					}
				}
				
				var byteArray:ByteArray;
				
				if (bitmapData) {
					if (bitmapData.width!=0 && bitmapData.height) {
						byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(bitmapData);
						saveFileAs(byteArray, fileName, "png");
						return true;
					}
					else {
						error("Selection must have a width and height greater than 0");
					}
				}
			}
			
			return false;
		}

		/**
		 * Save document. Uses constants, DocumentData.LOCAL_LOCATION, DocumentData.REMOTE_LOCATION, etc
		 * Separate them by ",". 
		 * */
		public function saveDocument(iDocument:IDocument, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var saveLocallySuccessful:Boolean;
			
			//trace("- Radiate save document " + iDocument.name);
			
			if (iDocument==null) {
				error("No document to save");
				return false;
			}
			
			if (saveRemote && iDocument && iDocument is EventDispatcher) {
				EventDispatcher(iDocument).addEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
				saveDocumentInProgress = true;
			}
			
			iDocument.saveFunction = saveDocumentHook;
			
			saveLocallySuccessful = iDocument.save(locations, options);
			
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			//saveDocumentLocally(document);
			return saveLocallySuccessful;
		}
		
		/**
		 * This gets called on save. It allows you to modify what is saved. 
		 * */
		public function saveDocumentHook(iDocument:IDocument, data:Object):Object {
			var htmlOptions:HTMLExportOptions;
			var language:String = CodeManager.HTML;
			var output:String = "";
			var sourceData:SourceData;
			
			if (language == CodeManager.HTML) {
				htmlOptions = CodeManager.getExportOptions(language) as HTMLExportOptions;
				
				htmlOptions.template = iDocument.template;
				//htmlOptions.bordersCSS = bordersCSS;
				//htmlOptions.showBorders = showBorders;
				//htmlOptions.useBorderBox = useBoderBox;
				//htmlOptions.useInlineStyles = setStylesInline.selected;
				//htmlOptions.template = iDocument.template;
				//htmlOptions.disableTabs = true;
				//htmlOptions.useExternalStylesheet = false;
				
				//if (updateCodeLive.selected && isCodeModifiedByUser) {
					//htmlOptions.useCustomMarkup = true;
					//htmlOptions.markup = aceEditor.text;
					//htmlOptions.styles = aceCSSEditor.text;
				//}
				
				sourceData = CodeManager.getSourceData(iDocument.instance, iDocument, language, htmlOptions);
				
				data["custom[html]"] = sourceData.source;
				data["custom[styles]"] = sourceData.styles;
				data["custom[userStyles]"] = sourceData.userStyles;
				data["custom[template]"] = sourceData.template;
				data["custom[markup]"] = sourceData.markup;
				iDocument.errors = sourceData.errors;
				iDocument.warnings = sourceData.warnings;
				
			}
			
			return data;
		}
		
		/**
		 * Handles uncaught errors from an HTML preview document
		 * */
		protected function uncaughtScriptExceptionHandler(event:*):void {
			//var target:Object = event.currentTarget;
			var exceptionValue:Object = event.exceptionValue;
			
			error("Line " + exceptionValue.line + "  " + exceptionValue.name + ": " + exceptionValue.message);
		}
		
		/**
		 * Handles results from document save
		 * */
		protected function documentSaveResultsHandler(event:SaveResultsEvent):void {
			var document:IDocument = IDocument(event.currentTarget);
			saveDocumentInProgress = false;
			
			if (document is Document) {
				Document(document).removeEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler);
			}
			
			
			if (event.successful) {
				setLastSaveDate();
				dispatchDocumentSaveCompleteEvent(document);
			}
			else {
				dispatchDocumentSaveFaultEvent(document);
			}
		}
		
		/**
		 * Save all projects
		 * */
		public function saveAllProjects(locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfProjects:int = projects ? projects.length : 0;
			var project:IProject;
			var anyProjectSaved:Boolean;
			
			if (numberOfProjects==0) {
				warn("No projects to save");
				return false;
			}
			
			for (var i:int;i<numberOfProjects;i++) {
				project = projects[i];
				
				if (project.isChanged || saveEvenIfClean) {
					project.save(locations);
				}
				else {
					project.save(locations);
				}
				
				anyProjectSaved = true;
			}
			
			return anyProjectSaved;
		}
		
		/**
		 * Save all documents
		 * */
		public function saveAllDocuments(locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfDocuments:int = documents.length;
			var document:IDocument;
			var anyDocumentSaved:Boolean;
			
			if (numberOfDocuments==0) {
				warn("No douments to save");
				return false;
			}
			
			for (var i:int;i<numberOfDocuments;i++) {
				document = documents[i];
				
				if (document.isChanged || saveEvenIfClean) {
					document.save(locations);
					// TODO add support to save after response from server 
					// because ID's may have been added from new documents
					//saveData();
					//document.saveCompleteCallback = saveData;
					SettingsManager.saveDocumentLocally(document);
					anyDocumentSaved = true;
				}
			}
			
			return anyDocumentSaved;
		}
		
		/**
		 * Get assets available to upload
		 * */
		public function getAssetsAvailableToUpload():Array {
			var numberOfAssets:int;
			var attachmentData:AttachmentData;
			var assetsToUpload:Array = [];
			
			numberOfAssets = assets.length;
			
			for (var i:int=0;i<numberOfAssets;i++) {
				attachmentData = assets[i] as AttachmentData;
				
				if (attachmentData) {
					
					if (attachmentData.id==null) {
						
						if (assetsToUpload.indexOf(attachmentData)==-1) {
							assetsToUpload.push(attachmentData);
						}
					}
				}
			}
			
			return assetsToUpload;
		}
		
		/**
		 * Save all attachments. 
		 * */
		public function saveAllAttachments(iDocument:DocumentData, saveToProject:Boolean = false, locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var document:IDocument;
			var anyDocumentSaved:Boolean;
			var numberOfAttachments:int;
			var numberOfAttachmentsToUpload:int;
			var numberOfAssets:int;
			var attachmentData:AttachmentData;
			var imageData:ImageData;
			var targetPostID:String;
			var projectID:String;
			var attachmentParentID:String;
			var hasAttachments:Boolean;
			var customData:Object;
			var uploadingStillInProgress:Boolean;

			// Continues in uploadAttachmentResultsHandler
			
			if (uploadAttachmentInProgress) {
				callAfter(100, saveAllAttachments, iDocument, saveToProject, locations, saveEvenIfClean);
				return true;
			}
			
			if (saveToProject) {
				projectID = iDocument.parentId;
				targetPostID = projectID;
			}
			else {
				targetPostID = iDocument.id;
			}
			
			// save attachments
			numberOfAssets = assets.length;
			
			if (numberOfAssets==0) {
				info("No attachments to save");
				return false;
			}
			
			if (attachmentsToUpload==null) {
				attachmentsToUpload = [];
			}
			else if (attachmentsToUpload.length) {
				uploadingStillInProgress = true;
			}
			
			// get attachments that still need uploading
			
			if (!uploadingStillInProgress) {
				for (var i:int=0;i<numberOfAssets;i++) {
					attachmentData = assets[i] as AttachmentData;
					
					if (attachmentData) {
						attachmentParentID = attachmentData.parentId;
						
						if (attachmentParentID==null) {
							attachmentData.parentId = iDocument.id;
							attachmentParentID = iDocument.id;
						}
						
						// only add if matches document or project
						// you need to set the parent ID at 
						if (attachmentParentID!=targetPostID && attachmentParentID!=projectID) {
							continue;
						}
						
						if (attachmentData.id==null) {
							
							if (attachmentsToUpload.indexOf(attachmentData)==-1) {
								attachmentsToUpload.push(attachmentData);
							}
						}
					}
				}
			}
			
			numberOfAttachmentsToUpload = attachmentsToUpload.length;
			customData = {};
			
			for (var m:int = 0; m < numberOfAttachmentsToUpload; m++) {
				attachmentData = attachmentsToUpload[m];
				
				// trying to add a custom field with the uid - doesn't works
				if (attachmentData.uid) {
					customData["custom[uid]"] = attachmentData.uid;
					customData["caption"] = attachmentData.uid;
					customData["post_excerpt"] = attachmentData.uid;
					customData["post_title"] = attachmentData.name;
				}
				
				imageData = attachmentData as ImageData;
				
				if (imageData) {
					if (imageData.byteArray==null && imageData.bitmapData) {
						imageData.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(imageData.bitmapData);
						//imageData.name = ClassUtils.getIdentifierNameOrClass(initiator) + ".png";
						imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
						imageData.file = null;
					}
					
					if (!imageData.saveInProgress && imageData.id==null) {
						
						//imageData.save();
						hasAttachments = true;
						imageData.saveInProgress = true;
						currentAttachmentToUpload = imageData;
						
						//trace("Uploading attachment " + currentAttachmentToUpload.name + " to post " + targetPostID);
						
						uploadAttachment(imageData.byteArray, targetPostID, imageData.name, null, imageData.contentType, customData);
						break;
					}
				}
				else {
					
					hasAttachments = true;
					attachmentData.saveInProgress = true;
					currentAttachmentToUpload = attachmentData;
					
					//trace("Uploading attachment " + currentAttachmentToUpload.name + " to post " + targetPostID);
					
					uploadAttachment(attachmentData.byteArray, targetPostID, attachmentData.name, null, attachmentData.contentType, customData);
					break;
				}
			}
			
			
			//for (var i:int;i<numberOfAttachments;i++) {
				//document = documents[i];
				
				//document.upload(locations);
				// TODO add support to save after response from server 
				// because ID's may have been added from new documents
				//saveData();
				//document.saveCompleteCallback = saveData;
				//saveDocumentLocally(document);
			//	anyDocumentSaved = true;
			//}
			
			if (hasAttachments) {
				callAfter(100, saveAllAttachments, iDocument, saveToProject, locations, saveEvenIfClean);
			}
			
			return anyDocumentSaved;
		}

		/**
		 * Save document as
		 * */
		public function saveDocumentAs(document:IDocument, extension:String = "html"):void {
			/*
			document.save();
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			saveDocumentLocally(document);*/
			//return true;
		}

		/**
		 * Save multiple files
		 * */
		public function saveFiles(sourceData:SourceData, directory:Object, overwrite:Boolean = false):Boolean {
			var file:Object;
			var files:Array = sourceData.files;
			var fileName:String;
			var numberOfFiles:int = files ? files.length : 0;
			var fileClassDefinition:String = "flash.filesystem.File";
			var fileStreamDefinition:String = "flash.filesystem.FileStream";
			var FileClass:Object = ClassUtils.getDefinition(fileClassDefinition);
			var FileStreamClass:Object = ClassUtils.getDefinition(fileStreamDefinition);
			var fileStream:Object;
			var writeFile:Boolean;
			var filesCreated:Boolean;
			var fileInfo:FileInfo;
			
			for (var i:int;i<numberOfFiles;i++) {
				fileInfo = files[i];
				fileInfo.created = false;
				fileName = fileInfo.fileName + "." + fileInfo.fileExtension;
				
				if (!directory.exists) {
					directory.createDirectory();
				}
				
				file = directory.resolvePath(fileName);
				
				if (file.exists && !overwrite) {
					writeFile = false;
				}
				else {
					writeFile = true;
				}
				
				if (writeFile) {
					fileStream = new FileStreamClass();
					// this might be causing an error on windows - might need to change to read / write
					fileStream.open(file, "write");// FileMode.WRITE
					fileStream.writeUTFBytes(fileInfo.contents);
					fileStream.close();
					fileInfo.created = true;
					fileInfo.filePath = file.nativePath;
					fileInfo.url = file.url;
					filesCreated = true;
				}
			}
			
			return filesCreated;
		}

		/**
		 * Save file as
		 * */
		public function saveFileAs(data:Object, name:String = "", extension:String = null):FileReference {
			var fileReference:FileReference;
			var fileName:String;
			
			fileName = name==null ? "" : name;
			
			if (fileName.indexOf(".")==-1 && data) {
				if (extension) {
					fileName = fileName + "." + extension;
				}
				else if ("fileExtension" in data && data.fileExtension) {
					fileName = fileName + "." + data.fileExtension;
				}
				else if ("extension" in data && data.extension) {
					fileName = fileName + "." + data.extension;
				}
			}
			
			// FOR SAVING A FILE (save as) WE MAY NOT NEED ALL THE LISTENERS WE ARE ADDING
			// add listeners
			fileReference = new FileReference();
			addFileSaveAsListeners(fileReference);
			
			if (data && !(data is String) && data is Object && "contents" in data) {
				fileReference.save(data.contents, fileName);
			}
			else {
				fileReference.save(data, fileName);
			}
			
			return fileReference;
		}
		
		/**
		 * Adds file save as listeners. Rename or refactor
		 * */
		public function addFileSaveAsListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CANCEL, cancelFileSaveAsHandler, false, 0, true);
			dispatcher.addEventListener(Event.COMPLETE, completeFileSaveAsHandler, false, 0, true);
		}
		
		/**
		 * Removes file save as listeners. Rename or refactor
		 * */
		public function removeFileListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(Event.CANCEL, cancelFileSaveAsHandler);
			dispatcher.removeEventListener(Event.COMPLETE, completeFileSaveAsHandler);
		}
		
		/**
		 * File save as complete
		 * */
		public function completeFileSaveAsHandler(event:Event):void {
			removeFileListeners(event.currentTarget as IEventDispatcher);
			
			dispatchDocumentSaveCompleteEvent(selectedDocument);
		}
		
		/**
		 * Cancel file save as
		 * */
		public function cancelFileSaveAsHandler(event:Event):void {
			removeFileListeners(event.currentTarget as IEventDispatcher);
			
			dispatchDocumentSaveAsCancelEvent(selectedDocument);
		}
		
		/**
		 * Get document locally
		 * */
		public function getDocumentLocally(iDocumentData:IDocumentData):IDocumentData {
			var result:Object = SharedObjectUtils.getSharedObject(SettingsManager.SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				//var data:Object = savedData;
				var documentsArray:Array = so.data.savedData.documents;
				var numberOfDocuments:int = documentsArray.length;
				var documentData:IDocumentData;
				var found:Boolean;
				var foundIndex:int = -1;
				
				for (var i:int;i<numberOfDocuments;i++) {
					documentData = IDocumentData(documentsArray[i]);
					
					if (documentData.uid == iDocumentData.uid) {
						found = true;
						foundIndex = i;
						
						break;
					}
				}
				
				return documentData;
			}
			else {
				error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return null;
		}
		
		
		/**
		 * Get images from the server
		 * */
		public function getAttachments(id:int = 0):void {
			// get selected document
			
			// we need to create service
			if (getAttachmentsService==null) {
				getAttachmentsService = new WPService();
				getAttachmentsService.addEventListener(WPService.RESULT, getAttachmentsResultsHandler, false, 0, true);
				getAttachmentsService.addEventListener(WPService.FAULT, getAttachmentsFaultHandler, false, 0, true);
			}
			
			getAttachmentsService.host = getWPURL();
			
			if (id!=0) {
				getAttachmentsService.id = String(id);
			}
			
			getAttachmentsInProgress = true;
			
			
			getAttachmentsService.getAttachments(id);
		}
		
		/**
		 * Upload attachment data to the server
		 * */
		public function uploadAttachmentData(attachmentData:AttachmentData, id:String):void {
			if (attachmentData==null) {
				warn("No attachment to upload");
				return;
			}
			
			var imageData:ImageData = attachmentData as ImageData;
			var formattedName:String = attachmentData.name!=null ? attachmentData.name : null;
			
			if (formattedName) {
				
				if (formattedName.indexOf(" ")!=-1) {
					formattedName = formattedName.replace(/ /g, "");
				}
			}
			
			if (imageData && imageData.bitmapData && imageData.byteArray==null) {
				attachmentData.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(BitmapData(imageData.bitmapData));
				
				if (formattedName && formattedName.indexOf(".")==-1) {
					formattedName = formattedName + ".png";
				}
				
				imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
			}
			
			
			uploadAttachment(attachmentData.byteArray, id, formattedName, null, attachmentData.contentType, null, attachmentData);
		}
		
		/**
		 * Upload image to the server.
		 * File name cannot have spaces and must have an extension.
		 * If you pass bitmap data it is converted to a PNG
		 * */
		public function uploadAttachment(data:Object, id:String, fileName:String = null, 
										 dataField:String = null, contentType:String = null, 
										 customData:Object = null, attachmentData:AttachmentData = null):void {
			// get selected document
			
			// we need to create service
			if (uploadAttachmentService==null) {
				uploadAttachmentService = new WPAttachmentService();
				uploadAttachmentService.addEventListener(WPService.RESULT, uploadAttachmentResultsHandler, false, 0, true);
				uploadAttachmentService.addEventListener(WPService.FAULT, uploadAttachmentFaultHandler, false, 0, true);
				//uploadAttachmentService = service;
			}
			
			uploadAttachmentService.host = getWPURL();
		
			if (id!=null) {
				uploadAttachmentService.id = id;
			}
			
			if (attachmentData) {
				currentAttachmentToUpload = attachmentData;
				currentAttachmentToUpload.saveInProgress = true;
			}
			
			uploadAttachmentService.customData = customData;
			
			uploadAttachmentInProgress = true;
			
			var formattedName:String = fileName!=null ? fileName : null;
			
			if (formattedName) {
				
				if (formattedName.indexOf(" ")!=-1) {
					formattedName = formattedName.replace(/ /g, "");
				}
				
				if (formattedName.indexOf(".")==-1) {
					
					if (contentType==DisplayObjectUtils.PNG_MIME_TYPE) {
						formattedName = formattedName + ".png";
					}
				}
			}
			
			
			if (data is FileReference) {
				uploadAttachmentService.file = data as FileReference;
				uploadAttachmentService.uploadAttachment();
			}
			else if (data) {
				
				if (data is ByteArray) {
					uploadAttachmentService.fileData = data as ByteArray;
				}
				else if (data is BitmapData) {
					uploadAttachmentService.fileData = DisplayObjectUtils.getByteArrayFromBitmapData(BitmapData(data));
					
					if (formattedName && formattedName.indexOf(".")==-1) {
						formattedName = formattedName + ".png";
					}
					
					contentType = DisplayObjectUtils.PNG_MIME_TYPE;
				}
				
				if (formattedName) {
					uploadAttachmentService.fileName = formattedName;
				}
				
				if (dataField) {
					uploadAttachmentService.dataField = dataField;
				}
				
				// default content type in service is application/octet
				if (contentType) {
					uploadAttachmentService.contentType = contentType;
				}
				
				uploadAttachmentService.uploadAttachment();
			}
			else {
				attachmentData.saveInProgress = false;
				uploadAttachmentInProgress = false;
				warn("No data or file is available for upload. Please select the file to upload.");
			}
			
		}
		
		/**
		 * Updates the user information from data object from the server
		 * */
		public function updateUserInfo(data:Object):void {
			
			if (data && data is Object && "loggedIn" in data) {
				isUserLoggedIn = data.loggedIn;
				userAvatar = data.avatar;
				userDisplayName = data.displayName ? data.displayName : "guest";
				username = data.username;
				userID = data.id;
				userEmail = data.contact;
				user = data;
				
				if (!isNaN(data.homePage)) {
					projectHomePageID = data.homePage;
				}
				else {
					projectHomePageID = -1;
				}
				
				userSites = [];
				
				if ("blogs" in user) {
					//userSites = user.blogs;
					for each (var blog:Object in user.blogs) {
						userSites.push(blog);
					}
					
					if (userSites.length>0) {
						userSitePath = userSites[0].path;
						WP_USER_PATH = userSitePath;
						WP_USER_PATH = WP_USER_PATH.replace(WP_PATH, "");
					}
					else {
						userSitePath = "";
						WP_USER_PATH = "";
					}
				}
				
				if (isUserLoggedIn==false) {
					userSitePath = "";
					WP_USER_PATH = "";
				}
			}
			else {
				isUserLoggedIn = false;
				userAvatar = "";
				userDisplayName = "guest";
				userID = 0;
				userEmail = "";
				user = null;
				projectHomePageID = -1;
				userSites = [];
				userSitePath = "";
				WP_USER_PATH = "";
			}
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Open list of projects. Need to eventually convert from wordpress post data object to type classes.
		 * See getAttachmentsResultsHandler() 
		 * */
		public function openProjectsFromData(projectsData:Array):void {
			var numberOfProjects:int;
			var post:Object;
			var project:IProject
			var xml:XML;
			var isValid:Boolean;
			var firstProject:IProject;
			var potentialProjects:Array;
			
			numberOfProjects = projectsData.count;
			
			for (var i:int;i<numberOfProjects;i++) {
				post = potentialProjects.posts[i];
				isValid = XMLUtils.isValidXML(post.content);
				
				if (isValid) {
					xml = new XML(post.content);
					project = createProjectFromXML(xml);
					addProject(project);
					potentialProjects.push(project);
				}
				else {
					log.info("Could not import project:" + post.title);
				}
			}
			
			
			//potentialProjects = addSavedProjects(data.projects);
			
			if (potentialProjects.length>0) {
				openProject(potentialProjects[0]);
				setProject(potentialProjects[0]);
			}
		}
		
		/**
		 * Result from save fault
		 * */
		public function getProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			Radiate.info("Could not get list of projects");
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Result get attachments
		 * */
		public function getAttachmentsResultsHandler(event:IServiceEvent):void {
			Radiate.info("Retrieved list of attachments");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var numberOfAttachments:int;
			var object:Object;
			var attachment:AttachmentData;
			
			if (data && data.count>0) {
				numberOfAttachments = data.count;
				
				for (var i:int;i<numberOfAttachments;i++) {
					object = data.attachments[i];
					
					if (String(object.mime_type).indexOf("image/")!=-1) {
						attachment = new ImageData();
						attachment.unmarshall(object);
					}
					else {
						attachment = new AttachmentData();
						attachment.unmarshall(object);
					}
					
					potentialAttachments.push(attachment);
				}
			}
			
			getAttachmentsInProgress = false;
			
			attachments = potentialAttachments;
			
			dispatchAttachmentsResultsEvent(true, attachments);
		}
		
		/**
		 * Result from attachments fault
		 * */
		public function getAttachmentsFaultHandler(event:IServiceEvent):void {
			
			Radiate.info("Could not get list of attachments");
			
			getAttachmentsInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchAttachmentsResultsEvent(false, []);
		}
		
		/**
		 * Result upload attachment
		 * */
		public function uploadAttachmentResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Upload attachment");
			var data:Object = event.data;
			//var potentialAttachments:Array = [];
			var successful:Boolean = data && data.status && data.status=="ok" ? true : false;
			var numberOfRemoteAttachments:int;
			//var remoteAttachment:Object;
			//var remoteAttachmentData:AttachmentData;
			//var attachmentData:AttachmentData;
			var remoteAttachments:Array = data && data.post && data.post.attachments ? data.post.attachments : []; 
			var containsName:Boolean;
			var numberOfAttachmentsToUpload:int;
			var numberOfDocuments:int;
			var foundAttachment:Boolean;
			var lastAddedRemoteAttachment:Object;
			//var currentAttachment:AttachmentData;
			
			// current attachment being uploaded
			//currentAttachmentToUpload
			
			// last attachment successfully uploaded
			lastAddedRemoteAttachment = remoteAttachments && remoteAttachments.length ? remoteAttachments[remoteAttachments.length-1]: null;

			var localIDExists:Boolean = com.flexcapacitor.utils.ArrayUtils.hasItem(assets, lastAddedRemoteAttachment.id, "id");
			
			if (currentAttachmentToUpload) {
				currentAttachmentToUpload.saveInProgress = false;
			}
			
			if (lastAddedRemoteAttachment && currentAttachmentToUpload) {
				//trace("Last uploaded attachment is " + lastAddedRemoteAttachment.title + " with id of " + lastAddedRemoteAttachment.id);
				containsName = lastAddedRemoteAttachment.slug.indexOf(currentAttachmentToUpload.slugSafeName)!=-1;
			}
			
			if (!localIDExists) {
				/*
				if (String(remoteAttachment.mime_type).indexOf("image/")!=-1) {
					remoteAttachmentData = new ImageData();
					remoteAttachmentData.unmarshall(lastRemoteAttachment);
				}
				else {
					remoteAttachmentData = new AttachmentData();
					remoteAttachmentData.unmarshall(lastRemoteAttachment);
				}*/
				foundAttachment = true;
				
				if (currentAttachmentToUpload) {
					currentAttachmentToUpload.unmarshall(lastAddedRemoteAttachment);
					currentAttachmentToUpload.uploadFailed = false;
				}
				
				// loop through documents and replace bitmap data with url to source
				numberOfDocuments = documents.length;
				k = 0;
				
				for (var k:int;k<numberOfDocuments;k++) {
					var iDocument:IDocument = documents[k] as IDocument;
					
					if (iDocument) {
						DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, replaceBitmapData, [currentAttachmentToUpload]);
					}
				}
			}
			else {
				warn("Attachment " + currentAttachmentToUpload.name + " could not be uploaded");
				currentAttachmentToUpload ? currentAttachmentToUpload.uploadFailed = true : -1;
				successful = false;
				foundAttachment = false;
			}
			
			lastAttemptedUpload = attachmentsToUpload && attachmentsToUpload.length ? attachmentsToUpload.unshift() : null;
			
			uploadAttachmentInProgress = false;
			
			if (!foundAttachment) {
				successful = false;
				dispatchUploadAttachmentResultsEvent(successful, [], data.post);
			}
			else {
				dispatchUploadAttachmentResultsEvent(successful, [currentAttachmentToUpload], data.post);
			}
			
			if (attachmentsToUpload && attachmentsToUpload.length) {
				// we should do this sequencially
			}
			
			currentAttachmentToUpload = null;
		}
		
		/**
		 * Result from upload attachment fault
		 * */
		public function uploadAttachmentFaultHandler(event:IServiceEvent):void {
			Radiate.info("Upload attachment fault");
			
			lastAttemptedUpload = attachmentsToUpload && attachmentsToUpload.length ? attachmentsToUpload.unshift() : null;
			
			uploadAttachmentInProgress = false;
			
			if (currentAttachmentToUpload) {
				currentAttachmentToUpload.saveInProgress = false;
			}
			
			if (attachmentsToUpload.length) {
				// we should do this sequencially
			}
			
			//dispatchEvent(saveResultsEvent);
			dispatchUploadAttachmentResultsEvent(false, [], event.data, event.faultEvent);
			
			currentAttachmentToUpload = null;
		}
		
		/**
		 * Replaces occurances where the bitmapData in Image and BitmapImage have
		 * been uploaded to the server and we now want to point the image to a URL
		 * rather than bitmap data
		 * */
		public function replaceBitmapData(component:ComponentDescription, imageData:ImageData):void {
			var instance:Object;
			
			if (imageData && component && component.instance) {
				instance = component.instance;
				
				if (instance is Image || instance is BitmapImage) {
					if (instance.source is BitmapData && 
						instance.source == imageData.bitmapData && 
						imageData.bitmapData!=null) {
						Radiate.setProperty(instance, "source", imageData.url);
					}
				}
			}
		}
		
		/**
		 * Delete project results handler
		 * */
		public function deleteProjectResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Delete project results");
			var data:Object = event.data;
			var status:Boolean;
			var successful:Boolean;
			var error:String;
			var message:String;
			
			if (data && data is Object) {
				//status = data.status==true;
			}
			
			deleteProjectInProgress = false;
			
			if (data && data is Object && "status" in data) {
				
				successful = data.status!="error";
			}
			
			//Include 'id' or 'slug' var in your request.
			if (event.faultEvent is IOErrorEvent) {
				message = "Are you connected to the internet? ";
				
				if (event.faultEvent is IOErrorEvent) {
					message = IOErrorEvent(event.faultEvent).text;
				}
				else if (event.faultEvent is SecurityErrorEvent) {
					
					if (SecurityErrorEvent(event.faultEvent).errorID==2048) {
						
					}
					
					message += SecurityErrorEvent(event.faultEvent).text;
				}
			}
			
			
			//dispatchProjectRemovedEvent(null);
			
			dispatchProjectDeletedEvent(successful, data);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteProjectFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the project. ");
			
			deleteProjectInProgress = false;
			
			dispatchProjectDeletedEvent(false, data);
		}
		
		/**
		 * Delete document results handler. You should save the project after
		 * document is deleted.
		 * */
		public function deleteDocumentResultsHandler(event:IServiceEvent):void {
			//..Radiate.info("Delete document results");
			var data:Object = event.data;
			//var status:Boolean;
			var successful:Boolean;
			var error:String;
			var message:String;
			
			
			if (data && data is Object && "status" in data) {
				successful = data.status!="error";
			}
			
			deleteDocumentInProgress = false;
			deleteAttachmentInProgress = false;
			
			//Include 'id' or 'slug' var in your request.
			if (event.faultEvent is IOErrorEvent) {
				message = "Are you connected to the internet? ";
				
				if (event.faultEvent is IOErrorEvent) {
					message = IOErrorEvent(event.faultEvent).text;
				}
				else if (event.faultEvent is SecurityErrorEvent) {
					
					if (SecurityErrorEvent(event.faultEvent).errorID==2048) {
						
					}
					
					message += SecurityErrorEvent(event.faultEvent).text;
				}
			}
			
			//status = message;
			
			//dispatchDocumentRemovedEvent(null);
			
			dispatchDocumentDeletedEvent(successful, data);
			
			if (successful) {
				
				if (deleteDocumentProjectId!=-1 && saveProjectAfterDelete) {
					var iProject:IProject = getProjectByID(deleteDocumentProjectId);
					
					if (iProject) {
						iProject.saveOnlyProject();
					}
				}
				
			}
			
			saveProjectAfterDelete = false;
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteDocumentFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. ");
			
			deleteDocumentInProgress = false;
			
			dispatchDocumentDeletedEvent(false, data);
		}
		
		/**
		 * Delete attachments. You should save the project after
		 * document is deleted.
		 * */
		public function deleteAttachmentsResultsHandler(event:IServiceEvent):void {
			//..Radiate.info("Delete document results");
			var data:Object = event.data;
			var deletedItems:Object = data ? data.deletedItems : [];
			var successful:Boolean;
			var error:String;
			var message:String;
			
			
			if (data && data is Object && "successful" in data) {
				successful = data.successful != "false";
			}
			
			deleteAttachmentsInProgress = false;
			
			//Include 'id' or 'slug' var in your request.
			if (event.faultEvent is IOErrorEvent) {
				message = "Are you connected to the internet? ";
				
				if (event.faultEvent is IOErrorEvent) {
					message = IOErrorEvent(event.faultEvent).text;
				}
				else if (event.faultEvent is SecurityErrorEvent) {
					
					if (SecurityErrorEvent(event.faultEvent).errorID==2048) {
						
					}
					
					message += SecurityErrorEvent(event.faultEvent).text;
				}
			}
			
			//status = message;
			
			//dispatchDocumentRemovedEvent(null);
			
			dispatchAttachmentsDeletedEvent(successful, data);
			
			if (successful) {
				
				if (deleteDocumentProjectId!=-1 && saveProjectAfterDelete) {
					var iProject:IProject = getProjectByID(deleteDocumentProjectId);
					
					if (iProject) {
						iProject.saveOnlyProject();
					}
				}
				
			}
			
			saveProjectAfterDelete = false;
		}
		
		/**
		 * Result from delete attachments fault
		 * */
		public function deleteAttachmentsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. ");
			
			deleteAttachmentsInProgress = false;
			
			dispatchAttachmentsDeletedEvent(false, data);
		}

		
		/**
		 * Check if the project has changed and mark changed if it is. 
		 * */
		public function checkIfProjectHasChanged(iProject:IProject):Boolean {
			
			var isChanged:Boolean = iProject.checkProjectHasChanged();
			
			return isChanged;
		}
		
		/**
		 * Updates the saved data with the changes from the document passed in
		 * */
		public function updateSaveDataForDocument(iDocumentData:IDocumentData, metaData:Boolean = false):SavedData {
			var savedData:SavedData = SettingsManager.savedData;
			var documentsArray:Array = savedData.documents;
			var numberOfDocuments:int = documentsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<numberOfDocuments;i++) {
				documentMetaData = IDocumentMetaData(documentsArray[i]);
				//Radiate.info("Exporting document " + iDocument.name);
				
				if (documentMetaData.uid == iDocumentData.uid) {
					found = true;
					foundIndex = i;
				}
			}
			
			if (found) {
				
				if (metaData) {
					documentsArray[foundIndex] = iDocumentData.toMetaData();
				}
				else {
					documentsArray[foundIndex] = iDocumentData.marshall();
				}
			}
			else {
				if (metaData) {
					documentsArray.push(iDocumentData.toMetaData());
				}
				else {
					documentsArray.push(iDocumentData.marshall());
				}
			}
			
			
			return savedData;
		}
		
		/**
		 * Updates the saved data with the changes from the project passed in
		 * */
		public function updateSaveDataForProject(iProject:IProject, metaData:Boolean = false):SavedData {
			var savedData:SavedData = SettingsManager.savedData;
			var projectsArray:Array = savedData.projects;
			var numberOfProjects:int = projectsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<numberOfProjects;i++) {
				documentMetaData = IDocumentData(projectsArray[i]);
				//Radiate.info("Exporting document " + iDocument.name);
				
				if (documentMetaData.uid == iProject.uid) {
					found = true;
					foundIndex = i;
				}
			}
			
			if (found) {
				
				if (metaData) {
					projectsArray[foundIndex] = iProject.toMetaData();
				}
				else {
					projectsArray[foundIndex] = iProject.marshall();
				}
			}
			else {
				if (metaData) {
					projectsArray.push(iProject.toMetaData());
				}
				else {
					projectsArray.push(iProject.marshall());
				}
			}
			
			
			return savedData;
		}
		
		/**
		 * Get a list of documents. If open is set to true then gets only open documents.
		 * */
		public function getOpenDocumentsSaveData(metaData:Boolean = false):Array {
			var documentsArray:Array = SettingsManager.getSaveDataForAllDocuments(true, metaData);
			return documentsArray;
		}
		
		/**
		 * Get a list of documents data for storage by project. If open is set to true then only returns open documents.
		 * */
		public function getDocumentsSaveDataByProject(project:IProject, open:Boolean = false):Array {
			var documentsArray:Array = project.getSavableDocumentsData(open);
			
			return documentsArray;
		}
		
		
		/**
		 * Get a list of projects that are open. 
		 * If meta data is true only returns meta data. 
		 * */
		public function getOpenProjectsSaveData(metaData:Boolean = false):Array {
			var projectsArray:Array = SettingsManager.getSaveDataForAllProjects(true, metaData);
			
			return projectsArray;
		}
		
		/**
		 * Get an array of projects serialized for storage. 
		 * If open is set to true then only returns open projects.
		 * If meta data is true then only returns meta data. 
		 * */
		public function saveProjectsRemotely(open:Boolean = false):Array {
			var projectsArray:Array = [];
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int; i < numberOfProjects; i++) {
				iProject = IProject(projects[i]);
				
				if (open) {
					if (iProject.isOpen) {
						iProject.save();
					}
				}
				else {
					iProject.save();
				}
			}
			
			
			return projectsArray;
		}
		
		/**
		 * Returns true if two objects are of the same class type
		 * */
		public function isSameClassType(target:Object, target1:Object):Boolean {
			return ClassUtils.isSameClassType(target, target1);
		}
		
		
		private static var lastErrorObject:Object;
		
		/**
		 * Catch uncaught errors
		 */
		public function uncaughtErrorHandler(event:UncaughtErrorEvent):void {
			event.preventDefault();
			
			//to capture the error message
			var errorMessage:String = new String();
			var errorObject:Object;
			var stack:String = getStackTrace(event.error);
			
			if (event) {
				errorObject = "error" in event ? event.error : null;
				
				if (errorObject is Error && "message" in errorObject) {
					errorMessage = Error(errorObject).message;
				}
				else if (errorObject is ErrorEvent && "text" in errorObject) {
					errorMessage = ErrorEvent(errorObject).text;
				}
				else if (errorObject) {
					errorMessage = errorObject.toString();
				}
				else {
					errorMessage = event.toString();
				}
				
			}
			
			if (event!=lastErrorObject) {
				lastErrorObject = event;
				Radiate.error(errorMessage, event);
			}
		}
		
		/**
		 * Removes ID and location data from example projects so that the user can 
		 * save and modify them themselves
		 * */
		public function clearExampleProjectData(exampleProject:IProject):Boolean {
			if (!exampleProject) return false;
			var exampleDocuments:Array;
			var numberOfDocuments:int;
			var exampleDocument:IDocument;
			
			removeUniqueDocumentData(exampleProject);
			exampleDocuments = exampleProject.documents;
			numberOfDocuments = exampleDocuments ? exampleDocuments.length :0;
			
			for (var i:int;i<numberOfDocuments;i++) {
				exampleDocument = exampleDocuments[i] as IDocument;
				
				if (exampleDocument) {
					removeUniqueDocumentData(exampleDocument);
					exampleDocument.uid = UIDUtil.createUID();
					exampleDocument.isExample = true;
				}
			}
			
			exampleProject.isExample = true;
			
			return true;
		}
		
		/**
		 * Update imported code so you can import it
		 * */
		public static function editImportingCode(message:String, ...Arguments):void {
			log.info("The document did not contain valid source code. Open the import window and edit the code or choose an earlier revision.");
		}
		
		/**
		 * Open document for editing in browser. 
		 * */
		public static function editDocumentInBrowser(documentData:IDocumentData):void {
			var request:URLRequest;
			var url:String;
			request = new URLRequest();
			
			if (documentData && documentData.id==null) {				
				error("The document ID is not set. You may need to save the document first.");
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = getWPEditPostURL(documentData);
			}
			
			if (url) {
				request.url = url;
				navigateToURL(request, "editInBrowser");
			}
			else {
				error("URL to the document was not set. You may need to save the document first.");
			}
		}
		
		/**
		 * Open document in browser. Right now you must be 
		 * logged in or the document must be published
		 * */
		public static function openInBrowser(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = url;
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to save the document first.");
			}
		}
		
		/**
		 * Open document in browser screenshot site. 
		 * The document must be published so the external site can view it
		 * */
		public static function openInBrowserScreenshot(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = SCREENSHOT_PATH + url;
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to publish and save the document first.");
			}
		}
		
		/**
		 * Open document in browser site scanner site. 
		 * The document must be published so the external site can view it
		 * */
		public static function openInBrowserSiteScanner(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = SITE_SCANNER_PATH + encodeURI(url);
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to publish and save the document first.");
			}
		}
		
		/**
		 * Open document in browser. Right now you must be 
		 * logged in or the document must be published
		 * */
		public static function loginThroughBrowser():void {
			var value:Object = PersistentStorage.read(Radiate.USER_STORE);
			
			if (value!=null) {
				serviceManager.loginThroughBrowser(value.u, value.p, true);
			}
			else {
				info("No login was saved.");
				setTimeout(openUsersLoginPage, 1000);
			}
		}
		
		/**
		 * Traces an fatal message
		 * */
		public static function fatal(message:String, event:* = null, sender:Object = null, ...Arguments):void {
			var issueData:IssueData;
			var errorObject:Object;
			var type:String;
			var errorID:String;
			var errorData:ErrorData;
			var name:String;
			var className:String;
			var stackTrace:String;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			
			if (event && "error" in event) {
				errorObject = event.error;
				message = "message" in errorObject ? errorObject.message : "";
				message = "text" in errorObject ? errorObject.text : message;
				type = "type" in errorObject ? errorObject.type : "";
				errorID = "errorID" in errorObject ? errorObject.errorID : "";
				name = "name" in errorObject ? errorObject.name : "";
			}
			
			stackTrace = getStackTrace(event);
			
			if (enableDiagnosticLogs) {
				errorData = addLogData(message, LogEventLevel.ERROR, className, Arguments) as ErrorData;
				
				if (errorData) {
					if (message=="" || message==null) {
						errorData.description = message;
					}
					errorData.type = type;
					errorData.errorID = errorID;
					errorData.message = message;
					errorData.name = name;
				}
			}
			
			log.error(message, Arguments);
			
			
			playMessage(message, LogEventLevel.FATAL);
		}
		
		/**
		 * Traces the MXML import errors
		 * */
		public static function outputMXMLErrors(title:String, errors:Array):void {
			var errorData:ErrorData;
			var message:String;
			
			title = title!=null && title!="" ? title : "MXML Import Errors";
			
			message = title;
			message += "\n";
			
			for (var i:int = 0; i < errors.length; i++) {
				errorData = errors[i] as ErrorData;
				
				if (errorData) {
					message += " " + errorData.label + "\n " + errorData.description + "\n\n";
				}
				
			}
			
			log.error(message);
			
			playMessage(title + " - Check console for more details", LogEventLevel.WARN);
		}
		
		/**
		 * Traces an error message.
		 * 
		 * Getting three error messages. 
		 * One from Radii8Desktop, one from here Radiate.as, and one from DocumentContainer
		 * */
		public static function error(message:String, event:Object = null, sender:String = null, ...Arguments):void {
			var errorData:ErrorData;
			var issueData:IssueData;
			var errorObject:Object;
			var errorID:String;
			var type:String;
			var name:String;
			var className:String;
			var stackTrace:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			if (message=="") {
				
			}
			
			if (event && "error" in event) {
				errorObject = event.error;
			}
			else if (event is Error) {
				errorObject = event;
			}
			
			lastErrorObject = event;
			
			if (errorObject) {
				message = "message" in errorObject ? errorObject.message : "";
				message = "text" in errorObject ? errorObject.text : message;
				type = "type" in errorObject ? errorObject.type : "";
				errorID = "errorID" in errorObject ? errorObject.errorID : "";
				name = "name" in errorObject ? errorObject.name : "";
			}
			
			stackTrace = getStackTrace(event);
			
			if (enableDiagnosticLogs) {
				issueData = addLogData(message, LogEventLevel.ERROR, className, Arguments);
				//errorData = addLogData(message, LogEventLevel.ERROR, className, Arguments);
				
				if (issueData is ErrorData) {
					errorData = ErrorData(issueData);
					
					if (message=="" || message==null) {
						ErrorData(errorData).description = message;
					}
					errorData.type = type;
					errorData.errorID = errorID;
					errorData.message = message;
					errorData.name = name;
					errorData.stackTrace = stackTrace;
				}
			}
			
			log.error(message, Arguments);
			
			playMessage(message, LogEventLevel.ERROR);
		}
		
		/**
		 * Traces an warning message
		 * */
		public static function warn(message:String, sender:Object = null, ...Arguments):void {
			var className:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			if (className=="") {
				//var object:Object = warn.arguments.caller;
			}
			
			log.warn(message, Arguments);
			
			if (enableDiagnosticLogs) {
				addLogData(message, LogEventLevel.WARN, className, Arguments);
			}
			
			playMessage(message, LogEventLevel.WARN);
		}
		
		/**
		 * Traces an info message
		 * */
		public static function info(message:String, sender:Object = null, ...Arguments):void {
			var className:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			log.info(message, Arguments);
			
			if (enableDiagnosticLogs) {
				addLogData(message, LogEventLevel.INFO, className, Arguments);
			}
			
			playMessage(message, LogEventLevel.INFO);
		}
		
		/**
		 * Traces an debug message
		 * */
		public static function debug(message:String, sender:Object = null, ...Arguments):void {
			var className:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";

			log.debug(message, Arguments);
			
			if (enableDiagnosticLogs) {
				addLogData(message, LogEventLevel.DEBUG, className, Arguments);
			}
			
			playMessage(message, LogEventLevel.DEBUG);
		}
		
		/**
		 * Adds a new log item for diagnostics and to let user go back and read messages
		 * */
		public static function addLogData(message:String, level:int = 4, className:String = null, arguments:Array = null):IssueData {
			var issue:IssueData;
			
			if (level == LogEventLevel.ERROR || level == LogEventLevel.FATAL) {
				issue = new ErrorData();
			}
			else if (level == LogEventLevel.WARN) {
				issue = new WarningData();
			}
			else if (level == LogEventLevel.DEBUG || level==LogEventLevel.INFO || level==LogEventLevel.ALL) {
				issue = new IssueData();
			}
			else {
				issue = new IssueData();
			}
			
			issue.description = message;
			issue.level = level;
			issue.className = className;
			logsCollection.addItem(issue);
			
			
			return issue;
		}
		
		/**
		 * Get the stack trace from an error. Stack traces are available from 11.5 on
		 * or possibly earlier if you set -compiler.verbose-stacktraces=true
		 * */
		protected static function getStackTrace(error:Object, removeLines:Boolean = true):String {
			var value:String;
			var stackTrace:Array;
			
			if (error==null) {
				error = new Error();
			}
			else if ("error" in error) {
				error = error.error;
			}
			
			if ("getStackTrace" in error) {
				value = error.getStackTrace();
				value = value.replace(/\t/, "");
				if (removeLines) {
					value = value.replace(/\[.*(:\d+)\]/, "$1");
					value = value.replace(/\[.*\]/g, "");
					value = value.replace(/.*?::/g, "");
				}
				stackTrace = value.split("\n");
				//stackTrace.shift();
				//stackTrace.shift();
				//stackTrace.shift();
				return stackTrace.join("\n");
			}
			
			return null;
		}
		
		/**
		 * Keep track of error messages
		 * */
		public static var logsCollection:ArrayCollection = new ArrayCollection();
		public static var logErrorBackgroundColor:uint;
		public static var logErrorColor:uint;
		public static var enableDiagnosticLogs:Boolean = true;
		
		/**
		 * Plays an animation for different log messages. 
		 * Uses the log event levels for different message types,
		 * LogEventLevel.FATAL, LogEventLevel.ERROR, etc
		 * We do not show debug messages. Check the logsCollection or ConsoleLogInspector.
		 * */
		public static function playMessage(message:String, level:int=0):void {
			if (showMessageAnimation==null) return; // UI not created yet
			
			var borderContainer:IStyleClient = showMessageAnimation.target as IStyleClient;
			
			if (level==LogEventLevel.FATAL) {
				borderContainer.setStyle("backgroundColor", "red");
				borderContainer.setStyle("color", "white");
			}
			if (level==LogEventLevel.ERROR) {
				borderContainer.setStyle("backgroundColor", "red");
				borderContainer.setStyle("color", "white");
			}
			else if (level==LogEventLevel.WARN) {
				borderContainer.setStyle("backgroundColor", "yellow");
				borderContainer.setStyle("color", "black");
			}
			else if (level==LogEventLevel.INFO) {
				borderContainer.setStyle("backgroundColor", "blue");
				borderContainer.setStyle("color", "white");
			}
			
			showMessageLabel.text = message;
			
			if (showMessageAnimation.isPlaying) {
				showMessageAnimation.end();
			}
			
			showMessageAnimation.play();
		}
		
		public static var showMessageAnimation:Sequence;
		public static var showMessageLabel:Label;

		public static var attachmentsToUpload:Array;
		public static var currentAttachmentToUpload:AttachmentData;
		public static var lastAttemptedUpload:Object;
		
		/**
		 * Calls a function after a set amount of time. 
		 * */
		public static function callAfter(time:int, method:Function, ...Arguments):void {
			var sprite:Sprite = new Sprite();
			var callTime:int = getTimer() + time;
			
			// todo: find out if this causes memory leaks
			sprite.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				var difference:int = getTimer()-callTime-time;
				if (getTimer()>=callTime) {
					//trace("callAfter: time difference:" + difference);
					sprite.removeEventListener(Event.ENTER_FRAME, arguments.callee);
					method.apply(this, Arguments);
					method = null;
				}
			});
		}
		
		/**
		 * Calls a function after a frame 
		 * */
		public static function callLater(method:Function, ...Arguments):void {
			var sprite:Sprite = new Sprite();
			var startTime:int = getTimer();
			
			// todo: find out if this causes memory leaks
			sprite.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				var difference:int = getTimer()-startTime;
				//trace("callLater: time difference:" + difference);
				sprite.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				method.apply(this, Arguments);
				method = null;
			});
		}
		
		/**
		 * Refreshes the document by closing and opening
		 * */
		public static function refreshDocument(iDocument:IDocument, rebuildFromHistory:Boolean = false):Boolean {
			var documentInstance:Object = iDocument.instance;
			
			if (rebuildFromHistory) {
				info("Rebuilding document");
				setTarget(null);
				callAfter(250, HistoryManager.rebuild, iDocument);
			}
			else if (iDocument.isOpen) {
				instance.closeDocument(iDocument);
				instance.openDocument(iDocument, DocumentData.REMOTE_LOCATION, true);
				Radiate.info("Document rebuilt");
			}
			
			return true;
		}
		
		/**
		 * Show message when document has been rebuilt
		 * */
		public function refreshDocumentHandler(event:RadiateEvent):void {
			Radiate.info("Document rebuilt");
		}
		
		/**
		 * Gets the size of the target if it is a UIComponent or a DisplayObject.
		 * If it is neither or it does not have a size it returns null.
		 * Also sets the positionRectangle width and height. Temporary fix to bigger problem.
		 * */
		public static function getSize(target:Object, container:Object = null):Rectangle {
			var rectangle:Rectangle;
			
			if (target) {
				
				if (target is UIComponent) {
					rectangle = DisplayObjectUtils.getRectangleBounds(target as UIComponent, container);
					positionRectangle.width = rectangle.width;
					positionRectangle.height = rectangle.height;
					return rectangle;
				}
				else if (target is DisplayObject) {
					positionRectangle.width = rectangle.width;
					positionRectangle.height = rectangle.height;
					rectangle = DisplayObjectUtils.getRealBounds(target as DisplayObject);
					return rectangle;
				}
			}
			
			return null;
		}
		
		/**
		 * Reuse position rectangle. TODO reuse size rectangle
		 * */
		[Bindable]
		public static var positionRectangle:Rectangle = new Rectangle();
		
		/**
		 * Returns the x and y position of the target in a rectangle instance
		 * if it has x and y properties or null if it doesn't have those properties.
		 * */
		public static function getPosition(target:Object):Rectangle {
			//if (target is DisplayObject || target is IBitmapDrawable || target is IVisualElement) {
			
			if (target is Line) {
				positionRectangle.x = Math.min(target.xFrom, target.xTo);
				positionRectangle.y = Math.min(target.yFrom, target.yTo);
				return positionRectangle;
			}
			else if ("x" in target && "y" in target) {
				positionRectangle.x = target.x;
				positionRectangle.y = target.y;
				return positionRectangle;
			}
			else {
				positionRectangle.x = 0;
				positionRectangle.y = 0;
			}
			return null;
		}
		
		/**
		 * Open users site in a browser
		 * */
		public static function openUsersWebsite():void
		{
			var request:URLRequest;
			request = new URLRequest();
			request.url = getWPURL();
			navigateToURL(request, DEFAULT_NAVIGATION_WINDOW);
		}
		/**
		 * Open users login page or dashboard if already logged in in a browser
		 * */
		public static function openUsersLoginPage():void
		{
			var request:URLRequest;
			request = new URLRequest();
			request.url = getWPLoginURL();
			navigateToURL(request, DEFAULT_NAVIGATION_WINDOW);
		}
		
		/**
		 * Open users profile in a browser
		 * */
		public static function openUsersProfile():void
		{
			var request:URLRequest;
			request = new URLRequest();
			request.url = getWPProfileURL();
			navigateToURL(request, DEFAULT_NAVIGATION_WINDOW);
		}
		
		/**
		 * Locks or unlocks an item. You cannot lock the application at this time. 
		 * 
		 * @returns true if able to set lock on target. 
		 * */
		public static function lockComponent(target:Object, locked:Boolean = true):Boolean {
			var iDocument:IDocument = instance.selectedDocument;
			var componentDescription:ComponentDescription = iDocument ? iDocument.getItemDescription(target) : null;
			
			if (componentDescription && !(componentDescription.instance is Application)) {
				componentDescription.locked = locked;
				
				return true;
			}
			return false;
		}
		
		public var windowMenuDictionary:Dictionary = new Dictionary(true);
		public var desktopHTMLClassName:String = "mx.controls.HTML";
		
		/**
		 * Update the window menu item
		 * */
		public function updateWindowMenu(windowItem:MenuItem, nativeMenuItem:Object = null):void {
			var numberOfItems:int = windowItem.children ? windowItem.children.length : 0;
			var menu:Object;
			var menuItem:MenuItem;
			var numberOfDocuments:int;
			var iDocumentData:IDocumentData;
			var menuFound:Boolean;
			var applicationMenusCollection:ListCollectionView;
			var items:Array;
			var numberOfMenus:int;
			var isNativeMenu:Boolean;
			
			numberOfDocuments = documents.length;
			
			
			if (applicationMenu is Class(MenuItem.NativeMenuDefinition)) {
				var keys:Array = org.as3commons.lang.DictionaryUtils.getKeys(windowMenuDictionary);
				org.as3commons.lang.DictionaryUtils.deleteKeys(windowMenuDictionary, keys);
				items = applicationMenu.items;
				numberOfMenus = items ? items.length : 0;
				isNativeMenu = true;
				
				return;
				for (var j:int; j < numberOfDocuments; j++) {
					iDocumentData = documents[j];
					
					menuItem = new MenuItem.NativeMenuItemDefinition();
					menuItem.data = iDocumentData;
					menuItem.type = ClassUtils.getQualifiedClassName(iDocumentData);
					menuItem.label = iDocumentData.name;
					windowItem.checked = false;
					windowItem.addItem(menuItem);
				}
			}
			else {
				windowItem.removeAllChildren();
				isNativeMenu = false;
				applicationMenusCollection = applicationMenu ? applicationMenu.dataProvider : ViewManager.mainView.mainMenuBar.dataProvider as ListCollectionView;
				numberOfMenus = applicationMenusCollection ? applicationMenusCollection.length : 0;
				
				for (j; j < numberOfDocuments; j++) {
					iDocumentData = documents[j];
					
					menuItem = new MenuItem();
					menuItem.data = iDocumentData;
					menuItem.type = "radio";//ClassUtils.getQualifiedClassName(iDocumentData);
					menuItem.label = iDocumentData.name;
					
					if (iDocumentData==selectedDocument) {
						windowItem.checked = true;
					}
					else {
						windowItem.checked = false;
					}
					windowItem.addItem(menuItem);
				}
			}
			
			
			for (var i:int; i < numberOfMenus; i++) {
				if (applicationMenusCollection.getItemAt(i)==applicationWindowMenu) {
					applicationMenusCollection.removeItemAt(i);
					applicationMenusCollection.addItemAt(windowItem, i);
					//windowItem.checked = true;
					menuFound = true;
					break;
				}
			}
			
			if (menuFound) {
				windowItem.checked = true;
			}
			else {
				applicationMenusCollection.addItem(windowItem);
			}
			
			applicationMenu.dataProvider = applicationMenusCollection;
			
		}
		
		/**
		 * Reverts the document template
		 * */
		public static function revertDocumentTemplate(iDocument:IDocument):void {
			iDocument.createTemplate();
		}
		
		/**
		 * Method to write straight to the console. Does not log events since
		 * it is the logger helping to view previous logs. 
		 * */
		public static function logToConsole(message:String):void
		{
			log.info(message);
		}
		
		/**
		 * Updates the selection if the selection tool is selected
		 * */
		public static function updateSelection(target:Object = null):void {
			if (instance.toolLayer && instance.selectedTool is Selection) {
				Selection(instance.selectedTool).updateSelection(target);
			}
		}
		
		/**
		 * Gets the module factory for the specified object or 
		 * selected document if object is null.
		 * */
		public static function getModuleFactory(object:Object):IFlexModuleFactory {
			
			if (object is UIComponent) {
				return UIComponent(object).moduleFactory;
			}
			
			if (object==null || object is GraphicElement) {
				if (instance.selectedDocument && instance.selectedDocument.instance) {
					return instance.selectedDocument.instance.moduleFactory;
				}
			}
			
			return null;
		}
		
	}
}

class SINGLEDOUBLE{}