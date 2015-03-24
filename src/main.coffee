DAT = require './globe'

globe = null

$ ->
  if not Detector.webgl
    Detector.addGetWebGLMessage()
  else
    # Fetch data from the server
    $.ajax
      url: 'http://cymon.io/api/publicajax/nexus/globe/?categories=1'
      dataType: 'json'
      error: ( jqXHR, textStatus, errorThrown ) ->
        alert "Could not load data. Reason: #{textStatus}"
      success: ( response ) ->
        container = document.getElementById 'globe'

        THREE.ImageUtils.loadTexture( '../img/map2.jpg', undefined, ( texture ) ->
          globe = DAT.createGlobe container, texture

          globe.addData response.data
          globe.initLegend()
          doAnimate()
        )

doAnimate = ->
  requestAnimationFrame doAnimate
  globe.render()
