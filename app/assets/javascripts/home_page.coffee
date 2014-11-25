renderUpvotes = (container) ->
  upvote_count = $(container).data('upvote-count')
  upvoted = $(container).data('upvoted')
  event_id = $(container).data('event-id')

  component = new FK.UpvoteCounterComponent(upvote_count: upvote_count, upvoted: upvoted, event_id: event_id)

  component.renderIn('[data-upvote-component][data-event-id="' + event_id + '"]')

$ ->
  $('[data-upvote-component]').each((i, container) ->
    renderUpvotes(container)
  )

  $('.more-form').on('ajax:success', (origin, resp) ->
    form = origin.target
    eventBlock = $(form).closest('.event-block').children('.events').first()
    eventBlock.append(resp)

    newCount = eventBlock.children().length

    $(form).remove() if (newCount >= $(form).attr('total'))


    $('[data-upvote-component]:not([data-rendered])').each((i, container) ->
      renderUpvotes(container)
    )
  )
