local function user_print_name(user)
   if user.print_name then
      return user.print_name
   end
   local text = ''
   if user.first_name then
      text = user.last_name..' '
   end
   if user.lastname then
      text = text..user.last_name
   end
   return text
end

local function returnids(cb_extra, success, result)
   local receiver = cb_extra.receiver
   --local chat_id = "chat#id"..result.id
   local chat_id = result.id
   local chatname = result.print_name

   local text = 'IDs for chat '..chatname
      ..' ('..chat_id..')\n'
      ..'در این گروه '..result.members_num..' ممبر وجود دارد !'
      ..'\n---------\n'
      i = 0
   for k,v in pairs(result.members) do
      i = i+1
      text = text .. i .. ". " .. string.gsub(v.print_name, "_", " ") .. " (" .. v.id .. ")\n"
   end
   send_large_msg(receiver, text)
end

local function username_id(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local qusername = cb_extra.qusername
   local text = 'کاربر '..qusername..' در این گروه یافت نشد !'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == qusername then
      	text = 'آیدی برای یوزرنیم\n'..vusername..' : '..v.id
      end
   end
   send_large_msg(receiver, text)
end

local function run(msg, matches)
   local receiver = get_receiver(msg)
   if matches[1] == "!id" then
      local text = 'نام : '.. string.gsub(user_print_name(msg.from),'_', ' ') .. '\nآیدی : ' .. msg.from.id
      if is_chat_msg(msg) then
         text = text .. "\n\nشما در این گروه هستید : " .. string.gsub(user_print_name(msg.to), '_', ' ') .. " (آیدی: " .. msg.to.id  .. ")"
      end
      return text
   elseif matches[1] == "chat" then
      -- !ids? (chat) (%d+)
      if matches[2] and is_sudo(msg) then
         local chat = 'chat#id'..matches[2]
         chat_info(chat, returnids, {receiver=receiver})
      else
         if not is_chat_msg(msg) then
            return "شما در گروه نیستید !"
         end
         local chat = get_receiver(msg)
         chat_info(chat, returnids, {receiver=receiver})
      end
   else
   	if not is_chat_msg(msg) then
   		return "تنها در گروه کار میکند !"
   	end
   	local qusername = string.gsub(matches[1], "@", "")
   	local chat = get_receiver(msg)
   	chat_info(chat, username_id, {receiver=receiver, qusername=qusername})
   end
end

return {
   description = "Know your id or the id of a chat members.",
   usage = {
      "!id: Return your ID and the chat id if you are in one.",
      "!ids chat: Return the IDs of the current chat members.",
      "!ids chat <chat_id>: Return the IDs of the <chat_id> members.",
      "!id <username> : Return the id from username given."
   },
   patterns = {
      "^!id$",
      "^!ids? (chat) (%d+)$",
      "^!ids? (chat)$",
      "^!id (.*)$"
   },
   run = run
}
