import baguetteBox from 'baguettebox.js';
import List from 'list.js';
import * as moment from 'moment';

// destroy broken images
window.addEventListener('error', function(event) {
  console.log(event)
  if (event.error.type == 'Event') {
    event.error.target.remove()
  }
})

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