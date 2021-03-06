renderUpvotes = () ->
  $('[data-upvote-component]:not([data-rendered])').each((i, container) ->
    upvote_count = $(container).data('upvote-count')
    upvoted = $(container).data('upvoted')
    event_id = $(container).data('event-id')
    logged_in = $(container).data('logged-in')

    component = new FK.UpvoteCounterComponent(upvote_count: upvote_count, upvoted: upvoted, event_id: event_id, logged_in: logged_in, inline: true)
    component.renderIn('[data-upvote-component][data-event-id="' + event_id + '"]')
  )

renderReminders = () ->
  $('[data-reminder-component]:not([data-rendered])').each((id, container) ->
    times = $(container).data('times')
    event_id = $(container).data('event-id')
    logged_in = $(container).data('logged-in')

    component = new FK.RemindersDropdownController(times_to_event: times, event_id: event_id, logged_in: logged_in)
    component.renderIn('[data-reminder-component][data-event-id="' + event_id + '"]')
  )

$ ->
  renderUpvotes()
  renderReminders()

  $('.event-info-container').on('click', 'a.mute-delete', deleteEventPrep)

  $('#comment-new').html($('#comment-new-template').html())
  $('#comment-new button[data-action=cancel]').remove()
  $('#comment-list').on('click', '[data-action="cancel"]', cancelComment)
  $('#event-comments-region').on('click', '[data-action="comment"]', comment)
  $('#event-comments-region').on('click', 'a.reply', replyComment)
  $('#event-comments-region').on('click','a.mute-delete', deletePrep)
  $('#event-comments-region').on('click','a.comment-upvote', upvoteComment)
  $('#event-comments-region').on('click','a.comment-downvote', downvoteComment)

deleteEventPrep = (e) ->
  e.stopPropagation()
  e.preventDefault()
  target = $(e.currentTarget)
  if target.text() != "Confirm?"
    target.addClass('btn btn-danger btn-xs')
    target.text('Confirm?')
    _.delay(->
      target.removeClass('btn btn-danger btn-xs')
      target.text(target.data('original-text'))
    , 5000)
  else
    $.ajax({
      method: 'delete',
      url: "/events/#{target.data('event-id')}",
      success: () =>
        window.location = '/events'
    })

cancelComment = (e) ->
  e.preventDefault()
  e.stopPropagation()
  $($(e.currentTarget).parents('form')).remove()

upvoteComment = (e) ->
  voteComment e, 'upvote'

downvoteComment = (e) ->
  voteComment e, 'downvote'

voteComment = (e, action) ->
  e.preventDefault()
  e.stopPropagation()
  commentId = $(e.currentTarget).data('comment-id')
  method = $(e.currentTarget).data('method')
  url = "/api/1/comments/#{commentId}/#{action}"
  xhr = new XMLHttpRequest()
  xhr.open(method, url, true)
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
  xhr.onload = (xhr_e) ->
    if this.status is 200
      success(xhr_e)
    else
      window.location = '/users/sign_in';
  xhr.send({})

replyComment = (e) ->
  e.preventDefault()
  parent_id = $(e.currentTarget).data('comment-id')
  container = $("div[data-comment-id='#{parent_id}'] > .row > .replybox-region")
  container.html($('#comment-new-template').html())
  $(container.find('input[name="parent_id"]')).val(parent_id)

comment = (e) ->
  e.preventDefault()
  form = $(e.currentTarget).parents('form')
  parent = $(form).find('input[name=parent_id]').val()
  if parent.length > 0
    url = "/api/1/comments/#{parent}/replies"
  else
    url = "/api/1/events/#{form.data('event-id')}/comments"

  formData = new FormData()
  formData.append('message', $(form).find('textarea[name=message]').val())

  xhr = new XMLHttpRequest()

  xhr.open(form.data('method'), url, true)
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

  xhr.onload = (xhr_e) ->
    return window.location = '/users/sign_in' if this.status is 401

    return success(xhr_e) if this.status is 200

    return reload(xhr_e)

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

success = (xhr_e)->
  return window.location.reload(false) if xhr_e is undefined
  json = JSON.parse(xhr_e.target.response)
  return window.location.reload(false) if json.response.id is undefined
  id = json.response.id['$oid']
  uri = window.location.toString().split('?')[0]
  window.location =  "#{uri}?r=#{rand()}#c_#{id}"

reload = (xhr_e) ->
  uri = window.location.toString().split('?')[0]
  window.location =  "#{uri}"

rand = ->
  Math.random().toString().slice(2,5)
