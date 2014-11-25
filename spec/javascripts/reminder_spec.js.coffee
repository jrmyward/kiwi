describe "Reminder", ->
  beforeEach ->
    $('body').append $('<div id="testbed"></div>')

  afterEach ->
    $('#testbed').remove()

  describe 'rendering', ->
    beforeEach ->
      @component = new FK.RemindersDropdownController(times_to_event: [], event_id: 'aa11bb22')
      @component.renderIn('#testbed')

    it 'renders in place', ->
      expect($('.reminder-component').length).toBe(1)

    it 'flags that it has been rendered', ->
      expect($('[data-rendered]').length).toBe(1)

    describe 'clicking on the bell', ->
      beforeEach ->
        $('.glyphicon-bell').click()

      it 'opens the popover', ->
        expect($('.event-reminders-super-container').length).toBe(1)

      it 'renders with the 1h reminder selected by default', ->
        expect($('[data-time="1h"]').is(':checked')).toBe(true)

      describe 'then clicking cancel', ->
        beforeEach ->
          $('[data-time="4h"]').click()
          $('[data-action="cancel"]').click()

          @xhr = sinon.useFakeXMLHttpRequest()
          @requests = []

          @xhr.onCreate = (xhr) =>
            @requests.push(xhr)

        it 'closes the popover', ->
          expect($('.event-reminders-super-container').length).toBe(0)

        it 'does not send any server requests', ->
          expect(@requests.length).toBe(0)

        it 'does not change when the popover opens again', ->
          $('.glyphicon-bell').click()
          expect($('[data-time="15m"]').is(':checked')).toBe(false)
          expect($('[data-time="1h"]').is(':checked')).toBe(true)
          expect($('[data-time="4h"]').is(':checked')).toBe(false)
          expect($('[data-time="1d"]').is(':checked')).toBe(false)

    describe 'with provided reminders', ->
      beforeEach ->
        @component = new FK.RemindersDropdownController(times_to_event: ['15m', '1h'], event_id: 'aa11bb22')
        @component.renderIn('#testbed')

      it 'has a higlight', ->
        expect($('.glyphicon-bell.highlight').length).toBe(1)

      it 'renders with each provided reminder checked', ->
        $('.glyphicon-bell').click()
        expect($('[data-time="15m"]').is(':checked')).toBe(true)
        expect($('[data-time="1h"]').is(':checked')).toBe(true)

  describe 'selecting reminder and clicking "set reminders"', ->
    beforeEach ->
      @component = new FK.RemindersDropdownController(times_to_event: ['15m', '1h'], event_id: 'aa11bb22')
      @component.renderIn('#testbed')
      $('.glyphicon-bell').click()

      @xhr = sinon.useFakeXMLHttpRequest()
      @requests = []

      @xhr.onCreate = (xhr) =>
        @requests.push(xhr)

    describe 'with no existing reminders', ->
      beforeEach ->
        @component = new FK.RemindersDropdownController(times_to_event: [], event_id: 'aa11bb22')
        @component.renderIn('#testbed')
        $('.glyphicon-bell').click()

        $('[data-time="4h"]').click()
        $('[data-time="1d"]').click()

        $('[data-action="set-reminder"]').click()

      it 'highlights the bell', ->
        expect($('.glyphicon-bell.highlight').length).toBe(1)

    describe 'adding two more reminders', ->
      beforeEach ->
        $('[data-time="4h"]').click()
        $('[data-time="1d"]').click()

        $('[data-action="set-reminder"]').click()

      describe 'server bound requests', ->

        it 'sends two', ->
          expect(@requests.length).toBe(2)

        it 'sends POST requests', ->
          expect(@requests[0].method).toBe('POST')
          expect(@requests[1].method).toBe('POST')

        it 'sends the intervals in the request body', ->
          expect(@requests[0].requestBody).toBe('interval=4h')
          expect(@requests[1].requestBody).toBe('interval=1d')

      it 'closes the reminder popover', ->
        expect($('.event-reminders-super-container').length).toBe(0)

      it 'still has the added reminders when the popover opens again', ->
        $('.glyphicon-bell').click()
        expect($('[data-time="15m"]').is(':checked')).toBe(true)
        expect($('[data-time="1h"]').is(':checked')).toBe(true)
        expect($('[data-time="4h"]').is(':checked')).toBe(true)
        expect($('[data-time="1d"]').is(':checked')).toBe(true)

    describe 'removing two reminders', ->
      beforeEach ->
        $('[data-time="15m"]').click()
        $('[data-time="1h"]').click()

        $('[data-action="set-reminder"]').click()

      describe 'server bound requests', ->

        it 'sends two', ->
          expect(@requests.length).toBe(2)

        it 'sends DELETE requests', ->
          expect(@requests[0].method).toBe('DELETE')
          expect(@requests[1].method).toBe('DELETE')

        it 'sends the inerval as the id in the url', ->
          expect(@requests[0].url).toBe("/api/1/events/aa11bb22/reminders/15m")
          expect(@requests[1].url).toBe("/api/1/events/aa11bb22/reminders/1h")

      it 'sends two reminder requests to the server', ->
        expect(@requests.length).toBe(2)

      it 'closes the reminder popover', ->
        expect($('.event-reminders-super-container').length).toBe(0)

      it 'only has the 1h reminder left because that is the default for no reminders', ->
        $('.glyphicon-bell').click()
        expect($('[data-time="1h"]').is(':checked')).toBe(true)

      it 'removes the highlight', ->
        expect($('.glyphicon-bell.highlight').length).toBe(0)
