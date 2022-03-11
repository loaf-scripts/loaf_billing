fx_version "cerulean"
game "gta5"
lua54 "yes"

version "1.0.0"

shared_script "shared/*.lua"
server_script {
    "@mysql-async/lib/MySQL.lua",
    "@oxmysql/lib/MySQL.lua",
    "server/*.lua"
}
client_script "client/*.lua"

files {
    "html/index.html",
    
    "html/assets/css/*.css",

    "html/assets/img/*.png",
    "html/assets/img/*.jfif",
    "html/assets/img/*.jpg",
    "html/assets/img/*.jpeg",
    
    "html/assets/logos/*.png",

    "html/assets/js/*.js"
}
ui_page "html/index.html"

dependency "loaf_lib"
