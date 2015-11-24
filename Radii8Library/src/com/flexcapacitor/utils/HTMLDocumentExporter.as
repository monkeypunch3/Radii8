
package com.flexcapacitor.utils {
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.XMLValidationInfo;
	import com.flexcapacitor.views.supportClasses.Styles;
	
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.styles.IStyleClient;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.NumericStepper;
	import spark.components.RichText;
	import spark.components.VGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ListBase;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	
	import org.as3commons.lang.ObjectUtils;
	
	/**
	 * Exports a document to HTML<br/><br/>
	 * 
	 * Recommendations for compatibility: <br/>
	 * http://www.w3.org/TR/xhtml-media-types/#C_2
	 * */
	public class HTMLDocumentExporter extends DocumentTranscoder implements IDocumentExporter {
		
		public function HTMLDocumentExporter() {
			supportsExport = true;
		}
		
		/**
		 * Version
		 * */
		public var version:String = "1.0.0";
		
		/**
		 * Sets explicit size regardless if size is explicit
		 * */
		public var setExplicitSize:Boolean = true;
		
		/**
		 * Sets styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * Styles added by users 
		 * */
		public var userStyles:String;
		
		/**
		 * Border box CSS
		 * cause all padding and borders to be inside width and height 
		 * http://www.paulirish.com/2012/box-sizing-border-box-ftw/
		 * */
		public var borderBoxCSS:String = "*, *:before, *:after {\n\t-moz-box-sizing:border-box;\n\t-webkit-box-sizing:border-box;\n\tbox-sizing:border-box;\n}";
		
		/**
		 * Show outline around each element
		 * */
		public var bordersCSS:String = "*,*:before,*:after {outline:1px dotted red;}";
		
		/**
		 * Zoom CSS
		 * */
		public var zoomCSS:String;
		
		/**
		 * Page zoom level
		 * */
		public var scaleLevel:Number;
		
		/**
		 * CSS for SVG button
		 * */
		public var buttonCSS:String;
		
		public var buttonCSS2:String = "";
		
		public var stylesheets:String;
		
		public var template:String;
		
		/**
		 * Creates a snapshot of the application and sets it as the background image
		 * */
		public var showScreenshotBackground:Boolean = false;
		
		/**
		 * Alpha of the background image
		 * */
		public var backgroundImageAlpha:Number = .5;
		
		/**
		 * Extension of the document when exporting to a file. 
		 * */
		public var extension:String;
		
		/**
		 * Indicates when the user has typed in the text area
		 * */
		public var isCodeModifiedByUser:Boolean;
		
		/**
		 * Show borders around HTML elements
		 * */
		public var showBorders:Boolean;
		
		/**
		 * Use border box model
		 * */
		public var useBorderBox:Boolean = true;
		
		/**
		 * Padding from browser text engine. 
		 * In browsers (some or all) the text is not absolutely placed 
		 * where you set it to be the larger the font is the farther down
		 * it is. So we adjust it but it's not that accurate. 
		 * If it is vertically aligned we shouldn't use this. TODO
		 * */
		public var paddingFromBrowserTextEngine:Number = .34615;
		
		/**
		 * Use SVG button class
		 * */
		public var useSVGButtonClass:Boolean = true;
		
		/**
		 * Show full HTML page source
		 * */
		public var showFullHTMLPageSource:Boolean = false;
		
		/**
		 * Convert bitmap data to graphic data
		 * */
		public var createImageDataForGraphics:Boolean = false;
		
		/**
		 * Last source code
		 * */
		public var sourceCode:String;
		
		public var includePreviewCode:Boolean;
		
		public var horizontalPositions:Array = ["x","left","right","horizontalCenter"];
		public var horizontalCenterPosition:String = "horizontalCenter";
		public var verticalPositions:Array = ["y","top","bottom","verticalCenter"];
		public var verticalCenterPosition:String = "verticalCenter";
		public var sizesPositions:Array = ["width","height"];
		
		public var addZoom:Boolean;
		
		public var output:String = "";
		public var markup:String = "";
		public var styles:String = "";
		
		public var wrapInPreview:Boolean;
		
		public var disableTabs:Boolean;
		
		/**
		 * URL to transparent Gif used for spacing
		 * */
		public var transparentGifURL:String = "/spacer.gif";
		
		/**
		 * 
		 * */
		public var useWrapperDivs:Boolean;
		
		/**
		 * 
		 * */
		public var showDocumentCode:Boolean;
		
		/**
		 * 
		 * */
		public var document:IDocument;
		
		/**
		 * @inheritDoc
		 * */
		override public function export(iDocument:IDocument, targetDescription:ComponentDescription = null, localOptions:ExportOptions = null):SourceData {
			var pageOutput:String = "";
			var file:FileInfo;
			var files:Array = [];
			var errorData:IssueData;
			var warningData:IssueData;
			var tabDepth:String = "";
			var bodyContent:String;
			
			document = iDocument;
			
			errors = [];
			warnings = [];
			styles = "";
			markup = "";
			sourceCode = "";
			template = "";
			
			
			///////////////////////
			// SET OPTIONS
			///////////////////////
			
			if (localOptions) {
				savePresets();
				applyPresets(localOptions);
			}
			
			
			///////////////////////
			// GET SOURCE CODE
			///////////////////////
			
			if (showDocumentCode) {
				targetDescription = document.componentDescription;
			}
			
			if (targetDescription) {
				var zoomOutput:String;
				var applicationContainerID:String = "applicationContainer";
				var zoomInID:String = wrapInPreview ? document.name : applicationContainerID;
				
				// see the top of this document on how to generate source code
				getAppliedPropertiesFromHistory(iDocument, targetDescription);
				
				if (!disableTabs) {
					tabDepth = getContentTabDepth(template);
				}
				
				// if useCustomMarkup is true then markup and styles is
				// is set by the options object
				if (!useCustomMarkup) {
					markup = getHTMLOutputString(document, targetDescription, true, tabDepth);
					// styles are updated here too
				}
				else if (createFiles) {
					warningData = IssueData.getIssue("Live Editing Enabled", "Your live changes have been saved. Disable live editing to revert changes.");
					warnings.push(warningData);
				}
				
				//showScreenshotBackground = true;
				
				// background-image didn't work in FF on mac. didn't test on other browsers
				if (showScreenshotBackground) {
					var backgroundImageID:String = "backgroundComparisonImage";
					var imageDataFormat:String = "png";//"jpeg";
					var imageData:String = DisplayObjectUtils.getBase64ImageDataString(document.instance, imageDataFormat, null, true);
					var backgroundSnapshot:String = "\n" + tabDepth + "\t" + "<img ";
					var backgroundImageAlpha:String = ".5";
					backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
					backgroundSnapshot += " style=\"position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;\"";
					backgroundSnapshot += " src=\"" + imageData + "\" >";
					
					pageOutput += backgroundSnapshot;
					
					var imageDataStyle:String;
					imageDataStyle = "body {\n";
					imageDataStyle += "\tbackground-repeat: no-repeat;\n";
					imageDataStyle += "\tbackground-image: url(" + imageData + ");\n";
					imageDataStyle += "}";
					//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
					
					styles += "\n" + imageDataStyle;
				}
				
				if (styles==null) {
					styles = "";
				}
				
				if (useBorderBox) {
					styles += "\n" + borderBoxCSS;
				}
				
				if (showBorders) {
					styles += "\n" + bordersCSS;
				}
				
				if (useSVGButtonClass) {
					styles += "\n" + buttonCSS2;
				}
				
				if (addZoom) {
					//zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + application.name);
					zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + zoomInID);
					zoomOutput = zoomOutput.replace(/ZOOM_VALUE/g, document.scale);
					styles += "\n" + zoomOutput;
				}
				
				// add user styles
				if (userStyles) {
					styles += "\n" + userStyles;
				}
				
				// wrap CSS with style tags
				// when not inline and not external
				if (!useExternalStylesheet && styles!="") {
					bodyContent = markup + "\n" + wrapInStyleTags(styles);
				}
				else {
					bodyContent = markup;
				}
				
				if (template==null) {
					template = "";
					warningData = IssueData.getIssue("Missing template content", "The template was empty.");
					warnings.push(warningData);
				}
				
				
				// replace content
				pageOutput = replaceContentToken(template, bodyContent);
					
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
					
					var stylesheetLinks:String;
					
					// create link to stylesheet
					stylesheetLinks = getExternalStylesheetLink(file.getFullFileURI());
					
					pageOutput = replaceStylesheetsToken(pageOutput, stylesheetLinks);
					
				}
				
				if (createFiles) {
					file = new FileInfo();
					file.contents = pageOutput;
					file.fileName = document.name;
					file.fileExtension = fileExtension;
					files.push(file);
				}
				
				
				///////////////////////
				// VALIDATION
				///////////////////////
				
				var validationInfo:XMLValidationInfo = XMLUtils.validateXML(pageOutput);
				
				if (validationInfo && !validationInfo.valid) {
					warningData = IssueData.getIssue("Possibly Invalid Markup", validationInfo.internalErrorMessage, validationInfo.row, validationInfo.column);
					warnings.push(warningData);
				}
				else {
					error = null;
					errorMessage = null;
				}
				
				var checkValidXML:Boolean = false;
				
				if (checkValidXML) {
					try {
						// don't use XML for HTML output because it converts this:
						// <div ></div>
						// to this:
						// <div />
						// and that breaks the html page
						
						// we can still try it to make sure it's valid
						// we could be saving CPU cycles here?
						var time:int = getTimer();
						
						// check if valid XML
						// we could also use XMLUtils.isValid but this is also for formatting
						var xml:XML = new XML(pageOutput);
						time = getTimer() -time;
						//trace("xml validation parsing time=" + time);
						sourceCode = pageOutput;
					}
					catch (error:Error) {
						// Error #1083: The prefix "s" for element "Group" is not bound.
						// <s:Group x="93" y="128">
						//	<s:Button x="66" y="17"/>
						//</s:Group>
						
						warningData = IssueData.getIssue(error.name, error.message);
						warnings.push(errorData);
						
						time = getTimer() -time;
						//trace("xml validation parsing time with error=" + time);
						sourceCode = pageOutput;
					}
				}
				else {
					sourceCode = pageOutput;
				}
			}
			
			var sourceData:SourceData = new SourceData();
			
			sourceData.markup = markup;
			sourceData.styles = styles;
			sourceData.source = pageOutput;
			sourceData.files = files;
			sourceData.errors = errors;
			sourceData.warnings = warnings;
			
			restorePreviousPresets();
			
			return sourceData;
		}
		
		/**
		 *  Gets the markup for a link to an external stylesheet
		 * <pre>
		 * &lt;link href="styles.css" type="text/css" />
		 * </pre>
		 * Returns a string of a link element.
		 * */
		public function getExternalStylesheetLink(filePath:String, relation:String = "stylesheet", title:String = null, type:String = "text/css", media:String = null):String {
			var xml:XML = new XML("<link/>");
			xml.@href = filePath;
			if (media) xml.@media = media;
			if (relation) xml.@rel = relation;
			if (title) xml.@rel = title;
			if (type) xml.@type = type;
			
			return xml.toXMLString();
		}
	
		/**
		 * Gets the formatted output from a component.
		 * Yes, this is a mess. It needs refactoring.  
		 * I wanted to see if I could quickly generate valid HTML 
		 * from the component tree and haven't had the chance to do it right. 
		 * 
		 * I did start though. There is partial work with CSS properties objects 
		 * but those aren't used yet. 
		 * Basically you set the properties and styles on an object instead of inline
		 * and then call propertyObject.toString(). The method would handle
		 * formatting, tab spacings and possibly wrapper objects.
		 * Wrapper objects... that's another thing. 
		 * Different elements would extend an HTMLElement object.
		 * */
		public function getHTMLOutputString(iDocument:IDocument, component:ComponentDescription, addLineBreak:Boolean = false, tabs:String = "", includePreview:Boolean = false):String {
			var componentInstance:Object = component.instance;
			if (componentInstance==null) return "";
			var propertyList:Object = component.properties;
			var propertiesStylesObject:Object = ObjectUtils.merge(component.properties, component.styles);
			var componentName:String = component.name ? component.name.toLowerCase() : "";
			var localName:String = componentName ? componentName : "";
			var htmlName:String;
			var tracking:Number;
			var componentChild:ComponentDescription;
			var instanceName:String = componentInstance && "name" in componentInstance ? componentInstance.name : "";
			var instanceID:String = componentInstance && "id" in componentInstance ? componentInstance.id : "";
			var contentToken:String = "[child_content]";
			var styleValue:String = "position:absolute;";
			var stylesModel:Styles = new Styles();
			var stylesOut:String = "";
			var wrapperStylesModel:Styles = new Styles();
			var isInHorizontalLayout:Boolean;
			var isInVerticalLayout:Boolean;
			var isInBasicLayout:Boolean;
			var isInTileLayout:Boolean;
			var childContent:String = "";
			var wrapperTag:String = "";
			var centeredHorizontally:Boolean;
			var wrapperTagStyles:String = "";
			var properties:String = "";
			var outlineStyle:String;
			var layoutOutput:String = "";
			var type:String = "";
			var instance:Object;
			var numElements:int;
			var index:int;
			var value:*;
			var gap:int;
			var initialTabs:String = tabs;
			var parentVerticalAlign:String;
			var errorData:ErrorData;
			var identity:String = ClassUtils.getIdentifier(componentInstance);
			
			
			// we are setting the styles in a string now
			// the next refactor should use the object so we can output to CSS
			stylesModel.position = Styles.ABSOLUTE;
			//outlineStyle = "outline:1px solid red;"; // we should enable or disable outlines via code not markup on in the export
			
			// get layout positioning
			if (component.parent && component.parent.instance is IVisualElementContainer) {
				
				if (component.parent.instance.layout is HorizontalLayout) {
					isInHorizontalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					//styleValue += "vertical-align:middle;";
					stylesModel.position = Styles.RELATIVE;
					index = GroupBase(component.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(componentInstance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStylesModel.display = hasExplicitSizeSet(componentInstance as IVisualElement) ? Styles.INLINE_BLOCK : Styles.INLINE;
					gap = HorizontalLayout(component.parent.instance.layout).gap - 4;
					parentVerticalAlign = component.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						wrapperTagStyles += Styles.MARGIN_RIGHT+":" + gap + "px;";
						wrapperStylesModel.marginRight =  gap + "px";
						
					}
					
					wrapperTag = "div";
				}
				else if (component.parent.instance.layout is TileLayout) {
					//isHorizontalLayout = true;
					isInTileLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					stylesModel.position = Styles.RELATIVE;
					index = GroupBase(component.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(componentInstance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStylesModel.display = hasExplicitSizeSet(componentInstance as IVisualElement) ? Styles.INLINE_BLOCK : Styles.INLINE;
					gap = TileLayout(component.parent.instance.layout).horizontalGap - 4;
					parentVerticalAlign = component.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						// using "margin-right" because if you set a fixed width padding was not doing anything
						wrapperTagStyles += Styles.MARGIN_RIGHT+":" + gap + "px;";
						//wrapperStyles.paddingRight =  gap + "px";
						wrapperStylesModel.marginRight =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (component.parent.instance.layout is VerticalLayout) {
					isInVerticalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					stylesModel.position = Styles.RELATIVE;
					index = GroupBase(component.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					gap = VerticalLayout(component.parent.instance.layout).gap;
					parentVerticalAlign = component.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-bottom:" + gap + "px;";
						wrapperTagStyles += Styles.MARGIN_BOTTOM+":" + gap + "px;";
						//wrapperStyles.paddingBottom =  gap + "px";
						wrapperStylesModel.marginBottom =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (component.parent.instance.layout is BasicLayout) {
					isInBasicLayout = true;
					
					
					
					//styleValue = styleValue.replace("absolute", "relative");
					//styles.position = Styles.RELATIVE;
					/*index = GroupBase(component.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					gap = BasicLayout(component.parent.instance.layout).gap;*/
					
					/*if (index<numElements-1 && numElements>1) {
						wrapperTagStyles += "padding-bottom:" + gap + "px";
					}
					
					wrapperTag = "div";*/
				}
			}
			
			// constraints take higher authority
			var isHorizontalCenterSet:Boolean;
			var isVerticalCenterSet:Boolean;
			
			// loop through assigned properties and check for layout rules 
			for (var propertyName:String in propertiesStylesObject) {
				value = null;
				
				if (propertyName in propertiesStylesObject) {
					value = propertiesStylesObject[propertyName];
				}
				
				if (value===undefined || value==null) {
					continue;
				}
				
				
				if (verticalPositions.indexOf(propertyName)!=-1 && !isVerticalCenterSet) {
					styleValue = getVerticalPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
					isVerticalCenterSet = true;
				}
				else if (horizontalPositions.indexOf(propertyName)!=-1 && !isHorizontalCenterSet) {
					styleValue = getHorizontalPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
					isHorizontalCenterSet = true;
				}
				
			}
			
			
			if (localName) {
				
				// create code for element type
				if (localName=="application") {
					htmlName = "div";
					
					// container div
					if (includePreview) {
						/*output = "<div style=\"position:absolute;";
						//output += "width:" + (componentInstance.width + 40) + "px;";
						output += "width:100%;";
						output += "height:" + (componentInstance.height + 40) + "px;";
						output += "background-color:#666666;\">";*/
						layoutOutput += "<div";
						//output = getNameString(componentInstance, output);
						layoutOutput += properties ? " " + properties : " ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						styleValue = styleValue.replace("absolute", "relative");
						stylesModel.position = Styles.ABSOLUTE;
						styleValue += "width:" + componentInstance.width+ "px;";
						styleValue += "height:" + componentInstance.height+ "px;";
						styleValue = getFontFamily(componentInstance, styleValue, true);
						styleValue = getFontWeight(componentInstance, styleValue, true);
						styleValue = getFontSize(componentInstance, styleValue, true);
						styleValue += "margin:0 auto;";
						styleValue += "left:8px;top:14px;";
						styleValue += "overflow:auto;";
						styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("backgroundColor"), true) + ";";
						//output += properties ? " " : "";
						stylesOut = styleValue;
						layoutOutput += setStyles(componentInstance, styleValue);
						
						if (showScreenshotBackground) {
							var backgroundImageID:String = "backgroundComparisonImage";
							var imageDataFormat:String = "png";//"jpeg";
							var imageData:String = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
							var backgroundSnapshot:String = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							layoutOutput += backgroundSnapshot;
							layoutOutput += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;", true);
							/* background-image didn't work in FF on mac. didn't test on other browsers
							//trace(imageData);
							var imageDataStyle:String = "#" + getIdentifierOrName(target) + "  {\n";
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							imageDataStyle += "\tbackground-repeat: no-repeat;\n";
							imageDataStyle += "\tbackground-image: url(data:image/"+imageDataFormat+";base64,"+imageData+");\n}";
							styles += "\n" + imageDataStyle;*/
						}
						
						layoutOutput += contentToken;
						//output += "\n </div>\n</div>";
						layoutOutput += "\n</div>";
						
					}
					else {
						if (addContainerDiv) {
							//output = "<div style=\"position: absolute;width:100%;height:100%;background-color:#666666;\">";
							layoutOutput = "<div";
							layoutOutput += properties ? " " + properties : " ";
							layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
							layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
							//output = getNameString(componentInstance, output);
							layoutOutput += properties ? " " + properties : "";
							styleValue += "width:" + componentInstance.width+ "px;";
							styleValue += "height:" + componentInstance.height+ "px;";
							styleValue += "border:1px solid black;";
						}
						else {
							styleValue = "";
						}
						
						styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("backgroundColor"), true) + ";";
						styleValue = getFontFamily(componentInstance, styleValue, true);
						styleValue = getFontWeight(componentInstance, styleValue, true);
						styleValue = getFontSize(componentInstance, styleValue, true);
						
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						//output += properties ? " " : "";
						stylesOut = styleValue;
						
						
						if (showScreenshotBackground) {
							backgroundImageID = "backgroundComparisonImage";
							imageDataFormat = "png";//"jpeg";
							imageData = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
							backgroundSnapshot = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							layoutOutput += backgroundSnapshot;
							layoutOutput += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;", true);
							/* background-image didn't work in FF on mac. didn't test on other browsers
							//trace(imageData);
							var imageDataStyle:String = "#" + getIdentifierOrName(target) + "  {\n";
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							imageDataStyle += "\tbackground-repeat: no-repeat;\n";
							imageDataStyle += "\tbackground-image: url(data:image/"+imageDataFormat+";base64,"+imageData+");\n}";
							styles += "\n" + imageDataStyle;*/
						}
						
						
						if (addContainerDiv) {
							layoutOutput += setStyles(componentInstance, styleValue);
							layoutOutput += contentToken;
							layoutOutput += "\n</div>";
						}
						else {
							setStyles("body", styleValue);
							layoutOutput += contentToken;
							layoutOutput += "";
						}
					}
				}
				
				else if (localName=="group" || localName=="vgroup") {
					htmlName = "div";
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<div " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += properties ? " " : "";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					if (componentInstance is VGroup) {
						styleValue += "text-align:" + VGroup(componentInstance).horizontalAlign + ";";
					}
					
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;"
					stylesOut = styleValue;
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += contentToken;
					layoutOutput += "\n" + tabs + "</div>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				
				else if (localName=="bordercontainer") {
					htmlName = "div";
					
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<div " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += properties ? " " : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += getBorderString(componentInstance as BorderContainer);
					styleValue += getCornerRadiusString(componentInstance as BorderContainer);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					//styleValue += getColorString(componentInstance as BorderContainer);
					//styles += componentInstance as BorderContainer);
					
					stylesOut = styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += componentInstance.numElements==0? "&#160;": contentToken;
					layoutOutput += "\n" + tabs + "</div>";
					layoutOutput += getWrapperTag(wrapperTag, true);
					
				}
				
				else if (localName=="hgroup" || localName=="tilegroup") {
					htmlName = "div";
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<div " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
					if (component.name=="HGroup") {
						styleValue = getWidthString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					}
					else {
						styleValue = getWidthString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					}
					
					styleValue = getHeightString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					
					//var vertical:String = componentInstance.getStyle("verticalAlign");
					var verticalAlign:String = componentInstance.verticalAlign;
					if (localName=="hgroup") {
						if (verticalAlign=="middle") {
							// warning - hack below!
							styleValue += "line-height:" + (componentInstance.height-2) + "px;"; 
						}
					}
					
					if (componentInstance is HGroup) {
						styleValue += "text-align:" + HGroup(componentInstance).horizontalAlign + ";";
						// we need whitespace for the hgroup but not inherited
						//styleValue += "white-space:" + "nowrap;";
						
						/*
						#parent {
							white-space: nowrap;
						}
						
						#parent * {
							white-space: initial;
						}
						*/
					}
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					layoutOutput += properties ? " " : "";
					stylesOut = styleValue;
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += contentToken;
					layoutOutput += "\n" + tabs + "</div>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="button" || localName=="togglebutton") {
					htmlName = "button";
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<input " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += " type=\"" + htmlName.toLowerCase() + "\"" ;
					layoutOutput += properties ? " " + properties : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					stylesOut = styleValue;
					
					layoutOutput += " value=\"" + componentInstance.label + "\"";
					//layoutOutput += " class=\"buttonSkin\"";
					
					layoutOutput += setStyles(componentInstance, styleValue);
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="videoplayer") {
					htmlName = "video";
					
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					
					layoutOutput += "<" +htmlName+ " ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					layoutOutput += " controls "  + properties;
					
					
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					//styleValue += "padding:2px;";
					
					var borderColor:String = componentInstance.getStyle("borderColor");
					
					if (borderColor!=null) {
						styleValue += "border:1px solid " + DisplayObjectUtils.getColorInHex(uint(borderColor), true) + ";";
					}
					
					stylesOut = styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					
					if (componentInstance.source) {
						layoutOutput += "\n" + tabs + "<source>" + componentInstance.source + "</source>";
					}
					
					layoutOutput += tabs + "</" + htmlName + ">";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="checkbox") {
					htmlName = localName;
					
					if (componentInstance.label!="") {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<label ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput, "_Label");
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						//styleValue += "width:" + (componentInstance.width + 6)+ "px;";
						//styleValue += "height:" + componentInstance.height+ "px;";
						styleValue = getFontFamily(componentInstance, styleValue);
						styleValue = getFontWeight(componentInstance, styleValue);
						styleValue = getFontSize(componentInstance, styleValue);
						styleValue = getFontColor(componentInstance, styleValue);
						stylesOut = styleValue;
						
						layoutOutput += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						//layoutOutput += styleValue;
						layoutOutput += "<input ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput += " type=\"" + htmlName.toLowerCase() + "\" ";
						layoutOutput += "/>" ;
					}
					else {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<input " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						layoutOutput += " type=\"" + htmlName.toLowerCase() + "\" " + properties;
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
						stylesOut = styleValue;
						layoutOutput += setStyles(componentInstance, styleValue);
					}
					
					if (componentInstance.label!="") {
						layoutOutput += " " + componentInstance.label + "</label>";
					}
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="radiobutton") {
					htmlName = "radio";
					if (componentInstance.label!="") {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<label ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput, "_Label");
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						//styleValue += "width:" + (componentInstance.width + 8)+ "px;";
						//styleValue += "height:" + componentInstance.height+ "px;";
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						styleValue = getFontFamily(componentInstance, styleValue);
						styleValue = getFontWeight(componentInstance, styleValue);
						styleValue = getFontSize(componentInstance, styleValue);
						styleValue = getFontColor(componentInstance, styleValue);
						//output += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						stylesOut = styleValue;
						
						layoutOutput += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						layoutOutput += "<input type=\"radio\" " ;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
						layoutOutput += "/>" ;
					}
					else {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<input type=\"" + htmlName.toLowerCase() + "\" " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
						stylesOut = styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
					}
					
					if (componentInstance.label!="") {
						layoutOutput += " " + componentInstance.label + "</label>";
					}
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="textinput" || localName=="combobox" || localName=="numericstepper"
						|| localName=="datefield" || localName=="colorpicker" 
						|| localName=="hslider" || localName=="vslider" ) {
					
					htmlName = "input";
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					
					layoutOutput += "<" +htmlName+ " ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					if ("prompt" in componentInstance && componentInstance.prompt) {
						layoutOutput += " placeholder=\"" + componentInstance.prompt + "\"";
					}
					
					if (localName=="textinput" && "displayAsPassword" in componentInstance && componentInstance.displayAsPassword) {
						layoutOutput += " type=\"password\" "  + properties;
					}
					else if (localName=="textinput" || localName=="combobox") {
						layoutOutput += " type=\"input\" "  + properties;
					}
					else if (localName=="numericstepper") {
						layoutOutput += " type=\"number\" "  + properties;
					}
					else if (localName=="datefield") {
						layoutOutput += " type=\"date\" "  + properties;
					}
					else if (localName=="colorpicker") {
						layoutOutput += " type=\"color\" "  + properties;
					}
					else if (localName=="hslider") {
						layoutOutput += " type=\"range\" "  + properties;
					}
					else if (localName=="vslider") {
						layoutOutput += " type=\"range\" "  + properties;
						layoutOutput += " orient=\"vertical\"";
					}
					
					
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					//styleValue += "padding:2px;";
					
					if (localName=="vslider") {
						styleValue += "writing-mode: bt-lr;";
					}
					
					borderColor = componentInstance.getStyle("borderColor");
					
					if (borderColor!=null) {
						styleValue += "border:1px solid " + DisplayObjectUtils.getColorInHex(uint(borderColor), true) + ";";
					}
					
					if (localName=="combobox") {
						layoutOutput += " list=\"listdata\"";
						//<datalist id="listData">
						  //<option value="value 1">
						  //<option value="value 2">
						  //<option value="value 3">
						//</datalist> 
					}
					else if (localName=="numericstepper") {
						layoutOutput += " min=\"" + NumericStepper(componentInstance).minimum + "\"";
						layoutOutput += " max=\"" + NumericStepper(componentInstance).maximum + "\"";
						layoutOutput += " quantity=\"" + NumericStepper(componentInstance).value + "\"";
						
						if (NumericStepper(componentInstance).maxChars!=0) {
							layoutOutput += " maxlength=\"" + NumericStepper(componentInstance).maxChars + "\"";
						}
						
						if (NumericStepper(componentInstance).stepSize!=0) {
							//layoutOutput += " step=\"" + NumericStepper(componentInstance).stepSize + "\"";
						}
					}
					
					stylesOut = styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="dropdownlist" || localName=="list") {
					htmlName = "select";
					
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<select ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += " type=\"input\" "  + properties;
					
					if ("allowMultipleSelection" in componentInstance && componentInstance.allowMultipleSelection) {
						layoutOutput += " multiple=\"multiple\"";
					}
					
					if (localName=="list" && ListBase(componentInstance).layout is VerticalLayout) {
						layoutOutput += " size=\"" + VerticalLayout(componentInstance.layout).rowCount + "\"";
					}
					
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue += "padding:0;border:1px solid " + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("borderColor"), true) + ";";
					
					stylesOut = styleValue;
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += "</select>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="label" || localName=="hyperlink" || localName=="textarea" || localName=="richtext") {
					
					if (localName=="label") {
						// we may want to use "p" but rendering and layout is slightly different
						htmlName = "label";
					}
					else if (localName=="textarea") {
						htmlName = "textarea";
					}
					else if (localName=="richtext") {
						htmlName = "p";
					}
					else if (localName=="hyperlink") {
						htmlName = "a";
					}
					
					if (useWrapperDivs) {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						layoutOutput = tabs;
					}
					
					layoutOutput += "<" + htmlName + " "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					//styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue = getWidthString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					//styleValue += wrapperTagStyles;
					//
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getLineHeight(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					
					var marginTop:int = getMarginTopAdjustment(componentInstance, isVerticalCenterSet);
					styleValue += "margin-top:" + marginTop + "px;";
					
					if (componentInstance.getStyle("typographicCase")!="default") {
						styleValue += "text-transform:" + componentInstance.getStyle("typographicCase") + ";";
					}
					if (componentInstance.getStyle("trackingLeft")!=0 && componentInstance.getStyle("trackingRight")!=0) {
						tracking = Number(componentInstance.getStyle("trackingLeft") + componentInstance.getStyle("trackingRight"));
						styleValue += "letter-spacing:" + tracking + "px;";
					}
					//styles += getBorderString(componentInstance as IStyleClient);
					
					layoutOutput += properties ? " " : "";
					
					if (localName=="hyperlink") {
						if (componentInstance.url) {
							layoutOutput += " " + getAttribute("href", componentInstance.url);
						}
						
						if (componentInstance.target) {
							layoutOutput += " " + getAttribute("target", componentInstance.target);
						}
					}
					
					// remove wrapperTagStyles since we are trying to not use wrapper tags
					//output += setStyles(componentInstance, styleValue+wrapperTagStyles);
					//output += setStyles(componentInstance, wrapperTagStyles + styleValue);
					stylesOut = wrapperTagStyles + styleValue;
					layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					
					if (localName=="richtext") {
						htmlName = "p";
						//layoutOutput += TextConverter.export(RichText(componentInstance).textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE);
						var test:Object = TextConverter.export(RichText(componentInstance).textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.XML_TYPE);
						var content:XML = test.children()[0].children()[0].children()[0].children()[0];
						
						if (content) {
							layoutOutput += content.toXMLString();
						}
					}
					else {
						layoutOutput += componentInstance.text;
					}
					
					layoutOutput += "</" + htmlName + ">";
					
					if (useWrapperDivs) {
						layoutOutput += getWrapperTag(wrapperTag, true);
					}
				}
				else if (localName=="hyperlink") {
					htmlName = "a";
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<a "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					//styles += getBorderString(componentInstance as IStyleClient);
					
					layoutOutput += properties ? " " : "";
					stylesOut = styleValue;
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += componentInstance.text;
					layoutOutput += "</a>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="image") {
					layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<img " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
					styleValue += getVisibleDisplay(componentInstance);
					layoutOutput += properties ? " " : "";
					
					if (componentInstance.source is BitmapData && createImageDataForGraphics) {
						layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance.source, "jpeg") + "\"";
					}
					else if (componentInstance.source is String) {
						layoutOutput += " src=\"" + componentInstance.source + "\"";
					}
					
					stylesOut = styleValue;
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="spacer") {
					//move to image
					// show placeholder NOT actual component
					htmlName = "div";
					if (useWrapperDivs) {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						layoutOutput = tabs;
					}
					layoutOutput += "<div "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					layoutOutput += properties ? " " : "";
					//output += setStyles(componentInstance, wrapperTagStyles+styleValue);
					stylesOut = wrapperTagStyles + styleValue;
					layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					//output += "&#160;"
					layoutOutput += "</div>";
					if (useWrapperDivs) {
						layoutOutput += getWrapperTag(wrapperTag, true);
					}
				}
				else {
					errorData = new ErrorData();
					errorData.description = component.name + " is not supported in HTML export at this time.";
					errorData.label = "Unsupported component";
					errors.push(errorData);
					
					// show placeholder NOT actual component
					htmlName = "label";
					if (useWrapperDivs) {
						layoutOutput = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						layoutOutput = tabs;
					}
					layoutOutput += "<label "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					//styleValue += "width:" + componentInstance.width+ "px;";
					//styleValue += "height:" + componentInstance.height+ "px;";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					//styleValue += wrapperTagStyles;
					styleValue += "color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("color"), true) + ";";
					
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getLineHeight(componentInstance, styleValue, true);
					//styles += getBorderString(componentInstance as IStyleClient);
					
					layoutOutput += properties ? " " : "";
					// remove wrapperTagStyles since we are trying to not use wrapper tags
					//output += setStyles(componentInstance, styleValue+wrapperTagStyles);
					//output += setStyles(componentInstance, wrapperTagStyles+styleValue);
					stylesOut = wrapperTagStyles + styleValue;
					layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					layoutOutput += getIdentifierOrName(componentInstance);
					layoutOutput += "</label>";
					if (useWrapperDivs) {
						layoutOutput += getWrapperTag(wrapperTag, true);
					}
					/*
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<" + htmlName.toLowerCase()  + " " + properties;
					output = getIdentifierAttribute(componentInstance, output);
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalSet);
					output += properties ? " " : "";
					output += setStyles(componentInstance, styleValue);
					output += getWrapperTag(wrapperTag, true);*/
				}
				
				var newLine:String = "\n";
				if (localName=="application" && !addContainerDiv) {
					newLine = "";
					//tabs = "";
				}
				else {
					tabs = tabs + "\t";
				}
				
				// add children
				if (component.children && component.children.length>0) {
					//output += ">\n";
					
					for (var i:int;i<component.children.length;i++) {
						componentChild = component.children[i];
						getAppliedPropertiesFromHistory(iDocument, componentChild);
						if (i>0) {
							childContent += "\n";
						}
						childContent += getHTMLOutputString(iDocument, componentChild, false, tabs);
					}
					
					component.markupData = layoutOutput;
					component.stylesData = stylesOut;
					
					layoutOutput = layoutOutput.replace(contentToken, newLine + childContent);
					
					component.processedMarkupData = layoutOutput;
					component.processedStylesData = stylesOut;

				}
				else {
					component.markupData = layoutOutput;
					component.stylesData = stylesOut;
					
					layoutOutput = layoutOutput.replace(contentToken, "\n");
					
					component.processedMarkupData = layoutOutput;
					component.processedStylesData = stylesOut;
				}
			}
			else {
				layoutOutput = "";
			}
			
			if (identity && identity.toLowerCase()=="theloop") {
				layoutOutput = "\n" + initialTabs + "<!--the loop-->" + layoutOutput + "\n" + initialTabs + "<!--the loop-->";
			}
			
			return layoutOutput;
		}
		
		/**
		 * Gets the font family if defined inline
		 * */
		public function getFontFamily(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			
			if (getInherited || (styleClient.styleDeclaration && "fontFamily" in styleClient.styleDeclaration.overrides)) {
				styleValue += "font-family:" + FontUtils.getSanitizedFontName(componentInstance) + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font weight if defined inline
		 * */
		public function getFontWeight(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			
			if (getInherited || (styleClient.styleDeclaration && "fontWeight" in styleClient.styleDeclaration.overrides)) {
				styleValue += "font-weight:" + styleClient.getStyle("fontWeight") + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font color if defined inline
		 * */
		public function getFontColor(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			
			if (getInherited || (styleClient.styleDeclaration && "color" in styleClient.styleDeclaration.overrides)) {
				styleValue += "color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("color"), true) + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font size if defined inline
		 * */
		public function getFontSize(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			
			if (getInherited || (styleClient.styleDeclaration && "fontSize" in styleClient.styleDeclaration.overrides)) {
				styleValue += "font-size:" + styleClient.getStyle("fontSize") + "px;"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the line height if defined inline
		 * */
		public function getLineHeight(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			
			if (getInherited || (styleClient.styleDeclaration && "lineHeight" in styleClient.styleDeclaration.overrides)) {
				styleValue += "line-height:" + parseInt(styleClient.getStyle("lineHeight"))/100+ ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Centering vertically
		 * */
		public function centerVertically():void {
			/*
			.container {
				position: absolute;
				display: table;
				width: 100%;
				height: 100%;
			}
			.containerElement{
				display: table-cell;
				vertical-align: middle;
			}
			*/
		}
		
		/**
		 * See note on #paddingFromBrowserTextEngine.
		 * If in vertically centered box the browser seems to align it correctly. 
		 * Otherwise large fonts are pushed down 
		 * @see #paddingFromBrowserTextEngine
		 * */
		private function getMarginTopAdjustment(componentInstance:Object, isVerticalCenterSet:Boolean):int {
			var fontSize:Number = componentInstance.getStyle("fontSize");
			var marginTop:int = fontSize > 18 ? fontSize * paddingFromBrowserTextEngine * -1 : 0;
			
			if (isVerticalCenterSet) {
				return 0;
			}
			
			return marginTop;
		}		
		
		/**
		 * Get a tag with less than or greater than wrapped around it. 
		 * */
		private function getWrapperTag(wrapperTag:String = "", end:Boolean = false, styles:String = ""):String {
			var output:String = "";
			
			if (wrapperTag=="") return "";
			
			if (end) {
				output = "</" + wrapperTag + ">";
				return output;
			}
			
			output += "<" + wrapperTag;
			
			if (styles) {
				output += " style=\"" + styles + "\"" ;
			}
			
			output += ">";
			
			return output;
		}
		
		/**
		 * Get width and height styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function getSizeString(instance:IVisualElement, styleValue:String = "", isHorizontalAlignSet:Boolean = false, isVerticalSet:Boolean = false, fitToContent:Boolean = false):String {
			var hasExplicitSize:Boolean;
			var hasBorder:Boolean;
			var border:int;
			
			//if (instance is IStyleClient && IStyleClient(instance).getStyle("borderWeight")) {
				
			//}
			
			if (!isNaN(instance.percentWidth)) {
				styleValue += "width:" + instance.percentWidth + "%;";
			}
			else if ("explicitWidth" in instance) {
				if (Object(instance).explicitWidth!=null && !isNaN(Object(instance).explicitWidth)
					|| setExplicitSize) {
					styleValue += "width:" + instance.width + "px;";
					hasExplicitSize = true;
				}
			}
			else {
				//styleValue += "width:" + instance.width + "px;";
			}
			
			if (!isNaN(instance.percentHeight)) {
				styleValue += "height:" + instance.percentHeight + "%;";
			}
			else if ("explicitHeight" in instance) {
				if (Object(instance).explicitHeight!=null && !isNaN(Object(instance).explicitHeight)
					|| setExplicitSize) {
					styleValue += "height:" + instance.height + "px;";
					hasExplicitSize = true;
				}
			}
			else {
				//styleValue += "height:" + instance.height + "px;";
			}
			
			
			// If explicit width is set then we should use inline-block 
			// because inline does not respect width and height
			if (!isHorizontalAlignSet && hasExplicitSize) {
				styleValue += "display:" + Styles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get height styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function getHeightString(instance:Object, styleValue:String = "", isHorizontalCenterSet:Boolean = false, isVerticalCenterSet:Boolean = false, fitToContent:Boolean = false):String {
			var hasExplicitSize:Boolean;
			
			if (fitToContent) {
				return "";
			}
			
			// percent height causes some issues - have to figure out what the deal is
			if (!isNaN(instance.percentHeight)) {
				styleValue += "height:" + instance.percentHeight + "%;";
			}
			else if ("explicitHeight" in instance) {
				if (Object(instance).explicitHeight!=null && !isNaN(Object(instance).explicitHeight)) {
					styleValue += "height:" + instance.height + "px;";
					hasExplicitSize = true;
				}
			}
			
			
			// If explicit height is set then we should use inline-block 
			// because inline does not respect width and height
			if (!isVerticalCenterSet && hasExplicitSize) {
				styleValue += "display:" + Styles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get width styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function getWidthString(instance:Object, styleValue:String = "", isHorizontalAlignSet:Boolean = false, isVerticalSet:Boolean = false, fitToContent:Boolean = false):String {
			var hasExplicitSize:Boolean;
			
			if (fitToContent) {
				return "";
			}
			
			if (!isNaN(instance.percentWidth)) {
				styleValue += "width:" + instance.percentWidth + "%;";
			}
			else if ("explicitWidth" in instance) {
				if (Object(instance).explicitWidth!=null && !isNaN(Object(instance).explicitWidth)) {
					styleValue += "width:" + instance.width + "px;";
					hasExplicitSize = true;
				}
			}
			
			// If explicit width is set then we should use inline-block 
			// because inline does not respect width and height
			if (!isHorizontalAlignSet && hasExplicitSize) {
				styleValue += "display:" + Styles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get block display
		 * */
		public function getDisplayBlock(instance:Object = null):String {
			if (instance) {
				if (!instance.visible) {
					return "display:none;";
				}
			}
			
			return "display:block;";
		}
		
		/**
		 * Get visible display
		 * */
		public function getVisibleDisplay(instance:Object = null):String {
			if (instance) {
				if (!instance.visible) {
					return "display:none;";
				}
			}
			
			return "";
		}
		
		/**
		 * Get parent vertical align display
		 * */
		public function getParentVerticalAlign(value:String = null):String {
			return value ? "vertical-align:" + value + ";" : "";
		}
		
		/**
		 * Checks if size is explicitly set
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function hasExplicitSizeSet(instance:IVisualElement):Boolean {
			
			if ("explicitWidth" in instance && Object(instance).explicitWidth!=null) {
				return true;
			}
			else if ("explicitHeight" in instance && Object(instance).explicitHeight!=null) {
				return true;
			}
			
			return false;
		}
			
		/**
		 * Get the horizontal position string for HTML
		 * */
		public function getHorizontalPositionHTML(instance:IVisualElement, propertyModel:Styles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			// horizontal center trumps left and x properties
			if (instance.horizontalCenter!=null) {
				stylesValue += "display:block;margin:" + instance.horizontalCenter + " auto;left:0;right:0;";
				//stylesValue = stylesValue.replace("absolute", "relative");
				
				propertyModel.display = Styles.BLOCK;
				//propertyModel.position = Styles.RELATIVE;
				propertyModel.position = Styles.ABSOLUTE;
				propertyModel.margin = instance.horizontalCenter + " auto;left:0;right:0;";
				
				return stylesValue;
			}
			else if (instance.left!=null || instance.right!=null) {
				stylesValue += instance.left!=null ? "left:" + instance.left + "px;" : "";
				stylesValue += instance.right!=null ? "right:" + instance.right + "px;" : "";
				if (instance.left!=null) propertyModel.left = instance.left + "px";
				if (instance.right!=null) propertyModel.right = instance.right + "px";
				return stylesValue;
			}
			else {
				stylesValue += "left:" + instance.x + "px;";
				propertyModel.left = instance.x + "px;";
			}
			
			return stylesValue;
		}
		
			
		/**
		 * Get the vertical position string for HTML
		 * */
		public function getVerticalPositionHTML(instance:IVisualElement, propertyModel:Styles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			
			if (instance.verticalCenter!=null) {
				stylesValue += "display:block;margin:" + instance.verticalCenter + " auto;";
				stylesValue = stylesValue.replace("absolute", "relative");
				
				propertyModel.display = Styles.BLOCK;
				propertyModel.position = Styles.RELATIVE;
				propertyModel.margin = instance.verticalCenter + " auto;";
				
				return stylesValue;
			}
			else if (instance.top!=null || instance.bottom!=null) {
				stylesValue += instance.top!=null ? "top:" + instance.top + "px;" : "";
				stylesValue += instance.bottom!=null ? "bottom:" + instance.bottom + "px;" : "";
				if (instance.top!=null) propertyModel.top = instance.top + "px";
				if (instance.bottom!=null) propertyModel.bottom = instance.bottom + "px";
				return stylesValue;
			}
			else {
				stylesValue += "top:" + instance.y + "px;";
				propertyModel.top = instance.y + "px;";
			}
			
			return stylesValue;
		}
		
		/**
		 * Get border and background styles of a border container
		 * */
		public function getBorderString(element:IStyleClient):String {
			var value:String = "";
			var borderWeight:Number = element.getStyle("borderWeight");
			
			if (element.getStyle("backgroundAlpha")!=0) {
				value += "background-color:" + DisplayObjectUtils.getColorInRGB(element.getStyle("backgroundColor"), element.getStyle("backgroundAlpha")) + ";";
			}
			
			if (element.getStyle("borderVisible")) {
				var borderSides:String = element.getStyle("borderSides");
				
				value += "border-style:solid;";
				
				if (borderSides!="left top right bottom") {
					var borderValues:String = "";
					
					borderValues += (borderSides.indexOf("top")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("right")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("bottom")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("left")!=-1) ? borderWeight + "px" : "0px";
					
					value += "border-width:" + borderValues;
				}
				else {
					value += "border-width:" + borderWeight + "px;";
				}
				
				if (element.getStyle("borderColor")!==undefined) {
					value += "border-color:" + DisplayObjectUtils.getColorInHex(element.getStyle("borderColor"), true) + ";";
				}
				
				
			}
			
			if (element.styleDeclaration && "color" in element.styleDeclaration.overrides) {
				value += "color:" + DisplayObjectUtils.getColorInHex(element.getStyle("color"), true) + ";";
			}
			
			return value;
		}
		
		/**
		 * Get corner radius styles of a border container
		 * */
		public function getCornerRadiusString(element:IStyleClient):String {
			var value:String = "";
			
			if (element.getStyle("cornerRadius")!==undefined) {
				value += "border-radius: " + element.getStyle("cornerRadius") + ";";
			}
			
			return value;
		}
		
		/**
		 * Set styles. 
		 * */
		public function setStyles(component:Object, stylesValue:String = "", singleton:Boolean = false):String {
			var out:String = ">";
			var formatted:String;
			
			if (useInlineStyles) {
				return " style=\"" + stylesValue + "\"" + (singleton?"\>":">");
			}
			else {
				formatted= "\t" + stylesValue.replace(/;/g, ";\n\t");
				
				//styles += ";";
				//cssOutput += "#" + getIdentifierOrName(component) + "  {\n\n";
				//cssOutput += "" + styles.replace(/;/g, ";\n") + "\n\n}  ";
				
				if (component is String) {
					out = component + " {\n";
				}
				else {
					out = "#" + getIdentifierOrName(component) + "  {\n";
				}
				
				out += formatted;
				out += "}\n\n";
				
				out = out.replace(/\t}/g, "}");
				
				if (styles==null) styles = "";
				styles += out;
			}
			
			return (singleton?"\>":">");
		}
		
		/**
		 * Adds an tag. If you singleton is true then the tag returned is "/>" 
		 * if singleton is false then the tag returned is ">". 
		 * */
		public function endTag(component:Object, singleton:Boolean = false):String {
			var out:String = ">";
			
			return singleton ? "\>" : ">";
		}
		
		/**
		 * Wrap in style tags
		 * */
		public function wrapInStyleTags(value:String):String {
			var out:String = "<style type=\"text/css\">\n" + value + "\n</style>";
			return out;
		}
		
		/**
		 * Gets the ID of the target object
		 * 
		 * @param name if id is not available then if the name parameter is true then use name
		 * 
		 * returns id or name
		 * */
		public function getIdentifierOrName(element:Object, name:Boolean = true, appendID:String = ""):String {

			if (element && "id" in element && element.id) {
				return element.id + appendID;
			}
			else if (element && name && "name" in element && element.name) {
				return element.name + appendID;
			}
			
			return "";
		}
		
		/**
		 * Get style name or class attribute
		 * */
		public function getStyleNameAttribute(instance:Object, value:String = "", appendID:String = ""):String {
			var styleName:String = instance.styleName;
			
			if (styleName!=null && styleName!="") {
				value += value.charAt(value.length)!=" " ? " " : "";
				value += "class=\"" + styleName + "\"";
			}
			
			return value;
		}
		
		/**
		 * Get ID from ID or else name attribute
		 * */
		public function getIdentifierAttribute(instance:Object, value:String = "", appendID:String = ""):String {
			
			if (instance && "id" in instance && instance.id) {
				value += "id=\"" + instance.id + appendID + "\"";
			}
				
			else if (instance && "name" in instance && instance.name) {
				value += "id=\"" + instance.name + appendID + "\"";
			}
			
			return value;
		}
		
		/**
		 * Get url attribute
		 * */
		public function getAttribute(name:String, value:String = "", encode:Boolean = true):String {
			// need to encode to be inside attribute quotes
			value = "" + name + "=\"" + value + "\"";
			return value;
		}
		
		/**
		 * Get name and ID attribute
		 * */
		public function getIdentifierOrNameAttribute(instance:Object, propertyValue:String = ""):String {
			
			if (instance && "id" in instance && instance.id) {
				propertyValue += "id=\"" + instance.id + "\"";
			}
			
			if (instance && "name" in instance && instance.name) {
				propertyValue += "name=\"" + instance.name + "\"";
			}
			
			return propertyValue;
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
		
		/**
		 * Instead of this class generating the markup the markup is passed in 
		 * through the options parameter
		 * @see #export()
		 * */
		public var useCustomMarkup:Boolean;
		
		/**
		 * Any styles not set inline are placed in an external stylesheet
		 * */
		public var useExternalStylesheet:Boolean;
		
		/**
		 * Default file extension. Default is html. 
		 * This can be changed by setting the export options.
		 * */
		public var fileExtension:String = "html";
		private var addContainerDiv:Boolean;
		
		/**
		 * @inheritDoc
		 * */
		override public function getExportOptions():ExportOptions {
			exportOptions = new HTMLExportOptions();
			return exportOptions;
		}
		
	}
}