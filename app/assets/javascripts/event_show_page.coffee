$ ->
  $('#comment-new').html($('#comment-new-template').html())
  $('.comments').on('click', '[data-action="comment"]', comment)
  $('.mute-delete').click(deletePrep)


comment = (e) ->
  e.preventDefault()
  form = $(e.currentTarget).parents('form')
  formData = new FormData()
  formData.append('message', $(form).find('textarea[name=message]').val())

  xhr = new XMLHttpRequest()
  url = "/api/1/events/#{form.data('event-id')}/comments"

  xhr.open(form.data('method'), url, true)
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

  xhr.onload = (xhr_e) =>
    success()
  xhr.send(formData)

deleteComment = (e) ->
  target = $(e.currentTarget)
  xhr = new XMLHttpRequest()
  url = "/api/1/events/#{target.data('event-id')}/comments/#{target.data('comment-id')}"
  xhr.open('DELETE', url, true)
  xhr.onload = (xhr_e) =>
    success()
  xhr.send({})

deletePrep = (e) ->
  e.stopPropagation()
  e.preventDefault()
  target = $(e.currentTarget)
  if target.text() == "Confirm?"
    deleteComment(e)
  else
    target.addClass('btn btn-danger btn-xs')
    target.text('Confirm?')
    _.delay(->
      target.removeClass('btn btn-danger btn-xs')
      target.text(target.data('original-text'))
    , 5000)

success = ->
  window.location.reload false
