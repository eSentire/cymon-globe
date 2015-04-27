// Used with the colour function (each subarray is an RGB tuple representing
// the percentage out of 255)
const COLOURS = [
  [  0,   0, 1.0], // blue
  [  0, 1.0,   0], // green
  [1.0, 1.0,   0], // yellow
  [1.0,   0,   0]  // red
];

// Logic for this function inspired by:
// http://www.andrewnoske.com/wiki/Code_-_heatmaps_and_color_gradients

// Gets the heatmap colour for x given the maxVal
export function colourMap( x, maxVal ) {
  x = x / maxVal;

  let fractBetween = 0;
  let idx1 = 0;
  let idx2 = 0;

  if( x >= 1 ) {
    idx1 = COLOURS.length - 1;
    idx2 = COLOURS.length - 1;
  } else {
    x = x * (COLOURS.length - 1);
    idx1 = Math.floor( x );
    idx2 = idx1 + 1;
    fractBetween = x - idx1;
  }

  let r = ( COLOURS[idx2][0] - COLOURS[idx1][0] ) * fractBetween + COLOURS[idx1][0];
  let g = ( COLOURS[idx2][1] - COLOURS[idx1][1] ) * fractBetween + COLOURS[idx1][1];
  let b = ( COLOURS[idx2][2] - COLOURS[idx1][2] ) * fractBetween + COLOURS[idx1][2];

  return {
    r: Math.floor( r*255 ),
    g: Math.floor( g*255 ),
    b: Math.floor( b*255 )
  };
}