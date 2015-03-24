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
      newState[ series.name ] = true

    @setState newState

  handleSeriesItemToggle: ( name, event )->
    newState = {}
    newState[ name ] = !@state[name]

    @setState newState

  render: ->
    activeHits = @props.totalHits

    # Step 1: calculate our total active hits
    for series in @props.series
      if !@state[ series.name ]
        activeHits -= series.numHits

    <div>
      <h2 style={@headerStyle}>Threat Types</h2>
      <ul style={@seriesListStyle}>
        { @props.series.map ( item ) =>
          itemProps =
            name: item.name
            percentage: Math.floor( (item.numHits / activeHits) * 100 )
            active: @state[item.name]
            toggleHandler: @handleSeriesItemToggle.bind( this, item.name )
          return <SeriesItem {...itemProps}/>
        }
      </ul>
    </div>
