#!/usr/bin/env bash
# Docker. En una máquina sin Docker el item no aporta nada, así que ni se agrega
# (los dotfiles se estiran a máquinas donde no está instalado).
#
# OJO: no alcanza con `command -v docker`. sketchybar arranca desde launchd con
# un PATH mínimo — /opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin — y el CLI de
# Docker Desktop vive en /usr/local/bin, que ahí no está. Se chequea también la
# app y el binario por ruta absoluta.
if ! [ -d /Applications/Docker.app ] \
   && ! [ -x /usr/local/bin/docker ] \
   && ! command -v docker >/dev/null 2>&1; then
    return 0
fi

# Nace oculto y lo prende el plugin si el daemon contesta: con el daemon caído
# el item no se dibuja, y así tampoco parpadea al arrancar la barra.
#
# updates=on es obligatorio. El `when_shown` que hereda de --default congela el
# item mientras no se dibuja, así que una vez apagado no volvería a correr el
# script y la ballena no reaparecería nunca al levantar Docker.
sketchybar --add item docker right \
           --set docker \
                 drawing=off \
                 updates=on \
                 icon="" \
                 update_freq=15 \
                 script="$PLUGIN_DIR/docker.sh" \
                 click_script="$PLUGIN_DIR/docker.sh open" \
           --subscribe docker system_woke
