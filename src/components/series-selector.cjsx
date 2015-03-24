# Main component for the interactive series selector
SeriesItem = require './series-item'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Component definitions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module.exports = React.createClass
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Styles
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  headerStyle:
    fontSize: 18

  seriesListStyle:
    margin: 0
    padding: 0

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Behaviours
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  getInitialState: ->
    return {}

  # Properties for the Legend. Object is of the form:
  # [
  #   { name: <str>, numHits: <num> },
  #   ...
  # ]
  componentWillMount: ->
    newState = {}
    for series in @props.series
      newState[ series.name ] = {}
      newState[ series.name ].active = true
      newState[ series.name ].percentage = Math.floor( (series.numHits / @props.totalHits) * 100 )
    @setState newState

  handleSeriesItemToggle: ( name, event )->
    newState = {}
    newState[ name ] = {}
    newState[ name ].active = !@state[name].active
    newState[ name ].percentage = @state[name].percentage

    @setState newState

  render: ->
    <div>
      <h2 style={@headerStyle}>Threat Types</h2>
      <ul style={@seriesListStyle}>
        { @props.series.map ( item ) =>
          itemProps =
            name: item.name
            percentage: @state[item.name].percentage
            active: @state[item.name].active
            toggleHandler: @handleSeriesItemToggle.bind( this, item.name )
          return <SeriesItem {...itemProps}/>
        }
      </ul>
    </div>
