-- Tema "Taligent": paleta ANSI de 16 colores (misma que la barra de tmux y
-- el perfil de Windows Terminal). Ver DESIGN.md en la raiz del repo para la
-- paleta canonica y la justificacion del mapeo base16.
--
-- mini.base16 genera todos los grupos de highlight a partir del mapeo de 16
-- colores, asi que mantiene la coherencia con el resto del entorno.
return {
  -- Plugin que construye el tema desde la paleta base16.
  { "echasnovski/mini.base16", version = false, lazy = true },

  -- Indica a LazyVim que aplique Taligent al arrancar.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("mini.base16").setup({
          palette = {
            base00 = "#0A0809", -- fondo (black)
            base01 = "#141215", -- fondo claro / statusline (brightBlack)
            base02 = "#232021", -- seleccion / linea actual (derivado)
            base03 = "#5F5953", -- comentarios, numeros de linea (derivado, dim)
            base04 = "#A8A29A", -- foreground oscuro (blue)
            base05 = "#F8F5F0", -- foreground principal (brightWhite)
            base06 = "#F4EEE4", -- foreground claro (white / brightCyan)
            base07 = "#FFFFFF", -- el mas claro (derivado)
            base08 = "#EB7522", -- variables, errores (red)
            base09 = "#F4A91C", -- constantes, numeros (yellow)
            base0A = "#F7B728", -- clases, search (brightYellow)
            base0B = "#56B36A", -- strings, ok (green)
            base0C = "#B8B2A8", -- escapes, regex (cyan)
            base0D = "#F4A91C", -- funciones (amber, para enfasis)
            base0E = "#EB7522", -- keywords (orange = "purple" de la paleta)
            base0F = "#56B36A", -- deprecado / otros (green)
          },
          use_cterm = true,
        })
        vim.g.colors_name = "taligent"
      end,
    },
  },
}
