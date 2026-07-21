# DESIGN.md — Paleta Taligent

Paleta de color canónica del entorno (terminal, tmux y Neovim). Mantener este
documento como única fuente de verdad: si cambia un color, actualizarlo aquí y
propagarlo a los consumidores listados abajo.

## Paleta ANSI de 16 colores (formato Windows Terminal)

```json
{
  "name": "Taligent",
  "background": "#0A0809",
  "foreground": "#F8F5F0",
  "cursorColor": "#F4A91C",
  "selectionBackground": "#141215",

  "black":         "#0A0809",
  "red":           "#EB7522",
  "green":         "#56B36A",
  "yellow":        "#F4A91C",
  "blue":          "#A8A29A",
  "purple":        "#EB7522",
  "cyan":          "#B8B2A8",
  "white":         "#F4EEE4",

  "brightBlack":   "#141215",
  "brightRed":     "#EB7522",
  "brightGreen":   "#56B36A",
  "brightYellow":  "#F7B728",
  "brightBlue":    "#B8B2A8",
  "brightPurple":  "#F4A91C",
  "brightCyan":    "#F4EEE4",
  "brightWhite":   "#F8F5F0"
}
```

## Carácter de la paleta

Esquema cálido casi monocromo: fondo negro cálido (`#0A0809`), grises cálidos
para texto secundario (`blue`/`cyan` son en realidad grises), y tres acentos
reales — **naranja** (`#EB7522`), **ámbar** (`#F4A91C` / `#F7B728`) y **verde**
(`#56B36A`). El cursor es ámbar.

## Mapeo a base16 (Neovim / mini.base16)

Neovim usa `mini.base16` para generar todos los highlights desde 16 tonos
base16. Algunos tonos de fondo/primer plano intermedios se **derivan** (no están
en la paleta ANSI) para que selección y comentarios sean legibles:

| base16 | hex       | rol                              | origen        |
|--------|-----------|----------------------------------|---------------|
| base00 | `#0A0809` | fondo                            | black         |
| base01 | `#141215` | fondo claro / statusline         | brightBlack   |
| base02 | `#232021` | selección / línea actual         | derivado      |
| base03 | `#5F5953` | comentarios, números de línea    | derivado      |
| base04 | `#A8A29A` | foreground oscuro                | blue          |
| base05 | `#F8F5F0` | foreground principal             | brightWhite   |
| base06 | `#F4EEE4` | foreground claro                 | white         |
| base07 | `#FFFFFF` | el más claro                     | derivado      |
| base08 | `#EB7522` | variables, errores               | red           |
| base09 | `#F4A91C` | constantes, números              | yellow        |
| base0A | `#F7B728` | clases, search                   | brightYellow  |
| base0B | `#56B36A` | strings, ok                      | green         |
| base0C | `#B8B2A8` | escapes, regex                   | cyan          |
| base0D | `#F4A91C` | funciones                        | yellow (énfasis) |
| base0E | `#EB7522` | keywords                         | purple        |
| base0F | `#56B36A` | deprecado / otros                | green         |

## Consumidores

- **Neovim (LazyVim):** `nvim/.config/nvim/lua/plugins/colorscheme.lua` —
  colorscheme `taligent` vía `mini.base16`.
- **tmux:** barra de status personalizada con esta paleta (commit `5cc34e5`).
- **Terminal:** perfil "Taligent" de Windows Terminal (JSON de arriba).
