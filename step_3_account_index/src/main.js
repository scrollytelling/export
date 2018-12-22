var locale = window.navigator.userLanguage || window.navigator.language

moment.locale(locale)

var times = document.querySelectorAll('time')
for(var i=0; i<times.length; i++) {
  var datetime = times[i].getAttribute('datetime')
  var published = moment(datetime)
  times[i].innerHTML = published.format("dddd D MMMM YYYY, h:mm:ss")
}

var entries = new List('scrollies', {
  valueNames: [
    'title',
    'author',
    { name: 'published', attr: 'datetime' }
  ],
  fuzzySearch: {
    searchClass: 'search'
  }
})
