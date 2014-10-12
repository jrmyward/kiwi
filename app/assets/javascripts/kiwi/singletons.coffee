FK.App.reqres.setHandler 'events', () ->
  FK.Data.EventStore.events

FK.App.reqres.setHandler 'eventStore', () ->
  FK.Data.EventStore

FK.App.reqres.setHandler 'eventConfig', () ->
  FK.Data.EventStore.configModel()

FK.App.reqres.setHandler 'currentUser', () ->
  FK.CurrentUser

FK.App.reqres.setHandler 'currentSubkast', () ->
  Fk.Data.EventStore.getSingleSubkast()

FK.App.reqres.setHandler 'subkasts', () ->
  FK.Data.Subkasts

FK.App.reqres.setHandler 'mySubkasts', () ->
  FK.Data.MySubkasts

FK.App.reqres.setHandler 'countryName', (countryCode) ->
  FK.Data.countries.get(countryCode).get('en_name').trim()

FK.App.reqres.setHandler 'easternOffset', () ->
  moment().tz('America/New_York').zone()

FK.App.reqres.setHandler 'scrollPosition', () ->
  FK.App.scrollPosition

FK.App.reqres.setHandler 'isModerator', () ->
  return FK.CurrentUser.get('moderator')

FK.App.commands.setHandler 'signInPage', () ->
  window.location.href = '/users/sign_in'

FK.App.commands.setHandler 'saveScrollPosition', (position) ->
  FK.App.scrollPosition = position

FK.App.module "Events", (Events, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    FK.App.Chrome.start()

    @listenTo App.vent, 'container:new', @startForm
    @listenTo App.vent, 'container:show', @startPage
    @listenTo App.vent, 'container:all', @startList
    @listenTo App.vent, 'notfound', @startNotFound
    

  @addFinalizer () ->
    @stopListening()

  @eventsListStartupData = () =>
    {
      eventStore: App.request('eventStore')
      subkasts: App.request('subkasts')
      mySubkasts: App.request('mySubkasts')
      config: App.request('eventConfig')
      topRanked: App.request('eventStore').topRanked
    }

  @startNotFound = () ->
    Events.stop()
    Events.start()
    Events.NotFound.start()

  @startForm = (event) ->
    Events.stop()
    Events.start()
    Events.EventForm.start(event)

  @startPage = (event) ->
    Events.stop()
    Events.start()
    Events.EventPage.start(event)

  @startList = () ->
    Events.stop()
    Events.start()
    Events.EventList.start(@eventsListStartupData())
