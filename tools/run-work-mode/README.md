# run-work-mode

Abre de una vez las apps de trabajo. Las que ya están abiertas no se tocan.

Lista actual: Safari, Terminal, Docker, Insomnia, Zap, Chrome y VS Code.

## Uso

**Desde Spotlight** (lo normal): `Cmd + Espacio` → escribe **`Work Mode`** → `Enter`.

No abre ninguna ventana y no deja procesos: corre en segundo plano y termina solo.

Desde una terminal:

```bash
~/my-dotfiles/tools/run-work-mode/dev.sh            # abre lo que falte
~/my-dotfiles/tools/run-work-mode/dev.sh --dry-run  # muestra qué haría, sin abrir nada
~/my-dotfiles/tools/run-work-mode/dev.sh --list     # lista y valida las apps configuradas
```

## Agregar o quitar apps

Se edita **`apps.conf`**: una ruta completa por línea, en el orden en que quieres que se abran.

```
/Applications/Safari.app
/Applications/Spotify.app
```

- Para agregar: añade la línea de la app.
- Para quitar: borra su línea.
- Para desactivarla sin borrarla: ponle `#` delante.
- `~` se expande a tu carpeta de usuario, y las líneas vacías se ignoran.

Luego valida las rutas:

```bash
~/my-dotfiles/tools/run-work-mode/dev.sh --list
```

Todas deben decir `ok`. Si alguna dice `NO EXISTE`, esa app no se abrirá (ruta mal escrita o app desinstalada).

No hay que reinstalar ni tocar el código: tanto la app de Spotlight como `dev.sh` leen el mismo `apps.conf`.

## Archivos

| Archivo | Qué es |
|---|---|
| `apps.conf` | la lista de apps — **edita aquí** |
| `Work Mode.app` | lanzador para Spotlight, sin ventana |
| `dev.sh` | el script (la lógica) |
| `dev.command` | lanzador alternativo: abre una ventana de Terminal, que queda abierta al terminar |

Si algo falla al lanzar desde Spotlight, revisa `/tmp/work-mode.log`: ahí queda el mismo resumen de la última ejecución.
