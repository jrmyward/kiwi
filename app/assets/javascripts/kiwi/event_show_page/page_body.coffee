FK.App.module "Events.EventPage", (EventPage, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer (event) ->
    @event = event
    @event.fetch(success: =>
      @eventCardView.render()
    )
    @loadSocialNetworking()
    if @event.get('location_type') is 'national'
      @event.set 'country_full_name', App.request('countryName', @event.get('country'))

    @view = new EventPage.EventPageLayout
    @eventCardView = new EventPage.EventCard
      model: @event

    @eventCardView.setUsername(App.request('currentUser').get('username'))
    @eventCardView.setModeratorMode(App.request('currentUser').get('moderator'))

    @listenTo @eventCardView, 'click:edit', @triggerEditEvent
    @listenTo @eventCardView, 'click:reminders', @showReminders
    @listenTo @event, 'destroy', @triggerEventList

    @eventCardView.on 'show', () =>
      @renderSocialNetworking()

    #TODO Find out WHY!?
    @view.onShow = () =>
      @view.eventCardRegion.show @eventCardView
      @commentsModule = App.Comments.create(event: @event, domLocation: "#event-comments-region")

    @view.onClose = () =>
      @stop()

    event.on 'change', (event) =>
      App.request('events').add event, merge: true

    Backbone.history.navigate('events/show/' + event.id, trigger : false)

    FK.App.chrome.main.show @view

  @triggerEditEvent = (args) ->
    event = args.model
    App.vent.trigger 'container:new', event

  @triggerEventList = () =>
    App.vent.trigger 'container:all'

  @showReminders = (args) =>
    @remindersComponent = FK.App.Reminders.create({event: args.model, container: args.view.ui.remindersContainer })

  @loadSocialNetworking = () ->
    @googleApi = $.Deferred()
    @facebookApi = $.Deferred()
    @twitterApi = $.Deferred()
    $.getScript('https://apis.google.com/js/plusone.js?onload=onLoadCallback',
      () =>
        @googleApi.resolve()
    )
    $.getScript('https://platform.twitter.com/widgets.js',
      () =>
        @twitterApi.resolve()
    )

  @renderSocialNetworking = () =>
    $.when(@googleApi, @twitterApi).then =>
      gapi.plusone.go()
      FB.XFBML.parse()
      twttr.widgets.load()

  @addFinalizer () ->
    @view.close()
    @stopListening()


  class EventPage.EventPageLayout extends Marionette.Layout
    template: FK.Template('event_show_page/page_body')
    className: 'event-page col-md-10'

    regions:
      eventCardRegion: '#event-card-region'
