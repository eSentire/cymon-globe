# Component representing an individual series

utils = require '../utils'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# <SeriesItem /> Component definition
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
module.exports = React.createClass
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Styles
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  seriesItemStyle:
    listStyleType: 'none'
    margin: '0 0 -1px 0'
    padding: 3
    border: '1px solid #555' # Fallback
    border: '1px solid rgba( 85, 85, 85, 0.5 )'
    minWidth: 150

  seriesToggleLinkStyle:
    color: '#fff'
    textDecoration: 'none'
    display: 'inline-block'
    width: '100%'
    position: 'relative'
    zIndex: 10
    textTransform: 'capitalize'

    # Transition for when we become inactive
    WebkitTransition: 'color 500ms ease-out'
    MozTransition:    'color 500ms ease-out'
    OTransition:      'color 500ms ease-out'
    transition:       'color 500ms ease-out'

  progressBarStyle:
    width: '66%'
    height: 20
    display: 'inline-block'
    position: 'absolute'
    left: 3
    maxWidth: 150

    # Transition for when we become inactive
    WebkitTransition: 'width 500ms linear'
    MozTransition:    'width 500ms linear'
    OTransition:      'width 500ms linear'
    transition:       'width 500ms linear'

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Final Render
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  render: ->
    ariaValue = 0

    colourTuple = utils.colourMap( @props.percentage, 100 )
    @progressBarStyle.backgroundColor = "rgba( #{colourTuple.r}, #{colourTuple.g}, #{colourTuple.b}, 0.5 )"

    if @props.active
      @seriesToggleLinkStyle.color = '#fff'
      @progressBarStyle.width = @props.percentage + '%'
      ariaValue = @props.percentage
    else
      @seriesToggleLinkStyle.color = '#555'
      @progressBarStyle.width = '0'

    <li style={@seriesItemStyle} className="series">
      <a style={@seriesToggleLinkStyle} onClick={@props.toggleHandler} href="#">{@props.name}</a>
      <div style={@progressBarStyle} aria-value-now={ariaValue} aria-value-min="0" aria-value-max="100"></div>
    </li>
