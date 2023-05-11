local prefix=""

local message_funcs = function(bot,msg)
	function msg:ID()
		return self.id
	end
	function msg:FromID()
		return self.from_id
	end
	function msg:IsReply()
		return (self.reply_message && self.reply_message) || self, (self.reply_message && true) || false
	end
	function msg:ChatID()
		return self.peer_id
	end
	msg.GetChat=msg.ChatID
	function msg:Reply(text,func,keyboard)
		keyboard = istable(func) && func || nil
		bot:SendMessage(self.peer_id, text, self.id, func, vkapi.keyboard(keyboard))
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

local kbuttons = function(data)
	data = istable(data) && data || {}
	local r = {}
	if (data) then
		for k,v in pairs(data) do
			local d = {action={}, color="primary"}
			d.color = v.type=='open_link'&&'positive'||v.color || "primary" -- secondary negative positive
			d.action.type = v.type||"text"
			d.action.link = v.type=='open_link'&&(v.link||"https://vk.com/id1")||nil
            d.action.payload = v.type=='open_link'&&util.TableToJSON({url = d.action.link})||"{\"button\": \"1\"}"
			d.action.label = v.text||"Команды"
			table.insert(r, d)
		end
	end
	return r --util.TableToJSON(r)
end
function vkapi.keyboard(data)
	-- print(data)
	-- print(util.TableToJSON(data,true))
	local k = {}
	if (!data) || (!istable(data)) then return k end

	k.one_time = (not data.inline) && true || nil
	k.inline = data.inline || nil
	k.buttons = {}
	for kk,v in pairs(data.buttons||{}) do
		k.buttons[kk] = kbuttons(v) --k.buttons[kk] || {}

		--table.insert(k.buttons[kk], kbuttons(v))
	end
	-- print(util.TableToJSON(k,true))
	-- print(data.inline, k.one_time)

	return k
end

vkapi.bot = setmetatable({},{})
vkapi.bots = {}
function vkapi.bot:Create(uid, token, gid)
	local bot = setmetatable({},{})
	LOADING_BOT = bot
	-------------------------------------
	function bot:print(...)
		vkapi:print('[BOT - "'.. self:Name() ..'"] ', Color(255,255,255), ...)
	end
	function bot:error(...)
		vkapi:error('[BOT - "'.. self:Name() ..'"] ', Color(255,255,255), ...)
	end

	bot._cmds = {
		['Авторбота'] = {
			func = function(m) return "https://fanca.smrtcommunity.xyz" end,
			acs = function()return true end,
			args = "",
			desc = "Автор бота"
		},
		['Команды'] = {
			func = function(m) 
				local str = "👀 Команды:\n"
				for k,v in pairs(bot._cmds) do
					if(isfunction(v.acs) && v.acs(m)==false)then continue end
					str = str .."\n".. k .." ".. tostring(v.args) ..(v.desc && " - ".. tostring(v.desc) || "")
				end
				return str
			end,
			acs = function()return true end,
			args = "",
			desc = "Все доступные для вас команды"
		},
	}
	function bot:Command(cmd,func,acs,args,desc)
		self._cmds[prefix .. cmd] = {
			func= func,
			acs = acs || function() return true end,
			args= args|| "",--"<без аргументов>",
			desc= desc|| false
		}
		self:print('Add command "'.. cmd ..'"')
	end
	function bot:CommandCopy(to,from)
		self._cmds[to] = self._cmds[from]
	end
	function bot:RemoveCommand(cmd)
		self._cmds[cmd] = nil
		self:print('Remove command "'.. cmd ..'"')
	end
	function bot:RunCommand(cmd, ...)
		if (!self._cmds[cmd] || !isfunction(self._cmds[cmd].func)) then return end
		self._cmds[cmd].func(...)
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

	bot._groupid = gid || 0
	function bot:SetGroupID(d)
		bot._groupid = d
	end
	function bot:GetGroupID(d)
		return bot._groupid
	end

	bot._token = token
	function bot:GetToken()
		return (self._token || "error")
	end
	function bot:SetToken(t)
		self._token = t
	end

	bot.modules = {}
	function bot:Module(n)
		if (!file.Exists('fvkbot/bots/modules/'.. n .."/init.lua", "LUA")) then
			self:print('module "'.. string.upper(n) ..'" not found')
			return
		end
		self:print('module "'.. n ..'" loading...')
		local res = vkapi:Include('bots/modules/'.. n .."/init.lua")
		self:print('module "'.. string.upper(n) ..'" loaded')
		self.modules[n]=res
		return res
	end
	function bot:GetModule(n)
		return self.modules[n]||false
	end
	-------------------------------------
	function bot:Method(method, req, func)
		vkapi:RunMethod(self, method, req, func)
	end
	function bot:EnableBypassAntiSpam(bool)
		vkapi.bypassAntispam.active[self:GetToken()] = bool or true
		self:print("set antispam bypass: ".. tostring(bool))
	end
	function bot:SendMessage(chat_id, msg, replyto, ffff, kb)
		kb = istable(ffff) && ffff 

		-- print("=  ".. tostring(kb))
		local result = false
		local m = vkapi.method('messages.send'):SetBot(self)
		:SetMessage(msg||"<no text> :/")
		:SetChat(chat_id)
		:Reply(replyto)
		:RandomID()
		:Add("keyboard", kb)
		:SetFunction(function(d,mm)
			if isfunction(ffff) then 
				ffff(d,mm)
			end
		end)
		:Run()
	end

	function bot:OnMessage(msg, chat)
		if hook.Run('vk.onmsg', self:GetClass(), msg, chat)==false then return end
		local args = string.Explode(' ', msg.text)
		local cmd = self._cmds[args[1]||""]
		cmd = (cmd) or (string.find(args[1], "@") and self._cmds[args[2]||""])
		if (cmd) then
			local fulltext = string.sub(msg.text, string.len(args[1])+1)
			table.remove(args, 1)
			msg = message_funcs(self,msg)
			if (!cmd.func || !isfunction(cmd.func) || (isfunction(cmd.acs) && cmd.acs(msg)==false)) then return function()end end
			return cmd.func(msg,args,fulltext,chat)
		end
		if vkapi:MSGType(chat)==VK_TYPE_MEMBER then
			return [[Это не команда.]], vkapi.cfg.default_keyboard
		end
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
vkapi.bot.__index = vkapi.bot.__call