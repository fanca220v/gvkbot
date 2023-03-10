vkapi.readed = {}
vkapi.chats = {}
function vkapi:GetMessage()
   self.chats = {}
   for k,bot in pairs(self.bots || {}) do
      self.chats[bot:GetClass()] = {}
      self.readed[bot:GetClass()] = self.readed[bot:GetClass()]||{}
      if (bot._ispoll) then
         self:RunMethod(bot, 'messages.getConversations', {}, function(data,_,_,_,req)
            data = istable(data) && data.response || false
            if (!istable(data)) then 
               vkapi:error(bot:GetClass() ..": ".. tostring(data))
               PrintTable({data})
               return
            end
            self.chats[bot:GetClass()] = data.items
            for k,v in pairs(data.items||{}) do
               if (v.last_message && v.last_message.attachment) then continue end -- soon
               local isnew = v.last_message && (!v.admin_author_id) && (os.time()-v.last_message.date)<(v.maxtime || 60) && (v.last_message.from_id>0)
               -- print(isnew==true)
               -- PrintTable({isnew==true && v.last_message, isnew==true && v.conversation})
               if isnew then

                  if (!v.last_message || self.readed[bot:GetClass()][v.last_message.id]) then 
                     -- vkapi:error(bot:GetClass() ..": ПОВТОР ПУШ СООБЩЕНИЯ")--, util.TableToJSON(data,true))

                     return
                  end

                  local type = self:MSGType(v)
                  local isaction = v.last_message.action || false
                  if (isaction) then
                     if (bot.OnAction) then
                        bot:OnAction(v.last_message, v.conversation)
                     end
                  else
                     if (bot.OnMessage) then
                        local text, keyboard = bot:OnMessage(v.last_message, v.conversation)
                        local inline = false
                        if (istable(keyboard)) then
                            inline = (keyboard.inline~=nil) || false
                            keyboard.inline = nil
                        end
                        -- print(inline)
                        if (text && isstring(text)) then
                           bot:SendMessage(v.last_message.peer_id, text, v.last_message.id, self.keyboard({
                              buttons = (istable(keyboard) && keyboard) || self.cfg.default_keyboard,
                              inline = (type==VK_TYPE_CHAT) || inline==true
                           }))
                        end
                     end
                  end

                  self.readed[bot:GetClass()][v.last_message.id] = true

               end
            end
         end)
      end
   end
end
timer.Create('vkapi.poll', 1, 0, function()
   vkapi:GetMessage()
end)