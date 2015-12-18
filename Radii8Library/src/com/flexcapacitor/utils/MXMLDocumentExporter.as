
package com.flexcapacitor.utils {
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.XMLValidationInfo;
	
	import spark.components.Application;
	
	/**
	 * Exports a document to MXML
	 * */
	public class MXMLDocumentExporter extends DocumentTranscoder implements IDocumentExporter {
		
		public function MXMLDocumentExporter() {
			supportsExport = true;
			language = "MXML";
		}
		
		/**
		 * Sets styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * Any styles not set inline are placed in an external stylesheet
		 * */
		public var useExternalStylesheet:Boolean;
		/**
		 * Default file extension. Default is mxml. 
		 * This can be changed by setting the export options.
		 * */
		public var fileExtension:String = "mxml";
		
		public var stylesheets:String;
		
		public var template:String;
		
		public var markup:String = "";
		
		public var styles:String = "";
		
		public var showChildren:Boolean = true;
		
		/**
		 * Styles added by users 
		 * */
		public var userStyles:String;
		
		/**
		 * @inheritDoc
		 * */
		override public function export(document:IDocument, componentDescription:ComponentDescription = null, parameterOptions:ExportOptions = null):SourceData {
			var output:String;
			var files:Array = [];
			var file:FileInfo;
			var pageOutput:String = "";
			var bodyContent:String;
			var sourceData:SourceData;
			var warningData:IssueData;
			var stylesheetLinks:String;
			var validationInfo:XMLValidationInfo;
			
			errors = [];
			warnings = [];
			styles = "";
			markup = "";
			template = "";
			
			///////////////////////
			// SET OPTIONS
			///////////////////////
			
			if (parameterOptions) {
				savePresets();
				applyPresets(parameterOptions);
			}
			
			
			///////////////////////
			// GET SOURCE CODE
			///////////////////////
			
			if (!componentDescription) {
				componentDescription = document.componentDescription;
			}
			
			markup = getMXMLOutputString(document, componentDescription);
			
			if (styles==null) {
				styles = "";
			}
			
			// add user styles
			if (userStyles) {
				styles += "\n" + userStyles;
			}
			
			// wrap CSS with style tags
			// when not inline and not external
			if (!useExternalStylesheet && styles!="") {
				bodyContent = markup + "\n" + wrapStylesInTags(styles);
			}
			else {
				bodyContent = markup;
			}
			
			// replace content
			if (template) {
				pageOutput = replaceContentToken(template, bodyContent);
			}
			else {
				pageOutput = bodyContent;
			}
			
			// replace title
			pageOutput = replacePageTitleToken(pageOutput, document.name);
			
			// replace scripts
			pageOutput = pageOutput.replace(scriptsToken, "");
			
			
			// styles
			if (useExternalStylesheet) {
				file = new FileInfo();
				file.contents = styles;
				file.fileName = document.name;
				file.fileExtension = "css";
				files.push(file);
				
				// create link to stylesheet
				stylesheetLinks = getExternalStylesheetLink(file.getFullFileURI());
				
				pageOutput = replaceStylesheetsToken(pageOutput, stylesheetLinks, false);
			}
			
			validationInfo = XMLUtils.validateXML(pageOutput);
			
			if (validationInfo && !validationInfo.valid) {
				warningData = IssueData.getIssue("Possibly Invalid Markup", validationInfo.internalErrorMessage);
				warnings.push(warningData);
			}
			else {
				error = null;
				errorMessage = null;
			}
			
			if (createFiles) {
				file = new FileInfo();
				file.contents = pageOutput;
				file.fileName = document.name;
				file.fileExtension = fileExtension;
				files.push(file);
			}
			
			sourceData = new SourceData();
			
			sourceData.markup = markup;
			sourceData.styles = styles;
			sourceData.source = pageOutput;
			sourceData.files = files;
			sourceData.errors = errors;
			sourceData.warnings = warnings;
			
			return sourceData;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportXML(document:IDocument, reference:Boolean = false):XML {
			return null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportJSON(document:IDocument, reference:Boolean = false):JSON {
			return null;
		}
		
		public var fcNamespace:String = "fc";
	
		/**
		 * Gets the formatted MXML output from a component. 
		 * TODO: This should be using namespaces. 
		 * */
		public function getMXMLOutputString(iDocument:IDocument, component:ComponentDescription, addLineBreak:Boolean = false, tabs:String = ""):String {
			//if (component.instance is Application) {
				getAppliedPropertiesFromHistory(iDocument, component);
			//}
			var validationInfo:XMLValidationInfo;
			var properties:Object = component.properties;
			var styles:Object = component.styles;
			var componentChild:ComponentDescription;
			var name:String = component.name;
			var output:String = "";
			var outputValue:String = "";
			var namespaces:String;
			var value:*;
			
			
			for (var propertyName:String in properties) {
				value = properties[propertyName];
				if (value===undefined || value==null) {
					continue;
				}
				
				output += " ";
				
				// we should be converting objects into tags
				if (value is Object) {
					// get a class exporter / dictionary - for example register "dataProvider" exporter 
					
					outputValue = XMLUtils.getAttributeSafeString(Object(value).toString());
					output += propertyName + "=\"" + outputValue + "\"";
					
				}
				else {
					output += propertyName + "=\"" + XMLUtils.getAttributeSafeString(Object(value).toString()) + "\"";
				}
			}
			
			for (var styleName:String in styles) {
				value = styles[styleName];
				if (value===undefined || value==null) {
					continue;
				}
				output += " ";
				output += styleName + "=\"" + XMLUtils.getAttributeSafeString(Object(styles[styleName]).toString()) + "\"";
			}
			
			// adding flexcapacitor attributes
			if (component.locked) {
				output += " ";
				output += fcNamespace + ":" + "locked=\"true\"";
			}
			
			if (component.name) {
				output += " ";
				output += fcNamespace + ":" + "name=\"" + component.name + "\"";
			}
			
			if (name) {
				if (component.instance is Application) {
					name = "Application";
					namespaces = defaultNamespaceDeclarations; 
					/*
					namespaces = " xmlns:fx=\"http://ns.adobe.com/mxml/2009\"";
					namespaces += " xmlns:s=\"library://ns.adobe.com/flex/spark\"";
					namespaces += " xmlns:mx=\"library://ns.adobe.com/flex/\"";
					namespaces += " xmlns:"+ fcNamespace + "=\"library://ns.flexcapacitor.com/flex/\"";
					*/
					output = namespaces + output;
				}
				
				// we are not handling namespaces here - we could use component descriptor
				output = tabs + "<s:" + name + " " + output;
				
				if (showChildren && component.children && component.children.length>0) {
					output += ">\n";
					
					for (var i:int;i<component.children.length;i++) {
						componentChild = component.children[i];
						// we should get the properties and styles from the 
						// the component description
						getAppliedPropertiesFromHistory(iDocument, componentChild);
						output += getMXMLOutputString(iDocument, componentChild, false, tabs + "\t");
					}
					
					output += tabs + "</s:" + name + ">\n";
				}
				else {
					 output += "/>\n";
				}
			}
			else {
				output = "";
			}
			
			return output;
		}
		
		/**
		 * Wrap in Style tags
		 * */
		public function wrapStylesInTags(value:String, namespaces:String = null):String {
			var out:String;
			
			if (namespaces==null) {
				namespaces = "@namespace controls \"com.flexcapacitor.controls.*\";";
				namespaces += "@namespace s \"library://ns.adobe.com/flex/spark\";"
				namespaces += "@namespace mx \"library://ns.adobe.com/flex/mx\";"
			}
			
			out = "<fx:Style>\n" + namespaces + "\n\n" + value + "\n</fx:Style>";
			
			return out;
		}
		
		/**
		 * Gets the markup for a link to an external stylesheet
		 * <pre>
		 * &lt;Style source="styles.css" />
		 * </pre>
		 * */
		public function getExternalStylesheetLink(filePath:String):String {
			var xml:XML = new XML("<fx:Style/>");
			xml.@source = filePath;
			
			return xml.toXMLString();
		}
	}
}