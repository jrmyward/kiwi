$ ->
  $('[data-upvote-component]').each((i, container) ->

    upvote_count = $(container).data('upvote-count')
    upvoted = $(container).data('upvoted')
    event_id = $(container).data('event-id')

    component = new FK.UpvoteCounterComponent(upvote_count: upvote_count, upvoted: upvoted, event_id: event_id)

    component.renderIn('[data-upvote-component][data-event-id="' + event_id + '"]')
  )
