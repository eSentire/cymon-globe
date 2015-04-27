// Main component for the interactive series selector
import SeriesItem from './series-item.jsx';
import React from 'react';

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Component definitions
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
export default class SeriesSelector extends React.Component {
  constructor( props ) {
    super( props );

    // set initial state
    this.state = {};

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Styles
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    this.headerStyle = {
      fontSize: 18
    };

    this.seriesListStyle = {
      margin: 0,
      padding: 0
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Behaviours
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Properties for the Legend. Object is of the form:
  // [
  //   { name: <str>, numHits: <num> },
  //   ...
  // ]
  componentWillMount() {
    let newState = {};

    this.props.series.forEach( (series) => {
      newState[ series.name ] = true;
    });

    this.setState( newState );
  }

  handleSeriesItemToggle( name, event ) {
    let newState = {};
    newState[ name ] = !this.state[name];

    this.setState( newState );

    // call up into the globe to toggle the data display
    this.props.toggleHandler( name, newState[name] );
  }

  render() {
    let activeHits = this.props.totalHits;

    // Step 1: calculate our total active hits
    this.props.series.forEach( (series) => {
      if( !this.state[ series.name ] ) {
        activeHits -= series.numHits;
      }
    });

    /* jshint ignore: start */
    return( <div>
      <h2 style={this.headerStyle}>Threat Types</h2>
      <ul style={this.seriesListStyle}>
        { this.props.series.map( ( item ) => {
          let itemProps = {
            name: item.name,
            key: item.name,
            percentage: Math.floor( (item.numHits / activeHits) * 100 ),
            active: this.state[item.name],
            toggleHandler: this.handleSeriesItemToggle.bind( this, item.name )
          };
          return <SeriesItem {...itemProps}/>
        })
        }
      </ul>
    </div> );
    /* jshint ignore: end */
  }
}
