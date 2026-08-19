#!/usr/bin/env bash
# La ventana que abre el item de kobo al hacer clic con el botón derecho.
#
# El popup de la barra entra en dos renglones por línea y corta los nombres.
# Acá corre el CLI de verdad, que ya se renderiza con rich —tabla, colores,
# ancho 100— así que no hay una segunda presentación que mantener sincronizada.
#
# Se cierra con Enter. El `read` va explícitamente contra /dev/tty: leyendo del
# stdin heredado volvía enseguida y la ventana se cerraba sola antes de que se
# pudiera leer nada (medido el 2026-08-19).
#
# Igual que el resto de estos dotfiles, no lleva ningún dato: llama a `kobo`,
# que vive en el repo privado.

KOBO="$HOME/.local/bin/kobo"
[ -x "$KOBO" ] || exit 0

cd "$HOME/kobo" 2>/dev/null || cd "$HOME" || exit 0

"$KOBO" alarma --siempre --sin-notificar
echo
"$KOBO" compromisos 2>/dev/null | head -20
echo
printf '  \033[2mEnter para cerrar\033[0m'
read -r _ </dev/tty
