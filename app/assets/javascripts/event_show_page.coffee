$ ->
  $('#comment-new').html($('#comment-new-template').html())
  $('#event-comments-region').on('click', '[data-action="comment"]', comment)
  $('#event-comments-region').on('click', 'a.reply', replyComment)
  $('#event-comments-region').on('click','a.mute-delete', deletePrep)
  $('#event-comments-region').on('click','a.comment-upvote', upvoteComment)
  $('#event-comments-region').on('click','a.comment-downvote', downvoteComment)

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
  console.log url
  xhr = new XMLHttpRequest()
  xhr.open(method, url, true)
  xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
  xhr.onload = (xhr_e) =>
    success(xhr_e)
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

  xhr.onload = (xhr_e) =>
    success(xhr_e)
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

rand = ->
  Math.random().toString().slice(2,5)
