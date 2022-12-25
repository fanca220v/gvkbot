local over_admin = {
	[230438837] = true -- ID ADMINS
}
local bot = vkapi.bot:Create(
	"server", -- UID
	"<TOKEN>" -- TOKEN
)
bot:StartPoll()

local isadmin = function(msg)
	return over_admin[msg.from_id]||false
end
local isattachment = function(msg)end

local enginespew = ""
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

bot:Command('/json', function(msg,args,str,chat)
	-- PrintTable(msg)
	return util.TableToJSON(args[1]=="chat" && chat || msg,true)
end)
bot:Command('/ping', function(msg,args,str,chat)
	return "🤙 ".. bot:GetClass()
end)
bot:Command('echo', function(msg,args,str,chat)
	msg:Remove()
	return str
end)
bot:Command('/status', function(msg,args,str,chat)
	return string.format([[
%s 🤙:

✊ Игроки: %s/%s
🗻 Карта: %s
🔥 Бот uid: %s

ЗАЙТИ 👉 %s
	]], GetHostName(), #player.GetAll(), game.MaxPlayers(), game.GetMap(), bot:GetClass(), game.GetIPAddress())
end)
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
end)
bot:Command('/lua', function(msg,args,str,chat)
	if(!isadmin(msg))then return "Вы не администратор." end

	if(!args[1])then return "Отсутствует код" end
	enginespew = ""
	RunString(str)
	msg:Reply(string.format([[
Выпоняю код🤙:

%s
	]], str))
end)

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
end)
