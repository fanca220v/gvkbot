local prefix=""

local message_funcs = function(bot,msg)
	function msg:Reply(text)
		bot:SendMessage(self.from_id, text, self.id)
	end
	function msg:Remove()
		bot:Method("messages.delete", {
			message_ids = self.id,
			-- cmids = self.id,
			peer_id = self.peer_id,
			delete_for_all = 0
		}, function(data) PrintTable(data) end)
	end
	return msg
end

vkapi.bot = setmetatable({},{})
vkapi.bots = {}
function vkapi.bot:Create(uid, token)
	local bot = setmetatable({},{})
	-------------------------------------
	function bot:print(...)
		vkapi:print('[BOT - "'.. self:Name() ..'"] ', Color(255,255,255), ...)
	end
	function bot:error(...)
		vkapi:error('[BOT - "'.. self:Name() ..'"] ', Color(255,255,255), ...)
	end

	bot._cmds = {}
	function bot:Command(cmd,func)
		self._cmds[prefix .. cmd] = func
		self:print(' Add command "'.. cmd ..'"')
	end
	function bot:RemoveCommand(cmd)
		self._cmds[cmd] = nil
		self:print(' Remove command "'.. cmd ..'"')
	end
	function bot:RunCommand(cmd, ...)
		if (!self._cmds[cmd] || !isfunction(self._cmds[cmd])) then return end
		self._cmds[cmd](...)
	end

	function bot:StartPoll()
		self._ispoll = true
	end
	function bot:StopPoll()
		self._ispoll = nil
	end

	bot._uid = uid || "main"
	function bot:UID()
		return (self._uid || 0)
	end
	bot.GetClass = bot.UID

	bot._name = uid
	function bot:Name()
		return self._name
	end
	function bot:SetName(name)
		self._name = name
	end

	bot._starttime = os.time()
	function bot:StartTime()
		return (self._starttime || 0)
	end

	bot._token = token
	function bot:GetToken()
		return (self._token || "error")
	end
	function bot:SetToken(t)
		self._token = t
	end
	-------------------------------------
	function bot:Method(method, req, func)
		vkapi:RunMethod(self, method, req, func)
	end
	function bot:SendMessage(chat_id, msg, replyto, func)
		self:Method('messages.send', 
			{
				peer_id = chat_id,
				reply_to= replyto,
				random_id=math.random(-2147483648, 2147483647),
				message = tostring(msg)
			},
			function(data) if func then func(data) end end
		)
	end

	function bot:OnMessage(msg, chat)
		if hook.Run('vk.onmsg', self:GetClass(), msg, chat)==false then return end
		local args = string.Explode(' ', msg.text)
		local cmd = self._cmds[args[1]||""]
		if (cmd) then
			local fulltext = string.sub(msg.text, string.len(args[1])+1)
			table.remove(args, 1)
			return cmd(message_funcs(self,msg),args,fulltext,chat)
		end
		return [[Это не команда.]]
	end
	function bot:OnAction(msg, chat)
		
	end
	-------------------------------------
	bot:print('CREATED')
	vkapi.bots[uid] = bot
	return bot
end
function vkapi.bot:Remove(uid)
	vkapi.bots[uid] = nil
	vkapi:print('[BOT "'.. uid ..'"] REMOVED')
end

vkapi.bot.__call = function(self, ...)
	self:Create(...)
end