local over_admin = { -- ids administrator for bot.IsAdmin()
	[230438837] = true
}
local bot = vkapi.bot:Create(
	'server', -- UID
	"vk1.a.xxxxx", --TOKEN
	192800689 -- group ID
)
bot:Start() -- start getting messages every 1 seconds

local database = bot:Module('database') -- Database query function[ sup darkrp db, darkrp, gmod sql(sv.db) ]
local sync = bot:Module('steam_sync') -- steam sync for bot
local vk_logs = bot:Module('logs') -- logs[set chats if error]

local isadmin = function(msg) -- user is admin?
	return over_admin[msg.from_id]||false
end
bot.IsAdmin = isadmin
local isattachment = function(msg)end -- soon

local enginespew = "" -- soon fix
if file.Exists('bin/gmsv_enginespew_win32.dll', "LUA") || file.Exists('bin/gmsv_enginespew_linux.dll', "LUA") then
	require('enginespew')
	hook.Add('EngineSpew', 'vk.'.. bot:GetClass(), function(_,t)
		enginespew = enginespew .."\n".. tostring(t)
		-- print(t)
	end)
	bot:print('engine spew прогружен')
else
	bot:error('engine spew отсутствует на сервере')
end





-- global logs functions for other scripts
function vkapi:SendMStuff(text, keyboardorfunc)
	bot:SendLogMessage('stuff', text, keyboardorfunc)
end
function vkapi:SendMHStuff(text, keyboardorfunc)
	bot:SendLogMessage('hstuff', text, keyboardorfunc)
end
function vkapi:SendMLog(text, keyboardorfunc)
	bot:SendLogMessage('logs', text, keyboardorfunc)
end
function vkapi:SendMCLog(text, keyboardorfunc)
	bot:SendLogMessage('clogs', text, keyboardorfunc)
end
function vkapi:SendMPlayers(text, keyboardorfunc)
	bot:SendLogMessage('players', text, keyboardorfunc)
end





bot:Command('/getmsg', function(msg,args,str,chat)
	local m = vkapi.method('messages.getById',bot)
	:SetFunction(function(data,r)
		data = istable(data) && data.response || {}
		if (data.error) then return "Сообщение не существует." end
		if (!data) || (!data.items) || (!data.items[1]) then return "Сообщение не существует." end
		bot:SendMessage(msg.peer_id, "Вот", data.items[1].id||msg:ID(), function(d)
			if (d.error) then
				if(string.find(tostring(d.error_msg), "reply_to have to be message from same chat")) then
					msg:Reply('Сообщение не существует в этом чате.\n\n'.. util.TableToJSON(data))
					return true
				else
					msg:Reply('Сообщение нельзя выделить.\n\n'.. util.TableToJSON(data))
					return true
				end
			end
		end)
	end)
	:SetMessages(args[1])
	:SetChat(msg:GetChat())
	:Run()
end, isadmin, "<msgid>", "Пингануть сообщение в этомчате по айди, либо получить о нем информацию")

bot:Command('/json', function(msg,args,str,chat)
	-- PrintTable(msg)
	return util.TableToJSON(args[1]=="chat" && chat || msg,true)
end, nil, "<chat>", "json сообщения/чата")

bot:Command('/ping', function(msg,args,str,chat)
	return "🤙 ".. bot:GetClass()
end, nil, nil, "Пинг бота")

-- bot:Command('echo', function(msg,args,str,chat)
-- 	msg:Remove()
-- 	return str
-- end)
bot:Command('/status', function(msg,args,str,chat)
	return string.format([[
%s 🤙:

✊ Игроки: %s/%s
🗻 Карта: %s
🔥 Бот uid: %s

ЗАЙТИ 👉 %s
		]], 
		GetHostName(), 
		#player.GetAll(), 
		game.MaxPlayers(), 
		game.GetMap(), 
		bot:GetClass(), 
		game.GetIPAddress()
	),{
		inline = true,
		{
			{
				-- type = "open_link",
				-- link = "https://swaaag.site/connect?ip=".. game.GetIPAddress(),
				text = "Присоеденится"
			}
		}
	}
end, nil, nil, "Информация о сервере")

bot:Command('/cmd', function(msg,args,str,chat)
	if(!isadmin(msg))then return "Вы не администратор." end

	if(!args[1])then return "Отсутствует command" end
	enginespew = ""
	RunConsoleCommand(unpack(args))
	str = string.Replace(str, " ".. args[1], "")
	msg:Reply(string.format([[
🤙 Выпоняю команду "%s" с аргументами "%s"

return:
%s -- soon enginespew
	]], args[1], str, "- Нету"))
end, isadmin, "<command> ... args", "Консольная команда")

bot:Command('/lua', function(msg,args,str,chat)
	if(!isadmin(msg))then return "Вы не администратор." end

	if(!args[1])then return "Отсутствует код" end
	enginespew = ""
	RunString(str)
	msg:Reply(string.format([[
Выпоняю код🤙:

%s
	]], str))
end, isadmin, "<code>", "LUARUN")

bot:Command('/anonc', function(msg,args,str,chat)
	if(!isadmin(msg))then return "Вы не администратор." end

	for k,v in pairs(vkapi.chats[bot:GetClass()]) do
		bot:SendMessage(v.last_message.peer_id, "[VK ANONS]\n\n".. str, nil, function(data)
			data = data.response || 0
			-- if v.last_message.peer_id==msg.from_id then
			-- 	timer.Simple(10,function()
			-- 		bot:Method("messages.delete", {
			-- 			message_ids = data,
			-- 			peer_id = v.last_message.peer_id,
			-- 			delete_for_all = 1
			-- 		}, function(data) PrintTable(data) end)
			-- 	end)
			-- end
		end)
	end
	bot:print('АНОНС ВСЕМ В СООБЩЕНИЯ:\n'.. str)
	-- return 'Отправлено всем: '.. str
end, isadmin, "<text>", "Текст во все беседы бота")

bot:Command('/say', function(msg,args,str,chat)
	bot:GetVKUser(msg.from_id,function(_,data)
		-- PrintTable({_,data})
		local name = data.response && (data.response.first_name||'no') .." ".. (data.response.last_name||'no') || msg.from_id--data && data.name || msg.from_id
		ChatPrint(Color(255,0,0), "[VK] ".. name ..": ", Color(255,255,255), str)
	end)
	return 'Отправлено'
end)

function bot:GetVKUser(id,p,func)
	if isfunction(p) then func=p end
	local m = vkapi.method('users.get',bot)
	:Add('name_case', p||'')
	:SetFunction(func)
	:SetUsers(id)
	:Run()
end

---------------------------------

timer.Simple(1, function()
	vkapi:SendMLog('Бот запущен')
end)
