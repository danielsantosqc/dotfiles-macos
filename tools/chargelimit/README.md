# chargelimit

Límite de carga real para MacBook con Apple Silicon, aplicado **a nivel de firmware** vía claves SMC. La carga se detiene en el porcentaje configurado y el Mac sigue alimentándose del adaptador de corriente: no hay bucle de software, no se fuerza descarga y no se cicla la batería.

Surgió porque [`actuallymentor/battery`](https://github.com/actuallymentor/battery) (v1.3.4 / v1.4.0) no soporta el firmware de este equipo y su límite nunca llegaba a aplicarse.

## Requisitos

- Mac con **Apple Silicon**.
- Firmware que exponga las claves `bfD0` / `bfE0` / `bfF0` (rango `20xxx`, p. ej. `mBoot-20457.1.29`). En esos equipos **ya no existen** `CH0B` / `CH0C` / `CHTE`, que son las que usa la app `battery`.
- macOS **sin la barrera de entitlement** que Apple añadió después: el kernel de macOS 26/27 protege estas claves con `com.apple.private.iokit.soc-limit`. En macOS 15.8 son escribibles.

Comprobar si tu Mac tiene las claves:

```bash
sudo /usr/local/lib/chargelimit/smc -k bfD0 -r
# "no data" o "Error: SMCReadKey() = e00002c1"  ->  no sirve
# [ui32] 0 (bytes 00 00 00 00)                  ->  OK
```

## Instalación

```bash
git clone <este-repo>    # o simplemente copia la carpeta
cd ~/my-dotfiles/chargelimit
sudo ./install.sh
```

Contenido de la carpeta:

| Archivo | Qué es |
|---|---|
| `chargelimit` | el comando |
| `smc` | binario que lee/escribe el SMC, **incluido** (arm64, 53 KB) |
| `local.chargelimit.plist` | LaunchDaemon que re-aplica al arrancar |
| `chargelimit.conf` | ajuste por defecto: `80 75` |
| `install.sh` / `uninstall.sh` | instalador / desinstalador |

El instalador:

1. Usa el binario `smc` **incluido en esta carpeta** (no necesita internet) y lo instala en `/usr/local/lib/chargelimit/smc`. Si faltara, cae en descargarlo desde `actuallymentor/battery`.
2. Instala el comando en `/usr/local/bin/chargelimit`.
3. Crea `/usr/local/etc/chargelimit.conf` **solo si no existe** (no pisa tu ajuste).
4. Instala y carga el LaunchDaemon, que re-aplica el límite en cada arranque.

## Uso

```bash
chargelimit              # ver estado actual (sin sudo)
chargelimit --help       # todas las opciones (-h o help tambien valen)
sudo chargelimit 80      # limite 80% (reinicia la carga por debajo de 75%)
sudo chargelimit 90 85   # rango personalizado: superior 90 / inferior 85
sudo chargelimit off     # desactiva el limite -> carga hasta 100%
sudo chargelimit apply   # re-aplica lo guardado en el config (lo hace el daemon al arrancar)
```

Salida típica de `chargelimit` con el límite activo:

```
Ajuste guardado : 80 75
Limite activo   : superior 80%  /  inferior 75%

  Now drawing from 'AC Power'
   -InternalBattery-0 (id=...)  80%; AC attached; not charging present: true
  Corriente       : 0 mA  (la bateria ni carga ni descarga)
```

`Corriente` es la linea que de verdad importa: en mA, con signo (`+` entra a la bateria, `-` sale) y los vatios equivalentes. **`0 mA` con el adaptador puesto significa que el limite esta actuando**; una cifra negativa solo quiere decir que estas desenchufado y el Mac tira de bateria.

## Casos de uso

| Situación | Comando |
|---|---|
| Día a día en el escritorio | `sudo chargelimit 80` |
| Salir de viaje y necesito el 100% | `sudo chargelimit off` |
| Volver a la rutina | `sudo chargelimit 80` |
| Revisar qué está pasando | `chargelimit` |

`off` también se guarda en el config, así que un reinicio **no** reactiva el límite por sorpresa.

## Archivos

| Ruta | Qué es |
|---|---|
| `/usr/local/lib/chargelimit/smc` | binario que lee/escribe el SMC |
| `/usr/local/bin/chargelimit` | el comando |
| `/usr/local/etc/chargelimit.conf` | ajuste persistente (`80 75` o `off`) |
| `/Library/LaunchDaemons/local.chargelimit.plist` | re-aplica al arrancar (`RunAtLoad`) |
| `/var/log/chargelimit.log` | stdout/stderr del daemon (vacío = sin errores) |

Sin regla en `sudoers`: cambiar el límite pide contraseña, a propósito. El daemon sí corre como root, porque escribir en el SMC lo requiere.

## Cómo funciona

El firmware gestiona el rango de carga con tres claves SMC:

| Clave | Tipo | Valor |
|---|---|---|
| `bfF0` | ui8 | `00` = límite inactivo · `02` = límite activo |
| `bfD0` | ui32 | límite superior (en el primer byte) |
| `bfE0` | ui32 | límite inferior: donde se reanuda la carga |

Secuencia aplicada por el comando y por el daemon:

```bash
smc -k bfF0 -w 00            # reset
smc -k bfD0 -w 50000000      # superior: 0x50 = 80%
smc -k bfE0 -w 4B000000      # inferior: 0x4B = 75%
smc -k bfF0 -w 02            # activar
```

El valor va en el primer byte, con el resto a cero: `printf '%02x000000' <porcentaje>`. Referencias: `50`=80, `4B`=75, `5A`=90, `3C`=60.

Con el límite activo, apenas se alcanza el superior la corriente hacia la batería queda en `0` y el adaptador pasa a alimentar el Mac. Al bajar del inferior, la carga se reanuda.

## Desinstalación

```bash
cd ~/my-dotfiles/chargelimit
sudo ./uninstall.sh
```

Desactiva el límite (la batería vuelve a cargar al 100%), descarga el daemon y borra el comando, el binario, el config y el log. El ajuste vive en el SMC, así que desinstalar no lo deja aplicado.

## Advertencias

- **No es una función oficial de Apple.** Es escribir directo en el SMC; se ha verificado en este equipo pero no hay garantía de que se comporte igual en otro modelo o firmware.
- **Actualizar a macOS 26 o 27 probablemente rompa esta vía**: esas versiones protegen las claves con entitlement. `chargelimit` fallará de forma visible y quedará registrado en `/var/log/chargelimit.log`. La alternativa entonces es el *Charge Limit* nativo de macOS 26.4+ (Ajustes → Batería).
- **No verificado tras un reinicio completo.** Sí se verificó que el daemon carga al arrancar y que `chargelimit apply` restaura el límite desde el config. Comprueba con `chargelimit` después del próximo reinicio.
- **Un solo dueño del límite.** No uses esto a la vez que `battery`, AlDente u otro limitador: se pelearán por el mismo estado.
- El binario `smc` es de terceros: [hholtmann/smcFanControl](https://github.com/hholtmann/smcFanControl) (carpeta `smc-command`), redistribuido en `actuallymentor/battery` (`dist/smc`). Es `arm64`, así que **no funciona en Macs Intel**.
- Licencia del binario: **GPL-2.0**. Para uso personal no cambia nada, pero si algún día publicas esta carpeta, esa licencia obliga a acompañar el código fuente o un enlace a él.
- Integridad: `shasum -a 256 smc` debe devolver `e3b4392c966dee700f3e1d6cc3812c0d487954c3d6d77b91f521a9590aadae44`. Ese mismo binario es el que está en uso en `/usr/local/lib/chargelimit/smc`.

## Historial

- El equipo tenía la app `battery` con mantenimiento al 80%, pero el log mostraba `smc charging unknown` y la batería llegaba igual al 100%: la app escribe en `CH0B`/`CH0C`/`CHTE`, que este firmware eliminó.
- El soporte para el firmware nuevo existe en dos PRs sin mergear: [actuallymentor/battery#469](https://github.com/actuallymentor/battery/pull/469) y [charlie0129/batt#142](https://github.com/charlie0129/batt/pull/142). De ahí salió la secuencia `bfF0`/`bfD0`/`bfE0`.
- `battery` fue desinstalado por completo (binarios, LaunchAgent, `sudoers`, preferencias y app).

## Verificado en

- MacBook Pro 18,1 (M1 Pro), macOS 15.8, firmware `mBoot-20457.1.29`.
- Resultado: `80%; AC attached; not charging`, `InstantAmperage = 0`, con el adaptador conectado.
