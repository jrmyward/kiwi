class FK.DatePicker.DatePickerController extends Marionette.Controller
  initialize: (options) =>
    @model = new FK.Models.Event
    @view = new FK.DatePicker.DatePickerView(model: @model)
    @regions = new Marionette.RegionManager()

  renderIn: (selector) =>
    $(selector).attr('data-rendered', 'true')
    @regions.addRegion('spot', selector)
    @regions.get('spot').show(@view)

  value: () =>
    {
      datetime: @model.get('datetime')
      local_time: @model.get('local_time')
      local_date: moment(@model.get('local_date')).format('YYYY-MM-DD')
      time_format: @model.get('time_format')
      is_all_day: @model.get('is_all_day')
    }
