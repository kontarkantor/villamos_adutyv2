fx_version 'adamant'

game 'gta5'

description 'admin duty by 6osvillamos#0006 v2'

version '1.2.0'

ui_page('html/index.html') 

files {
	"icons/*.png",
	'html/index.html',
  	'html/index.js',
  	'html/style.css'
}

server_scripts {
	'config.lua',
	'server.lua'
}

client_scripts {
	'config.lua',
	'client.lua'
}

dependencies {
	'es_extended'
}