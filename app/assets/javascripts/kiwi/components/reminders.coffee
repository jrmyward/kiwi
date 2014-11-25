class FK.RemindersDropdownController extends Marionette.Controller
  initialize: (opts) =>
    @model = new FK.Models.Reminder(opts)
    @view = new FK.RemindersView(model: @model)
    @regions = new Marionette.RegionManager()

  renderIn: (selector) =>
    $(selector).attr('data-rendered', 'true')
    @regions.addRegion('spot', selector)
    @regions.get('spot').show(@view)

class FK.RemindersView extends Marionette.ItemView
  template: FK.Template('components/reminders')
  className: 'event-reminders-super-container'

  triggers:
    'click [data-action="set-reminder"]': 'click:set-reminder'
    'click [data-action="cancel"]': 'click:cancel'

  events:
    'click': 'stopPropagate'

  stopPropagate: (e) =>
    e.stopPropagation()

  getTimes: () =>
    $.map($('input:checked'), (box, i) =>
      $(box).data('time')
    )

  setTimes: () =>
    _.each(@model.get('times_to_event'), (time) =>
      $('[data-time="' + time + '"]').prop('checked', true)
    )

    $('[data-time="1h"]').prop('checked', true) if @model.noTimesSet()

  onShow: =>
    @setTimes()
