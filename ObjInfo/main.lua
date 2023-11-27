--[[
	Project: Info
	Version: 1.0
	Author: OKeez
]] 

function print_r (t, indent, done)
  done = done or {}
  indent = indent or ''
  local nextIndent -- Storage for next indentation value
  if(t ~= nil) then
      for key, value in pairs (t) do
        if type (value) == "table" and not done [value] then
          nextIndent = nextIndent or
              (indent .. string.rep(' ',string.len(tostring (key))+2))
              -- Shortcut conditional allocation
          done [value] = true
          print (indent .. "[" .. tostring (key) .. "] => Table {");
          print  (nextIndent .. "{");
          print_r (value, nextIndent .. string.rep(' ',2), done)
          print  (nextIndent .. "}");
        else
          print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
        end
      end
   else
      print  (indent .. "[nil]")   
   end
end

function print_j(v)
   print("JSON:" .. encode(v))
end

local function help()
	print("Usage: /list [option] or /json [option]:")
	print("/list will dump option info in a tree-like printout.")
   print("/json will dump option info in JSON format")	
   print("    [p] [player]: dump player info")
   print("    [t] [target]: dump player target info")
   print("    [s] [skills]: dump abilities")
   print("    [bp] [buffplayer]: dump player buffs")
   print("    [bt] [bufftarget]: dump player target buffs")   
   print("    [cp] [castplayer]: dump player cast bar")
   print("    [ct] [casttarget]: dump player target cast bar")
   print("    [u] [units]: dump all viewable units")  
   print("    [u+] [unitsdetail]: dump detail of all viewable units") 
   print("    [cpu]: dump CPU usage info")
   print("    [doc]: dump API documentation info")
   print("    [mouse]: dump Mouse info")
   print("    [shard]: dump Shard info")
   print("    [lang]: dump Language info")
   print("    [tf] [timeframe]: dump Time Frame info")
   print("    [tr] [timereal]: dump Time Real info")
   print("    [ui]: dump UI Object info")	
end

function list(param)
   if( (param ~= nil) and (param ~= "")) then
   
      if (param == "help") then
         help()
      end
   
      if ((param == "skills") or (param == "s")) then
         local o = Inspect.Ability.List()
         print_r(Inspect.Ability.Detail(o))      
      end
      
      if ((param == "buffp") or (param == "bp")) then
         local o = Inspect.Buff.List("player")
         print_r(Inspect.Buff.Detail("player", o))      
      end 
      
      if ((param == "bufft") or (param == "bt")) then
         local o = Inspect.Buff.List("player.target")
         print_r(Inspect.Buff.Detail("player.target", o))      
      end  
      
      if ((param == "castp") or (param == "cp")) then
         print_r(Inspect.Unit.Castbar("player"))      
      end 
      
      if ((param == "castt") or (param == "ct")) then
         print_r(Inspect.Unit.Castbar("player.target"))      
      end  
      
      if ((param == "player") or (param == "p")) then
         print_r(Inspect.Unit.Detail("player"))      
      end 
      
      if ((param == "target") or (param == "t")) then
         print_r(Inspect.Unit.Detail("player.target"))      
      end 
      
      if ((param == "units") or (param == "u")) then
         print_r(Inspect.Unit.List())      
      end 
      
      if ((param == "unitsdetail") or (param == "u+")) then
         local o = Inspect.Unit.List()
         print_r(Inspect.Unit.Detail(o))      
      end                 
                          
      if (param == "cpu") then
         print_r(Inspect.Addon.Cpu())      
      end 
      
      if (param == "doc") then
         print_r(Inspect.Documentation())      
      end      
   
      if (param == "mouse") then
         print_r(Inspect.Mouse())      
      end 
      
      if ((param == "timereal") or (param == "tr")) then
         print(Inspect.Time.Real())      
      end       
           
      if ((param == "timeframe") or (param == "tf")) then
         print(Inspect.Time.Frame())      
      end            
            
      if (param == "ui") then
         print_r(UI)      
      end      
   
   else
   
      help()   
   
   end
end


function json(param)
   if( (param ~= nil) and (param ~= "")) then
   
      if (param == "help") then
         help()
      end
   
      if ((param == "skills") or (param == "s")) then
         local o = Inspect.Ability.List()
         print_j(Inspect.Ability.Detail(o))      
      end
      
      if ((param == "buffp") or (param == "bp")) then
         local o = Inspect.Buff.List("player")
         print_j(Inspect.Buff.Detail("player", o))      
      end 
      
      if ((param == "bufft") or (param == "bt")) then
         local o = Inspect.Buff.List("player.target")
         print_j(Inspect.Buff.Detail("player.target", o))      
      end  
      
      if ((param == "castp") or (param == "cp")) then
         print_j(Inspect.Unit.Castbar("player"))      
      end 
      
      if ((param == "castt") or (param == "ct")) then
         print_j(Inspect.Unit.Castbar("player.target"))      
      end  
      
      if ((param == "player") or (param == "p")) then
         print_j(Inspect.Unit.Detail("player"))      
      end 
      
      if ((param == "target") or (param == "t")) then
         print_j(Inspect.Unit.Detail("player.target"))      
      end 
      
      if ((param == "units") or (param == "u")) then
         print_j(Inspect.Unit.List())      
      end 
      
      if ((param == "unitsdetail") or (param == "u+")) then
         local o = Inspect.Unit.List()
         print_j(Inspect.Unit.Detail(o))      
      end                 
                          
      if (param == "cpu") then
         print_j(Inspect.Addon.Cpu())      
      end 
      
      if (param == "doc") then
         print_j(Inspect.Documentation())      
      end      
   
      if (param == "mouse") then
         print_j(Inspect.Mouse())      
      end 
      
      if ((param == "timereal") or (param == "tr")) then
         print(Inspect.Time.Real())      
      end       
           
      if ((param == "timeframe") or (param == "tf")) then
         print(Inspect.Time.Frame())      
      end            
            
      if (param == "ui") then
         print_j(UI)      
      end      
   
   else
   
      help()   
   
   end
end
table.insert(Command.Slash.Register("list"), {function (params) list(params) end, "ObjInfo", "Slash command"})
table.insert(Command.Slash.Register("json"), {function (params) json(params) end, "ObjInfo", "Slash command"})

