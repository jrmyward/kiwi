$ ->
  $('[name="name"]').keyup(refreshRemaningCount)
  $('[name="location_type"]').change(refreshLocationType)

  $('[data-action="save"]').click(saveEvent)

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
  elem = $('#image-region')

  url = elem.data('url')
  width = elem.data('width')
  crop_x = elem.data('crop-x')
  crop_y = elem.data('crop-y')

  trimmer = new FK.ImageTrimmer.ImageTrimmerController
  trimmer.renderIn('#image-region')

  if url && url isnt '/images/original/missing.png'
    trimmer.newImage(url, 'reload')
    trimmer.setWidth(width)
    trimmer.setPosition(crop_x, crop_y)

renderDateTimePicker = ->
  elem = $('#datetime-region')

  date = elem.data('date')
  hour = elem.data('hour')
  minute = elem.data('minute')
  ampm = elem.data('ampm')
  allDay = elem.data('all-day')
  format = elem.data('format')
  
  dateTimePicker = new FK.DatePicker.DatePickerController
    date: date
    hour: hour
    minute: minute
    ampm: ampm
    all_day: allDay
    format: format

  dateTimePicker.renderIn('#datetime-region')

saveEvent = (e) ->
  e.preventDefault()
  form = $('form.event_form')

  name = form.find('input[name="name"]').val()
  subkast = form.find('[name="subkast"]').val()
  location_type = form.find('[name="location_type"]:checked').val()
  country = form.find('[name="country"]').val()
  date = form.find('[name="date"]').val()
  time = "#{form.find('[name="hours"]').val()}:#{form.find('[name="minutes"]').val()}:00 #{form.find('[name="ampm"]').val()}"
  all_day = form.find('[name="is_all_day"]').is(':checked')
  time_type = form.find('[name="time_format"]:checked').val()
  image = form.find('[type="file"]')[0].files[0]
  image_url = form.find('[name="image_url"]').val()
  use_upload = form.find('[name="upload_or_url"]').val() is 'upload'
  height = form.find('[name="image_height"]').val()
  width = form.find('[name="image_width"]').val()
  crop_x = form.find('[name="image_x"]').val()
  crop_y = form.find('[name="image_y"]').val()
  description = form.find('[name="description"]').val()

  formData = new FormData()

  formData.append('name', name)
  formData.append('subkast', subkast)
  formData.append('international', true) if location_type is 'international'
  formData.append('country', country) if location_type is 'national'
  formData.append('date', date)
  formData.append('time', time) unless all_day
  formData.append('time_zone', jstz.determine().name()) if time_type is '' and all_day is false
  formData.append('all_day', true) if all_day
  formData.append('recurring', true) if time_type is 'recurring'
  formData.append('eastern_tv_show', true) if time_type is 'tv_show'
  formData.append('image', image) if use_upload
  formData.append('image_url', image_url) unless use_upload
  formData.append('crop_x', crop_x)
  formData.append('crop_y', crop_y)
  formData.append('height', height)
  formData.append('width', width)
  formData.append('description', description)

  xhr = new XMLHttpRequest()
  xhr.open('POST', '/api/1/events', true)
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

  xhr.onload = (xhr_e) =>
    event = JSON.parse(xhr_e.target.response)
    console.log(event)
    return unless event.response.id
    window.location = "/events/#{event.response.id}"

  xhr.send(formData)
