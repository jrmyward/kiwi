describe 'Upvote Counter', ->
  beforeEach ->
    $('body').append $('<div id="testbed"></div>')

  afterEach ->
    $('#testbed').remove()

  describe 'rendering', ->

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

      it 'flags that it has been rendered', ->
        expect($('[data-rendered]').length).toBe(1)

    describe 'when the upvote has not already happened', ->
      beforeEach ->
        @component = new FK.UpvoteCounterComponent(upvote_count: 4, upvoted: false, event_id: 'aa11bb22')
        @component.renderIn('#testbed')

      it 'has a chevron', ->
        expect($('.glyphicon-chevron-up').length).toBe(1)

      it 'does not have a checkmark', ->
        expect($('.glyphicon-ok').length).toBe(0)

  describe 'clicking the upvote button', ->
    describe 'when the upvote has not already happened (chevron)', ->
      beforeEach ->
        @component = new FK.UpvoteCounterComponent(upvote_count: 4, upvoted: false, event_id: 'aa11bb22')
        @component.renderIn('#testbed')

        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []

        @xhr.onCreate = (xhr) =>
          @requests.push(xhr)

        $('.glyphicon-chevron-up').click()

      it 'increases the upvote count by 1', ->
        expect($('.upvote-counter').text()).toEqual('5')

      it 'has a checkmark', ->
        expect($('.glyphicon-ok').length).toBe(1)

      it 'does not have a chevron', ->
        expect($('.glyphicon-chevron-up').length).toBe(0)

      it 'sends a request to the server to register the upvote', ->
        expect(@requests.length).toBe(1)

      it 'posts the request', ->
        expect(@requests[0].method).toBe('POST')

      it 'sends to the api\'s upvote url for the provided event', ->
        expect(@requests[0].url).toBe('/api/1/events/aa11bb22/upvote')

    describe 'when the upvote has already happened (checkbox)', ->
      beforeEach ->
        @component = new FK.UpvoteCounterComponent(upvote_count: 4, upvoted: true, event_id: 'aa11bb22')
        @component.renderIn('#testbed')

        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []

        @xhr.onCreate = (xhr) =>
          @requests.push(xhr)

        $('.glyphicon-ok').click()

      it 'deecreases the upvote count by 1', ->
        expect($('.upvote-counter').text()).toEqual('3')

      it 'has a chevron', ->
        expect($('.glyphicon-chevron-up').length).toBe(1)

      it 'does not have a checkbox', ->
        expect($('.glyphicon-ok').length).toBe(0)

      it 'sends a request to the server to register the upvote', ->
        expect(@requests.length).toBe(1)

      it 'deletes the request', ->
        expect(@requests[0].method).toBe('DELETE')

      it 'sends to the api\'s upvote url for the provided event', ->
        expect(@requests[0].url).toBe('/api/1/events/aa11bb22/upvote')

    describe 'when the user is not logged in', ->
      beforeEach ->
        @component = new FK.UpvoteCounterComponent(upvote_count: 4, upvoted: false, event_id: 'aa11bb22', logged_in: false)
        @component.renderIn('#testbed')

        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []

        @xhr.onCreate = (xhr) =>
          @requests.push(xhr)

        $('.glyphicon-chevron-up').click()

      it 'does not change the upvote count', ->
        expect($('.upvote-counter').text()).toEqual('4')

      it 'does not change to a checbox', ->
        expect($('.glyphicon-ok').length).toEqual(0)

      it 'does not send any requests to the server', ->
        expect(@requests.length).toBe(0)
