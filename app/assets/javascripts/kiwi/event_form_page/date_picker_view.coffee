class FK.DatePicker.DatePickerView extends Marionette.ItemView
  className: 'date_picker'
  template: FK.Template('event_form_page/date_picker')

  events:
    'click [name="all_day"]': 'updateAllDay'
    'change [name="date"]': 'updateDate'
    'change [name="hours"]': 'updateTime'
    'change [name="minutes"]': 'updateTime'
    'change [name="ampm"]': 'updateTime'
    'click [name="time_format"]': 'updateFormat'

  updateAllDay: (e) =>
    @model.set('all_day', $(e.target).is(':checked'))

  updateDate: (e) =>
    @model.set('date', $(e.target).val())

  updateTime: =>
    @model.set('hour', @$('[name="hours"]').val())
    @model.set('minute', @$('[name="minutes"]').val())
    @model.set('ampm', @$('[name="ampm"]').val())

  updateFormat: =>
    @model.set('format', @$('[name="time_format"]:checked').val())

  modelEvents:
    'change:all_day': 'refreshTimeSelectActive'
    'change:hour change:minute change:ampm change:format': 'refreshTimeShown'
    'change:format': 'refreshTimezoneDisplay'

  refreshTimeSelectActive: (model, all_day) =>
    if all_day
      @$('.all_day_toggle').css('display', 'none')
      @$('[name="all_day"]').prop('checked', true)
    else
      @$('.all_day_toggle').css('display', 'block')
      @$('[name="all_day"]').prop('checked', false)

  refreshTime: (model) =>
    @$('[name="hours"]').val(model.get('hour'))
    @$('[name="minutes"]').val(model.get('minute'))
    @$('[name="ampm"]').val(model.get('ampm'))

  refreshTimeFormat: (model) =>
    @$("[name=\"time_format\"][value=\"#{model.get('format')}\"]").prop('checked', true)

  refreshTimezoneDisplay: (model) =>
    if model.get('format') is 'tv_show'
      @$('.zone-display').text('(US Eastern Timezone)')
    else
      @$('.zone-display').text('(Your Timezone)')

  refreshTimeShown: (model) =>
    @$('.time-display-value').text(model.timeDisplay())

  onRender: () =>
    @datepicker = @$('input[name="date"]').datepicker(
      format: 'dd/mm/yyyy'
    )
    @refreshTimeSelectActive(@model, @model.get('all_day'))
    @refreshTimeShown(@model)
    @refreshTime(@model)
    @refreshTimeFormat(@model)
    @refreshTimezoneDisplay(@model)

  onShow: () =>
    @updateTime() unless @model.hasTime()
