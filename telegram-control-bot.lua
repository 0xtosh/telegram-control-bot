-- Telegram bot for command execution, file retrieval, photo and message exchange
-- Tom Van de Wiele 2017
--
-- Syntax for command execution: "x" followed by the command e.g. "!x pwd"
-- Syntax for file retrieval: "!get " followed by the desired file e.g. "!get passwords.txt"
--
now = os.time()    -- to reject old messages
destdir = "/home/bots/telegram/files"

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

function save_file(extra, success, file)
  if success then
      print(file)        -- filename where the media is stored
      print(extra[0])    -- sender name
      print(extra[1])    -- msg.id
      print(extra[2])    -- msg.date
  end
end

function get_receiver(msg)
  if msg.to.type == 'user' then
    return 'user#id'..msg.from.id
  end
  if msg.to.type == 'chat' then
    return 'chat#id'..msg.to.id
  end
  if msg.to.type == 'encr_chat' then
    return msg.to.print_name
  end
end 

function on_msg_receive (msg)
  if msg.date < now then
      return
  end

  if msg.out then
    return
  end

  local receiver = get_receiver(msg)

  -- if it's text
  if msg.text then
    mark_read (msg.from.print_name)
    -- if it's a command
    if string.sub(msg.text,1,2) == "!x " then
      local cmd = string.sub(msg.text, 4) -- strip off "!x "
      local fullcmd = cmd .. " 2>&1" -- make sure to catch stderr too
      local file = assert(io.popen(fullcmd, 'r')) -- read the cmd like a file handle
      local output = file:read('*all')
      file:close()
      send_msg (msg.from.print_name, output, ok_cb, false)

    -- if it's a file get request
    elseif string.sub(msg.text,1,5) == "!get " then
      local filepath = string.sub(msg.text, 6) -- strip off "!get "
      local cb_extra = {file_path=filepath} -- needed for path finding
      print ("file is: " .. filepath)
      if file_exists(filepath) then
        print ("we can read it")
        send_document (msg.from.print_name, filepath, rmtmp_cb, cb_extra)
      else 
        send_msg (msg.from.print_name, "File does not exist or not readable", ok_cb, false)
      end
    else
      send_msg (msg.from.print_name, "?", ok_cb, false)
    end
  end  

  -- if it's a file
  if msg.media then    ---check if msg is media
      mark_read (msg.from.print_name)
      a = {}
      a[0] = msg.from.print_name
      a[1] = msg.id
      a[2] = msg.date
      if msg.media == 'photo' then    ---check if photo
          print ("pic!")
          load_photo(msg.id, save_file, a)   ---load the photo
          view_photo(msg.id)
      end
 
  end
end

function on_our_id (id)
  print(id)
  postpone (postpone_cb, "", 1)
end

function on_secret_chat_created (peer)
end

function on_user_update (user)
end

function on_chat_update (user)
end

function on_get_difference_end ()
end

function on_binlog_replay_end ()
end