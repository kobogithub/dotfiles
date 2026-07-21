# Reporte de uso de tokens — Claude Code — 2026-07-15

Generado: 2026-07-16. Datos extraídos de los logs locales de sesión en `~/.claude/projects/*/*.jsonl` (todos los timestamps convertidos a hora local).

## Resumen

| Métrica | Valor |
|---|---|
| Tokens totales | 331.898.123 |
| Costo equivalente (precio API) | ~$742,85 |
| Modelo usado | 100% Claude Opus 4.8 |
| Cache read (contexto re-leído) | 97,5% del total |

**Diagnóstico principal:** el gasto no vino de contenido nuevo (input/output = 0,7% del total combinado). Vino de re-enviar contexto acumulado en sesiones largas, todo bajo el modelo más caro disponible.

## Por proyecto

| Proyecto | Tokens | % | Costo est. |
|---|---:|---:|---:|
| `~/Github/taligent/taligent_coe_framework` | 92.641.414 | 27,9% | $183,00 |
| `~/Github/personal/autogasto` | 74.639.130 | 22,5% | $160,82 |
| `~/taligent` | 68.823.311 | 20,7% | $162,89 |
| `~/Github/taligent/taligent_coe_dbt_duckdb` | 45.199.005 | 13,6% | $112,16 |
| `~/Github/taligent/taligent_app` | 29.927.629 | 9,0% | $64,52 |
| `~/.dotfiles` | 13.612.902 | 4,1% | $38,66 |
| `~/Github` | 4.171.224 | 1,3% | $11,83 |
| `~/Github/taligent/taligent_coe_databricks` | 2.652.596 | 0,8% | $7,70 |
| `~/Github/taligent/unilam_fabric` | 230.912 | 0,1% | $1,26 |

## Desglose por tipo de token

| Tipo | Tokens | % |
|---|---:|---:|
| Input nuevo | 231.288 | 0,1% |
| Output generado | 1.866.266 | 0,6% |
| Cache creation | 6.069.900 | 1,8% |
| **Cache read** | **323.730.669** | **97,5%** |

## Distribución horaria

Picos entre 13:00 y 14:00 (222M tokens en esas dos horas) — señal de sesión(es) larga(s) y pesadas sin reinicio de contexto.

```
09:00  ██   9.829.769
10:00  █    5.132.581
11:00  ██   8.220.118
12:00  █████████    31.588.600
13:00  ███████████████████████    82.441.616
14:00  ████████████████████████████████████████   140.158.077
15:00  —
18:00  231.746
20:00  █████   20.186.256
21:00  █████████   34.109.360
```

## Causas identificadas

1. **Sesiones largas sin `/clear` ni `/compact`.** El 97,5% de cache read indica que el historial completo se re-envía en cada turno. En sesiones de cientos de turnos esto crece de forma acumulativa (no lineal).

2. **Modelo pineado en Opus 4.8 para todo.** `.claude/settings.json` de al menos un proyecto (`taligent_coe_framework`) fija Opus 4.8 como default al reiniciar, sin importar qué modelo se elija con `/model` en la sesión.

3. **Framework de subagentes de `taligent_coe_framework` no aplica su propia estrategia de modelos.** El repo define una "Estrategia Cognitiva" (Planner=Thinking, ejecución=Balanced, QA=Fast) documentada en `CLAUDE.md` y en `tali-meta.json`, pero los archivos `.claude/agents/*.md` (backend, devops, security, documenter, frontend, qa, cobol) **no tenían frontmatter YAML real** — solo una línea de texto `**Modelo:** balanced` dentro del cuerpo, que Claude Code no interpreta. Resultado: todo subagente corría con el modelo activo de la sesión (Opus), no con el modelo más barato que el framework pretendía.
   - **Ya corregido en esta sesión**: se agregó frontmatter `model: sonnet` / `model: haiku` / `model: opus` a los 7 archivos de agentes en `taligent_coe_framework/.claude/agents/`.
   - **Pendiente**: si existen plantillas fuente en `blueprints/*/templates/claude/` usadas por `tali generate`, hay que replicar el fix ahí, o `tali generate` va a sobreescribir el arreglo.

## Estrategias de ahorro (a implementar)

1. **`/clear` entre tareas.** No arrastrar conversaciones largas de una tarea a otra — es la palanca de mayor impacto dado que 97,5% del gasto es cache read.
2. **Usar Sonnet para trabajo rutinario**, reservar Opus para diseño/arquitectura difícil. Revisar qué proyecto tiene Opus pineado en `settings.json` y evaluar si debe ser el default.
3. **`/compact` en sesiones que sí necesitan continuidad** en vez de dejar crecer el historial crudo.
4. **Delegar exploración amplia a subagentes** (Explore/Task) en vez de leer archivos grandes directo al contexto principal — así no quedan pesando en cada re-lectura de cache.
5. **En `taligent_coe_framework`**, terminar de propagar el fix de modelos por subagente a las plantillas fuente, y considerar por qué el proyecto tuvo el pico de uso más alto (92,6M tokens) — vale la pena revisar si hubo loops de `cargo build`/`cargo test` con output muy verboso quedando atrapado en el contexto vía los hooks (`PreToolUse: tali workflow guard`, `Stop: tali validate`).

## Notas metodológicas

- Costos estimados con precios de lista de la API de Anthropic (Opus 4.8: $15/$75 por millón input/output, cache write $18,75, cache read $1,5 por millón). No reflejan necesariamente el plan de suscripción real del usuario.
- Deduplicado por `requestId`/`message.id` cuando estaba disponible.
- Rango: 2026-07-15T00:00 a 2026-07-15T23:59 hora local.
