describe 'Date Picker', ->
  describe 'time display', ->
    beforeEach ->
      @model = new FK.DatePicker.DateTimeModel

    it 'provides the given time string when the format is none (relative)', ->
      @model.set('hour', '3')
      @model.set('minute', '30')
      @model.set('ampm', 'PM')
      @model.set('format', '')

      expect(@model.timeDisplay()).toEqual('3:30 PM')

    it 'provides the given time string when the format is recurring', ->
      @model.set('hour', '3')
      @model.set('minute', '30')
      @model.set('ampm', 'PM')
      @model.set('format', 'recurring')

      expect(@model.timeDisplay()).toEqual('3:30 PM')

    describe 'tv time', ->
      it 'provides an eastern and central time', ->
        @model.set('hour', '7')
        @model.set('minute', '30')
        @model.set('ampm', 'PM')
        @model.set('format', 'tv_show')

        expect(@model.timeDisplay()).toEqual('7:30/6:30c')

      it 'provides the correct central time when the eastern time is 1:30', ->
        @model.set('hour', '1')
        @model.set('minute', '30')
        @model.set('ampm', 'PM')
        @model.set('format', 'tv_show')

        expect(@model.timeDisplay()).toEqual('1:30/12:30c')

      it 'provides an eastern and central time even going back a day (weird, right?)', ->
        @model.set('hour', '12')
        @model.set('minute', '30')
        @model.set('ampm', 'AM')
        @model.set('format', 'tv_show')

        expect(@model.timeDisplay()).toEqual('12:30/11:30c')

      it 'pads zeroes in its response', ->
        @model.set('hour', '1')
        @model.set('minute', '5')
        @model.set('ampm', 'PM')
        @model.set('format', 'tv_show')

        expect(@model.timeDisplay()).toEqual('1:05/12:05c')
