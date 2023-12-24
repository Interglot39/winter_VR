fx_version 'bodacious'
game 'gta5'

author '@interglot1' -- Twitter
description 'Survival'
version '1.0.0'

ui_page "ui/index.html"

files {
	"ui/index.html",
	"ui/sounds/*.ogg",
	"stream/**.ydr",
	"stream/**.ytd",
}

client_scripts {'client/*.lua'}

server_scripts {'@oxmysql/lib/MySQL.lua','server/*.lua'}

shared_scripts {'shared/*.lua'}

exports {
	'checkInGame'
}