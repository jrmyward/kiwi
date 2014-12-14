$ ->
  $('[name="name"]').keyup(refreshRemaningCount)
  $('[name="location_type"]').change(refreshLocationType)

  refreshRemaningCount()
  refreshLocationType()

  renderImageTrimmer()

refreshRemaningCount = ->
  val = $('input[name="name"]').val()
  remaining_count = 100 - val.length
  $('[data-role="counter"]').text(remaining_count)

refreshLocationType = ->
  location_type = $('[type="radio"][name="location_type"]:checked').val()
  $('select[name="country"]').prop('disabled', location_type == 'international')

renderImageTrimmer = ->
  console.log(FK)
  trimmer = new FK.ImageTrimmer.ImageTrimmerController
  trimmer.renderIn('#image-region')
