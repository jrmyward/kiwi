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
      expect($('.event-reminders-super-container').length).toBe(1)

    it 'flags that it has been rendered', ->
      expect($('[data-rendered]').length).toBe(1)

    it 'renders with the 1h reminder selected by default', ->
      expect($('[data-time="1h"]').is(':checked')).toBe(true)

    describe 'with provided reminders', ->
      beforeEach ->
        @component = new FK.RemindersDropdownController(times_to_event: ['15m', '1h'], event_id: 'aa11bb22')
        @component.renderIn('#testbed')

      it 'renders with each provided reminder checked', ->
        expect($('[data-time="15m"]').is(':checked')).toBe(true)
        expect($('[data-time="1h"]').is(':checked')).toBe(true)
