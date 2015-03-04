$(function() {
  if (!Detector.webgl) {
    Detector.addGetWebGLMessage();
  } else {
    // Fetch our data
    $.ajax( { url: 'data-magnitude.json', dataType: 'json' } )
      .done( function( response ) {
        THREE.ImageUtils.crossOrigin = '';
        var container = document.getElementById('globe');

        var globe = DAT.Globe(container);

        globe.addData( response );
        globe.createPoints();
        globe.animate();
      })
      .fail( function( jqXHR, textStatus ) {
        alert( 'Could not load data. Reason: ' + textStatus );
      });
  }
});
