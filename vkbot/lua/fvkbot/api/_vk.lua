local api_version = 5.131
function vkapi:RunMethod(bot, method, req, func)
	req = req || {}
	req.v = api_version
	req.access_token = bot && bot:GetToken() || "???"

	local req_str = ""
	for k,v in pairs(req) do
		v = string.Replace(v, ' ', "%20")
		req_str = req_str .."&".. k .."=".. v
	end

	local request = method .. "?v=".. api_version .."".. req_str
	http.Post(
		'https://api.vk.com/method/'.. request,
		req,  -- вк просто отказывается видеть эту дрянь(POST), временно через url работает
		function(data,len,head,code)
			if (func) then
				local json = util.JSONToTable(data)
				func(json || data,len,head,code,req)
			end
		end,
		function()  end
	)
end