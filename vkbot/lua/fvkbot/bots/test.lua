local bot = vkapi.bot:Create(
	"test",
	"token"
)
bot:StartPoll()

bot:Command('echo', function(msg,args,str,chat)
	msg:Remove()
	return str
end)
bot:Command('/all', function(msg,args,str,chat)
	for k,v in pairs(vkapi.chats[bot:GetClass()]) do
		bot:SendMessage(v.last_message.peer_id, str, nil, function(data)
			data = data.response || 0
			-- timer.Simple(3,function()
			-- 	bot:Method("messages.delete", {
			-- 		message_ids = data,
			-- 		peer_id = v.last_message.peer_id,
			-- 		delete_for_all = 1
			-- 	}, function(data) PrintTable(data) end)
			-- end)
		end)
	end
	return 'Отправлено всем: '.. str
end)
