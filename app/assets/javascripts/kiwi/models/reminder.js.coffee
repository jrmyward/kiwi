class FK.Models.Reminder extends Backbone.GSModel
  idAttribute: "_id"

  defaults:
    times_to_event: []
    event_id: null

  noTimesSet: =>
    @get('times_to_event').length == 0

  updateTimes: (times) =>
    newTimes = _.difference(times, @get('times_to_event'))
    oldTimes = _.difference(@get('times_to_event'), times)

    _.each(newTimes, (newTime) ->
      $.post("/api/1/events/#{@get('event_id')}/reminders", {
        interval: newTime
      })
    , @)

    _.each(oldTimes, (oldTime) ->
      $.ajax(url: "/api/1/events/#{@get('event_id')}/reminders/#{oldTime}", method: 'DELETE')
    , @)

    @set('times_to_event', times)
