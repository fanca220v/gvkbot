local chats = {
	stuff = 2000000003,
	hstuff = 2000000005,
	logs = 2000000004,
	clogs = 2000000006,
	players = 2000000001
}
local bot 	= LOADING_BOT
local sync 	= bot:GetModule'steam_sync'
--[[
{
   buttons = (istable(keyboard) && keyboard) || self.cfg.default_keyboard,
   inline = (type==VK_TYPE_CHAT) || inline==true
}
]]
--------------------------------------------------------------------------
function bot:SendLogMessage(chat, text, keyboardorfunc)
	self:SendMessage(chats[chat]||0, string.format([[
⚡ БОТ - %s
💜 Сервер: %s (%s)

> %s]], self:GetClass(), GetHostName(), game.GetIPAddress(), text), nil, keyboardorfunc)
end
--------------------------------------------------------------------------
hook.Add('PlayerInitialSpawn', 'vk.logs', function(ply)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s зашел на сервер.', ply:Name(), ply:SteamID(), ply:GetUserGroup()), vkapi.keyboard({
	   buttons = {
	   		{
	   			{text="/kick ".. (IsValid(ply) && ply:SteamID() || "-")},
				{text="/getprofile ".. (IsValid(ply) && ply:SteamID() || "-")}
	   		}
	   },
	   inline = true
	}))
end)
hook.Add('PlayerDisconnected', 'vk.logs', function(ply)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s вышел с сервера.', ply:Name(), ply:SteamID(), ply:GetUserGroup()))
end)
hook.Add('PlayerDeath', 'vk.logs', function(ply, wep, killer)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s помер от %s.', ply:Name(), ply:SteamID(), ply:GetUserGroup(), tostring(ply)), vkapi.keyboard({
	   buttons = {
	   		{
				{text="/ban ".. (IsValid(ply) && ply:SteamID() || "-") ..", 0, by VK", color = "negative"},
	   			{text="/kick ".. (IsValid(ply) && ply:SteamID() || "-")},
				{text="/getprofile ".. (IsValid(ply) && ply:SteamID() || "-")}
	   		}
	   },
	   inline = true
	}))
end)
hook.Add('PlayerWanted', 'vk.logs', function(ply, actor, reason)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s получил розыск, выдал: %s, причина:\n%s', ply:Name(), ply:SteamID(), ply:GetUserGroup(), tostring(actor), reason), vkapi.keyboard({
	   buttons = {
	   		{
				{text="/ban ".. (IsValid(ply) && ply:SteamID() || "-") ..", 0, by VK", color = "negative"},
	   			{text="/kick ".. (IsValid(ply) && ply:SteamID() || "-")},
				{text="/getprofile ".. (IsValid(ply) && ply:SteamID() || "-")}
	   		}
	   },
	   inline = true
	}))
end)
hook.Add('PlayerUnWanted', 'vk.logs', function(ply, actor)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s снял розыск %s', tostring(actor), ply:Name(), ply:SteamID(), ply:GetUserGroup()))
end)
hook.Add('PlayerWarranted', 'vk.logs', function(ply, actor, reason)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s получил ордер, выдал: %s, причина:\n%s', ply:Name(), ply:SteamID(), ply:GetUserGroup(), tostring(actor), reason), vkapi.keyboard({
	   buttons = {
	   		{
				{text="/ban ".. (IsValid(ply) && ply:SteamID() || "-") ..", 0, by VK", color = "negative"},
	   			{text="/kick ".. (IsValid(ply) && ply:SteamID() || "-")},
				{text="/getprofile ".. (IsValid(ply) && ply:SteamID() || "-")}
	   		}
	   },
	   inline = true
	}))
end)
hook.Add('PlayerUnWarranted', 'vk.logs', function(ply, actor)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s снял ордер %s', tostring(actor), ply:Name(), ply:SteamID(), ply:GetUserGroup()))
end)
hook.Add('PlayerArrested', 'vk.logs', function(ply, actor, reason)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s арестовал %s, причина:\n%s', ply:Name(), ply:SteamID(), ply:GetUserGroup(), tostring(actor), tostring(reason)), vkapi.keyboard({
	   buttons = {
	   		{
				{text="/ban ".. (IsValid(ply) && ply:SteamID() || "-") ..", 0, by VK", color = "negative"},
	   			{text="/kick ".. (IsValid(ply) && ply:SteamID() || "-")},
				{text="/getprofile ".. (IsValid(ply) && ply:SteamID() || "-")}
	   		}
	   },
	   inline = true
	}))
end)
hook.Add('PlayerUnArrested', 'vk.logs', function(ply, actor)
	bot:SendLogMessage('logs', string.format('%s(%s) - %s снял арест %s', ply:Name(), ply:SteamID(), ply:GetUserGroup(), tostring(actor)))
end)
hook.Add('PlayerSay', 'vk.logs', function(ply, text)
	bot:SendLogMessage('clogs', string.format('%s(%s) - %s:\n> %s', ply:Name(), ply:SteamID(), ply:GetUserGroup(), tostring(text)), vkapi.keyboard({
	   buttons = {
	   		{
				{text="/ban ".. (IsValid(ply) && ply:SteamID() || "-") ..", 0, by VK", color = "negative"},
	   			{text="/kick ".. (IsValid(ply) && ply:SteamID() || "-")},
				{text="/getprofile ".. (IsValid(ply) && ply:SteamID() || "-")}
	   		}
	   },
	   inline = true
	}))
end)
-------------------------------------------------------------------------
return {
	steam 	= steam,
	setsteam= setsteam,
	getall 	= getall,
	get 	= get
}