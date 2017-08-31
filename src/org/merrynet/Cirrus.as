package org.merrynet
{
	import flash.net.*;
	import flash.utils.*;
	import flash.events.*;
	import mx.charts.chartClasses.StackedSeries;
	import mx.formatters.DateFormatter;
	import mx.events.SliderEvent;
	import mx.events.FlexEvent;
	import mx.collections.ArrayCollection;
	import mx.events.ItemClickEvent;
	import flash.events.SampleDataEvent;
	
	/**
	$(CBI)* ...
	$(CBI)* @author SARI
	$(CBI)*/
	public class Cirrus
	{
		
		// rtmfp server address (Adobe Cirrus or FMS)
		[Bindable] private var connectUrl:String = "rtmfp://p2p.rtmfp.net";
		
		// developer key, please insert your developer key here
		private const DeveloperKey:String = "e8febb4d83f65ed90f46afc8-3cfcd2299c8d";
		
		// please insert your web service URL here for exchanging peer ID
		private const WebServiceUrl:String = "http://www.merryyellow.com/handlercirrus.ashx?type=getrandom";
		
		// this is the connection to rtmfp server
		private var netConnection:NetConnection;	
		
		// after connection to rtmfp server, publish listener stream to wait for incoming call 
		private var listenerStream:NetStream;
		
		// caller's incoming stream that is connected to callee's listener stream
		private var controlStream:NetStream;
		
		// outgoing media stream (audio, video, text and some control messages)
		private var outgoingStream:NetStream;
		
		// incoming media stream (audio, video, text and some control messages)
		private var incomingStream:NetStream;
		
		// ID management serice
		private var idManager:AbstractIdManager;
		
		// login/registration state machine
		[Bindable] private var loginState:int;
		
		private const LoginNotConnected:int = 0;
		private const LoginConnecting:int = 1;
		private const LoginConnected:int = 2;
		private const LoginDisconnecting:int = 3;
		
		// call state machine
		[Bindable] private var callState:int;
		
		private const CallNotReady:int = 0;
		private const CallReady:int = 1;
		private const CallCalling:int = 2;
		private const CallRinging:int = 3;
		private const CallEstablished:int = 4;
		private const CallFailed:int = 5;
		
		
		
		private var activityTimer:Timer;
		
		
		[Bindable] private var remoteName:String = "";
		
		private var callTimer:int;
		
		
		private var username:String
		
		
		
		
		public function Cirrus(username:String) 
		{
			this.username = username
			init()
			connect()
		}
		
		// called when application is loaded            		
		private function init():void
		{		
			loginState = LoginNotConnected;
			callState = CallNotReady;
		}
				
		private function status(msg:String):void
		{
			trace("ScriptDebug: " + msg);
		}
		
		private function connect():void
		{
			
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
						
			try
			{
				netConnection.connect(connectUrl + "/" + DeveloperKey);
			}
			catch (e:ArgumentError)
			{
				status("Incorrect connet URL\n");
				return;
			}
			
			loginState = LoginConnecting;	
			
			status("Connecting to " + connectUrl + "\n");
		}
		
		private function netConnectionHandler(event:NetStatusEvent):void
		{
			status("NetConnection event: " + event.info.code + "\n");
			
			switch (event.info.code)
			{
				case "NetConnection.Connect.Success":
					connectSuccess();
					break;
					
				case "NetConnection.Connect.Closed":
					loginState = LoginNotConnected;
					callState = CallNotReady;
					break;
					
				case "NetStream.Connect.Success":
					// we get this when other party connects to our control stream our outgoing stream
					status("Connection from: " + event.info.stream.farID + "\n");
					break;
					
				case "NetConnection.Connect.Failed":
					status("Unable to connect to " + connectUrl + "\n");
					loginState = LoginNotConnected;
					break;
					
				case "NetStream.Connect.Closed":
					onHangup();
					break;
			}
		}
		
		private function listenerHandler(event:NetStatusEvent):void
		{
			status("Listener event: " + event.info.code + "\n");
		}
		
		private function controlHandler(event:NetStatusEvent):void
		{
			status("Control event: " + event.info.code + "\n");
		}
		
		private function outgoingStreamHandler(event:NetStatusEvent):void
		{
			status("Outgoing stream event: " + event.info.code + "\n");
			switch (event.info.code)
			{
				case "NetStream.Play.Start":
					if (callState == CallCalling)
					{
						outgoingStream.send("onIncomingCall", username);
					}
					break;
			}
		}
		
		private function incomingStreamHandler(event:NetStatusEvent):void
		{
			status("Incoming stream event: " + event.info.code + "\n");
			switch (event.info.code)
			{
				case "NetStream.Play.UnpublishNotify":
					onHangup();
					break;
			}
		}
		
		// connection to rtmfp server succeeded and we register our peer ID with an id exchange service
		// other clients can use id exchnage service to lookup our peer ID
		private function connectSuccess():void
		{
			status("Connected, my ID: " + netConnection.nearID + "\n");
			
			// exchange peer id using web service
			idManager = new HttpIdManager();
			idManager.service = WebServiceUrl;
			
			idManager.addEventListener("registerSuccess", idManagerEvent);
			idManager.addEventListener("registerFailure", idManagerEvent);
			idManager.addEventListener("lookupFailure", idManagerEvent);
			idManager.addEventListener("lookupSuccess", idManagerEvent);
			idManager.addEventListener("idManagerError", idManagerEvent);
			
			idManager.register(username, netConnection.nearID);
		}
		
		private function completeRegistration():void
		{
			// start the control stream that will listen to incoming calls
			listenerStream = new NetStream(netConnection, NetStream.DIRECT_CONNECTIONS);
			listenerStream.addEventListener(NetStatusEvent.NET_STATUS, listenerHandler);
			listenerStream.publish("control" + username);
			
			var c:Object = new Object
			c.onPeerConnect = function(caller:NetStream):Boolean
			{
				status("Caller connecting to listener stream: " + caller.farID + "\n");
							
				if (callState == CallReady)
				{
					
					callState = CallRinging;
								
					// callee subscribes to media, to be able to get the remote user name
					incomingStream = new NetStream(netConnection, caller.farID);
					incomingStream.addEventListener(NetStatusEvent.NET_STATUS, incomingStreamHandler);
					incomingStream.play("media-caller");
					
					
								
					var i:Object = new Object;
					i.onIncomingCall = function(caller:String):void
					{
						if (callState != CallRinging)
						{
							status("onIncomingCall: Wrong call state: " + callState + "\n");
							return;
						}
						remoteName = caller;
								
						status("Incoming call from: " + caller + "\n");
					}
					
					i.onIm = function(name:String, text:String):void
					{
						/*
						textOutput.text += name + ": " + text + "\n";
						textOutput.validateNow();
						textOutput.verticalScrollPosition = textOutput.textHeight;
						*/
						Game.debugLabel.text = name + ": " + text
					}
					incomingStream.client = i;
								
					return true;
				}
					
				status("onPeerConnect: all rejected due to state: " + callState + "\n");
	
				return false;
			}
						
			listenerStream.client = c;
						
			callState = CallReady;
		}
		
		private function placeCall(user:String, identity:String):void
		{
			status("Calling " + user + ", id: " + identity + "\n");
						
			if (identity.length != 64)
			{	
				status("Invalid remote ID, call failed\n");
				callState = CallFailed;
				return;
			}
						
			// caller subsrcibes to callee's listener stream 
			controlStream = new NetStream(netConnection, identity);
			controlStream.addEventListener(NetStatusEvent.NET_STATUS, controlHandler);
			controlStream.play("control" + user);
						
			// caller publishes media stream
			outgoingStream = new NetStream(netConnection, NetStream.DIRECT_CONNECTIONS);
			outgoingStream.addEventListener(NetStatusEvent.NET_STATUS, outgoingStreamHandler);
			outgoingStream.publish("media-caller");
						
			var o:Object = new Object
			o.onPeerConnect = function(caller:NetStream):Boolean
			{
				status("Callee connecting to media stream: " + caller.farID + "\n");
										
				return true; 
			}
			outgoingStream.client = o;
			
													
			// caller subscribes to callee's media stream
			incomingStream = new NetStream(netConnection, identity);
			incomingStream.addEventListener(NetStatusEvent.NET_STATUS, incomingStreamHandler);
			incomingStream.play("media-callee");
			
			
						
			var i:Object = new Object;
			i.onCallAccepted = function(callee:String):void
			{
				if (callState != CallCalling)
				{
					status("onCallAccepted: Wrong call state: " + callState + "\n");
					return;
				}
							
				callState = CallEstablished;
													
				status("Call accepted by " + callee + "\n");
			}
			i.onIm = function(name:String, text:String):void
			{
				//textOutput.text += name + ": " + text + "\n";
			}
			incomingStream.client = i;
							
			
						
			remoteName = user;
			callState = CallCalling;
		}
					
				
		// process successful response from id manager		
		private function idManagerEvent(e:Event):void
		{
			status("ID event: " + e.type + "\n");
			
			if (e.type == "registerSuccess")
			{
				switch (loginState)
				{
					case LoginConnecting:
						loginState = LoginConnected;
						break;
					case LoginDisconnecting:
					case LoginNotConnected:
						loginState = LoginNotConnected;
						return;
					case LoginConnected:
						return;
				}	
						
				completeRegistration();
			}
			else if (e.type == "lookupSuccess")
			{
				// party query response
				var i:IdManagerEvent = e as IdManagerEvent;
				
				placeCall(i.user, i.id);	
			}
			else
			{
				// all error messages ar IdManagerError type
				var error:IdManagerError = e as IdManagerError;
				status("Error description: " + error.description + "\n");
				
				onDisconnect();
			}
		}
		
		
					
		private function onDisconnect():void
		{
			status("Disconnecting.\n");
			
			onHangup();
			
			callState = CallNotReady;
			
			if (idManager)
			{
				idManager.unregister();
				idManager = null;
			}
			
			loginState = LoginNotConnected;
			
			netConnection.close();
			netConnection = null;
		}
		
		// placing a call
		public function call(calleename:String):void
		{	
			if (netConnection && netConnection.connected)
			{
				if (calleename.length == 0)
				{
					status("Please enter name to call\n");
					return;
				}
				
				// first, we need to lookup callee's peer ID
				if (idManager)
				{
					idManager.lookup(calleename);
				}
				else
				{
					status("Not registered.\n");
					return;
				}
			}
			else
			{
				status("Not connected.\n");
			}
		}
		
		private function onDeviceStatus(e:StatusEvent):void
		{
			status("Device status: " + e.code + "\n");
		}
		
		private function onDeviceActivity(e:ActivityEvent):void
		{
//				status("Device activity: " + e.activating + "\n");
		}
				
		
		
		public function send(message:String):void {
			
			if (message.length != 0 && outgoingStream)
			{
				outgoingStream.send("onIm", username, message);
			}
			
		}
		
		
		// sending text message
		private function onSend():void
		{
			var msg:String = "MESAAAJ"; 
			if (msg.length != 0 && outgoingStream)
			{
				
				//textOutput.text += username + ": " + msg + "\n";
				outgoingStream.send("onIm", username, msg);
				//textInput.text = "";
				
			}
		}
			
		
		private function onHangup():void
		{
			status("Hanging up call\n");
			
			
			
			callState = CallReady;
			
			if (incomingStream)
			{
				incomingStream.close();
				incomingStream.removeEventListener(NetStatusEvent.NET_STATUS, incomingStreamHandler);
			}
			
			if (outgoingStream)
			{
				outgoingStream.close();
				outgoingStream.removeEventListener(NetStatusEvent.NET_STATUS, outgoingStreamHandler);
			}
			
			if (controlStream)
			{
				controlStream.close();
				controlStream.removeEventListener(NetStatusEvent.NET_STATUS, controlHandler);
			}
			
			incomingStream = null;
			outgoingStream = null;
			controlStream = null;
			
			remoteName = "";
			
			callTimer = 0;
		}
	
		
		
	}

}