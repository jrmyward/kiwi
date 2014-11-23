describe 'Upvote', ->
  beforeEach ->
    $('body').append $('<div id="testbed"></div>')
    @event = new FK.Models.Event()
    @component = new FK.UpvoteCounterComponent(4, true, @event)

  it 'renders in place', () ->
    @component.render_in('#testbed')
