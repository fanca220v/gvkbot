local stringRand = string.Random || function(length)
	local length = tonumber( length )
    if length < 1 then return end
    local result = {}
    for i = 1, length do
        result[i] = string.char( math.random(32, 126) )
    end
    return table.concat(result)
end
local bot 	= LOADING_BOT
local db 	= bot:GetModule'database'
-- PrintTable({'e',bot,bot.modules})
-- print(db)

db.query('CREATE TABLE IF NOT EXISTS vk_sync(id INT, steamid BIGINT, date INT)')

local steam = function(vkid, steamid, msg)
	if(!vkid)||(!steamid)then return end
	db.query('SELECT * FROM vk_sync WHERE id=%s OR steamid=%s', function(d)
		if (!d) then
			db.query("INSERT INTO vk_sync VALUES(%s,%s,%s)", function(data)
				local t = vkid .." и ".. steamid .." теперь синхронизированы."
				bot:print("vksync: ".. t)
				if (msg) then
					msg:Reply(t)
				end
			end, vkid, steamid, os.time())
		else
			local t = vkid .." и ".. steamid .." уже синхронизированы."
			bot:print('vksync: '.. t)
			if (msg) then
				msg:Reply(t)
			end
			PrintTable(d)
		end
	end, vkid, steamid)
end
local setsteam = function(vkid, steamid, msg)
	if(!vkid)||(!steamid)then return end
	db.query('SELECT * FROM vk_sync WHERE id=%s OR steamid=%s', function(d)
		if (!d) then
			db.query("INSERT INTO vk_sync VALUES(%s,%s,%s)", nil, vkid, steamid, os.time())
		else
			db.query("UPDATE vk_sync SET steamid=%s, id=%s, date=%s WHERE id=%s", nil, steamid, vkid, os.time(), vkid)
		end
		local t = vkid .." и ".. steamid .." теперь синхронизированы."
		bot:print("vksync: ".. t)
		if (msg) then
			msg:Reply(t)
		end
	end, vkid, steamid)
end
local get = function(vkorsid,func)
	db.query('SELECT * FROM vk_sync WHERE id=%s OR steamid=%s', function(d)
		if func then func(d&&d[1]||false) end
	end,vkorsid,vkorsid)
end
local getall = function(func)
	db.query('SELECT * FROM vk_sync', function(d)
		if func then func(d&&d[1]||false) end
	end,vkorsid,vkorsid)
end

local tokens = {}
hook.Add("PlayerSay", 'vk.sync', function(p,t)
	if (string.lower(string.Trim(t))=='/vk') then
		local token = stringRand(32)
		if (tokens[p:SteamID64()]) then token = tokens[tostring(p:SteamID64())] end
		tokens[token] = tostring(p:SteamID64())
		tokens[tostring(p:SteamID64())] = token
		p:ChatPrint("[VK] ЧТОБЫ ПРИВЯЗАТЬ СВОЙ АККАУНТ")
		p:ChatPrint("[VK] ОТКРОЙТЕ БЕСЕДУ С БОТОМ В НАШЕЙ ГРУППЕ ВК")
		p:ChatPrint("[VK] И НАПИШИТЕ ЭТУ КОМАНДУ: /steam ".. tokens[tostring(p:SteamID64())])
	end
end)

bot:Command('/steam', function(msg,args,str,chat)
	local token = args[1]
	if (tokens[token]) then
		steam(msg:FromID(), tokens[token], msg)
	end
end)
bot:Command('/getallsteam', function(msg,args,str,chat)
	getall(function(data)
		if (!data) then return end
		msg:Reply(util.TableToJSON(data))
	end)
end, bot.IsAdmin)
bot:Command('/getsteam', function(msg,args,str,chat)
	get(msg:IsReply().from_id, function(data)
		if (data) then
			msg:Reply("Ваш профиль: https://steamcommunity.com/profiles/".. (data.steamid||"error") .."\nПривязан: ".. os.date("%d.%m.%Y",data.date))
			return
		else
			msg:Reply("Steam не привязан.")
			return
		end
		msg:Reply("че")
	end)
end)
bot:Command('/setsteam', function(msg,args,str,chat)
	setsteam(msg:IsReply().from_id, tostring(args[1])||0, msg)
end, bot.IsAdmin, "<steamid64>")

return {
	steam 	= steam,
	setsteam= setsteam,
	getall 	= getall,
	get 	= get
}