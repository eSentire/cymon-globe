$(function() {
  if (!Detector.webgl) {
    Detector.addGetWebGLMessage();
  } else {
    // Fetch our data
    $.ajax( 'data-magnitude.json' )
      .done( function( response ) {
        THREE.ImageUtils.crossOrigin = '';
        var container = document.getElementById('globe');

        var globe = DAT.Globe(container);

        globe.addData( response, {format: 'magnitude', name: 'Security Events'} );
        globe.createPoints();
        globe.animate();
      })
      .fail( function( jqXHR, textStatus ) {
        alert( 'Could not load data. Reason: ' + textStatus );
      });
  }
});
