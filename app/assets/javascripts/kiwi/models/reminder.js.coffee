class FK.Models.Reminder extends Backbone.GSModel
  idAttribute: "_id"

  defaults:
    times_to_event: []
    event_id: null

  noTimesSet: =>
    @get('times_to_event').length == 0
