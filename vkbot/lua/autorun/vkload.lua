if CLIENT then return end

vkapi = setmetatable({},{})
vkapi.version = "24.12.2022 [first]"
function vkapi:error(...)
	MsgC(Color(255,0,0), "[VK err] ", Color(255,255,255), ...)
	Msg('\n')
end
function vkapi:print(...)
	MsgC(Color(0,120,255), "[VK] ", Color(255,255,255), ...)
	Msg('\n')
end
function vkapi:Include(file)
	include('fvkbot/'.. file)
end
function vkapi:IncludeFolder(fold,recurse)
	local f,d = file.Find('fvkbot/'.. fold ..'/*', "LUA")
	for k,v in pairs(f) do
		self:Include(fold .. "/".. v)
	end
	if recurse then
		for k,v in pairs(d) do
			self:IncludeFolder(fold .. "/".. v)
		end
	end
end
function vkapi:Load()
	self:Include('init.lua')
	self:print(Color(0,255,0), '[LOADER] ', Color(255,255,255), 'FULL LOADED - version: '.. self.version)
	-- self:Include("core/bots.lua")
end
hook.Add('serv.fullload', 'vkapi.load', function()
	vkapi:Load()
end)


--------------------------------
if (!serv) then

timer.Simple(.1, function()
	hook.Run('serv.fullload')
end)

end