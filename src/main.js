import * as DAT from './globe';

let globe = null;

$( () => {
  if( !Detector.webgl ) {
    Detector.addGetWebGLMessage();
  } else {
    // Fetch data from the server
    $.ajax({
      url: '//cymon.io/api/publicajax/nexus/globe/?categories=1',
      dataType: 'json',
      error: ( jqXHR, textStatus, errorThrown ) => {
        alert( `Could not load data. Reason: ${textStatus}` );
      },
      success: ( response ) => {
        let container = document.getElementById( 'globe' );

        THREE.ImageUtils.loadTexture( '../img/map2.jpg', undefined, ( texture ) => {
          globe = DAT.createGlobe( container, texture );

          globe.addData( response.data );
          globe.initLegend();
          doAnimate();
        });
      }
    });
  }
});

function doAnimate() {
  requestAnimationFrame( doAnimate );
  globe.render();
}
