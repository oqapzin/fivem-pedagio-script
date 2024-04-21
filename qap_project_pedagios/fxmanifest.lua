fx_version "adamant"
game "gta5"

shared_scripts {
  "@vrp/lib/utils.lua"
}

client_scripts{ 
  "client-side/client.lua",
  "config.lua"
}

server_scripts{ 
  "server-side/server.lua",
  "config.lua"
}