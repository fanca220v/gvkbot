vkapi.method = function(method, bot)
	local met 	= setmetatable({},{})

	met.result 	= false
	met.method 	= method||false
	met.bot 	= bot||false
	met.request = {}
	met._callback= function(data)
		if (!data) || (!istable(data)) then met._fcallback(data) end
		if (met.ccallback) then
			return met.ccallback(data, met)
		end
		return data
	end
	met._fcallback=function(data)
		data = istable(data) && data || {error={}}
		local isokay=met.ccallback(data, met)
		if (!isokay) then
			vkapi:error('method '.. met.method .." is error:")
			if istable(data) then
				PrintTable(data)
			else
				print(data)
			end
			return false
		end
		return isokay
	end
	met.callback= function(data)
		if (!data) || (!istable(data)) || (data.error) then 
			return met._fcallback(data)
		end
		return met._callback(data)
	end

	function met:SetBot(bot)
		if (!bot) then return self end
		self.bot = bot
		return self
	end
	function met:SetFunction(f)
		if (!f) || (!isfunction(f)) then return self end
		self.ccallback = f
		return self
	end
	function met:Change(method)
		self.method = method
		return self
	end
	function met:SetRequest(data)
		if (!data) || (!istable(data)) then
			vkapi:error('method '.. met.method .." is error: no request")
			return self
		end
		self.request = data
		return self
	end
	function met:Add(key, val)
		self.request = self.request||{}
		self.request[tostring(key)] = val
		return met
	end
	function met:Run()
		if (!self.bot) || (!self.method) || (!self.request || !istable(self.request)) then return self end
		self.result = vkapi:RunMethod(self.bot, self.method, self.request, self.callback, self.callback)
		return self
	end

	function met:SetChat(id)
		self.request = self.request||{}
		self.request['peer_id'] = id
		return self
	end
	function met:SetMessage(msg)
		self.request = self.request||{}
		self.request['message'] = msg
		return self
	end
	local many_ids=function(...)
		local ids = {...}
		local str = tonumber(ids[1])||1
		ids[1]=false
		for k,v in pairs(ids) do
			if (v==false) then continue end
			str = str ..", ".. tonumber(v)
		end
	end
	function met:SetMessages(...)
		local str = many_ids(...)
		self.request = self.request||{}
		self.request['message_ids'] = str
		return self
	end
	function met:SetUsers(...)
		local str = many_ids(...)
		self.request = self.request||{}
		self.request['user_ids'] = str
		return self
	end
	function met:Reply(id)
		self.request = self.request||{}
		self.request['reply_to'] = id
		return self
	end
	function met:RandomID()
		self.request = self.request||{}
		self.request['random_id'] = math.random(-2147483648, 2147483647)
		return self
	end
	met.__call = function()
		return {
			bot = met.bot,
			method = met.method,
			request = met.request,
			result = met.result
		}
	end

	return met
end