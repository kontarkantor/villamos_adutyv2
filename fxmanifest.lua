fx_version 'adamant'

game 'gta5'

description 'admin duty by 6osvillamos'

version '1.2.2'

ui_page 'html/index.html'

files {
	"icons/*.png",
	"html/**"
}

shared_scripts {
	'@es_extended/imports.lua',
	'config/shared.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
}

server_scripts {
	'config/server.lua',
	'server.lua'
}

client_scripts {
	'client.lua'
}

dependencies {
	'es_extended'
}
