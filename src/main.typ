
// --- Importaciones ---
// Se mantienen tus importaciones originales
#import "@preview/touying:0.6.1": *
#import themes.university: *
// Usar cetz 4.0 ó 4.1 con cetz-plot 1.1 ó 1.2 crashea
// lo más actual que funciona es 3.4 con 1.1
#import "@preview/cetz:0.3.4" // caja fundamental para crear formas
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import "@preview/cetz:0.3.4": canvas, draw
#import draw: circle, content, line, rect
#import "@preview/cetz-plot:0.1.1"
#import "@preview/cetz-plot:0.1.1": chart

#import "@preview/tiaoma:0.3.0": qrcode

// --- Reglas 'show' y Configuración del Tema ---
// Primero se configura el tema y luego se aplica la regla de Theorion
#show: university-theme.with(
  aspect-ratio: sys.inputs.at("aspect-ratio", default: "16-9"),
  align: horizon,
  config-common(handout: sys.inputs.at("handout", default: "false") == "true"),
  config-common(frozen-counters: (theorem-counter,)),
  config-info(
    title: text(size:0.9em)[Exploración de modelos Transformers y su Interpretabilidad
      Mecanicista],
    subtitle: [Proyecto de investigación, parte 2],
    author: [Sergio Antonio Hernández Peralta, Juan Emmanuel Cuéllar Lugo, \
      Julia López Diego, Nathael Ramos Cabrera \
      Asesores: Oscar Yañez Suarez, Gabriel Nuñez Antonio ],
    logo: box(image("Logo_de_la_UAM_no_emblema.svg", width: 36pt)),
  ),
  footer-a: [Sergio, Juan, Julia, Nathael],
)
#show: show-theorion // Se aplica después del tema

// --- Configuraciones Generales ---
#set text(lang: "es")
#set text(font: "New Computer Modern")
#set heading(numbering: numbly("{1}.", default: "1.1"))

// --- Definiciones Personalizadas ---
// Se mantienen tus definiciones personalizadas
#let invisible(content) = box(fill: none, stroke: none, text(fill: white.transparentize(100%), content))

#let palette = (
  "q": rgb("e6b800"),
  "k": blue,
  "v": red,
  "out": gray.darken(30%),
)
#let innerproduct(x, y) = $lr(angle.l #x, #y angle.r)$
#let sae-neuron-color = rgb("4a90e2")
#let transparent = black.transparentize(100%)
#let edge-corner-radius = 0.4cm
#let node-corner-radius = 10pt
#let blob(pos, label, tint: white, hidden: false, ..args) = node(
  pos,
  align(center, if hidden { text(fill: black.transparentize(100%), label) } else { label }),
  width: 175pt,
  fill: if hidden { transparent } else { tint.lighten(60%) },
  stroke: if hidden { transparent } else { 1pt + tint.darken(20%) },
  corner-radius: 10pt,
  ..args,
)
#let plusnode(pos, ..args) = node(pos, $ plus.circle $, inset: -5pt, ..args)
#let edge-hidden(hidden: false, ..args) = {
  let named = args.named()
  if hidden { named.insert("stroke", transparent) }
  edge(..args.pos(), ..named)
}

// --- Vínculos de Touying con Cetz y Fletcher ---
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show raw: set text(size: 0.8em)


// --- Contenido de la Presentación ---

#title-slide()

== Índice <touying:hidden>
#show outline.entry: it => block(
  below: 2.5em,
  it.indented(
    it.prefix(),
    it.body(),
  ),
)

#components.adaptive-columns(outline(
  title: none,
  indent: 1em,
  depth: 1,
))

= Resumen

== Resumen

#speaker-note[Los temas que abordamos en la primera parte del proyecto proporcionaron
una base sólida para comprender en profundidad los experimentos presentados
en esta exposición. Algunos de los más relevantes que analizamos fueron los siguientes]

Temas abordados en proyecto parte 1: 

- Formulación matemática desde las redes neuronales más simples hasta el
  transformer

  // Se debe mencionar el proceso de optimización que también definimos,
  // entre otros temas relevantes.

- Definición y aproximaciones a la interpretabilidad mecanicista

- SAE

- Modelo Llama

== Transformer

#align(center)[
  #let edge-corner-radius = 10pt
  #let branch-off-offset = edge-corner-radius*1.4
  #let second-col-offset = 100pt
  #let before-branch = 10pt
  #fletcher-diagram(
    edge-corner-radius: edge-corner-radius,
    edge-stroke: 0.9pt,

    node((0,0), name: <xl>),
    plusnode((rel:(0pt, 117pt), to:<xl>),        name: <xlp>),
    plusnode((rel:(0pt, 117pt), to:<xlp.north>), name: <xlpp>),

    edge((rel:(0pt, -25pt), to:<xl>), <xl>, "--|>"),
    edge(<xl>, <xlp>, "-|>",
      label: $x^((l))$,
      label-pos: -9pt,
      label-side: right,
      label-sep: 18pt,
    ),
    edge(
      <xlp>,
      <xlpp>,
      label: $x^((l+1)) x^((l)) + sum_h h(x^((l))|"contexto")$,
      label-side: right,
      label-pos: -12pt,
      label-sep: 18pt,
      "-|>",
    ),
    edge(
      <xlpp>,
      (rel:(0pt, 25pt), to:<xlpp.north>),
      label: $x^((l+2)) = x^((l+1)) + m(x^((l+1)))$,
      label-side: right,
      label-pos: -10pt,
      label-sep: 18pt,
      "--|>",
    ),

    node(
      enclose: (<xl>, <xlp>, <xlpp>, <mha>, <mlp>),
      fill: green.transparentize(70%),
      snap: false,
      corner-radius: 10pt,
      inset: 10pt,
      stroke: green.darken(20%),
    ),

    {
      let hidden = false
      node(
        (rel:(-second-col-offset, branch-off-offset), to:<xl>),
        name:<mha-pre>,
      )
      edge-hidden(
        (<xl>, "|-", (rel:(0pt, -edge-corner-radius), to:<mha-pre>)),
        (<xl>, "|-", <mha-pre>),
        <mha-pre>,
        <mha>, "-|>",
        hidden:hidden,
      )
      blob(
        (<mha-pre>, 50%, (<mha-pre>, "|-", <xlp>)),
        [Autoatención\ multicabezal],
        tint: orange,
        name: <mha>,
        hidden: hidden,
      )
      edge-hidden(<mha>, (<mha>, "|-", <xlp>), <xlp>, "-|>",
        hidden: hidden,
      )
    },

    {
      let hidden = false
      node(
        (rel:(-second-col-offset, branch-off-offset), to:<xlp.north>),
        name:<mlp-pre>,
      )
      edge-hidden(
        (<xlp>, "|-", (rel:(0pt, -edge-corner-radius), to: <mlp-pre>)),
        (<xlp>, "|-", <mlp-pre>),
        <mlp-pre>,
        <mlp>,
        hidden:hidden,
        "-|>",
      )
      blob(
        (<mlp-pre>, 50%, (<mlp-pre>, "|-", <xlpp>)),
        [Perceptrón\ Multicapa],
        tint: blue,
        name: <mlp>,
        hidden: hidden,
      )
      edge-hidden(
        <mlp>,
        (<mlp>, "|-", <xlpp>),
        <xlpp>,
        hidden: hidden,
        "-|>",
      )
    },

  )
]


== Definición
#slide(composer: (2fr, 5fr))[
  #fletcher-diagram(
    edge-corner-radius: 10pt,
    edge-stroke: 0.9pt,
    blob((0,0),  none, height:50pt, tint:green),
    blob((0,-1), none, height:50pt, tint:green),
  )
][
  #definition[
    Un transformer consiste#super(sym.ast) en una capa de embeding, una serie
    de bloques de atención y procesamiento, y una capa de salida que se ajusta a la tarea.
  ]
]

== Autoencoder Disperso

- Autoencoder: aprende la función identidad bajo restricciones
  a consecuencia aprende una codificación y decodificación

- Disperso: La codificación para cualquier entrada es un vector con casi todas
  sus entradas igual a cero

== Introducción

En esta sección nos propusimos realizar una serie de experimentos orientados a
entender el funcionamiento interno de modelos transformers desde una perspectiva
mecanicista, analizando cómo se activan y organizan sus representaciones
internas (activaciones latentes) para interpretar patrones y decisiones
del modelo.

#pagebreak(weak: true)

- Se siguió el procedimiento documentado en el paper \
  "Gemma Scope: Open Sparse Autoencoders Everywhere All At Once on Gemma 2" @lieberum2024gemmascope,
  pero sobre Llama 3.2 1B:

  - Obteniendo las salidas del perceptrón multicapa intermedio

  - Creando código para el autoencoder disperso

  - Creando código para autointerpretabilidad @templeton2024scaling



== Infraestructura

#speaker-note[El desarrollo del proyecto se ha apoyado en una infraestructura híbrida que
combina herramientas en la nube y recursos de cómputo de alto rendimiento.]



#slide(composer: (2fr, 0.7fr))[

Entorno de desarrollo:

- Jupyter Notebook alojado en GitHub.

- Generación de presentaciones con Typst.

- Hugging Face. 

Cómputo para entrenamiento del modelo:

- Plataforma: VAST.ai

- GPU: NVIDIA RTX 4090

//CPU: Multinúcleo (ej. AMD Ryzen o Intel Xeon)
//RAM: 64-128 GB (opcional, pero se utilizó menos)
//Almacenamiento: SSD NVMe
//Herramientas: Acceso por SSH

][
  #figure(
    image("Jnotebook.png", width: 80%),
  ) <logo-vast>

  #v(2em) // Espacio vertical entre las imágenes

  #figure(
    image("4090.jpg", width: 80%),
  ) <logo-nvidia>
]



= Activaciones

== ¿Qué es una activación?
Una activación es el valor que produce 
una neurona artificial tras procesar su entrada con una función de activación.
//Representa cuánto y cómo responde esa neurona a la información que recibe.(speaker note)

== ¿Qué es una activación?

#slide(composer: (1fr, 1.5fr))[
  // --- Columna Izquierda: Texto ---
  #block(
    inset: (top: -6em), // Bajamos un poco el texto para alinear
    [
      Una activación es el valor que produce 
      una neurona tras procesar su entrada con una función de activación.
      
      #v(3em)

    ]
  )
  
  // --- Columna Derecha: Gráfico ---
  #place(center,
   cetz-canvas({
    // --- FUNCIÓN AUXILIAR DEFINIDA LOCALMENTE (LA FORMA CORRECTA) ---
    let neuron(pos, text: none, fill: white, stroke: black, radius: 0.6, name: none) = {
      // Ahora usamos los comandos de dibujo directamente, sin prefijo.
      circle(
        pos,
        radius: radius,
        fill: fill,
        stroke: stroke + 0.5pt,
        name: name
      )
      if text != none {
        content(pos, text, anchor: "center")
      }
    }
    
    // --- El resto del código del gráfico es el mismo ---
    let blue = rgb("#80b2ff")
    let gray = rgb("#ccc")
    let red = rgb("#ff6666")
    let dark-gray = rgb("#555")
    
    // Sintaxis de flecha COMPATIBLE con cetz v0.3.2
    let arrow-style = (
      mark: (end: (symbol: "stealth", size: 8pt, fill: dark-gray)),
      stroke: dark-gray + 0.5pt
    )

    // Entradas
    let input-x = -6
    content((input-x, 2.2), text(size: 0.9em)[Entradas])
    for i in range(3) {
      let y-pos = 1.2 - i * 1.2
      neuron((input-x, y-pos), text: $x_#(i+1)$, fill: blue, name: "x" + str(i+1))
    }

    // Suma Ponderada
    let sum-pos = (-2, 0)
    neuron(sum-pos, text: $z$, fill: gray, name: "sum-node")
    content((rel: (0, 1.0), to: "sum-node"), text(size: 0.9em)[Suma])
    for i in range(3) {
      line("x" + str(i+1), "sum-node", ..arrow-style, label: (content: $w_#(i+1)$, pos: 0.5, anchor: "south"))
    }
     content((sum-pos.at(0), -1.8), $z = sum_(i) w_i x_i + b$, anchor: "center")

    // Función de Activación (ReLU)
    let activation-pos = (2.5, 0)
    let box-width = 1.5; let box-height = 1.0;
    let center-x = activation-pos.at(0); let center-y = activation-pos.at(1)
    rect(
      (center-x - box-width, center-y - box-height),
      (center-x + box-width, center-y + box-height),
      name: "activation-box", stroke: 0.5pt + luma(200)
    )
    line((center-x - box-width, center-y), (center-x + box-width, center-y), stroke: luma(180) + 0.4pt)
    line((center-x, center-y - box-height), (center-x, center-y + box-height), stroke: luma(180) + 0.4pt)
    line((center-x - box-width, center-y), (center-x, center-y), (center-x + box-width, center-y + box-height), stroke: red + 1pt)
    content((center-x, 1.8), text(size: 0.9em)[Activación (ReLU)], anchor: "center")
    content((center-x+ 2.5
    , -1.8), $a = "ReLU"(z)$, anchor: "center")

    // Salida
    let output-pos = (7, 0)
    neuron(output-pos, text: $a$, fill: red, name: "output-node", radius: 0.7)
    content((rel: (0, 1.0), to: "output-node"), text(size: 0.9em)[Salida])

    // Flechas de Proceso
    line("sum-node", "activation-box.west", ..arrow-style)
    line("activation-box.east", "output-node", ..arrow-style)
  })
)
]

== Llama 3.2 1B

#{
  // 1. Centrar la tabla en la página
  set align(center)

  // 2. Ajustar el tamaño de texto
  show table.cell: set text(size: 22pt)

  // 3. Definir la tabla con alineación izquierda
  table(
    columns: 3,
    align: left,
    table.header[*Parámetro*][*Valor*][*Uso en el pipeline*],

    [hidden_size],       [**2048**],      [Dimensión de cada activación],
    [intermediate_size], [8192],          [Ancho del MLP (SiLU)],
    [num_hidden_layers], [16],            [Profundidad total],
    [num_attention_heads],[32 (8 K-V)], [Concurrencia de atención],
    [torch_dtype],       [**bfloat16**],  [Menor memoria, buen rango],
    [rope_scaling.factor],[32],           [Rango > 128 K tokens],
    [vocab_size],        [128 256],     [ID máximo que verás en datos],
  )

  // 4. Restaurar alineación por defecto
  set align(start)
}

== Captura de activaciones del modelo Llama 3

- Extraer activaciones internas (MLP-8) token por token.

- Modelo: Llama 3.2-1B, capa 8 

- Corpus: textos reales en streaming, filtrados por calidad.

- Tokenización y segmentación en bloques de 4096.


== Construcción y subida del dataset

- Procesamiento por lotes → activaciones (bfloat16 → uint16).

- Shards de 50K ejemplos

- RMS global calculado para normalizar activaciones.

- Backup local en caso de error de subida.

== Datos generados

```python
  "doc_id": int,       # ID del documento original en The Pile
  "tok_pos": int,      # posición del token dentro del documento
  "token_id": int,     # ID del token (según el tokenizer de LLaMA)
  "activacion": [uint16] # vector de activaciones MLP-8 (codificado)

```


#{
  set align(center)               // Centra la tabla
  show table.cell: set text(size: 17pt)

  table(
    columns: 4,
    table.header[*doc_id*][*tok_pos*][*token_id*][*activacion*],

    [0], [0],  [11192], [[48545, 48675, 48015, 15893, 15783, 48325, 159…]],
    [0], [1],  [16647], [[15318, 15506, 48442, 15616, 14923, 15797, 157…]],
    [0], [2],  [25],    [[48377, 15745, 48356, 48455, 48513, 48359, 485…]],
  )

  set align(start)                // Restaura alineación izquierda
}


== Flujo de datos

#{
  // 1. Centrar todo el bloque
  set align(center)

  // 2. Ajustar tamaño de texto
  show text: set text(size: 13pt)
  show text: set align(center)

  // 3. Texto multilineal con flechas
  text(       "The Pile (100 000 documentos)\n↓\n
                               Tokenizador → Secuencias de longitud 4096\n      ↓\n
        Forward capas 0–8 (GPU de 24 GB)\n      ↓\n
           Hook en MLP-8 → Vector en ℝ²⁰⁴⁸\n      ↓\n
                      Vista uint16 → Aceptado por HF\n      ↓\n
                  Shard de 50 000 filas → Hugging Face (HF)\n      ↓\n
                        RMS global → Normalización para SAE"
  )

  // 4. Restaurar alineación por defecto
  set align(start)
}


#pagebreak(weak: true)

#{
  // 1. Centrar el bloque en la página
  set align(center)

  // 2. Ajustar el tamaño del texto de las celdas a 8 pt
  show table.cell: set text(size: 16pt)
  // 3. Alinear el contenido de cada celda a la izquierda
  show table.cell: set align(start)

  // 4. Definir la tabla con dos columnas y sin comillas en los valores
  table(
    columns: 2,
    align: (start, start),
    table.header[*Fuente*][*Descripción breve*],

    [Pile-CC],            [Versión curada de Common Crawl con textos web de alta calidad.],
    [Wikipedia (en)],     [Enciclopedia libre en inglés con artículos revisados por la comunidad.],
    [GitHub],             [Repositorios de código fuente y documentación técnica.],
    [StackExchange],      [Preguntas y respuestas técnicas y académicas en múltiples áreas.],
    [PubMed Abstracts],   [Resúmenes de artículos biomédicos y científicos.],
    [PubMed Central],     [Repositorio de artículos completos de investigación médica.],
    [arXiv],              [Prepublicaciones científicas en física, matemáticas, informática, etc.],
    [USPTO],              [Patentes y solicitudes de patente del sistema estadounidense.],
    [FreeLaw],            [Opiniones judiciales de cortes y tribunales de EE. UU.],
    [HackerNews],         [Foro sobre tecnología, ciencia y startups.],
    [PhilPapers],         [Artículos académicos de filosofía.],
    [DM Mathematics],     [Documentos de matemáticas de dominio público (ej. Project Euclid, etc.)],
  )

  // 5. Restaurar alineación por defecto para el resto del documento
  set align(start)
}


= Aprendizaje de diccionario
== ¿Qué es?
- Es la búsqueda de una función mapeando una entrada a sus características

- Si pensamos en la AI como un programa compilado, entonces el aprendizaje de
  diccionario es una herramienta para observar y modificar las variables de un
  programa.

- En otras palabras, es la transformación de las activaciones a una forma
  interpretable y manipulable

- Nuestro caso: Salida del MLP 8, modelo Llama 3.2 1B

== Retos

  - El stream residual conserva la mayoría de la información de la entrada

  - Al entrenar modelos profundos para encontrar una representación
    interpretable no sabes si el cómputo lo hace el llm o el modelo de
    descomposición, por lo tanto _se suelen usar modelos de pocas capas_
    - Othello GPT: representación lineal emergente interna del tablero aún
      cuando solo se le informa de los movimientos de piezas y no el tablero @li2023emergent @nanda2023othello.


== Objetivo

Dado:
- Hipótesis de representaciones lineales
- Preferencia de modelos no-profundos
- Disperso implica interpretable @elhage2022toy

el objetivo es aprender un conjunto sobrecompleto de direcciones en el espacio
de activaciones, tal que solo se necesiten pocas direciones para reconstruir
una entrada


= Entrenamiento de Autoencoder

== JumpReLU SAE

- Optimización con restricciones #pause

- $ell_0$ #pause

- $ "JumpReLU" (z | theta) = z dot.circle H(z - theta) $

== JumpReLU

#slide(repeat: 6, self => {
  let u(n, text) = if self.subslide < n  {" " * text.len()} else {text}

  let o(n, text) = if self.subslide != n {""} else {text}

  let a(..alternatives) = {
    let options = alternatives.pos()
    if options.len() == 0 { return "" }

    // Determine which alternative to show based on subslide
    let index = calc.min(self.subslide - 1, options.len() - 1)
    if index < 0 { index = 0 }

    // Get the content to show
    let content = options.at(index)

    // Find the maximum width for layout preservation
    let max-len = 0
    for option in options {
      max-len = calc.max(max-len, option.len())
    }

    // Pad content to max width with spaces if needed
    let padding = " " * calc.max(0, max-len - content.len())
    return content + padding
  }

  let lines = (
    u(6, "class JumpReLU(torch.autograd.Function):"      ),
    u(6, "    @staticmethod"                             ),
         "    def forward(ctx, x, threshold):",
         "        ctx.save_for_backward(x, threshold)",
         "        return (x > threshold).float() * x",
    o(1, "        #      ⌞▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁⌟"         )
  +      "",
    o(1, "        #         vector de 0s y 1s"            )
  + u(6, "    @staticmethod"                              ),
    o(1, "        # "                                     )
  + u(2, "    def backward(ctx, grad_output):"            ),
    o(1, "        # \">\" funciona elemento por elemento" )
  + u(2, "        bandwidth = 0.001"                      ),
    u(2, "        x, threshold = ctx.saved_tensors"       ),
    u(3, "        jacobian_x = (x > threshold).float()"   ),
    u(4, "        jacobian_threshold = (-threshold / bandwidth) * ("),
    u(4, "          (abs(x - threshold) < bandwidth/2)") + u(5, " & (x > 0)") + o(5, " # <──────"),
    u(4, "        ).float()") +            o(5, "                                      #        │"),
    o(5, "        # evitar pre-activaciones negativas influyan threshold ─┘"),
    u(3, "        return jacobian_x*grad_output") + u(4, ", jacobian_threshold*grad_output")
  )

  // h(1fr)
  raw(lines.join("\n"), lang: "python")
})

== Entrenamiento

```python
def hook(grad_in):
    # esto asume que la norma de las columnas es 1
    # así que hay que normalizar luego de cada
    # actualización a los parámetros
    dot = (self.dec.weight * grad_in).sum(dim=0, keepdim=True)
    return grad_in - dot * tensor

self.dec.weight.register_hook(hook)
```

#pagebreak(weak: true)

```python
with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
    reconstrución_y_otras_salidas = model(x)
```

== Rendimiento General

#align(center, block(
  width: 80%,
  fill: rgb("#fff3cd"),
  inset: 0.5em,
  radius: 0.9em,

  stroke: 0.04em + rgb("#d4a934"),
  [
    "Como matemático, escribes la ecuación y todas las letras están en la
    misma línea, no hay cuello de botella de comunicación entre la $A$ y la $B$
    que está al lado."
    
    #align(right)[--- Josh Batson @anthropic2024scaling]
  ]))
#pagebreak(weak: true)


#let performance_data = (
  ([GPU],     49559),
  ([Memcpy],      2111),
  ([Memset],         3),
  ([Runtime],        0),
  ([DataLoader],     0),
  ([CPU $->$ GPU],  14805),
  ([CPU Other],     150),
  ([Other],        486),
)

#align(center)[
#cetz-canvas({
  let colors = gradient.linear(
      blue.lighten(40%),
      purple.lighten(40%),
      red.lighten(40%),
    )
  let total = performance_data.map(el => el.at(1)).sum()

  chart.piechart(
    performance_data,
    value-key: 1,
    label-key: 0,
    radius: 4,
    slice-style: colors,
    inner-radius: 1,
    inner-label: (content: (value, label) => (
      if value <= total * 0.02 {invisible(str(calc.round(value / total * 100)) + "%")} else {str(calc.round(value / total * 100)) + "%"}
    ), radius: 110%),
    outer-label: (content: (value, label) => (
      if value <= total * 0.02 {invisible(label)} else {label}
    ), radius: 140%),
    legend: (label: none)
  )
})
]

== Eficiencia GPU
#let data = (
  // durations in μs
  ([ADAM],                32716),
  ([mm1],       15698),
  ([mm2],       15477),
  ([mm3],       15417),
  ([mm4],       15336),
  ([mm5],       15240),
  ([mm6],       15230),
  ([eltwise-mul],          5570),
  ([vec-add],              3830),
  ([poi-exp-gt-mul],       3827),
  ([poi-copy],             3825),
  ([vec-mul],              3761),
  ([step-backward-reduce], 3699),
  ([l2-norm-reduce],       1876),
  ([sum-reduce],           1415),
)

#slide(repeat: 2, self => {
  align(center)[
    #cetz-canvas({
      let colors = gradient.linear(
        red.lighten(30%),
        blue.lighten(30%),
        green.lighten(30%),
        yellow.lighten(30%)
      )
      let total = data.map(el => el.at(1)).sum()

      chart.piechart(
        data,
        value-key: 1,
        label-key: 0,
        radius: 4,
        slice-style: colors,
        inner-radius: 1,
        inner-label: (content: (value, label) => (
          if value <= total * 0.05 {none} else {str(calc.round(value / total * 100)) + "%"}
        ), radius: 110%),
        outer-label: (content: (value, label) => (
          if self.subslide == 1 {
            if label == [ADAM] {label} else {invisible(label)}
          } else {
            if value <= total * 0.05 {invisible(label)} else {label}
          }
        ),
          radius: 140%),
        legend: (label: none)
      )
    })
  ]
})

== Pérdidas durante el entrenamiento

#slide(composer: (1fr, 1fr))[
  #cetz-canvas({
    import cetz.draw: *
    import cetz-plot: *

    let datos_reconstruccion = json("recons.json")
      .map(row => (float(row.at(1)), float(row.at(2))))

    plot.plot(
      size: (10, 10),

      title: text(16pt, [Reconstrucción]),
      x-label: text(0.9em)[Paso de entrenamiento],
      y-label: text(0.9em)[Reconstrucción],

      // --- EJE X CON EL ÚLTIMO VALOR INCLUIDO ---

      x-tick-step: none,

      // Creamos la lista de marcas: 0, 80k, 160k y luego añadimos 256k.
      x-ticks: range(0, 160001, step: 80000) + (256000,),

      // El formato se encarga de convertir 256000 en "256k"
      x-format: v => {
        if v == 0 { return text(1em)[0] }
        if v > 0 { return text(1em)[#(int(v/1000))k] }
        return []
      },

      y-format: v => text(1em)[#v],

      axis-style: "scientific",

      {
        plot.add(
          datos_reconstruccion,

          mark: none,
          line: "linear",

          style: (
            stroke: 0.1em + rgb("#4C5C7A")
          )
        )
      },
    )
  })
][
  #cetz-canvas({
    import cetz.draw: *
    import cetz-plot: *

    let datos_reconstruccion = json("L0.json")
      .map(row => (float(row.at(1)), float(row.at(2))))

    plot.plot(
      size: (10, 10),

      title: text(16pt, [L0]),
      x-label: text(0.9em)[Paso de entrenamiento],
      y-label: text(0.9em)[L0],

      // --- EJE X CON EL ÚLTIMO VALOR INCLUIDO ---

      x-tick-step: none,

      // Creamos la lista de marcas: 0, 80k, 160k y luego añadimos 256k.
      x-ticks: range(0, 160001, step: 80000) + (256000,),

      // El formato se encarga de convertir 256000 en "256k"
      x-format: v => {
        if v == 0 { return text(1em)[0] }
        if v > 0 { return text(1em)[#(int(v/1000))k] }
        return []
      },

      y-format: v => text(1em)[#v],

      axis-style: "scientific",

      {
        plot.add(
          datos_reconstruccion,

          mark: none,
          line: "linear",

          style: (
            stroke: 0.1em + rgb("#4C5C7A")
          )
        )
      },
    )
  })
]


== Dim y prevalencia

#slide(composer: (9fr, 4fr))[
  #align(center)[
    #image("scatter_plot.png", width: 100%)
  ]
][
  #align(center + horizon)[
    $"dimencionalidad"_j \ = (norm(f_j)_2^2) / sqrt(sum_(k=1)^(d_"sae") (f_k^T f_j)^2)$
  ]
]

#pagebreak(weak: true)

== Histograma de prevalencia

#let histogram_csv = csv("histogram_data.csv")
#let histogram_data = histogram_csv.slice(1).enumerate().map(((i, row)) => (
  if calc.rem(i, 5) == 0 { row.at(0) } else { [] }, 
  int(row.at(1))
))

#align(center)[
#cetz-canvas({
  chart.columnchart(
    histogram_data,
    mode: "basic",
    size: (20, 8),
    label-key: 0,
    value-key: 1,
    x-label: $log_10 ("Prevalencia")$,
    y-label: [Número de características],
    bar-style: (fill: blue.lighten(20%)),
  )
})
]

= Interpretabilidad

== Interpretabilidad en modelos Transformer

Utilizamos un SAE para proyectar las activaciones internas del
Transformer en un espacio latente disperso. Esto nos permite identificar
direcciones latentes que influyen en tareas específicas y analizar el 
comportamiento del modelo de forma interpretable.


== Configuración

```python
openai.api_key = OPENAI_API_KEY
def create_prompt(nid: int, acts_idx: np.ndarray, acts_val: np.ndarray, raw_dataset: Dataset, tokenizer_param: AutoTokenizer, doc_map: dict) -> str:
    example_texts = []
    context_window_size = 5 
    for i, global_idx in enumerate(acts_idx):
        
        example_data = raw_dataset[int(global_idx)]
        
        doc_id = example_data['doc_id']
        tok_pos = example_data['tok_pos']
        token_id_at_pos = example_data['input_ids'].item()
        pairs = "\n".join(example_texts)
```

== Generación prompt final

```python

    full_prompt_for_ai = textwrap.dedent(f"""
        You are an expert analyst specialized in interpreting latent neurons of a Sparse Auto-Encoders
        Your task is to analyze neuron #{nid}.
        Here are its {len(acts_val)} highest activating examples:
        {pairs}

        Based on these examples, 
        1. *Hypothesis*:...
        2. *Observed Patterns*: ...
        3. *Illustrative Examples*:..
        4. *Confidence*:... """)
    return full_prompt_for_ai, pairs

    ```

== Resultados

 Document Overlap: A notable number of high-activating examples come from the same documents  
    (e.g., doc_id=67640 and doc_id=180370), suggesting that this neuron may be tuned to specific 
    content or styles present in these documents.
    #pagebreak(weak: true)
    
    Examples:
    - “The overwhelming joy I felt when I received the news was indescribable.”  
    - “Many people believe that this new policy will greatly benefit our community.”  
    - “I can’t help but feel a sense of dread every time I think about the future.”

    Estas frases incorporan lenguaje emocional y expresiones subjetivas, alineándose con los  
    posibles temas detectados por la neurona #28311.

= Desarrollo actual y futuro

== Stack Tecnológico

#slide(composer: (3fr, 4fr))[
  #align(center)[
    #image("contributors-github.png", width: 90%)
  ]
][
  #align(center)[
    #image("network-github.png", width: 90%)
  ]
]

== Trabajo próximo

- Entrenar con 8 TB de datos

- Usar formato de punto flotante de 8 bits (float8)

- Utilizar múltiples núcleos

- Limpiar y refactorizar el código para optimizarlo y mejorar su legibilidad

== Referencias

#text(size: 0.6em)[
  #bibliography("works.bib", style: "ieee")
]

== Más información

// #set page(width: auto, height: auto, margin: 0.5cm)
#let length = 1.9cm

#let back-diagram = cetz.canvas(length: length, {
  import cetz.draw
let spacing = 0.3
let width   = 4
let h-offset = width + 1.6*spacing
let height  = 5.5
let radius  = 0.5
  let left-color   = rgb("d3ede0")
  let middle-color = rgb("ffe1bb")
  let right-color  = rgb("eddfec")

  let info-rect = (pos, title, url, img: none, tint, ..args) => {
    draw.rect(
      (rel: (-width/2, -height/2), to: pos),
      (rel: (width,     height)),
      stroke: none,
      radius: radius,
      fill:   tint,
      ..args,
    )
    let inner-size = width - 2*spacing
    draw.rect(
      (rel: (-inner-size/2, -inner-size/2), to: pos),
      (rel: (inner-size, inner-size)),
      stroke: none,
      radius: radius,
      fill:   tint.lighten(80%),
    )
    draw.content(
      (pos.at(0), pos.at(1) + 0.39*height),
      text(size: 0.6*length, weight: "bold", fill: tint.darken(80%), title),
    )
    let qr-size = inner-size - 2*spacing
    draw.content(pos, scale(x: qr-size*length, y: qr-size*length, qrcode(
      url,
      options:(
        fg-color: tint.darken(80%),
        // Can't have option-1 too at the same time.
        option-2: 4,
      ))))
    if img != none {
      draw.content(pos, {
        let svg-content = read(img)
        let colored-svg = svg-content
        .replace(
          "#000000",
          tint.darken(80%).to-hex(),
        )
        .replace(
          "#ffffff",
          tint.lighten(50%).to-hex(),
        )
        image(bytes(colored-svg), height: length)
      })
    }
  }

  info-rect(
    (-h-offset, 0),
    [Diapositivas],
    "mech-interp-uam.github.io/presentacion1",
    left-color,
    img: "document-svgrepo-com-edit.svg",
  )

  info-rect(
    (0, 0),
    [Código],
    "github.com/mech-interp-uam/mech-interp",
    middle-color,
    img: "github.svg",
  )

  info-rect(
    (h-offset, 0),
    [Sitio Web],
    "mech-interp-uam.github.io/mech-interp",
    right-color,
    img: "web-internet-online-network-seo-svgrepo-com.svg",
  )

})


#align(center)[*mech-interp-uam.github.io/mech-interp*]
#align(center, back-diagram)

