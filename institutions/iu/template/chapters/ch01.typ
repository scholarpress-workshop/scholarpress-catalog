// Per-file chapter convention: each file exports one #let binding
// with a descriptive kebab-case name. template.typ imports it via
//   #import "chapters/ch01.typ": historical-context
// and passes it to the chapter() function:
//   #chapter(number: "1", title: "Historical Context", body: historical-context, first: true)

#let historical-context = [
  == Historiography of Glacier Science

  The study of glacial dynamics emerged in the late 19th century when
  naturalists first observed that glaciers were not static formations but
  rivers of ice in slow, perpetual motion. Early accounts by Alpine
  villagers described glaciers advancing and retreating over generations,
  burying pastures and revealing ancient tree stumps. These observations,
  though anecdotal, laid the groundwork for systematic scientific inquiry.

  === Early Observations

  Louis Agassiz, a Swiss naturalist, was among the first to propose that
  glaciers had once covered much of Europe during an "Ice Age" — a radical
  departure from the prevailing belief in a static Earth. In 1840, he
  published _Études sur les glaciers_, documenting striations on bedrock
  and erratic boulders far from their source. His work demonstrated that
  glaciers were powerful geological agents, capable of reshaping
  landscapes over millennia.

  === Institutional Resistance

  Agassiz's contemporaries were initially skeptical. The notion that ice
  sheets could have extended from the poles to the Mediterranean seemed
  fantastical. Yet by the 1870s, accumulating evidence from Scandinavia,
  the British Isles, and North America had convinced most of the
  scientific community. Geologists began mapping terminal moraines and
  tracing the extent of Pleistocene ice sheets across continents.

  == Visual Evidence

  The following figures illustrate key concepts in glacier science.

  #figure(
    image("../../tests/fig-2-1.png", width: 80%),
    caption: [Glacier morphology diagram showing accumulation and ablation zones.],
  )

  #figure(
    image("../../tests/fig-3-1.png", width: 80%),
    caption: [Cross-section of a valley glacier illustrating flow dynamics.],
  )

  == Comparative Analysis

  Additional data supports the glacier dynamics model. Figures 4-1 and 4-2
  below show temperature and pressure gradients across multiple field sites.

  #figure(
    image("../../tests/fig-4-1.png", width: 80%),
    caption: [Temperature gradients measured at three field sites (2018-2024).],
  ) <fig-temp>

  #figure(
    image("../../tests/fig-4-2.png", width: 80%),
    caption: [Pressure distribution across the ablation zone.],
  ) <fig-pressure>

  As shown in @fig-temp and @fig-pressure, the data supports the theoretical
  framework established in Chapter 2.
]
