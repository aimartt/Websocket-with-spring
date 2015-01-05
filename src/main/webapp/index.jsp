<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<html>
	<head>
		<script src="resource/scripts/jquery-1.8.2.min.js"></script>
		<script src="resource/scripts/sockjs-0.3.min.js"></script>
		<script src="resource/scripts/stomp.js"></script>
		<script type=text/javascript> 
			var socket;	
		  	var connectCallback;
		  	var errorCallback; 
		  	var stompClient;
		
			$(function() {
				//注册按钮点击事件函数
				$("#connBtn").click(connect);
				$("#sendButton").click(postToServer);
				$("#endButton").click(closeConnect);
			});
			
			/** 处理消息响应 */
			function renderChat(message) {
				var id = $("#id").val();
				var withUserId = $("#withUserId").val();
				var data = JSON.parse(message.body);
				//控制获取消息的客户端
				if ((id == data.id && withUserId == data.withUserId) || 
						(id == data.withUserId && withUserId == data.id)) {
					document.getElementById("chatlog").textContent += data.returnMsg + "\n";
				}
			}
			
			/** 连接服务器 */
			function connect() {
				socket = new SockJS("/ws");
			    stompClient = Stomp.over(socket);
			    connectCallback = function() {
			      	stompClient.subscribe("/topic/chat", renderChat);
		    	}; 
		    	errorCallback = function(error) {
		    		alert(error);
		    	};
		    	//Websocket 连接服务器
		        stompClient.connect("guest", "guest", connectCallback, errorCallback);
				//连接后禁止再次连接
				$("#id").attr("disabled", "disabled");
				$("#withUserId").attr("disabled", "disabled");
				$("#connBtn").attr("disabled", "disabled");
				//启用发送和结束按钮
				$("#sendButton").removeAttr("disabled");
				$("#endButton").removeAttr("disabled");
			}
			
			/** 发送消息 */
			function postToServer() {
				if (stompClient) {
					var id = $("#id").val();
					var withUserId = $("#withUserId").val();
					var msg = $("#msg").val();
					//非空白消息才进行发送操作
					if (msg.length > 0) {	
						var jsonstr = JSON.stringify({
							"id": id, 
							"withUserId": withUserId,
							"msg": msg
						});
						//发送消息
				        stompClient.send("/chat/sendMsg", {}, jsonstr);
						//清空输入框
				        $("#msg").val("");
					}
				}
			}
			
			/** 关闭连接 */
			function closeConnect() {
				if (stompClient) {
					stompClient.disconnect(function() {
						alert("disconnect");
					});
					//连接关闭后启用连接按钮
					$("#id").removeAttr("disabled");
					$("#withUserId").removeAttr("disabled");
					$("#connBtn").removeAttr("disabled");
					//禁用发送和结束按钮
					$("#sendButton").attr("disabled", "disabled");
					$("#endButton").attr("disabled", "disabled");
				}
			}
		</script>
	</head>
	<body>
		<select id="id">
			<option value="1">张老师</option>
			<option value="2">梅西</option>
			<option value="3">西罗</option>
		</select>
		<select id="withUserId">
			<option value="1">张老师</option>
			<option value="2">梅西</option>
			<option value="3">西罗</option>
		</select>
		<button type="button" id="connBtn">Connect</button><br />
		<textarea id="chatlog" readonly="readonly" rows="15" cols="50"></textarea><br />
		<input id="msg" type="text" />
		<button type="submit" id="sendButton" disabled="disabled">Send!</button>
		<button type="submit" id="endButton" disabled="disabled">End</button>
	</body>
</html>