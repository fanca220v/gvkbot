local f = file.Find('fvkbot/bots/*.lua', "LUA")
for k,v in pairs(f) do
	vkapi:Include('bots/'.. v)
	vkapi:print(Color(0,255,0), '[BOT LOADER] ', Color(255,255,255), '"'.. string.upper(string.Replace(v,".lua","")) ..'" LOADED')
end
-- PrintTable(vkapi)