// Component representing an individual series
import * as utils from '../utils';

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// <SeriesItem /> Component definition
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
export default class SeriesItem extends React.Component {
  constructor( props ) {
    super( props );

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Styles
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    this.seriesItemStyle = {
      listStyleType: 'none',
      margin: '0 0 -1px 0',
      padding: 3,
      border: '1px solid rgba( 85, 85, 85, 0.5 )',
      minWidth: 150
    };

    this.seriesToggleLinkStyle = {
      color: '#fff',
      textDecoration: 'none',
      display: 'inline-block',
      width: '100%',
      position: 'relative',
      zIndex: 10,
      textTransform: 'capitalize',
      cursor: 'pointer',

      // Transition for when we become inactive
      WebkitTransition: 'color 500ms ease-out',
      MozTransition:    'color 500ms ease-out',
      OTransition:      'color 500ms ease-out',
      transition:       'color 500ms ease-out'
    };

    this.progressBarStyle = {
      width: '66%',
      height: 20,
      display: 'inline-block',
      position: 'absolute',
      left: 3,
      maxWidth: 150,

      // Transition for when we become inactive
      WebkitTransition: 'width 500ms linear',
      MozTransition:    'width 500ms linear',
      OTransition:      'width 500ms linear',
      transition:       'width 500ms linear'
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Final Render
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  render() {
    let ariaValue = 0;

    let colourTuple = utils.colourMap( this.props.percentage, 100 );
    this.progressBarStyle.backgroundColor = `rgba( ${colourTuple.r}, ${colourTuple.g}, ${colourTuple.b}, 0.5 )`;

    if( this.props.active ) {
      this.seriesToggleLinkStyle.color = '#fff';
      this.progressBarStyle.width = this.props.percentage + '%';
      ariaValue = this.props.percentage;
    } else {
      this.seriesToggleLinkStyle.color = '#555';
      this.progressBarStyle.width = '0';
    }

    /* jshint ignore: start */
    <li style={this.seriesItemStyle} className="series">
      <span style={this.seriesToggleLinkStyle} onClick={this.props.toggleHandler} role="checkbox" aria-checked={this.props.active}>{this.props.name}</span>
      <div style={this.progressBarStyle} aria-value-now={ariaValue} aria-value-min="0" aria-value-max="100"></div>
    </li>
    /* jshint ignore: end */
  }
}
