# Component representing an individual series

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
    backgroundColor: '#008EAF' # Fallback
    backgroundColor: 'rgba( 0, 142, 175, 0.5 )'

    # Transition for when we become inactive
    WebkitTransition: 'width 500ms linear'
    MozTransition:    'width 500ms linear'
    OTransition:      'width 500ms linear'
    transition:       'width 500ms linear'

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Behaviours
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  getInitialState: ->
    return {active: true}

  handleLinkClick: ->
    @setState { active: !@state.active }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Final Render
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  render: ->
    ariaValue = 0

    if @state.active
      @seriesToggleLinkStyle.color = '#fff'
      @progressBarStyle.width = @props.percentage + '%'
      ariaValue = @props.percentage
    else
      @seriesToggleLinkStyle.color = '#555'
      @progressBarStyle.width = '0'

    <li style={@seriesItemStyle} className="series">
      <a style={@seriesToggleLinkStyle} onClick={@handleLinkClick} href="#">Sample series</a>
      <div style={@progressBarStyle} ariaValuenow={ariaValue} ariaValuemin="0" ariaValuemax="100"></div>
    </li>
