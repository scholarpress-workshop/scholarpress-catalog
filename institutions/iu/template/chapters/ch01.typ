// Per-file chapter convention: each file exports one #let binding
// with a descriptive kebab-case name. template.typ imports it via
//   #import "chapters/ch01.typ": historical-context
// and passes it to the chapter() function:
//   #chapter(number: "1", title: "Historical Context", body: historical-context, first: true)

#let historical-context = [
  = Historiography of Glacier Science

  The study of glacial dynamics emerged in the late 19th century when
  naturalists first observed that glaciers were not static formations but
  rivers of ice in slow, perpetual motion. Early accounts by Alpine
  villagers described glaciers advancing and retreating over generations,
  burying pastures and revealing ancient tree stumps. These observations,
  though anecdotal, laid the groundwork for systematic scientific inquiry.

  == Early Observations

  Louis Agassiz, a Swiss naturalist, was among the first to propose that
  glaciers had once covered much of Europe during an "Ice Age" — a radical
  departure from the prevailing belief in a static Earth. In 1840, he
  published _Études sur les glaciers_, documenting striations on bedrock
  and erratic boulders far from their source. His work demonstrated that
  glaciers were powerful geological agents, capable of reshaping
  landscapes over millennia.

  Agassiz's contemporaries were initially skeptical. The notion that ice
  sheets could have extended from the poles to the Mediterranean seemed
  fantastical. Yet by the 1870s, accumulating evidence from Scandinavia,
  the British Isles, and North America had convinced most of the
  scientific community. Geologists began mapping terminal moraines and
  tracing the extent of Pleistocene ice sheets across continents.
]
