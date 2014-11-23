#= require application

describe 'Upvote', ->
  beforeEach ->
    $('body').append $('<div id="testbed"></div>')
    @component = new FK.UpvoteCounterComponent(4, true, 'aa11bb22')

  afterEach ->
    $('#testbed').remove()

  it 'renders in place', () ->
    @component.render_in('#testbed')
