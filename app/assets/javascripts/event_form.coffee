$ ->
  $('[name="name"]').keyup(refreshRemaningCount)
  $('[name="location_type"]').change(refreshLocationType)

  refreshRemaningCount()
  refreshLocationType()

  renderDateTimePicker()
  renderImageTrimmer()

refreshRemaningCount = ->
  val = $('input[name="name"]').val()
  remainingCount = 100 - val.length
  $('[data-role="counter"]').text(remainingCount)

refreshLocationType = ->
  location_type = $('[type="radio"][name="location_type"]:checked').val()
  $('select[name="country"]').prop('disabled', location_type == 'international')

renderImageTrimmer = ->
  trimmer = new FK.ImageTrimmer.ImageTrimmerController
  trimmer.renderIn('#image-region')

renderDateTimePicker = ->
  dateTimePicker = new FK.DatePicker.DatePickerController
  dateTimePicker.renderIn('#datetime-region')
