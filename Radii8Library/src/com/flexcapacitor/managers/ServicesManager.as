package com.flexcapacitor.managers
{
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.Project;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPAttachmentService;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.services.WPServiceEvent;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.utils.ArrayUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Image;
	import spark.primitives.BitmapImage;

	
	/**
	 * Dispatched when register results are received
	 * */
	[Event(name="registerResults", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on get project home page event
	 * */
	[Event(name="projectGetHomePage", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on set project home page event
	 * */
	[Event(name="projectSetHomePage", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when blog posts are received
	 * */
	[Event(name="blogPostsReceived", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Track changes
	 * */
	public class ServicesManager extends EventDispatcher {
		
		
		public function ServicesManager(s:SINGLEDOUBLE) {
			
		}
		
		public static const LOGGED_IN:String = "loggedIn";
		public static const LOGGED_OUT:String = "loggedOut";
		
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ServicesManager
		{
			if (!_instance) {
				_instance = new ServicesManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ServicesManager {
			return instance;
		}
		
		private static var _instance:ServicesManager;
		
		/**
		 * Reference to radiate
		 * */
		[Bindable]
		public var radiate:Radiate;
		
		/**
		 * Service to check if user is logged in
		 * */
		public var getLoggedInStatusService:WPService;
		
		/**
		 * Set to true when checking if user is logged in
		 * */
		[Bindable]
		public var getLoggedInStatusInProgress:Boolean;
		
		/**
		 * Upload attachment
		 * */
		public var uploadAttachmentService:WPAttachmentService;
		
		/**
		 * Service to get list of example projects
		 * */
		public var getExampleProjectsService:WPService;
		
		/**
		 * Set to true when getting list of example projects
		 * */
		[Bindable]
		public var getExampleProjectsInProgress:Boolean;
		
		/**
		 * Service to get list of attachments
		 * */
		public var getAttachmentsService:WPService;
		
		/**
		 * Service to get list of projects
		 * */
		public var getProjectsService:WPService;
		
		/**
		 * Service to get list of blog posts
		 * */
		public var getBlogPostsService:WPService;
		
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
		 * Service to request reset the password
		 * */
		public var lostPasswordService:WPService;
		
		/**
		 * Service to change the password
		 * */
		public var changePasswordService:WPService;
		
		/**
		 * Send feedback
		 * */
		public var sendFeedbackService:URLLoader;
		
		/**
		 * Service to login
		 * */
		public var loginService:WPService;
		
		/**
		 * Service to login through browser
		 * */
		public var loginThroughBrowserService:WPService;
		
		/**
		 * Service to logout
		 * */
		public var logoutService:WPService;
		
		/**
		 * Service to register
		 * */
		public var registerService:WPService;
		
		/**
		 * Get project home page
		 * */
		public var getProjectHomePageService:WPService;
		
		/**
		 * Set project home page
		 * */
		public var setProjectHomePageService:WPService;
		
		/**
		 * Set to true when set project home page is being sent to the server
		 * */
		[Bindable]
		public var setProjectHomePageInProgress:Boolean;
		
		/**
		 * Set to true when get project home page is in progress
		 * */
		[Bindable]
		public var getProjectHomePageInProgress:Boolean;
		
		/**
		 * Set to true when feedback is being sent to the server
		 * */
		[Bindable]
		public var sendFeedbackInProgress:Boolean;
		
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
		 * Set to true when lost password call is made
		 * */
		[Bindable]
		public var lostPasswordInProgress:Boolean;
		
		/**
		 * Set to true when changing password
		 * */
		[Bindable]
		public var changePasswordInProgress:Boolean;
		
		/**
		 * Set to true when registering
		 * */
		[Bindable]
		public var registerInProgress:Boolean;
		
		/**
		 * Set to true when logging in
		 * */
		[Bindable]
		public var loginInProgress:Boolean;
		
		/**
		 * Set to true when logging out
		 * */
		[Bindable]
		public var logoutInProgress:Boolean;
		
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
		 * Set to true when deleting an attachment
		 * */
		[Bindable]
		public var deleteAttachmentInProgress:Boolean;
		
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
		 * Set to true when getting list of blog posts
		 * */
		[Bindable]
		public var getBlogPostsInProgress:Boolean;
		
		/**
		 * Default storage location for save and load. 
		 * */
		[Bindable]
		public var defaultStorageLocation:String;
		
		/**
		 * Get project home page
		 * */
		public function getProjectHomePage():void {
			var service:WPService;
			
			// we need to create service
			if (getProjectHomePageService==null) {
				service = new WPService();
				service.host = Radiate.getWPURL();
				service.addEventListener(WPService.RESULT, getProjectHomePageResult, false, 0, true);
				service.addEventListener(WPService.FAULT, getProjectHomePageFault, false, 0, true);
				getProjectHomePageService = service;
			}
			
			getProjectHomePageInProgress = true;
			
			getProjectHomePageService.getProjectHomePage();
		}
		
		/**
		 * Handles get project home page result 
		 * */
		protected function getProjectHomePageResult(event:WPServiceEvent):void {
			
			getProjectHomePageInProgress = false;
			
			dispatchGetHomePageEvent(event.data);
		}
		
		/**
		 * Handles get project home page fault
		 * */
		protected function getProjectHomePageFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			getProjectHomePageInProgress = false;
			
			dispatchGetHomePageEvent(data);
		}
		
		/**
		 * Set project home page
		 * */
		public function setProjectHomePage(id:int):void {
			var service:WPService;
			
			// we need to create service
			if (setProjectHomePageService==null) {
				service = new WPService();
				service.host = Radiate.getWPURL();
				service.addEventListener(WPService.RESULT, setProjectHomePageResult, false, 0, true);
				service.addEventListener(WPService.FAULT, setProjectHomePageFault, false, 0, true);
				setProjectHomePageService = service;
			}
			
			setProjectHomePageInProgress = true;
			
			setProjectHomePageService.setProjectHomePage(id);
		}
		
		/**
		 * Handles set project home page result 
		 * */
		protected function setProjectHomePageResult(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			setProjectHomePageInProgress = false;
			
			dispatchSetHomePageEvent(data);
		}
		
		/**
		 * Handle set project home page fault
		 * */
		protected function setProjectHomePageFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			setProjectHomePageInProgress = false;
			
			dispatchSetHomePageEvent(data);
		}
		
		/**
		 * Get projects
		 * */
		public function getLoggedInStatus():void {
			// get selected document
			var service:WPService;
			
			// we need to create service
			if (getProjectsService==null) {
				service = new WPService();
				service.host = Radiate.getWPURL();
				service.addEventListener(WPService.RESULT, getLoggedInStatusResult, false, 0, true);
				service.addEventListener(WPService.FAULT, getLoggedInStatusFault, false, 0, true);
				getLoggedInStatusService = service;
			}
			
			getLoggedInStatusInProgress = true;
			
			getLoggedInStatusService.getLoggedInUser();
		}
		
		/**
		 * Handles result to check if user is logged in 
		 * */
		protected function getLoggedInStatusResult(event:WPServiceEvent):void {
			radiate.isUserConnected = true;
			
			var data:Object = event.data;
			
			radiate.updateUserInfo(data);
			
			getLoggedInStatusInProgress = false;
			
			dispatchLoginStatusEvent(radiate.isUserLoggedIn, data);
		}
		
		/**
		 * Handles fault when checking if user is logged in
		 * */
		protected function getLoggedInStatusFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			radiate.isUserConnected = false;
			//isUserLoggedIn = false;
			
			getLoggedInStatusInProgress = false;
			
			dispatchLoginStatusEvent(radiate.isUserLoggedIn, data);
		}
		
		/**
		 * Get example projects
		 * */
		public function getExampleProjects(status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			if (status==null) status = WPService.STATUS_ANY;
			var loadLocally:Boolean = locations.indexOf(DocumentData.LOCAL_LOCATION)!=-1;
			var loadRemote:Boolean = locations.indexOf(DocumentData.REMOTE_LOCATION)!=-1;
			
			
			if (loadRemote) {
				// we need to create service
				if (getExampleProjectsService==null) {
					var service:WPService = new WPService();
					service.host = Radiate.getExamplesWPURL();
					service.addEventListener(WPService.RESULT, getExampleProjectsResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, getExampleProjectsFaultHandler, false, 0, true);
					getExampleProjectsService = service;
				}
				
				getExampleProjectsInProgress = true;
				
				getExampleProjectsService.getProjects(WPService.STATUS_PUBLISH, count);
				
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get blog posts 
		 * */
		public function getBlogPostsByCategory(category:String, status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = locations.indexOf(DocumentData.LOCAL_LOCATION)!=-1;
			var loadRemote:Boolean = locations.indexOf(DocumentData.REMOTE_LOCATION)!=-1;
			
			
			if (loadRemote) {
				// we need to create service
				if (getBlogPostsService==null) {
					var service:WPService = new WPService();
					service = new WPService();
					service.host = Radiate.getWPURL();
					service.addEventListener(WPService.RESULT, getBlogPostsResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, getBlogPostsFaultHandler, false, 0, true);
					getBlogPostsService = service;
				}
				
				getBlogPostsInProgress = true;
				
				getBlogPostsService.getPostsByCategory(category, count);
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get projects 
		 * */
		public function getProjects(status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = locations.indexOf(DocumentData.LOCAL_LOCATION)!=-1;
			var loadRemote:Boolean = locations.indexOf(DocumentData.REMOTE_LOCATION)!=-1;
			
			
			if (loadRemote) {
				// we need to create service
				if (getProjectsService==null) {
					var service:WPService = new WPService();
					service = new WPService();
					service.host = Radiate.getWPURL();
					service.addEventListener(WPService.RESULT, getProjectsResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, getProjectsFaultHandler, false, 0, true);
					getProjectsService = service;
				}
				
				getProjectsInProgress = true;
				
				getProjectsService.getProjects(status, count);
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get projects by user ID
		 * */
		public function getProjectsByUser(id:int, status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			if (status==null) status = WPService.STATUS_ANY;
			var loadLocally:Boolean = locations.indexOf(DocumentData.LOCAL_LOCATION)!=-1;
			var loadRemote:Boolean = locations.indexOf(DocumentData.REMOTE_LOCATION)!=-1;
			
			
			if (loadRemote) {
				// we need to create service
				if (getProjectsService==null) {
					var service:WPService = new WPService();
					service.host = Radiate.getWPURL();
					service.addEventListener(WPService.RESULT, getProjectsResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, getProjectsFaultHandler, false, 0, true);
					getProjectsService = service;
				}
				
				getProjectsInProgress = true;
				
				getProjectsService.getProjectsByUser(id, status, count);
				
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Send feedback
		 * */
		public function sendFeedback(message:Object):void {
			
			// we need to create service
			if (sendFeedbackService==null) {
				sendFeedbackService = new URLLoader();
				sendFeedbackService.dataFormat = URLLoaderDataFormat.TEXT;
				sendFeedbackService.addEventListener(Event.COMPLETE, sendFeedbackHandler, false, 0, true);
				sendFeedbackService.addEventListener(SecurityErrorEvent.SECURITY_ERROR, sendFeedbackHandler, false, 0, true);
				sendFeedbackService.addEventListener(IOErrorEvent.IO_ERROR, sendFeedbackHandler, false, 0, true);
			}
			
			var request:URLRequest = new URLRequest(Radiate.CONTACT_FORM_URL);
			request.data = message;
			request.method = URLRequestMethod.POST;
			
			sendFeedbackInProgress = true;
			
			sendFeedbackService.load(request);
			
		}
		
		
		/**
		 * Login user 
		 * */
		public function login(username:String, password:String):void {
			
			// we need to create service
			if (loginService==null) {
				loginService = new WPService();
				loginService.addEventListener(WPService.RESULT, loginResultsHandler, false, 0, true);
				loginService.addEventListener(WPService.FAULT, loginFaultHandler, false, 0, true);
			}
			
			loginService.host = Radiate.getWPURL();
				
			loginInProgress = true;
			
			loginService.loginUser(username, password);
			
		}
		
		
		
		/**
		 * Login user through browser
		 * */
		public function loginThroughBrowser(username:String, password:String, remember:Boolean = false, window:String = null):void {
			var useNavigate:Boolean = true;
			
			// we need to create service
			if (loginThroughBrowserService==null) {
				loginThroughBrowserService = new WPService();
			}
			
			if (useNavigate) {
				var url:String = Radiate.getWPURL() + "?json=" + loginThroughBrowserService.loginUserURL;
				var variables:URLVariables = new URLVariables();
				variables.log = encodeURIComponent(username);
				variables.pwd = encodeURIComponent(password);
				variables.rememberme = remember;
				
				var request:URLRequest = new URLRequest(url);
				request.contentType = "application/x-www-form-urlencoded";
				request.data = variables;
				request.method = URLRequestMethod.POST;
				
				navigateToURL(request, window);
				return;
			}
			
			
			loginThroughBrowserService.useNavigateToURL = true;
			loginThroughBrowserService.windowName = window;
			//var rhArray:Array = new Array(new URLRequestHeader("Content-Type", "text/html"));
			// request.requestHeaders
			// request.contentType = "application/x-www-form-urlencoded";
			loginThroughBrowserService.host = Radiate.getWPURL();
			
			
			loginThroughBrowserService.loginUser(username, password);
			
			/**/
		}
		
		/**
		 * Logout user 
		 * */
		public function logout():void {
			
			// we need to create service
			if (logoutService==null) {
				logoutService = new WPService();
				logoutService.addEventListener(WPService.RESULT, logoutResultsHandler, false, 0, true);
				logoutService.addEventListener(WPService.FAULT, logoutFaultHandler, false, 0, true);
			}
			
			logoutService.host = Radiate.getWPURL();
			
			logoutInProgress = true;
			
			logoutService.logoutUser();
			
		}
		
		/**
		 * Register user 
		 * */
		public function register(username:String, email:String):void {
			
			// we need to create service
			if (registerService==null) {
				registerService = new WPService();
				registerService.addEventListener(WPService.RESULT, registerResultsHandler, false, 0, true);
				registerService.addEventListener(WPService.FAULT, registerFaultHandler, false, 0, true);
			}
			
			registerService.host = Radiate.getWPURL();
			
			registerInProgress = true;
			
			registerService.registerUser(username, email);
			
		}
		
		/**
		 * Register site 
		 * */
		public function registerSite(blogName:String = "", blogTitle:String = "", isPublic:Boolean = false):void {
			
			// we need to create service
			if (registerService==null) {
				registerService = new WPService();
				registerService.addEventListener(WPService.RESULT, registerResultsHandler, false, 0, true);
				registerService.addEventListener(WPService.FAULT, registerFaultHandler, false, 0, true);
			}
			
			registerService.host = Radiate.getWPURL();
			
			registerInProgress = true;
			
			registerService.registerSite(blogName, blogTitle, isPublic);
			
		}
		
		/**
		 * Register user and site 
		 * */
		public function registerUserAndSite(username:String, email:String, siteName:String = "", blogTitle:String = "", isPublic:Boolean = false, requireSiteName:Boolean = false):void {
			
			// we need to create service
			if (registerService==null) {
				registerService = new WPService();
				registerService.addEventListener(WPService.RESULT, registerResultsHandler, false, 0, true);
				registerService.addEventListener(WPService.FAULT, registerFaultHandler, false, 0, true);
			}
			
			registerService.host = Radiate.getWPURL();
			
			registerInProgress = true;
			
			if (!requireSiteName) {
				if (siteName=="") {
					siteName = username;
				}
				
				if (blogTitle=="") {
					blogTitle = "A Radiate site";
				}
			}
			
			registerService.registerUserAndSite(username, email, siteName, blogTitle, isPublic);
			
		}
		
		/**
		 * Request lost password. Sends an email with instructions. 
		 * @param username or email address
		 * */
		public function lostPassword(usernameOrEmail:String):void {
			
			// we need to create service
			if (lostPasswordService==null) {
				lostPasswordService = new WPService();
				lostPasswordService.addEventListener(WPService.RESULT, lostPasswordResultsHandler, false, 0, true);
				lostPasswordService.addEventListener(WPService.FAULT, lostPasswordFaultHandler, false, 0, true);
			}
			
			lostPasswordService.host = Radiate.getWPURL();
				
			lostPasswordInProgress = true;
			
			lostPasswordService.lostPassword(usernameOrEmail);
			
		}
		
		/**
		 * Reset or change password
		 * */
		public function changePassword(key:String, username:String, password:String, password2:String):void {
			
			// we need to create service
			if (changePasswordService==null) {
				changePasswordService = new WPService();
				changePasswordService.addEventListener(WPService.RESULT, changePasswordResultsHandler, false, 0, true);
				changePasswordService.addEventListener(WPService.FAULT, changePasswordFaultHandler, false, 0, true);
			}
			
			changePasswordService.host = Radiate.getWPURL();
				
			changePasswordInProgress = true;
			
			changePasswordService.resetPassword(key, username, password, password2);
			
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
			
			getAttachmentsService.host = Radiate.getWPURL();
			
			if (id!=0) {
				getAttachmentsService.id = String(id);
			}
			
			getAttachmentsInProgress = true;
			
			
			getAttachmentsService.getAttachments(id);
		}
		
		/**
		 * Upload image to the server
		 * */
		public function uploadAttachment(data:Object, id:String, fileName:String = null, dataField:String = null, contentType:String = null):void {
			// get selected document
			
			// we need to create service
			if (uploadAttachmentService==null) {
				uploadAttachmentService = new WPAttachmentService();
				uploadAttachmentService.addEventListener(WPService.RESULT, uploadAttachmentResultsHandler, false, 0, true);
				uploadAttachmentService.addEventListener(WPService.FAULT, uploadAttachmentFaultHandler, false, 0, true);
				//uploadAttachmentService = service;
			}
			
			uploadAttachmentService.host = Radiate.getWPURL();
		
			if (id!=null) {
				uploadAttachmentService.id = id;
			}
			
			uploadAttachmentInProgress = true;
			
			if (data is FileReference) {
				uploadAttachmentService.file = data as FileReference;
				uploadAttachmentService.uploadAttachment();
			}
			else if (data) {
				uploadAttachmentService.fileData = data as ByteArray;
				
				if (fileName) {
					uploadAttachmentService.fileName = fileName;
				}
				
				if (dataField) {
					uploadAttachmentService.dataField = dataField;
				}
				
				if (contentType) {
					uploadAttachmentService.contentType = contentType;
				}
				
				uploadAttachmentService.uploadAttachment();
			}
			else {
				Radiate.warn("No data or file is available for upload. Please select the file to upload.");
			}
			
		}
		
		
		/*********************************************************/
		
		
		/**
		 * Add an asset
		 * */
		public function addAssets(data:Array, dispatchEvents:Boolean = true):void {
			var length:int;
			var added:Boolean;
			
			if (data) {
				length = data.length;
				
				for (var i:int;i<length;i++) {
					addAsset(data[i], dispatchEvents);
				}
				
			}
			
		}
		
		/**
		 * Add an asset
		 * */
		public function addAsset(data:DocumentData, dispatchEvent:Boolean = true):void {
			var length:int = radiate.assets.length;
			var found:Boolean;
			var item:DocumentData;
			
			for (var i:int;i<length;i++) {
				item = radiate.assets.getItemAt(i) as DocumentData;
				
				if (item.id==data.id && item.id!=null) {
					found = true;
					break;
				}
			}
			
			if (!found) {
				radiate.assets.addItem(data);
			}
			
			if (!found && dispatchEvent) {
				dispatchAssetAddedEvent(data);
			}
		}
		
		/**
		 * Remove an asset
		 * */
		public function removeAsset(iDocumentData:IDocumentData, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = getIsRemoteLocation(locations);
			var index:int = radiate.assets.getItemIndex(iDocumentData);
			var removedInternally:Boolean;
			
			if (index!=-1) {
				radiate.assets.removeItemAt(index);
				removedInternally = true;
			}
			
			if (remote && iDocumentData && iDocumentData.id) { 
				// we need to create service
				if (deleteAttachmentService==null) {
					deleteAttachmentService = new WPService();
					deleteAttachmentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteAttachmentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteAttachmentService.host = Radiate.getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteAttachmentService.deleteAttachment(int(iDocumentData.id), true);
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
			
			dispatchAssetRemovedEvent(iDocumentData, removedInternally);
			
			return removedInternally;
		}
		
		//----------------------------------
		//
		//  EVENT HANDLERS
		// 
		//----------------------------------
		
		
		/**
		 * Project opened result handler
		 * */
		public function projectOpenResultHandler(event:Event):void {
			var iProject:IProject = event.currentTarget as IProject;
			
			// add assets
			addAssets(iProject.assets);
			
			if (iProject is EventDispatcher) {
				EventDispatcher(iProject).removeEventListener(Project.PROJECT_OPENED, projectOpenResultHandler);
			}
			
			radiate.dispatchProjectOpenedEvent(iProject);
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
		 * Results from call to get blog posts
		 * */
		public function getBlogPostsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getBlogPostsInProgress = false;
			
			dispatchGetBlogPostsResultsEvent(data);
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getExampleProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getExampleProjectsInProgress = false;
			
			dispatchGetExampleProjectsListResultsEvent(data);
		}
		
		/**
		 * Result example projects fault
		 * */
		public function getExampleProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			Radiate.info("Could not get list of example projects");
			
			getExampleProjectsInProgress = false;
			
			dispatchGetExampleProjectsListResultsEvent(data);
		}
		
		/**
		 * Result from get projects fault
		 * */
		public function getProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			Radiate.info("Could not get list of projects");
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Result from get blog posts fault
		 * */
		public function getBlogPostsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			Radiate.info("Could not get list of blog posts. Check to make sure you are online. ");
			
			getBlogPostsInProgress = false;
			
			dispatchGetBlogPostsResultsEvent(data);
		}
		
		/**
		 * Result get attachments
		 * */
		public function getAttachmentsResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Retrieved list of attachments");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var length:int;
			var object:Object;
			var attachment:AttachmentData;
			
			if (data && data.count>0) {
				length = data.count;
				
				for (var i:int;i<length;i++) {
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
			
			radiate.attachments = potentialAttachments;
			
			dispatchAttachmentsResultsEvent(true, radiate.attachments);
		}
		
		/**
		 * Result from attachments fault
		 * */
		public function getAttachmentsFaultHandler(event:IServiceEvent):void {
			
			Radiate.info("Could not get list of attachments. Check to make sure you are online.");
			
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
			var potentialAttachments:Array = [];
			var successful:Boolean = data && data.status && data.status=="ok" ? true : false;
			var length:int;
			var object:Object;
			var attachment:AttachmentData;
			var asset:AttachmentData;
			var remoteAttachments:Array = data && data.post && data.post.attachments ? data.post.attachments : []; 
			var containsName:Boolean;
			var assetsLength:int;
			
			if (remoteAttachments.length>0) {
				length = remoteAttachments.length;
				
				for (var i:int;i<length;i++) {
					object = remoteAttachments[i];
					
					if (String(object.mime_type).indexOf("image/")!=-1) {
						attachment = new ImageData();
						attachment.unmarshall(object);
					}
					else {
						attachment = new AttachmentData();
						attachment.unmarshall(object);
					}
					
					potentialAttachments.push(attachment);
					
					//attachments = potentialAttachments;
					assetsLength = radiate.assets.length;
					j = 0;
					
					for (var j:int;j<assetsLength;j++) {
						asset = radiate.assets.getItemAt(j) as AttachmentData;
						containsName = asset ? asset.name.indexOf(attachment.name)==0 : false;
						
						// this is not very robust but since uploading only supports one at a time 
						// it should be fine. when supporting multiple uploading, keep
						// track of items being uploaded
						if (containsName && asset.id==null) {
							asset.unmarshall(attachment);
							
							var documentLength:int = radiate.documents.length;
							k = 0;
							
							for (var k:int;k<documentLength;k++) {
								var iDocument:IDocument = radiate.documents[k] as IDocument;
								
								if (iDocument) {
									DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, replaceBitmapData, [asset]);
								}
							}
							
							break;
						}
					}
				}
			}
			
			
			uploadAttachmentInProgress = false;
			
			dispatchUploadAttachmentResultsEvent(successful, potentialAttachments, data.post);
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
					if (instance.source == imageData.bitmapData) {
						Radiate.setProperty(instance, "source", imageData.url);
					}
				}
			}
		}
		
		/**
		 * Result from upload attachment fault
		 * */
		public function uploadAttachmentFaultHandler(event:IServiceEvent):void {
			Radiate.info("Upload attachment fault");
			
			uploadAttachmentInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchUploadAttachmentResultsEvent(false, [], event.data);
		}
		
		/**
		 * Feedback form results handler
		 * */
		public function sendFeedbackHandler(event:Object):void {
			//Radiate.info("Feedback results");
			var type:String = event.type;
			var data:Object;
			var successful:Boolean;
			var success:String = "Mail sent";
			var loader:URLLoader;
			
			if (type==Event.COMPLETE) {
				loader = event.currentTarget as URLLoader;
				data = loader.data;
				
				if (data && String(data).toLowerCase().indexOf("Mail sent")!=-1) {
					successful = data.success==true;
				}
			}
			
			sendFeedbackInProgress = false;
			
			
			dispatchFeedbackResultsEvent(successful, data);
		}
		
		/**
		 * Login results handler
		 * */
		public function loginResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Login results");
			var data:Object = event.data;
			var loggedIn:Boolean;
			
			if (data && data is Object) {
				
				loggedIn = data.loggedIn==true;
				
				radiate.updateUserInfo(data);
			}
			
			loginInProgress = false;
			
			
			dispatchLoginResultsEvent(loggedIn, data);
		}
		
		/**
		 * Result from login fault
		 * */
		public function loginFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to login. Check to make sure you are online.");
			
			loginInProgress = false;
			
			dispatchLoginResultsEvent(false, data);
		}
		
		/**
		 * Logout results handler
		 * */
		public function logoutResultsHandler(event:IServiceEvent):void {
			Radiate.info("Logout results");
			var data:Object = event.data;
			var loggedOut:Boolean;
			
			if (data && data is Object) {
				
				loggedOut = data.loggedIn==false;
				
				radiate.updateUserInfo(data);
			}
			
			logoutInProgress = false;
			
			
			dispatchLogoutResultsEvent(loggedOut, data);
		}
		
		/**
		 * Result from logout fault
		 * */
		public function logoutFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to logout. Check to make sure you are online.");
			
			logoutInProgress = false;
			
			dispatchLogoutResultsEvent(false, data);
		}
		
		/**
		 * Register results handler
		 * */
		public function registerResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Register results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				
				successful = data.created;
				
			}
			
			registerInProgress = false;
			
			
			dispatchRegisterResultsEvent(successful, data);
		}
		
		/**
		 * Result from register fault
		 * */
		public function registerFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to register. Check to make sure you are online.");
			
			registerInProgress = false;
			
			dispatchRegisterResultsEvent(false, data);
		}
		
		/**
		 * Register results handler
		 * */
		public function changePasswordResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Change password results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				
				successful = data.created;
				
			}
			
			changePasswordInProgress = false;
			
			
			dispatchChangePasswordResultsEvent(successful, data);
		}
		
		/**
		 * Result from change password fault
		 * */
		public function changePasswordFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server. Check to make sure you are online. " + event.faultEvent.toString());
			
			changePasswordInProgress = false;
			
			dispatchChangePasswordResultsEvent(false, data);
		}
		
		/**
		 * Lost password results handler
		 * */
		public function lostPasswordResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Change password results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				successful = data.created;
			}
			
			lostPasswordInProgress = false;
			
			
			dispatchLostPasswordResultsEvent(successful, data);
		}
		
		/**
		 * Result from lost password fault
		 * */
		public function lostPasswordFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server. Check to make sure you are online. " + event.faultEvent.toString());
			
			lostPasswordInProgress = false;
			
			dispatchLostPasswordResultsEvent(false, data);
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
			
			Radiate.info("Could not connect to the server to delete the project. Check to make sure you are online.");
			
			deleteProjectInProgress = false;
			
			dispatchProjectDeletedEvent(false, data);
		}
		
		/**
		 * Delete document results handler
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
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteDocumentFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. Check to make sure you are online.");
			
			deleteDocumentInProgress = false;
			
			dispatchDocumentDeletedEvent(false, data);
		}

		
		//----------------------------------
		//
		//  DISPATCHING EVENTS
		// 
		//----------------------------------
		
		
		/**
		 * Dispatch example projects list received results event
		 * */
		public function dispatchGetExampleProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED);
			
			if (hasEventListener(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch projects list received results event
		 * */
		public function dispatchGetProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECTS_LIST_RECEIVED);
			
			if (hasEventListener(RadiateEvent.PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch blog posts received results event
		 * */
		public function dispatchGetBlogPostsResultsEvent(data:Object):void {
			var blogPostsResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.BLOG_POSTS_RECEIVED);
			
			if (hasEventListener(RadiateEvent.BLOG_POSTS_RECEIVED)) {
				blogPostsResultEvent.data = data;
				dispatchEvent(blogPostsResultEvent);
			}
		}
		
		/**
		 * Parses data into an array of usable objects 
		 * Should be in a ServicesManager class?
		 * */
		public function parsePostsData(data:Object):Array {
			var dataLength:int;
			var post:Object;
			var xml:XML;
			var isValid:Boolean;
			var source:String;
			var posts:Array = [];
			
			dataLength = data && data is Object ? data.count : 0;
			
			for (var i:int;i<dataLength;i++) {
				post = data.posts[i];
				posts.push(post);
			}
			
			var sort:Sort = new Sort();
			var sortField:SortField = new SortField("dateSaved");
			sort.fields = [sortField];
			
			return posts;
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchLoginStatusEvent(loggedIn:Boolean, data:Object):void {
			var loggedInStatusEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGGED_IN_STATUS);
			
			if (hasEventListener(RadiateEvent.LOGGED_IN_STATUS)) {
				loggedInStatusEvent.status = loggedIn ? LOGGED_IN : LOGGED_OUT;
				loggedInStatusEvent.data = data;
				dispatchEvent(loggedInStatusEvent);
			}
		}
		
		/**
		 * Dispatch get home page received event
		 * */
		public function dispatchGetHomePageEvent(data:Object):void {
			var getHomePageEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_GET_HOME_PAGE);
			
			if (hasEventListener(RadiateEvent.PROJECT_GET_HOME_PAGE)) {
				getHomePageEvent.data = data;
				dispatchEvent(getHomePageEvent);
			}
		}
		
		/**
		 * Dispatch set home page received event
		 * */
		public function dispatchSetHomePageEvent(data:Object):void {
			var setHomePageEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_SET_HOME_PAGE);
			
			if (hasEventListener(RadiateEvent.PROJECT_SET_HOME_PAGE)) {
				setHomePageEvent.data = data;
				dispatchEvent(setHomePageEvent);
			}
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchAttachmentsResultsEvent(successful:Boolean, attachments:Array):void {
			var attachmentsReceivedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_RECEIVED, false, false, attachments);
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_RECEIVED)) {
				attachmentsReceivedEvent.successful = successful;
				attachmentsReceivedEvent.status = successful ? "ok" : "fault";
				attachmentsReceivedEvent.targets = ArrayUtil.toArray(attachments);
				dispatchEvent(attachmentsReceivedEvent);
			}
		}
		
		/**
		 * Dispatch upload attachment received event
		 * */
		public function dispatchUploadAttachmentResultsEvent(successful:Boolean, attachments:Array, data:Object):void {
			var uploadAttachmentEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ATTACHMENT_UPLOADED, false, false);
			
			if (hasEventListener(RadiateEvent.ATTACHMENT_UPLOADED)) {
				uploadAttachmentEvent.successful = successful;
				uploadAttachmentEvent.status = successful ? "ok" : "fault";
				uploadAttachmentEvent.data = attachments;
				uploadAttachmentEvent.selectedItem = data;
				dispatchEvent(uploadAttachmentEvent);
			}
		}
		
		/**
		 * Dispatch feedback results event
		 * */
		public function dispatchFeedbackResultsEvent(successful:Boolean, data:Object):void {
			var feedbackResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.FEEDBACK_RESULT);
			
			if (hasEventListener(RadiateEvent.FEEDBACK_RESULT)) {
				feedbackResultsEvent.data = data;
				feedbackResultsEvent.successful = successful;
				dispatchEvent(feedbackResultsEvent);
			}
		}
		
		/**
		 * Dispatch login results event
		 * */
		public function dispatchLoginResultsEvent(successful:Boolean, data:Object):void {
			var loginResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGIN_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOGIN_RESULTS)) {
				loginResultsEvent.data = data;
				loginResultsEvent.successful = successful;
				dispatchEvent(loginResultsEvent);
			}
		}
		
		/**
		 * Dispatch logout results event
		 * */
		public function dispatchLogoutResultsEvent(successful:Boolean, data:Object):void {
			var logoutResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGOUT_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOGOUT_RESULTS)) {
				logoutResultsEvent.data = data;
				logoutResultsEvent.successful = successful;
				dispatchEvent(logoutResultsEvent);
			}
		}
		
		/**
		 * Dispatch register results event
		 * */
		public function dispatchRegisterResultsEvent(successful:Boolean, data:Object):void {
			var registerResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REGISTER_RESULTS);
			
			if (hasEventListener(RadiateEvent.REGISTER_RESULTS)) {
				registerResultsEvent.data = data;
				registerResultsEvent.successful = successful;
				dispatchEvent(registerResultsEvent);
			}
		}
		
		/**
		 * Dispatch change password results event
		 * */
		public function dispatchChangePasswordResultsEvent(successful:Boolean, data:Object):void {
			var changePasswordResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CHANGE_PASSWORD_RESULTS);
			
			if (hasEventListener(RadiateEvent.CHANGE_PASSWORD_RESULTS)) {
				changePasswordResultsEvent.data = data;
				changePasswordResultsEvent.successful = successful;
				dispatchEvent(changePasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch lost password results event
		 * */
		public function dispatchLostPasswordResultsEvent(successful:Boolean, data:Object):void {
			var lostPasswordResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOST_PASSWORD_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOST_PASSWORD_RESULTS)) {
				lostPasswordResultsEvent.data = data;
				lostPasswordResultsEvent.successful = successful;
				dispatchEvent(lostPasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch project deleted results event
		 * */
		public function dispatchProjectDeletedEvent(successful:Boolean, data:Object):void {
			var deleteProjectResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_DELETED);
			
			if (hasEventListener(RadiateEvent.PROJECT_DELETED)) {
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
			var deleteDocumentResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_DELETED);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_DELETED)) {
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteDocumentResultsEvent);
			}
		}
		
		/**
		 * Dispatch asset added event
		 * */
		public function dispatchAssetAddedEvent(data:Object):void {
			var assetAddedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ASSET_ADDED);
			
			if (hasEventListener(RadiateEvent.ASSET_ADDED)) {
				assetAddedEvent.data = data;
				dispatchEvent(assetAddedEvent);
			}
		}
		
		/**
		 * Dispatch asset removed event
		 * */
		public function dispatchAssetRemovedEvent(data:IDocumentData, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ASSET_REMOVED);
			
			if (hasEventListener(RadiateEvent.ASSET_REMOVED)) {
				assetRemovedEvent.data = data;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		/**********************************
		 * 
		 * 
		 *********************************/
		
		
		
		/**
		 * Returns true if location includes local shared object
		 * */
		public static function getIsLocalLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.LOCAL_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes remote
		 * */
		public static function getIsRemoteLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.REMOTE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes file system
		 * */
		public static function getIsFileLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.FILE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes a database
		 * */
		public static function getIsDataBaseLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.FILE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes internal
		 * */
		public static function getIsInternalLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.INTERNAL_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
	}
}

class SINGLEDOUBLE{}