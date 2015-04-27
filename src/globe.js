// dat.globe Javascript WebGL Globe Toolkit
// http://dataarts.github.com/dat.globe
//
// Copyright 2011 Data Arts Team, Google Creative Lab
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import TWEEN from 'tween.js';
import React from 'react';

import SeriesSelector from './components/series-selector.jsx';
import * as utils from './utils';

// variables static to the Globe class
const PI_HALF = Math.PI / 2;
const ROTATIONSPEED = 0.003;
const Shaders = {
  'earth': {
    uniforms: {
      'texture': { type: 't', value: null }
    },
    vertexShader: [
      'varying vec3 vNormal;',
      'varying vec2 vUv;',
      'void main() {',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
        'vNormal = normalize( normalMatrix * normal );',
        'vUv = uv;',
      '}'
    ].join('\n'),
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
  },
  'atmosphere': {
    uniforms: {},
    vertexShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'vNormal = normalize( normalMatrix * normal );',
        'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
      '}'
    ].join('\n'),
    fragmentShader: [
      'varying vec3 vNormal;',
      'void main() {',
        'float intensity = pow( 0.8 - dot( vNormal, vec3( 0, 0, 1.0 ) ), 12.0 );',
        'gl_FragColor = vec4( 0.5, 0.5, 0.5, 0.25 ) * intensity;',
      '}'
    ].join('\n')
  }
};

// Also used with the colour function
let _seriesWithMaxDataVal = '';
let _seriesMaximums = {}; // format: { <name>: <max val> }

export function createGlobe( container, texture ) {
  return new Globe( container, texture );
}

class Globe {
  constructor( container, backgroundTexture ) {
    // Define instance variables
    this.container = container;
    this.backgroundTexture = backgroundTexture;
    this.mouse = { x: 0, y: 0 };
    this.mouseOnDown = { x: 0, y: 0 };
    this.inMouseDrag = false;
    this.overRenderer = false;
    this.rotation = { x: 0, y: 0 };
    this.target = { x: Math.PI*1.7, y: Math.PI / 5.0 };
    this.targetOnDown = { x: 0, y: 0 };

    this.seriesGeos = {};

    // Properties for the Legend. Object is of the form:
    // [
    //   { name: <str>, numHits: <num> },
    //   ...
    // ]
    this._legendState = [];
    this._totalHits = 0;

    this.distance = 100000;
    this.distanceTarget = 100000;

    this.k = ROTATIONSPEED;
    this.f = false;

    let w = this.container.offsetWidth || window.innerWidth;
    let h = this.container.offsetHeight || window.innerHeight;

    this.camera = new THREE.PerspectiveCamera(26, w / h, 1, 10000);
    this.camera.position.z = this.distance;

    this.scene = new THREE.Scene();
    let geometry = new THREE.SphereGeometry(150, 40, 30);

    let shader = Shaders.earth;
    let uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    uniforms.texture.value = this.backgroundTexture;

    let material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader
    });

    this.mesh = new THREE.Mesh(geometry, material);
    this.mesh.rotation.y = Math.PI;
    this.scene.add( this.mesh );

    shader = Shaders.atmosphere;
    uniforms = THREE.UniformsUtils.clone(shader.uniforms);

    material = new THREE.ShaderMaterial({
      uniforms: uniforms,
      vertexShader: shader.vertexShader,
      fragmentShader: shader.fragmentShader,
      side: THREE.BackSide,
      blending: THREE.AdditiveBlending,
      transparent: true
    });

    this.mesh = new THREE.Mesh(geometry, material);
    this.mesh.scale.set( 1.1, 1.1, 1.1 );
    this.scene.add( this.mesh );

    geometry = new THREE.BoxGeometry(0.75, 0.75, 1);
    geometry.applyMatrix(new THREE.Matrix4().makeTranslation(0,0,-0.5));

    this.point = new THREE.Mesh(geometry);

    this.renderer = new THREE.WebGLRenderer({antialias: true});
    this.renderer.setSize(w, h);

    this.renderer.domElement.style.position = 'absolute';

    this.container.appendChild(this.renderer.domElement);

    this.container.addEventListener('mousemove', this.onMouseMove.bind(this), false);
    this.container.addEventListener('mouseup', this.onMouseUp.bind(this), false);
    this.container.addEventListener('mouseout', this.onMouseOut.bind(this), false);
    this.container.addEventListener('mousedown', this.onMouseDown.bind(this), false);
    this.container.addEventListener('mousewheel', this.onMouseWheel.bind(this), false);
    // firefox mouse wheel handler
    this.container.addEventListener( 'DOMMouseScroll', (e) => {
      let evt = window.event || e;
      this.onMouseWheel( evt );
    }, false );

    this.container.addEventListener( 'mouseover', () => {
      this.overRenderer = true;
    }, false );

    this.container.addEventListener( 'mouseout', () => {
      this.overRenderer = false;
    }, false );
  }

  addData( data ) {
    // get ready for our colour function
    _setMaxDataVal( data );

    let colorFnWrapper = (data, i) => {
      let colourVals = utils.colourMap( data[i+2], _seriesMaximums[ _seriesWithMaxDataVal ] );
      return new THREE.Color( colourVals.r, colourVals.g, colourVals.b );
    };

    this._legendState = [];
    this._totalHits = 0;

    data.forEach( ( series ) => {
      let subgeo = new THREE.Geometry();
      let seriesTotal = 0;

      for( let i = 0; i < series[1].length; i += 3 ) {
        let lat = series[1][i];
        let lng = series[1][i + 1];
        let color = colorFnWrapper(series[1],i);
        seriesTotal += series[1][i+2];
        this.addPoint(lat, lng, 0, color, subgeo);
      }

      // Add to our Legend state
      this._legendState.push({
        name: series[0],
        numHits: seriesTotal
      });
      this._totalHits += seriesTotal;

      // Add to our list of series geometries
      let points = new THREE.Mesh( subgeo, new THREE.MeshBasicMaterial({
        color: 0xffffff,
        vertexColors: THREE.FaceColors,
        morphTargets: false,
        transparent: true,
        opacity: 1.0
      }) );
      this.seriesGeos[ series[0] ] = points;
      this.scene.add( points );
    });
  }

  addPoint(lat, lng, size, color, subgeo) {
    let phi = (90 - lat) * Math.PI / 180;
    let theta = (180 - lng) * Math.PI / 180;

    this.point.position.x = 150 * Math.sin(phi) * Math.cos(theta);
    this.point.position.y = 150 * Math.cos(phi);
    this.point.position.z = 150 * Math.sin(phi) * Math.sin(theta);

    this.point.lookAt(this.mesh.position);

    this.point.scale.z = Math.max( size, 0.1 ); // avoid non-invertible matrix
    this.point.updateMatrix();

    this.point.geometry.faces.forEach( ( face ) => {
      face.color = color;
    });

    // Note: this method was introduced in r70 but is only documented in the
    // release notes. Hopefully it will stick around and not break in the future
    subgeo.mergeMesh( this.point );
  }

  initLegend() {
    React.render(
      React.createElement( SeriesSelector, {
        series: this._legendState,
        totalHits: this._totalHits,
        toggleHandler: this.onLegendToggle.bind( this )
      }),
      document.getElementById( 'series-selector' )
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Event Handlers
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  onMouseDown( event ) {
    event.preventDefault();

    this.k = 0;
    this.f = true;
    this.inMouseDrag = true;

    this.target.y = this.rotation.y;
    this.mouseOnDown.x = -event.clientX;
    this.mouseOnDown.y = event.clientY;

    this.targetOnDown.x = this.target.x;
    this.targetOnDown.y = this.target.y;

    this.container.style.cursor = 'move';
  }

  onMouseMove( event ) {
    if( !this.inMouseDrag ) return;

    this.mouse.x = -event.clientX;
    this.mouse.y = event.clientY;

    let zoomDamp = this.distance/1000;

    this.target.x = this.targetOnDown.x + (this.mouse.x - this.mouseOnDown.x) * 0.005 * zoomDamp;
    this.target.y = this.targetOnDown.y + (this.mouse.y - this.mouseOnDown.y) * 0.005 * zoomDamp;

    this.target.y = this.target.y > PI_HALF ? PI_HALF : this.target.y;
    this.target.y = this.target.y < -PI_HALF ? -PI_HALF : this.target.y;
  }

  onMouseUp( event ) {
    if( !this.inMouseDrag ) return;

    this.k = ROTATIONSPEED;
    this.f = false;

    this.inMouseDrag = false;
    this.container.style.cursor = 'auto';
  }

  onMouseOut( event ) {
    if( !this.inMouseDrag ) return;

    this.k = ROTATIONSPEED;
    this.f = false;
    this.inMouseDrag = false;
  }

  onMouseWheel( event ) {
    event.preventDefault();

    if( this.overRenderer ) {
      let delta = 0;
      if( event.wheelDelta ) {
        delta = event.wheelDelta * 0.3;
      } else if( event.detail ) {
        delta = -event.detail * 10;
      }
      this.zoom( delta );
    }

    return false;
  }

  onLegendToggle( name, active ) {
    let startVal = 0.0;
    let endVal = 1.0;

    if( !active ) {
      startVal = 1.0;
      endVal = 0.0;
    }

    let mat = this.seriesGeos[ name ].material;
    let tween = new TWEEN.Tween( {x: startVal} ).to( {x: endVal}, 500 );
    tween.onUpdate( function() {
      mat.opacity = this.x;
    });
    tween.start();

    // TODO: recalculate all point colours based on the (potentially) new max data val
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Render-related Methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  zoom( delta ) {
    this.distanceTarget -= delta;
    this.distanceTarget = this.distanceTarget > 1100 ? 1100 : this.distanceTarget;
    this.distanceTarget = this.distanceTarget < 350 ? 350 : this.distanceTarget;
  }

  render() {
    this.zoom( 0 );
    this.target.x -= this.k;
    this.rotation.x += (this.target.x - this.rotation.x) * 0.2;

    if( this.f ) {
      this.rotation.y += (this.target.y - this.rotation.y) * 0.2;
    } else {
      this.target.y = Math.PI / 5.0;
      this.rotation.y += (this.target.y - this.rotation.y) * 0.02;
    }

    this.distance += (this.distanceTarget - this.distance) * 0.3;

    this.camera.position.x = this.distance * Math.sin(this.rotation.x) * Math.cos(this.rotation.y);
    this.camera.position.y = this.distance * Math.sin(this.rotation.y);
    this.camera.position.z = this.distance * Math.cos(this.rotation.x) * Math.cos(this.rotation.y);

    this.camera.lookAt( this.mesh.position );

    this.renderer.render( this.scene, this.camera );

    // Update any in-flight tweens
    TWEEN.update();
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Private Helper Methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// helper function to find the max value in an array of data (used for colour
// interpolation in the colorFn)
function _setMaxDataVal( data ) {
  let currMax = 0;

  data.forEach( (subArr) => {
    let seriesMax = Math.max.apply( Math, subArr[1] );
    _seriesMaximums[ subArr[0] ] = seriesMax;

    if( seriesMax > currMax ) {
      currMax = seriesMax;
      _seriesWithMaxDataVal = subArr[0];
    }
  });
}
