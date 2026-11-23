# Modo de subasta por voz

## Idea general

Este modo es una opción adicional de **Subasta Ciega Argentina**. Los jugadores anuncian sus ofertas con el micrófono y el servidor las valida. Se elige de manera independiente del modo de contenido (**Family friendly** o **Sin límites**).

El estado actual del modo:

- El jugador dice «pujo» seguido del monto, por ejemplo «pujo doscientos mil». La oferta debe superar la anterior y respetar el saldo disponible.
- Una oferta en tono grave o agudo se multiplica por 2; el tono medio no la modifica.
- El reconocimiento usa Vosk y el modelo español pequeño en el navegador. La primera ejecución de `npm start` descarga el modelo oficial de 39 MB; requiere alrededor de 300 MB de memoria al usarlo.
- El audio se procesa localmente. El servidor recibe el texto reconocido, la categoría de tono y el nivel de actividad, pero no la grabación.
- No hay pujas manuales alternativas en este modo. La ruleta está desactivada temporalmente.

## Comando especial activo

Al reconocer el comando especial durante una subasta, todos los jugadores de la sala, incluido quien lo invoca, pierden todo su dinero y todos los objetos de su inventario. También se cancelan las ofertas activas para evitar que se cobre una puja después de perder el dinero. La sala anuncia: “exodia a sido invocado, todos los participantes sucumben ante su poder” y la partida termina inmediatamente.

## Diseño futuro de ruleta (desactivada)

Las reglas de esta sección describen una posible ampliación; no son funciones activas del modo actual.

## Funcionamiento acordado

- Cada jugador podrá **convocar la ruleta hasta dos veces por partida**.
- El anfitrión puede activar o desactivar el modo admin diciendo “modo admin”. En ese modo puede convocar la ruleta mediante un botón sin consumir sus usos normales y ajustar los temporizadores en pasos de ±10 segundos, sin reducirlos por debajo de 10 segundos.
- Cuando un jugador convoque la ruleta, todos los jugadores, incluso quien la convocó, podrán participar en ese giro.
- La ruleta se podrá convocar en cualquier momento, incluso durante una subasta. Mientras esté activa, la subasta quedará pausada.
- La ruleta dura **40 segundos** en total: 30 segundos para elegir una casilla y 10 segundos para mostrar el resultado antes de reanudar la subasta.
- Cada participación costará **$50.000** del dinero del juego.
- La participación estará abierta durante **30 segundos**.
- Cada participante podrá elegir **una casilla** por giro.
- Cada participante podrá anunciar por voz la casilla que predice. Vosk procesa el audio localmente; el servidor recibe solo el texto reconocido, no una grabación.
- Si varios participantes predicen correctamente una casilla con premio, cada acertante recibe el premio completo indicado en ella.
- Si se activa una casilla de penalización, el efecto se aplica una sola vez a todos los demás jugadores, hayan participado o no. Quien acertó queda exento.
- Si nadie acierta, el costo de participación no se devuelve.

## Flujo propuesto para un giro

1. Un jugador convoca la ruleta y consume uno de sus dos usos; también puede participar.
2. La subasta se pausa y se abre una ventana de 30 segundos para que los jugadores se sumen.
3. Cada participante paga $50.000 y anuncia una predicción; solo puede elegir una casilla.
4. El navegador reconoce la frase de cada participante. Se ofrecerán botones como alternativa para quienes no tengan reconocimiento de voz disponible o habilitado.
5. Al cerrarse la ventana, el servidor determina el resultado y lo comparte con toda la sala.
6. La interfaz anima la ruleta hasta la casilla resultante y aplica el premio o efecto correspondiente.
7. El resultado permanece visible durante 10 segundos y luego se reanuda la subasta pausada con el tiempo restante que tenía.

## Estructura prevista de la ruleta

La implementación inicial contempla **8 casillas**. Los valores y pesos se centralizan en `backend/game/voiceRouletteRules.js` y quedan sujetos a balance:

- 3 casillas de premios económicos.
- 2 casillas de pérdida de dinero.
- 2 casillas de información.
- 1 casilla especial.
- Pesos actuales: 18, 14, 2, 16, 16, 14, 14 y 6, respectivamente; el premio de $3.000.000 y la casilla especial tienen menor probabilidad.

## Casillas previstas

- Premios: +$100.000, +$300.000 y +$3.000.000. Cada acertante recibe el premio completo.
- Pérdidas: dos casillas de −$200.000. Si alguien acierta, el resto de los jugadores pierde hasta ese monto una sola vez; los acertantes quedan exentos.
- Información: nombre del próximo objeto o categoría del próximo objeto, entregada en privado a cada acertante.
- **Prenda:** cada acertante no puede pujar en la siguiente subasta.
- Si no hay acertantes, no se aplica premio/efecto y no se devuelve el costo de participación.

## Decisiones pendientes

Antes de cerrar el balance y ampliar los comandos hay que definir:

- Confirmar o ajustar los montos y pesos provisionales de las casillas.
- Definir qué pasa con las casillas de información cuando no queda un próximo objeto (actualmente no entregan información).
- Definir si los jugadores desconectados conservan premios o penalizaciones de un giro ya registrado.
- La compatibilidad del reconocimiento de voz depende del navegador y debe revisarse al desplegar.

## Consideraciones de diseño y técnica

- El servidor debe ser la autoridad para pausar y reanudar la subasta, cobrar la participación, validar las elecciones, generar el resultado y aplicar premios o penalizaciones. Así todos reciben el mismo resultado y el cliente no puede decidir la casilla ganadora.
- Al convocar la ruleta durante una subasta, se debe conservar el tiempo restante, mantener la partida pausada durante el giro de 40 segundos y reanudarla luego.
- El navegador solicita permiso y usa Vosk para transcribir localmente. El servidor recibe y valida el texto, nunca el audio.
- La interfaz muestra el texto reconocido para que el jugador lo revise y confirme. Si el navegador no está soportado o el permiso se rechaza, la voz se bloquea y se ofrece selección por botones, con dos usos manuales por jugador y partida.
- El servidor pausa y reanuda la subasta, cobra participaciones, valida las elecciones, sortea la casilla y aplica sus efectos.
- La versión Sin límites muestra tres advertencias: puede incluir temas polémicos o sensibles; algunos contenidos pueden herir sensibilidades; se recomienda elegirla solo si el grupo está cómodo con ello.
- Las reglas definitivas deben mantener las partidas apropiadas para el modo de contenido seleccionado.

## Estado

La subasta por voz está implementada con Vosk y el modelo local de español. La ruleta permanece desactivada por el momento; las reglas y casillas descritas arriba son una propuesta para una futura reactivación.
