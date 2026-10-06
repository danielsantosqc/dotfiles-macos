# My Dotfiles - MacOs

Mi configuración de shell, scripts y proyectos pequeños. Pensado para que en una máquina nueva baste con clonar y ejecutar un instalador.

## Instalación en una máquina nueva

```bash
git clone <repo> ~/my-dotfiles
~/my-dotfiles/install.sh
```

`install.sh` hace siete cosas y **no usa `sudo`**:

1. Ajusta permisos (755 para lo ejecutable, 644 para el resto).
2. Enlaza `config/` a su sitio (respaldando lo que hubiera antes).
3. Deja `~/.zshrc` cargando `init.sh` (respaldando el anterior).
4. Avisa de prerrequisitos que falten.
5. Pregunta por `terminal-notifier` (la usa `bin/alert` para el banner).
6. Avisa si falta `yt-dlp`/`ffmpeg` (para `ytda`/`ytdv`).
7. Ofrece instalar otros programas que usamos (fórmulas y casks de brew).

En los bloques 5, 6 y 7 pregunta `[y/N]`: si dices `y` instala con `brew`, si dices `n` sigue con el resto.

## Estructura

```
my-dotfiles/
├── bin/
│   ├── alert
│   └── dockermon
├── config/
│   ├── gitconfig
│   ├── gitignore_global
│   └── starship.toml
├── manual-config/
│   └── vscode/
│       ├── keybindings.json
│       └── settings.json
├── shell/
│   ├── nodejs/
│   │   ├── nvm-config.sh
│   │   └── pnpm-config.sh
│   ├── utils/
│   │   ├── dev-commands.sh
│   │   ├── tools-functions.sh
│   │   └── yt-dlp-configs.sh
│   └── aliases.sh
├── tools/
│   ├── chargelimit/
│   │   ├── chargelimit
│   │   ├── chargelimit.conf
│   │   ├── install.sh
│   │   ├── local.chargelimit.plist
│   │   ├── README.md
│   │   ├── smc
│   │   └── uninstall.sh
│   └── run-work-mode/
│       ├── Work Mode.app/
│       │   └── Contents/
│       │       ├── Info.plist
│       │       └── MacOS/
│       │           └── dev-initiation
│       ├── README.md
│       ├── apps.conf
│       ├── dev.command
│       └── dev.sh
├── .gitignore
├── init.sh
├── install.sh
└── README.md
```

| Carpeta | Qué contiene | Cómo se usa |
|---|---|---|
| `init.sh` | punto de entrada | lo sourcea `~/.zshrc` |
| `shell/` | alias y funciones | lo sourcea `init.sh` |
| `bin/` | scripts sueltos | se ejecutan |
| `config/` | configuración enlazable | `install.sh` crea el symlink |
| `manual-config/` | referencia para copiar/pegar | tú, a mano |
| `tools/` | proyectos con instalador propio | `sudo tools/<x>/install.sh` |

La regla: **`shell/` se sourcea, `bin/` se ejecuta, `config/` se enlaza, `manual-config/` se copia, `tools/` se instala**. Meter algo en la carpeta equivocada es la única forma de romper esto.

### `shell/`

- `aliases.sh` — alias generales (`cat`, `ll`, `ports`, `dockermon`…)
- `nodejs/` — `nvm` y `pnpm`
- `utils/` — `dev-commands.sh` (chuletas), `tools-functions.sh` (`mkcd`, `listar`), `yt-dlp-configs.sh` (`ytda`/`ytdv`)

### `bin/`

- `dockermon` — tablero que se refresca con cada evento de Docker.
- `alert` — avisa (pitido + banner) cuando termina un proceso. `brew update | alert`, `alert -f` para alarma fuerte. Ayuda: `alert -h`.

### `tools/`

- `chargelimit/` — límite de carga al 80% por firmware (SMC). Ver su propio README.
- `run-work-mode/` — abre las apps de trabajo desde Spotlight. Ver su propio README.

## Cómo agregar cosas

- **Un alias o función** → un archivo `.sh` nuevo en `shell/` (se sourcea solo, no hay que registrarlo).
- **Un script para ejecutar** → `bin/`.
- **Una config enlazable** → `config/` y añade su `link` en `install.sh`.
- **Apps de trabajo** → edita `tools/run-work-mode/apps.conf`.

## Pendiente a mano

- **VS Code**: copiar `manual-config/vscode/*.json` a `~/Library/Application Support/Code/User/`.
- **chargelimit**: `sudo tools/chargelimit/install.sh` (necesita root para escribir en el SMC).
