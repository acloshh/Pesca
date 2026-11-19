# Documento de Diseño de Juego (GDD) – [Título Provisional]

## 1. Resumen Ejecutivo (High Concept)
* **Concepto:** Juego de pesca arcade en 2D con vista lateral inspirado en *Gold Miner Classic*. El jugador controla a un pescador que se desplaza sobre el río, lanza su anzuelo de forma parabólica y debe interceptar peces en movimiento antes de que se agote el tiempo para cumplir una meta monetaria.
* **Género:** Arcade / Acción casual / Gestión ligera.
* **Tono y Ritmo:** Frenético, directo y rejugable. Enfocado en la presión del reloj, reflejos y toma de decisiones rápidas (riesgo vs. recompensa).
* **Plataforma objetivo:** PC (lanzamiento inicial), con diseño de interfaz y controles escalables para dispositivos móviles (Android/iOS).
* **Motor Gráfico:** Godot Engine 4.x.
* **Dirección de Arte:** 2D Pixel Art (basado en el paquete *Free Fishing Pixel Art Pack*).
* **Alcance de Producción:** Desarrollador en solitario (*Solo Dev*).

### 1.1. Especificaciones Técnicas y Adaptación de Pantalla
* **Resolución Base:** `1920x1080` (relación de aspecto 16:9).
* **Modo de Ventana (PC):** Pantalla completa exclusiva (*Exclusive Fullscreen*) por defecto para minimizar la latencia de entrada (*input lag*) en mecánicas arcade.
* **Escalado Multipantalla (PC y Móviles):**
  * Configuración en Godot 4 mediante *Stretch Mode* (`viewport` para mantener la nitidez del *pixel art* o `canvas_items` para escalado suave) combinado con *Stretch Aspect* (`keep` o `expand`).
  * **Interfaz Adaptativa (UI):** Todos los elementos del HUD y menús deben estructurarse mediante nodos `Control` con anclajes (*Anchors*) y márgenes relativos (*Containers*) para adaptarse sin deformaciones a monitores ultrawide, resoluciones menores y pantallas de celulares (ej. 19.5:9 o 20:9).
  * **Área Segura (*Safe Area*):** En la adaptación móvil, el HUD deberá respetar los márgenes de cámaras frontales (*notches*) y bordes curvos.

---

## 2. Bucle de Juego (Core Gameplay Loop)

### Micro-Loop (Segundo a segundo)
1. **Posicionamiento:** El jugador mueve al pescador horizontalmente para alinearse con el flujo de los peces.
2. **Lanzamiento:** Calcula la distancia y carga la fuerza para lanzar el anzuelo en arco parabólico hacia el agua.
3. **Intercepción:** El anzuelo desciende verticalmente por el agua buscando impactar un pez (evitando basura).
4. **Recogida (Tensión):** Al enganchar un objetivo, el jugador pulsa repetidamente un botón para recoger el hilo y subir la captura.
5. **Recompensa:** La captura llega a la superficie, se convierte en dinero y se suma al progreso de la meta del nivel.

### Macro-Loop (Nivel a nivel)
1. **Desafío:** Completar la meta de dinero del nivel antes de que el temporizador llegue a cero.
2. **Resolución:** 
   * *Éxito:* Pantalla de **"Nivel Superado"** con dos opciones: **Continuar a la Tienda** o **Salir al Menú Principal**.
   * *Fracaso:* Pantalla de *Game Over* con opción de reintentar o volver al menú.
3. **Progresión (Tienda):** El jugador invierte el dinero acumulado en mejoras permanentes (cañas, carrete) o potenciadores temporales.
4. **Escalada:** Inicio del siguiente nivel con una meta de dinero más alta y patrones de peces más complejos.

---

## 3. Mecánicas Principales y Controles

### 3.1. Movimiento del Pescador
* El personaje puede desplazarse libremente en el eje X (izquierda/derecha) dentro de los límites de la pantalla sobre la superficie del río.
* **Restricción de estado:** El pescador **no puede moverse** mientras el anzuelo está en el agua o siendo recogido (esto obliga a posicionarse bien antes de lanzar).

### 3.2. Lanzamiento Parabólico y Descenso
* **Fase Aérea:** Al mantener pulsado el botón de acción, se carga una barra de fuerza (o indicador visual). Al soltar, el anzuelo sale disparado en una trayectoria parabólica determinada por la fuerza acumulada.
* **Fase Acuática:** Al entrar en contacto con la superficie del agua, el impulso horizontal se detiene y el anzuelo comienza a hundirse en línea recta vertical a una velocidad constante.
* Si el anzuelo llega al fondo del río sin golpear nada, inicia el retorno a la superficie.

### 3.3. Captura y Recogida Activa
* Al colisionar el anzuelo con un pez o basura, el objeto queda enganchado y cambia el estado del jugador a **"Recogiendo"**.
* El jugador debe realizar pulsaciones rápidas (*tapping*) del botón de acción para elevar el anzuelo.
* **Factor Peso:** Cada entidad tiene un atributo de `peso`. A mayor peso, menor distancia sube el anzuelo por cada pulsación, consumiendo más tiempo valioso del reloj.
* **Potenciador de Carrete Automático:** Cuando está activo, anula la necesidad de pulsar repetidamente y sube cualquier captura a velocidad constante automática durante un tiempo limitado.

### 3.4. Esquema de Controles (PC y Apertura Móvil)

| Acción | Control en PC (Teclado/Ratón) | Adaptación a Móvil (Táctil) |
| :--- | :--- | :--- |
| **Mover Pescador** | Teclas `A`/`D` o `Flechas Izq/Der` | Botones virtuales en pantalla o deslizar en la zona superior |
| **Cargar y Lanzar** | Mantener y soltar `Espacio` o `Clic Izq` | Mantener y soltar botón de acción (zona derecha) |
| **Recoger Hilo** | Pulsar repetidamente `Espacio` o `Clic Izq` | Tocar repetidamente en cualquier parte de la pantalla (o botón de acción) |
| **Usar Potenciador** | Teclas numéricas (`1`, `2`, `3`) | Tocar el ícono del potenciador en el HUD |