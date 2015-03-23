DAT = require './globe'

globe = null

$ ->
  if not Detector.webgl
    Detector.addGetWebGLMessage()
  else
    # Fetch data from the server
    $.ajax
      url: 'data-legend.json'
      dataType: 'json'
      error: ( jqXHR, textStatus, errorThrown ) ->
        alert "Could not load data. Reason: #{textStatus}"
      success: ( response ) ->
        container = document.getElementById 'globe'

        THREE.ImageUtils.loadTexture( '../img/map2.jpg', undefined, ( texture ) ->
          globe = DAT.createGlobe container, texture

          globe.addData response.data
          globe.createPoints()
          globe.initLegend()
          doAnimate()
        )

doAnimate = ->
  requestAnimationFrame doAnimate
  globe.render()
