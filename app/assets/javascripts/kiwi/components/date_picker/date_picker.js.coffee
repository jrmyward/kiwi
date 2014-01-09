FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  Instance = null

  @addFinalizer () ->
    Instance.close()

  @create = (domLocation, model) ->
    Instance = new DatePicker.DatePickerController
      model: model
    
    regionManager = new Marionette.RegionManager()
    region = regionManager.addRegion("instance", domLocation)
    datepicker_view = new DatePicker.DatePickerView
      model: model
   

    region.show datepicker_view

    Instance.on 'close', () =>
      regionManager.close()

    return Instance

  class DatePicker.DatePickerController extends Marionette.Controller
    initialize: (options) =>
      @model = options.model
    value: () =>
      # I'm a good citizen, i only return what I partied on
      {
        datetime: @model.get('datetime')
        time_format: @model.get('time_format')
        local_time: @model.get('local_time')
        is_all_day: @model.get('is_all_day')
      }
