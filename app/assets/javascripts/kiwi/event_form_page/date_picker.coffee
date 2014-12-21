class FK.DatePicker.DatePickerController extends Marionette.Controller
  initialize: (options) =>
    @model = new FK.DatePicker.DateTimeModel
    @view = new FK.DatePicker.DatePickerView(model: @model)
    @regions = new Marionette.RegionManager()

  renderIn: (selector) =>
    $(selector).attr('data-rendered', 'true')
    @regions.addRegion('spot', selector)
    @regions.get('spot').show(@view)

class FK.DatePicker.DateTimeModel extends Backbone.Model
  defaults:
    hour: ''
    minute: ''
    ampm: ''
    date: null
    all_day: false
    format: ''

  hasTime: () =>
    @get('hour') isnt '' && @get('minute') isnt '' && @get('ampm') isnt ''

  timeDisplay: () =>
    return "#{@get('hour')}:#{@get('minute')} #{@get('ampm')}" if @get('format') is '' or @get('format') is 'recurring'

    hour = parseInt(@get('hour'))
    minute = parseInt(@get('minute'))

    minute = "0#{minute}" if minute < 10

    centralHour = hour - 1
    centralHour = 12 if centralHour == 0

    return "#{hour}:#{minute}/#{centralHour}:#{minute}c"
