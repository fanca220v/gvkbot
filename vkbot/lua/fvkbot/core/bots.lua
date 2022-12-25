local prefix=""

local message_funcs = function(bot,msg)
	function msg:ID()
		return self.id
	end
	function msg:ChatID()
		return self.peer_id
	end
	msg.GetChat=msg.ChatID
	function msg:Reply(text,func)
		bot:SendMessage(self.peer_id, text, self.id, func)
	end
	function msg:Remove(all)
		local m = vkapi.method('messages.delete')
		:SetBot(bot)
		:Add('delete_for_all', all||0)
		:SetMessages(self.id)
		:SetChat(self.peer_id)
		:Run()
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

	bot._cmds = {
		['/author'] = function(m) return "https://swaaag.site/fanca.xyz" end
	}
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

	function bot:Start()
		self._ispoll = true
		self:print"Получение сообщений: Включено"
	end
	function bot:Stop()
		self._ispoll = nil
		self:print"Получение сообщений: Выключено"
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
	function bot:SendMessage(chat_id, msg, replyto, ffff)
		local result = false
		local m = vkapi.method('messages.send'):SetBot(self)
		:SetMessage(msg||"<no text> :/")
		:SetChat(chat_id)
		:Reply(replyto)
		:RandomID()
		:SetFunction(function(d,m)
			result = {d,m}
			return ffff && isfunction(ffff) && ffff(d,m) || nil
		end)
		:Run()
		return result
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
function vkapi.bot:Get(uid)
	return vkapi.bots[uid]||false
end

vkapi.bot.__call = function(self, ...)
	self:Create(...)
end