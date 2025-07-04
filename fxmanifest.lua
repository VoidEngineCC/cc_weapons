fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Faction Selection System'
version '1.0.0'
lua54 'yes'

-- Server scripts
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

-- Client scripts
client_script 'client.lua'

-- UI
ui_page 'ui.html'

files {
    'ui.html',
    'https://fonts.googleapis.com/css2?family=Teko:wght@400;500;700&family=Electrolize&display=swap',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'
}