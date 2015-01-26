fetching = false

renderUpvotes = () ->
  $('[data-upvote-component]:not([data-rendered])').each((i, container) ->
    upvote_count = $(container).data('upvote-count')
    upvoted = $(container).data('upvoted')
    event_id = $(container).data('event-id')
    logged_in = $(container).data('logged-in')

    component = new FK.UpvoteCounterComponent(upvote_count: upvote_count, upvoted: upvoted, event_id: event_id, logged_in: logged_in)

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

fetchMore = _.throttle(() ->
  return if fetching
  fetching = true
  $.get('/events/from_date', {
    country: $('#home-list').data('country'),
    subkasts: $('#home-list').data('subkasts'),
    date: $('[data-tomorrow]').last().data('tomorrow')
  }, (resp) ->
    $('#home-list').append(resp)
    renderUpvotes()
    renderReminders()
    fetching = false
  )
, 700)

$ ->
  renderUpvotes()
  renderReminders()

  $('.more-form').on('ajax:success', (origin, resp) ->
    form = origin.target

    eventBlock = $(form).closest('.event-block').children('.events').first()
    eventBlock.append(resp)

    newCount = eventBlock.children().length

    $(form).remove() if (newCount >= $(form).attr('total'))
    $(form).find('input[name=skip]').val(newCount)


    renderUpvotes()
    renderReminders()
  )

  $(document).scroll( (e) ->
    $doc = $(e.target)
    $window = $(window)

    percentage = $doc.scrollTop() / ($doc.height() - $window.height())

    fetchMore() if percentage > 0.7
  )

  $('select[name="country"]').on('change', (e) =>
    country = $(e.target).val()

    noCountryLocation = window.location.href.substring(0, window.location.href.indexOf('?'))

    window.location.href = "#{noCountryLocation}?country=#{country}"
  )
