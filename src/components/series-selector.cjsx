# Main component for the interactive series selector

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Styles
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
headerStyle =
  fontSize: 18

seriesListStyle =
  margin: 0
  padding: 0

seriesItemStyle =
  listStyleType: 'none'
  margin: '0 0 -1px 0'
  padding: 3
  border: '1px solid #555' # Fallback
  border: '1px solid rgba( 85, 85, 85, 0.5 )'
  minWidth: 150

seriesToggleLinkStyle =
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

progressBarStyle =
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Component definitions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeriesSelector = React.createClass
  render: ->
    <div>
      <h2 style={headerStyle}>Threat Types</h2>
      <ul style={seriesListStyle}>
        <li style={seriesItemStyle}><a style={seriesToggleLinkStyle} href="#">Sample series</a><div ariaValuenow="25" ariaValuemin="0" ariaValuemax="100" style={progressBarStyle} dataToggleWidth="0"></div></li>
        <li style={seriesItemStyle}><a style={seriesToggleLinkStyle} href="#">Sample series</a><div ariaValuenow="40" ariaValuemin="0" ariaValuemax="100" style={progressBarStyle} dataToggleWidth="0"></div></li>
        <li style={seriesItemStyle}><a style={seriesToggleLinkStyle} href="#">Sample series</a><div ariaValuenow="66" ariaValuemin="0" ariaValuemax="100" style={progressBarStyle} dataToggleWidth="0"></div></li>
        <li style={seriesItemStyle}><a style={seriesToggleLinkStyle} href="#">Sample series</a><div ariaValuenow="75" ariaValuemin="0" ariaValuemax="100" style={progressBarStyle} dataToggleWidth="0"></div></li>
        <li style={seriesItemStyle}><a style={seriesToggleLinkStyle} href="#">Sample series</a><div ariaValuenow="90" ariaValuemin="0" ariaValuemax="100" style={progressBarStyle} dataToggleWidth="0"></div></li>
        <li style={seriesItemStyle}><a style={seriesToggleLinkStyle} href="#">Sample series</a><div ariaValuenow="38" ariaValuemin="0" ariaValuemax="100" style={progressBarStyle} dataToggleWidth="0"></div></li>
      </ul>
    </div>

React.render(
  <SeriesSelector />
  document.getElementById 'series-selector'
)
