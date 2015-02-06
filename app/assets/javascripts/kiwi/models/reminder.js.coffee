class FK.Models.Reminder extends Backbone.Model
  idAttribute: "_id"

  defaults:
    times_to_event: []
    event_id: null
    logged_in: true

  noTimesSet: =>
    @get('times_to_event').length == 0

  updateTimes: (times) =>
    newTimes = _.difference(times, @get('times_to_event'))
    oldTimes = _.difference(@get('times_to_event'), times)

    _.each(newTimes, (newTime) ->
      $.post("/api/1/events/#{@get('event_id')}/reminders", {
        interval: newTime,
        recipient_time_zone: jstz.determine().name()
      })
    , @)

    _.each(oldTimes, (oldTime) ->
      $.ajax(url: "/api/1/events/#{@get('event_id')}/reminders/#{oldTime}", method: 'DELETE')
    , @)

    @set('times_to_event', times)
