#!/bin/sh
savePath=/var/factorio/saves
saveFile=$savePath/${1:-default}.zip
if [ ! -d savePath ]; then
    echo "======================"
    echo "Creating new save game"
    echo "======================"
    factorio --create $saveFile --config /etc/factorio/config
fi

if [ -f /etc/factorio/map-gen-settings.json ]; then
    map_gen_settings='--map-gen-settings=/etc/factorio/map-gen-settings.json'
fi

if [ -f /etc/factorio/server-settings.json ]; then
    server_settings='--server-settings=/etc/factorio/server-settings.json'
fi

if [ -d /usr/share/factorio/mods ]; then
    mod_directory='--mod-directory=/usr/share/factorio/mods'
fi

echo "================="
echo "Starting Factorio"
echo "================="
factorio --start-server $saveFile \
    --config /etc/factorio/config \
    ${mod_directory} ${map_gen_settings} ${server_settings}
