
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
author 'KevinGirardx'
lua54 'yes'
game 'gta5'

files {
    'shared/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
	'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

ox_libs {
	'math'
}

escrow_ignore {
    'configs/*.lua',
    'locales/*.json',
}