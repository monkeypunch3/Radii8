
package com.flexcapacitor.model {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.managers.CodeManager;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.managers.ImportManager;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.core.IVisualElement;
	
	import spark.components.supportClasses.InvalidatingSprite;
	import spark.primitives.supportClasses.GraphicElement;
	
	
	
	/**
	 * Document model
	 * */
	public class Document extends DocumentData implements IDocument, ISavable {
		
		/**
		 * Constructor
		 * */
		public function Document(target:IEventDispatcher=null) {
			super(target);
			createTemplate();
		}
		
		public function createTemplate():void
		{
			// this causes issues later when not exporting html refactor 
			template = new Radii8LibraryTranscodersAssets.basicHTMLDocumentReusable();
		}
		
		/**
		 * URL to get code
		 * */
		public var URL:String;
		
		/**
		 * Dots per inch
		 * */
		public var DPI:int;
		
		/**
		 * Width of document
		 * */
		public var width:String;
		
		/**
		 * Height of document
		 * */
		public var height:String;
		
		private var _scale:Number = 1;

		/**
		 * Scale of document
		 * */
		public function get scale():Number {
			return _scale;
		}

		/**
		 * Scale of document
		 * */
		public function set scale(value:Number):void {
			_scale = value;
			
			if (instance) {
				DisplayObject(instance).scaleX = value;
				DisplayObject(instance).scaleY = value;
			}
		}
		
		private var _xml:XML;

		/**
		 * Stores the original XML of an MXML document
		 * */
		public function get xml():XML
		{
			return _xml;
		}

		/**
		 * @private
		 */
		public function set xml(value:XML):void
		{
			_xml = value;
		}


		private var _errors:Array;

		public function get errors():Array
		{
			return _errors;
		}

		public function set errors(value:Array):void
		{
			_errors = value;
		}
		
		private var _warnings:Array;

		public function get warnings():Array
		{
			return _warnings;
		}

		public function set warnings(value:Array):void
		{
			_warnings = value;
		}

		
		private var _projectID:String;

		/**
		 * ID of project. Can be part of multiple projects so we may need to change this. 
		 * */
		public function get projectID():String {
			return _projectID;
		}

		/**
		 * @private
		 */
		public function set projectID(value:String):void {
			_projectID = value;
		}

		private var _language:String;

		/**
		 * Language to export document to.  
		 * */
		public function get language():String {
			return _language;
		}

		/**
		 * @private
		 */
		public function set language(value:String):void {
			_language = value;
		}

		private var _project:IProject;

		/**
		 * Reference to parent project
		 * */
		public function get project():IProject {
			return _project;
		}

		/**
		 * @private
		 */
		public function set project(value:IProject):void {
			_project = value;
		}
		
		private var _containerType:Class;

		/**
		 * @inheritDoc
		 * */
		public function get containerType():Class {
			return _containerType;
		}

		public function set containerType(value:Class):void {
			_containerType = value;
		}

		private var _containerTypeName:String;

		/**
		 * @inheritDoc
		 * */
		public function get containerTypeName():String {
			return _containerTypeName;
		}

		public function set containerTypeName(value:String):void {
			_containerTypeName = value;
		}

		private var _sourceData:SourceData;

		/**
		 * Last reference to a source data object if document was imported from MXML data 
		 * */
		public function get sourceData():SourceData
		{
			return _sourceData;
		}

		public function set sourceData(value:SourceData):void
		{
			_sourceData = value;
		}

		
		/**
		 * @private
		 * */
		private var _componentDescription:ComponentDescription;

		/**
		 * Reference to the component description
		 * */
		public function get componentDescription():ComponentDescription {
			
			// creates initial application description
			if (!_componentDescription) {
				
				if (instance) {
					_componentDescription = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary, exclusions);
				}
			}
			
			// com.flexcapacitor.utils.supportClasses.ComponentDescription (@1234c3539)
			_componentDescription = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary, exclusions);
			
			return _componentDescription;
		}

		/**
		 * @private
		 */
		public function set componentDescription(value:ComponentDescription):void {
			_componentDescription = value;
		}

		private var _instance:Object;
		
		/**
		 * Adds a component to the components dictionary.
		 * Does not add any properties or other methods to it. 
		 * Need to refactor. Most of the work is done by accessing the property 
		 * componentDescription. 
		 * */
		public function addComponentDescription(instance:*):ComponentDescription {

			if (descriptionsDictionary[instance]==null) {
				//descriptionsDictionary[instance] = new ComponentDescription(instance);
				descriptionsDictionary[instance] = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary);
			}
			
			return descriptionsDictionary[instance];
		}

		/**
		 * Instance of document
		 * */
		public function get instance():Object {
			return _instance;
		}

		/**
		 * @private
		 */
		public function set instance(value:Object):void {
			_instance = value;
		}
		
		/**
		 * @private
		 * */
		private var _history:ListCollectionView = new ArrayCollection();

		/**
		 * History
		 * */
		public function get history():ListCollectionView {
			return _history;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set history(value:ListCollectionView):void {
			_history = value;
		}

		
		private var _historyIndex:int = -1;

		/**
		 * Index of current event in history
		 * */
		public function get historyIndex():int {
			return _historyIndex;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set historyIndex(value:int):void {
			_historyIndex = value;
			
			if (value != lastSavedHistoryIndex) {
				isChanged = true;
			}
			else {
				isChanged = false;
			}
		}

		
		private var _lastSavedHistoryIndex:int = -1;

		/**
		 * Index of event in history when the document was last saved
		 * */
		public function get lastSavedHistoryIndex():int {
			return _lastSavedHistoryIndex;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set lastSavedHistoryIndex(value:int):void {
			_lastSavedHistoryIndex = value;
			
			isChanged = historyIndex!=value;
		}
		
		private var _isPreviewOpen:Boolean;

		/**
		 * @inheritDoc
		 * */
		public function get isPreviewOpen():Boolean {
			return _isPreviewOpen;
		}

		public function set isPreviewOpen(value:Boolean):void {
			_isPreviewOpen = value;
		}

		/**
		 * If we encounter an invalidating sprite it's may be a GraphicElement
		 * */
		public var invalidatingSpritesDictionary:Dictionary = new Dictionary(true);
		
		private var _descriptionsDictionary:Dictionary = new Dictionary(true);

		/**
		 * Reference to component description for each component instance
		 * */
		public function get descriptionsDictionary():Dictionary {
			return _descriptionsDictionary;
		}

		/**
		 * @private
		 */
		public function set descriptionsDictionary(value:Dictionary):void {
			_descriptionsDictionary = value;
		}
		
		/**
		 * Adds the instance and component description to this document.
		 * 
		 * @see #addComponentDescription() 
		 * */
		public function setItemDescription(value:*, itemDescription:ComponentDescription):void {
			var spriteFound:Boolean;
			
			if (value is InvalidatingSprite) {
				for (var object:Object in invalidatingSpritesDictionary) {
					if (object==value) {
						spriteFound = true;
						break;
					}
				}
			}
			
			// this might be incorrect - should it be (if value is InvalidatingSprite && spriteFound)? 
			if (!spriteFound) {
				invalidatingSpritesDictionary[value] = itemDescription;
			}
			
			// we also need to avoid adding the editable text field 
			// and other other items in the future 
			// such as resize components or guidelines 
			
			descriptionsDictionary[value] = itemDescription;
			
			// we need to set the component's parent - calling this will 
			// try to find it in the component display list and that will
			// set it's parent and children properties
			updateComponentTree();
			
		}
		
		/**
		 * Objects not to show in the component tree
		 * */
		public var exclusions:Dictionary = new Dictionary(true);
		
		/**
		 * Rebuilds or updates the component tree  
		 * */
		public function updateComponentTree(target:Object = null):void
		{
			if (target==null) {
				target = instance;
			}
			
			DisplayObjectUtils.getComponentDisplayList2(target, null, 0, descriptionsDictionary, exclusions);
		}
		
		/**
		 * Adds an item to ignore when creating a component tree
		 * */
		public function addExclusion(object:Object):void {
			if (object) {
				exclusions[object] = 1;
			}
		}
		
		public function removeExclusion(object:Object):void {
			if (object && object in exclusions) {
				exclusions[object] = null;
				delete exclusions[object];
			}
		}
		
		public function removeAllExclusions(object:Object):void {
			for(var id:* in exclusions) {
				delete exclusions[id];
			}
		}
		
		/**
		 * Returns the component description for the give item. 
		 * Some items may not be in the descriptions dictionary.
		 * If they are not null is returned.
		 * */
		public function getItemDescription(value:*):ComponentDescription {
			
			if (value == instance) {
				return componentDescription;
			}
			
			if (value is InvalidatingSprite) {
				for (var object:Object in descriptionsDictionary) {
					if (object is GraphicElement && object.displayObject==value) {
						return descriptionsDictionary[object];
					}
				}
			}
			
			return descriptionsDictionary[value];
			
		}
		
		private var _documentData:IDocumentData;

		/**
		 * Reference to the last saved data that was loaded in
		 * */
		public function get documentData():IDocumentData {
			return _documentData;
		}

		/**
		 * @private
		 */
		public function set documentData(value:IDocumentData):void {
			_documentData = value;
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function close():void {
			super.close();
			//Radiate.info("Close:" + source);
			clearHistory();
		}
		
		/**
		 * Removes the history events
		 * */
		public function clearHistory():void {
			//history.refresh();
			history.removeAll();
			historyIndex = -1;
			isChanged = false;
		}
		
		/**
		 * Save 
		 * */
		override public function save(locations:String = REMOTE_LOCATION, options:Object = null):Boolean {
			var savedLocallyResult:Boolean = super.save(locations, options);
			//trace("- IDocument save document " + name);
			
			lastSavedHistoryIndex = historyIndex;
			
			return savedLocallyResult;
		}
		
		/**
		 * Saves our data to the post before sending it to the server
		 * */
		override public function toSaveFormObject():URLVariables {
			var object:URLVariables = super.toSaveFormObject();
			
			if (isOpen) {
				// we need to move away from this
				// use DocumentManager.saveDocument() 
				// and DocumentManager.saveDocumentHook() instead 
				if (false) {
					object["custom[html]"] = getHTMLSource();
				}
				object["custom[notes]"] = notes ? notes : "";
				object["custom[template]"] = template;
			}
			
			if (saveFunction!=null) {
				saveFunction(this, object);
			}
			
			//trace("- IDocument save form object " + object);
			
			return object;
		}
		
		private var _saveFunction:Function;

		/**
		 * Hook to allow updating information saved to the page.
		 * Usage: 
<pre>
myDocument.saveFunction = mySaveFunction;
myDocument.save(); 

public function mySaveFunction(document:IDocument, data:Object):Object {
 
	data.content = "My post content";
	data["custom[css]"] = "some css";
	
	return data;
};
</pre>
		 * */
		public function get saveFunction():Function {
			return _saveFunction;
		}

		/**
		 * @private
		 */
		public function set saveFunction(value:Function):void {
			_saveFunction = value;
		}

		/**
		 * 
		 * */
		override public function toString():String {
			var sourceData:SourceData = exporter.export(this);
			var output:String = sourceData.source;
			
			return output;
		}
		
		/**
		 * Exports to XML object
		 * */
		override public function toXML(representation:Boolean = false):XML {
			var output:XML = exporter.exportXML(this, representation);
			
			return output;
		}

		/**
		 * Exports an XML string.
		 * If reference is true then just returns just enough basic information to locate it. 
		 * */
		/*override public function toXMLString(reference:Boolean = false):String {
			var output:String;
			
			output = exporter.exportXMLString(this, reference);
			
			return output;
		}*/

		/**
		 * Exports an MXML string.
		 * If reference is true then just enough basic information to locate it. 
		 * */
		/*override public function toMXMLString(reference:Boolean = false):String {
			var output:String;
			
			output = internalExporter.exportXMLString(this, reference);
			
			return output;
			
		}*/
		
		/**
		 * Exports a string
		 * */
		/*public function export(exporter:IDocumentExporter):String {
			var output:String = exporter.exportXMLString(this);
			
			return output;
			
		}*/
		
		/**
		 * Get basic document data
		 * */
		override public function unmarshall(data:Object):void {
			super.unmarshall(data); 
			
			if (data is IDocumentData) {
				//documentData = IDocumentData(data);// this and
				//IDocumentData(data).document = this;// this should be removed just have references somewhere 
			}
		}
		
		/**
		 * Get source code for document. 
		 * Exporters may not work if the document is not open. 
		 * Deprecated. Use CodeManager to get source. 
		 * */
		override public function getSource(target:Object = null):String {
			var sourceData:SourceData;
			var value:String;
			var options:ExportOptions;
			
			
			if (isOpen) {
				if (this.historyIndex==-1) {
					//Radiate.info("Document history is empty!");
				}
				
				// value was not saving so ignoring is changed property
				//if (isChanged || source==null || source=="") {
				if (true) {
					options = CodeManager.getExportOptions(CodeManager.MXML);
					options.exportChildDescriptors = true;
					sourceData = CodeManager.getSourceData(instance, this, CodeManager.MXML, options);
					value = sourceData.source;
					
					// if the document is not fully open then we get errors and warnings like:
					// Possibly Invalid Markup - XML node kind is not element
					// Could not continue exporting MXML on this node. - Component definition for 'null' not found
					//  those errors mean the document may not be completely loaded or initialized yet
					//  in that case we need to save the original source code
					// TODO: find and track down the cause of the empty string
					if (value!=null && value!="") {
						return value;
					}
					
				}
				
				if (source) {
					value = source;
				}
				else if (originalSource) {
					value = originalSource;
				}
				
				return value;
				
			}
			
			return source;
		}
		
		/**
		 * Default class that exports the document to HTML
		 * */
		[Transient]
		public static var htmlExporter:IDocumentExporter;
		
		/**
		 * Get HTML source code for document. 
		 * Exporters may not work if the document is not open. 
		 * Deprecated. Use CodeManager to get HTML output
		 * */
		public function getHTMLSource(target:Object = null):String {
			var sourceData:SourceData;
			var value:String;
			
			if (isOpen) {
				if (this.historyIndex==-1) {
					//Radiate.info("Document history is empty!");
				}
				
				// value was not saving so ignoring is changed property
				//if (isChanged || source==null || source=="") {
				if (true) {
					var options:ExportOptions = CodeManager.getExportOptions(CodeManager.HTML);
					options.exportChildDescriptors = true;
					sourceData = CodeManager.getSourceData(instance, this, CodeManager.HTML, options);
					value = sourceData.source;
					//sourceData = htmlExporter.export(this, componentDescription);
					//value = sourceData.source;
				}
				else if (source) {
					value = source;
				}
				else if (originalSource) {
					value = originalSource;
				}
				
				//Radiate.info("Saving this HTML=" + value);
				
				return value;
				
			}
			
			return source;
		}
		
		/**
		 * Reverts to previous saved value
		 * */
		public function revert(parent:IVisualElement = null):void {
			HistoryManager.revert(this);
			ImportManager.parseSource(this, originalSource, parent);
		}
		
		/**
		 * Resets the save status after loading a document
		 * */
		public function resetSaveStatus():void {
			lastSavedHistoryIndex = historyIndex;
		}
	}
}