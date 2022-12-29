local api_version = 5.131
function vkapi:RunMethod(bot, method, req, func, ffunc)
	req = req || {}
	-- req.v = api_version
	req.access_token = bot && bot:GetToken() || "???"

	local req_str = ""
	for k,v in pairs(req) do
		-- v = string.Replace(v, ' ', "%20")
		-- print(k,istable(v),v)
		v = istable(v) && util.TableToJSON(v) || v
		req_str = req_str .."&".. k .."=".. v
	end

	local request = method .. "?v=".. api_version .."".. req_str
	local url = string.gsub('https://api.vk.com/method/'.. request, "%s+", "%%20")
	-- print(url)
	http.Post(
		url,
		req,
		function(data,len,head,code)
			if (func) then
				local json = util.JSONToTable(data)
				func(json || data,len,head,code,req)
			end
		end,
		function(err)
			if (ffunc) then
				local json = util.JSONToTable(data)
				ffunc(json || data,len,head,code,req)
			end
		end
	)
end

VK_TYPE_MEMBER 	= 0
VK_TYPE_CHAT 	= 1
function vkapi:MSGType(msg)
	if (msg.conversation) && (msg.conversation.chat_settings) then return 1 end
	if (msg) && (msg.chat_settings) then return 1 end
	return 0
end