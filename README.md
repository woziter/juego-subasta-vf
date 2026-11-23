# Subasta Ciega Argentina

Juego de subastas multijugador en tiempo real. Los jugadores pujan por lotes ocultos, revelan la pieza al cerrar cada ronda y pueden pagar un peritaje para descubrir su valor real.

## Requisitos

- Node.js 18 o posterior
- npm

## Ejecutar

```bash
npm install
npm start
```

En Windows también puedes ejecutar `Iniciar servidor.bat`: crea un certificado HTTPS para las IP privadas activas, confía su CA en el almacén del usuario actual e inicia el servidor. El lanzador requiere OpenSSL. Desde la computadora usa `https://localhost:3443`; desde un celular, abre `https://<IP-del-servidor>:3443`.

Para confiar en el celular, transfiere `.certificates\local-root-ca.cer` al dispositivo e instálalo en los ajustes de Android como certificado de CA. La ubicación exacta depende de la versión de Android. Después, entra por HTTPS a una de las IP que muestra el lanzador. Si la IP de la computadora cambia, vuelve a ejecutar `Iniciar servidor.bat` para regenerar el certificado.

La clave privada de la CA queda en `%LOCALAPPDATA%\SubastaCiega\https-ca` y no se debe compartir. Las claves del servidor se guardan en `.certificates`, excluida de Git. Esta CA es solo para desarrollo local; no la uses en producción. La carpeta `portable` no incluye esta configuración.

### Version portable para Windows

La carpeta `portable` contiene el juego y dos accesos directos:

1. Ejecuta `Instalar dependencias.bat` una vez. Se necesita Node.js 18 o posterior y conexion a Internet para descargar las dependencias.
2. Ejecuta `Iniciar servidor.bat` para iniciar el juego en `http://localhost:3000`.

Puedes mover la carpeta `portable` a otra ubicacion o equipo Windows; instala Node.js en ese equipo y ejecuta primero el instalador de dependencias. `node_modules` se crea dentro de la propia carpeta. No se incluye la clave TLS local. El modo de voz puede requerir HTTPS segun el navegador.

En desarrollo local, el servidor puede usar HTTPS en `https://localhost:3443`. También redirige HTTP local a HTTPS. Para probar solo HTTP en desarrollo, configurá `HTTPS_ENABLED=false`.

### Confiar en el certificado local en Windows

`Iniciar servidor.bat` confía automáticamente la CA local solo para tu usuario de Windows. Si ejecutas `npm start` manualmente, se usa el certificado de `localhost`; para confiarlo por separado, ejecutá PowerShell desde la carpeta del proyecto:

```powershell
certutil -user -addstore Root .certificates\localhost-cert.pem
```

Esto agrega el certificado autofirmado únicamente al almacén de raíces de confianza de tu usuario de Windows. Cerrá y volvé a abrir el navegador y entrá a `https://localhost:3443`. Si el certificado local se regenera, repetí el comando para confiar en el nuevo certificado.

## HTTPS y acceso a cámara/micrófono

El servidor admite HTTPS directo cuando se configuran **ambas** variables de entorno:

- `HTTPS_KEY_PATH`: ruta a la clave privada PEM.
- `HTTPS_CERT_PATH`: ruta al certificado PEM (incluí la cadena intermedia si tu proveedor la entrega).
- `HTTPS_ENABLED`: `true` exige HTTPS; `false` permite HTTP explícitamente (solo desarrollo o detrás de un proxy TLS).
- `PORT`: puerto HTTPS opcional; por defecto es `3443` en modo TLS y `3000` en modo local HTTP.
- `HTTP_REDIRECT_PORT`: puerto HTTP que redirige a HTTPS en desarrollo; por defecto es `3000` y debe diferir de `PORT`.

El servidor verifica que el certificado esté vigente, tenga SAN y corresponda a la clave privada configurada. TLS 1.2 es la versión mínima. En producción, configurá ambas rutas de certificado; si TLS termina en un proxy, definí `HTTPS_ENABLED=false` y restringí el acceso al servidor para que solo sea alcanzable desde ese proxy.

Ejemplo en PowerShell:

```powershell
$env:HTTPS_KEY_PATH = "C:\certificados\privkey.pem"
$env:HTTPS_CERT_PATH = "C:\certificados\fullchain.pem"
$env:PORT = "3443"
npm start
```

Después abrí `https://localhost:3443` o el dominio cubierto por el certificado. El navegador debe confiar en el certificado; un certificado autofirmado puede mostrar una advertencia y no sirve para producción.

En producción, también se puede terminar TLS en un proxy inverso o plataforma de alojamiento. En ese caso, configurá allí el certificado y mantené el servidor de Node accesible solo desde el proxy. El proxy debe reenviar las conexiones WebSocket de Socket.IO. No expongas la clave privada en el repositorio: `.env.example` solo documenta los nombres de configuración.

HTTPS permite al navegador habilitar funciones de micrófono. La clave y el certificado local están excluidos de Git mediante `.gitignore`.

Para usar el modo de voz desde un celular, Chrome requiere una conexión HTTPS confiable. El certificado generado por `Iniciar servidor.bat` incluye las IP privadas activas del equipo; Android también debe confiar en la CA instalada desde `.certificates\local-root-ca.cer`.

## Reglas implementadas

- Cada jugador comienza con $1.000.000.
- La partida tiene 15 lotes y cada subasta dura 20 segundos.
- En algunas subastas, la silueta puede pertenecer a otro objeto; la pieza real se revela al cerrar el lote.
- La primera oferta es de $50.000; cada puja posterior aumenta $25.000.
- El mejor postor paga su oferta y recibe el objeto al revelarse el lote.
- En la revelación, los jugadores pueden tocar «Listo para continuar»; la siguiente ronda comienza cuando todos confirman o al cumplirse 20 segundos. Los bots confirman cuando lo hace un jugador.
- Cada peritaje cuesta $25.000 y determina un multiplicador aleatorio: x0,1, x0,5, x1,5 o x3.
- Al peritar un objeto, se reproduce el audio del tasador correspondiente al resultado.
- Los objetos se pueden vender por su valor de catálogo o, si fueron peritados, por el valor autenticado.
- El patrimonio final suma efectivo e inventario; gana el total más alto.
- El catálogo incluye 133 objetos; cada partida selecciona 15 lotes y los ultra legendarios tienen probabilidad reducida.
- El anfitrión puede completar lugares vacíos con bots de distintos perfiles de puja.
- Las salas y partidas viven en memoria y se reinician al apagar el servidor.

## Modo de subasta por voz

Al crear una sala, el anfitrión puede elegir **Subasta clásica** o **Subasta por voz**. Esa selección es independiente de **Family friendly** / **Sin límites**. Al elegir Sin límites se muestran tres advertencias sobre contenido polémico o sensible y la posibilidad de herir sensibilidades.

En el modo de subasta por voz:

- Decí el monto en frases naturales, por ejemplo «ofrezco 150 mil», «subo a 2 millones», «quiero pagar 750.000» o simplemente «doscientos mil». El monto hablado no puede superar tu saldo; la oferta efectiva debe superar la puja anterior. No hay una alternativa de puja manual en este modo.
- Cada subasta dura 35 segundos para dar más tiempo a hablar y confirmar la oferta.
- El texto que va reconociendo el micrófono aparece sobre el avatar de quien habla y lo ven los demás participantes.
- El reconocimiento usa Vosk y el modelo español pequeño, ejecutados localmente en el navegador. La primera vez, `npm start` descarga el modelo oficial (39 MB), verifica su SHA-256 y lo guarda en `public/models`; hace falta conexión a Internet solo para esa descarga inicial. El archivo local no se incluye en Git.
- El audio se procesa en el dispositivo y no se envía al servidor. Para validar una oferta, el servidor recibe el texto reconocido y la categoría de tono; también recibe el nivel de actividad para animar el avatar.
- El tono grave o agudo multiplica por 2 la oferta efectiva; el tono medio la deja igual. Al ganar, solo se descuenta del saldo el monto hablado, no el multiplicador.
- El navegador necesita permiso de micrófono, WebAssembly, Web Workers y una conexión segura (HTTPS o `localhost`). El modelo usa aproximadamente 300 MB de memoria mientras está cargado.
- La ruleta está desactivada temporalmente. Sus reglas en `backend/game/voiceRouletteRules.js` no forman parte de la partida activa.

Vosk y el modelo español `vosk-model-small-es-0.42` se distribuyen bajo licencia Apache 2.0.

## Bots y herramientas de prueba

En el lobby, el anfitrión puede agregar un bot o completar los lugares libres (hasta 8 jugadores). Los bots tienen estrategias distintas y pujan con un presupuesto limitado, sin conocer el lote oculto.

Para habilitar en desarrollo los controles de resultado de peritaje y revelación inmediata, definí `ENABLE_DEV_TOOLS=true` antes de iniciar. Los controles solo aparecen para el anfitrión. Mantené esta opción desactivada en producción.

## Estructura

- `backend/server.js`: arranque de Express, Socket.IO y ensamblado del juego.
- `backend/game/`: estado y reglas centrales de partidas, salas, jugadores, lotes y ruleta.
- `backend/services/`: casos de uso de pujas, peritajes y operaciones de inventario.
- `backend/sockets/`: handlers Socket.IO para salas, subastas e inventario.
- `backend/data/items.json`: catálogo de lotes.
- `readmeobjetos.md`: catálogo editable con valor y seguimiento de textura de los objetos.
- `backend/tests/`: pruebas automatizadas de las reglas del juego.
- `public/`: interfaz web adaptable a escritorio y móvil.

## Pruebas

```bash
npm test
```
