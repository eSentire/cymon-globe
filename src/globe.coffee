# dat.globe Javascript WebGL Globe Toolkit
# http://dataarts.github.com/dat.globe
#
# Copyright 2011 Data Arts Team, Google Creative Lab
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
TWEEN = require 'tween.js'

SeriesSelector = require './components/series-selector'
utils = require './utils'

# Also used with the colour function
_seriesWithMaxDataVal = ''
_seriesMaximums = {} # format: { <name>: <max val> }

module.exports =
  createGlobe: ( container, texture ) ->
    return new Globe container, texture

# variables static to the Globe class
PI_HALF = Math.PI / 2
ROTATIONSPEED = 0.003
Shaders =
  'earth':
    uniforms:
      'texture': { type: 't', value: null }
    vertexShader: [
      'varying vec3 vNormal;',
      'varying vec2 vUv;',
      'void main() {',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
        'vNormal = normalize( normalMatrix * normal );',
        'vUv = uv;',
      '}'
    ].join('\n')
    fragmentShader: [
      'uniform sampler2D texture;',
      'varying vec3 vNormal;',
      'varying vec2 vUv;',
      'void main() {',
        'vec3 diffuse = texture2D( texture, vUv ).xyz;',
        'float intensity = 1.05 - dot( vNormal, vec3( 0.0, 0.0, 1.0 ) );',
        'vec3 atmosphere = vec3( 1.0, 1.0, 1.0 ) * pow( intensity, 3.0 );',
        'gl_FragColor = vec4( diffuse + atmosphere, 1.0 );',
      '}'
    ].join('\n')
  'atmosphere':
    uniforms: {}
    vertexShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'vNormal = normalize( normalMatrix * normal );',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
      '}'
    ].join('\n')
    fragmentShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'float intensity = pow( 0.8 - dot( vNormal, vec3( 0, 0, 1.0 ) ), 12.0 );',
        'gl_FragColor = vec4( 0.5, 0.5, 0.5, 0.25 ) * intensity;',
      '}'
    ].join('\n')

class Globe
  constructor: ( @container, @backgroundTexture ) ->
    # Define instance variables
    @mouse = { x: 0, y: 0 }
    @mouseOnDown = { x: 0, y: 0 }
    @inMouseDrag = false
    @overRenderer = false
    @rotation = { x: 0, y: 0 }
    @target = { x: Math.PI*1.7, y: Math.PI / 5.0 }
    @targetOnDown = { x: 0, y: 0 }

    @seriesGeos = {}

    # Properties for the Legend. Object is of the form:
    # [
    #   { name: <str>, numHits: <num> },
    #   ...
    # ]
    @_legendState = []
    @_totalHits = 0

    @distance = 100000
    @distanceTarget = 100000

    @k = ROTATIONSPEED
    @f = false

    w = @container.offsetWidth or window.innerWidth
    h = @container.offsetHeight or window.innerHeight

    @camera = new THREE.PerspectiveCamera(26, w / h, 1, 10000)
    @camera.position.z = @distance

    @scene = new THREE.Scene()
    geometry = new THREE.SphereGeometry(150, 40, 30)

    shader = Shaders.earth
    uniforms = THREE.UniformsUtils.clone(shader.uniforms)

    uniforms.texture.value = @backgroundTexture

    material = new THREE.ShaderMaterial
      uniforms: uniforms
      vertexShader: shader.vertexShader
      fragmentShader: shader.fragmentShader

    @mesh = new THREE.Mesh(geometry, material)
    @mesh.rotation.y = Math.PI
    @scene.add @mesh

    shader = Shaders.atmosphere
    uniforms = THREE.UniformsUtils.clone(shader.uniforms)

    material = new THREE.ShaderMaterial
      uniforms: uniforms
      vertexShader: shader.vertexShader
      fragmentShader: shader.fragmentShader
      side: THREE.BackSide
      blending: THREE.AdditiveBlending
      transparent: true

    @mesh = new THREE.Mesh(geometry, material)
    @mesh.scale.set( 1.1, 1.1, 1.1 )
    @scene.add @mesh

    geometry = new THREE.BoxGeometry(0.75, 0.75, 1)
    geometry.applyMatrix(new THREE.Matrix4().makeTranslation(0,0,-0.5))

    @point = new THREE.Mesh(geometry)

    @renderer = new THREE.WebGLRenderer({antialias: true})
    @renderer.setSize(w, h)

    @renderer.domElement.style.position = 'absolute'

    @container.appendChild(@renderer.domElement)

    @container.addEventListener('mousemove', @onMouseMove, false)
    @container.addEventListener('mouseup', @onMouseUp, false)
    @container.addEventListener('mouseout', @onMouseOut, false)
    @container.addEventListener('mousedown', @onMouseDown, false)
    @container.addEventListener('mousewheel', @onMouseWheel, false)
    # firefox mouse wheel handler
    @container.addEventListener( 'DOMMouseScroll', (e) =>
      evt = window.event or e
      @onMouseWheel evt
    , false )

    @container.addEventListener('mouseover', =>
      @overRenderer = true
    , false)

    @container.addEventListener('mouseout', =>
      @overRenderer = false
    , false)

    return

  addData: (data) ->
    # get ready for our colour function
    _setMaxDataVal data

    colorFnWrapper = (data, i) ->
      colourVals = utils.colourMap( data[i+2], _seriesMaximums[ _seriesWithMaxDataVal ] )
      return new THREE.Color( colourVals.r, colourVals.g, colourVals.b )

    @_legendState = []
    @_totalHits = 0

    for series in data
      subgeo = new THREE.Geometry()
      seriesTotal = 0
      for point, i in series[1] by 3
        lat = series[1][i]
        lng = series[1][i + 1]
        color = colorFnWrapper(series[1],i)
        seriesTotal += series[1][i+2]
        @addPoint(lat, lng, 0, color, subgeo)

      # Add to our Legend state
      @_legendState.push
        name: series[0]
        numHits: seriesTotal
      @_totalHits += seriesTotal

      # Add to our list of series geometries
      points = new THREE.Mesh( subgeo, new THREE.MeshBasicMaterial
        color: 0xffffff
        vertexColors: THREE.FaceColors
        morphTargets: false,
        transparent: true,
        opacity: 1.0
      )
      @seriesGeos[ series[0] ] = points
      @scene.add points

    return

  addPoint: (lat, lng, size, color, subgeo) ->
    phi = (90 - lat) * Math.PI / 180
    theta = (180 - lng) * Math.PI / 180

    @point.position.x = 150 * Math.sin(phi) * Math.cos(theta)
    @point.position.y = 150 * Math.cos(phi)
    @point.position.z = 150 * Math.sin(phi) * Math.sin(theta)

    @point.lookAt(@mesh.position)

    @point.scale.z = Math.max( size, 0.1 ) # avoid non-invertible matrix
    @point.updateMatrix()

    for face in @point.geometry.faces
      face.color = color

    # Note: this method was introduced in r70 but is only documented in the
    # release notes. Hopefully it will stick around and not break in the future
    subgeo.mergeMesh @point

  initLegend: ->
    React.render(
      React.createElement( SeriesSelector,
        series: @_legendState
        totalHits: @_totalHits
        toggleHandler: @onLegendToggle
      )
      document.getElementById 'series-selector'
    )

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Event Handlers
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  onMouseDown: (event) =>
    event.preventDefault()

    @k = 0
    @f = true
    @inMouseDrag = true

    @target.y = @rotation.y
    @mouseOnDown.x = -event.clientX
    @mouseOnDown.y = event.clientY

    @targetOnDown.x = @target.x
    @targetOnDown.y = @target.y

    @container.style.cursor = 'move'

  onMouseMove: (event) =>
    if not @inMouseDrag then return

    @mouse.x = -event.clientX
    @mouse.y = event.clientY

    zoomDamp = @distance/1000

    @target.x = @targetOnDown.x + (@mouse.x - @mouseOnDown.x) * 0.005 * zoomDamp
    @target.y = @targetOnDown.y + (@mouse.y - @mouseOnDown.y) * 0.005 * zoomDamp

    @target.y = if @target.y > PI_HALF then PI_HALF else @target.y
    @target.y = if @target.y < - PI_HALF then -PI_HALF else @target.y

  onMouseUp: (event) =>
    if not @inMouseDrag then return

    @k = ROTATIONSPEED
    @f = false

    @inMouseDrag = false
    @container.style.cursor = 'auto'

  onMouseOut: (event) =>
    if not @inMouseDrag then return

    @k = ROTATIONSPEED
    @f = false
    @inMouseDrag = false

  onMouseWheel: (event) =>
    event.preventDefault()
    if @overRenderer
      delta = 0
      if event.wheelDelta
        delta = event.wheelDelta * 0.3
      else if event.detail
        delta = -event.detail * 10

      @zoom delta

    return false

  onLegendToggle: ( name, active ) =>
    startVal = 0.0
    endVal = 1.0

    if !active
      startVal = 1.0
      endVal = 0.0

    mat = @seriesGeos[ name ].material
    tween = new TWEEN.Tween( {x: startVal} ).to( {x: endVal}, 500 )
    tween.onUpdate ->
      mat.opacity = @x
    tween.start()

    # TODO: recalculate all point colours based on the (potentially) new max data val

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Render-related Methods
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  zoom: (delta) ->
    @distanceTarget -= delta
    @distanceTarget = if @distanceTarget > 1100 then 1100 else @distanceTarget
    @distanceTarget = if @distanceTarget < 350 then 350 else @distanceTarget

  render: ->
    @zoom 0
    @target.x -= @k
    @rotation.x += (@target.x - @rotation.x) * 0.2

    if @f
      @rotation.y += (@target.y - @rotation.y) * 0.2
    else
      @target.y = Math.PI / 5.0
      @rotation.y += (@target.y - @rotation.y) * 0.02

    @distance += (@distanceTarget - @distance) * 0.3

    @camera.position.x = @distance * Math.sin(@rotation.x) * Math.cos(@rotation.y)
    @camera.position.y = @distance * Math.sin(@rotation.y)
    @camera.position.z = @distance * Math.cos(@rotation.x) * Math.cos(@rotation.y)

    @camera.lookAt @mesh.position

    @renderer.render( @scene, @camera )

    # Update any in-flight tweens
    TWEEN.update()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Private Helper Methods
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# helper function to find the max value in an array of data (used for colour
# interpolation in the colorFn)
_setMaxDataVal = ( data ) ->
  currMax = 0
  for subArr in data
    seriesMax = Math.max.apply( Math, subArr[1] )
    _seriesMaximums[ subArr[0] ] = seriesMax

    if seriesMax > currMax
      currMax = seriesMax
      _seriesWithMaxDataVal = subArr[0]

  return
