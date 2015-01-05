/**
 * Copyright (c) 2009 FEINNO, Inc. All rights reserved.
 * This software is the confidential and proprietary information of 
 * FEINNO, Inc. You shall not disclose such Confidential
 * Information and shall use it only in accordance with the terms of the 
 * license agreement you entered into with FEINNO.
 */
package com.aimartt.websocket;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Title:
 * <p>Description:</p>
 * Copyright (c) feinno 2013
 * @author Tangtao on 2015年1月4日
 */
@Controller
public class ChatController {
	
	private static final Map<String, String> NAMES_MAP = new HashMap<String, String>();
	
	static {
		NAMES_MAP.put("1", "张老师");
		NAMES_MAP.put("2", "梅西");
		NAMES_MAP.put("3", "西罗");
	}
	
	@Autowired
	private SimpMessagingTemplate template;
	
	@SuppressWarnings("unchecked")
	@MessageMapping(value = {"/sendMsg"})
	public void chat(String json) {
		ObjectMapper mapper = new ObjectMapper();
		Map<String, String> map = new HashMap<String, String>();
		try {
			map = mapper.readValue(json, HashMap.class);
		} catch (Exception e) {
			e.printStackTrace();
		}
		String timestamp = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").format(new Date());
		String id = map.get("id");
		String withUserId = map.get("withUserId");
		String msg = map.get("msg");
		//console log
		String log = NAMES_MAP.get(id) + " 对 " + NAMES_MAP.get(withUserId) + " 说：" + msg;
		System.out.println(log);
		//return msg
		String returnMsg = NAMES_MAP.get(id) + "\\t" + timestamp + "\\n" + msg;
		String payload = "{\"id\": \"" + id + "\", "
				+ "\"withUserId\": \"" + withUserId + "\", "
				+ "\"returnMsg\": \"" + returnMsg + "\"}";
		template.convertAndSend("/topic/chat", payload);
	}

}