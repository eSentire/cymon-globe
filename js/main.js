$(function() {
  if (!Detector.webgl) {
    Detector.addGetWebGLMessage();
  } else {
    // Fetch our data
    $.ajax( { url: 'data-magnitude.json', dataType: 'json' } )
      .done( function( response ) {
        THREE.ImageUtils.crossOrigin = '';
        var container = document.getElementById('globe');

        THREE.ImageUtils.loadTexture( '../img/map2.jpg', undefined, function( texture ) {
          var globe = DAT.Globe(container, texture);

          globe.addData( response );
          globe.createPoints();
          globe.animate();
        });
      })
      .fail( function( jqXHR, textStatus ) {
        alert( 'Could not load data. Reason: ' + textStatus );
      });
  }
});
