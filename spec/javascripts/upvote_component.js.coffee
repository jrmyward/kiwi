describe 'Upvote Counter', ->
  describe 'rendering', ->
    beforeEach ->
      $('body').append $('<div id="testbed"></div>')

    afterEach ->
      $('#testbed').remove()

    describe 'when the upvote has already happened', ->
      beforeEach ->
        @component = new FK.UpvoteCounterComponent(upvote_count: 4, upvoted: true, event_id: 'aa11bb22')
        @component.renderIn('#testbed')

      it 'renders in place', ->
        expect($('.upvote-counter').length).toBe(1)

      it 'shows the upvote count', ->
        expect($('.upvote-counter').text()).toEqual('4')

      it 'has a checkmark', ->
        expect($('.glyphicon-ok').length).toBe(1)

      it 'does not have a chevron', ->
        expect($('.glyphicon-chevron-up').length).toBe(0)

    describe 'when the upvote has not already happened', ->
      beforeEach ->
        @component = new FK.UpvoteCounterComponent(upvote_count: 4, upvoted: false, event_id: 'aa11bb22')
        @component.renderIn('#testbed')

      it 'has a chevron', ->
        expect($('.glyphicon-chevron-up').length).toBe(1)

      it 'does not have a checkmark', ->
        expect($('.glyphicon-ok').length).toBe(0)
