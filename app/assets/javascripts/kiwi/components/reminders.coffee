class FK.RemindersDropdownController extends Marionette.Controller
  initialize: (opts) =>
    @model = new FK.Models.Reminder(opts)
    @view = new FK.RemindersView()
    @regions = new Marionette.RegionManager()

    @view.on 'openPopover', () =>
      @popoverView = new FK.RemindersPopoverView(model: @model)
      @view.remindersPopover.show(@popoverView)

  renderIn: (selector) =>
    $(selector).attr('data-rendered', 'true')
    @regions.addRegion('spot', selector)
    @regions.get('spot').show(@view)

class FK.RemindersView extends Marionette.Layout
  template: FK.Template('components/reminder')
  className: 'reminder-component'
  regions:
    'remindersPopover': '.popover-container'

  triggers:
    'click .glyphicon-bell': 'openPopover'

class FK.RemindersPopoverView extends Marionette.ItemView
  template: FK.Template('components/reminders_popover')
  className: 'event-reminders-super-container'

  events:
    'click': 'stopPropagate'
    'click [data-action="set-reminder"]': 'updateTimes'
    'click [data-action="cancel"]': 'close'

  stopPropagate: (e) =>
    e.stopPropagation()

  getTimes: () =>
    $.map($('input:checked'), (box, i) =>
      $(box).data('time')
    )

  updateTimes: () =>
    times = @getTimes()
    @model.updateTimes(times)
    @close()

  setTimes: () =>
    _.each(@model.get('times_to_event'), (time) =>
      $('[data-time="' + time + '"]').prop('checked', true)
    )

    $('[data-time="1h"]').prop('checked', true) if @model.noTimesSet()

  onShow: =>
    @setTimes()
