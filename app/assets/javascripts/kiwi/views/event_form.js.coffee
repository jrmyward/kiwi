FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  
  @startWithParent = false

  EventComponents = []

  @addInitializer (event) ->
    @listenTo EventForm, 'save', @saveEvent

    @event = event || new FK.Models.Event()
    @listenTo @event, 'saved', @toEvent
    @listenTo @event, 'change:originalUrl', @setImageUrl
    @listenTo @event, 'change:width', @setImageSize
    @listenTo @event, 'change:crop_x', @setImagePositionX
    @listenTo @event, 'change:crop_y', @setImagePositionY
    

    @view = new EventForm.FormLayout
      model: @event

    @view.on 'show', () =>
      @imageTrimmer = FK.App.ImageTrimmer.create '#image-region'
      @imageStartup @event
      EventComponents.push @imageTrimmer
      @datePicker = FK.App.DatePicker.create '#datetime-region', @event
      EventComponents.push @datePicker

    @view.on 'close', () =>
      @stop()

    FK.App.mainRegion.show @view
    EventComponents.push @view

  @saveEvent = () ->
    params =
      user: FK.CurrentUser.get('name')

    _.each EventComponents, (child) ->
      _.extend params, child.value()

    @event.save(params)
    FK.Data.events.add(@event, merge: true)

  @imageStartup = (event) =>
    if event.get('originalUrl')
      @setImageUrl event, event.get('originalUrl')
      @setImageSize event, event.get('width')
      @imageTrimmer.setPosition event.get('crop_x'), event.get('crop_y')

  @setImageUrl = (event, url) =>
    @imageTrimmer.newImage url, 'remote'

  @setImageSize = (event, width) =>
    @imageTrimmer.setWidth width

  @setImagePositionX = (event, x) =>
    @imageTrimmer.setPosition x, event.get('crop_y')

  @setImagePositionY = (event, y) =>
    @imageTrimmer.setPosition event.get('crop_x'), y

  @toEvent = (event) ->
    App.vent.trigger 'container:show', event

  @addFinalizer () =>
    _.each EventComponents, (child) ->
      child.close()

    EventComponents = []
    @stopListening()

  class EventForm.FormLayout extends Backbone.Marionette.Layout
    className: "row-fluid"
    template: FK.Template('event_form')

    events:
      'click .save': 'saveClicked'
      'change input[name=name]': 'validateName'
      'change input[name=location_type]': 'renderLocation'

    validateName: (e) =>
      @$el.find(".error").remove()
      if $(e.target).val().length > 79
        $("<div class=\"error\">Event is too long</div>").insertAfter(e.target)
    
    renderLocation: (e) =>
      if @$el.find('input[name=location_type]:checked').val() is "international"
        @$el.find('select[name=country]').attr('disabled','disabled')
      else
        @$el.find('select[name=country]').removeAttr('disabled')
        

    saveClicked: (e) =>
      e.preventDefault()
      @$('.save').addClass 'disabled'
      @$('.save').html 'Saving...'
      EventForm.trigger('save')
      
    modelEvents:
      'change:name': 'refreshName'
      'change:location': 'refreshLocation'
      'change:country': 'refreshLocation'
    
    refreshName: (event) ->
      @$('#name').val event.get('name')
      
    refreshLocation: (event) ->
      @$('[name="location_type"][value="' + event.get('location_type') + '"]').attr('checked', 'checked')
      @$('[name="country"] [value="' + event.get('country') + '"]').attr('selected', 'selected')

    value: () ->
      window.serializeForm(@$el.find('input,select,textarea'))

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @refreshName @model
      @refreshLocation @model
      @$('.current_user').text(FK.CurrentUser.get('name'))
      @renderLocation()
