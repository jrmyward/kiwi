FK.App = new Backbone.Marionette.Application()
FK.App.addRegions({
  'chrome' : '#chrome-container'
})

FK.App.addInitializer (prefetch) ->
  FK.Links = prefetch.links

  FK.CurrentUser = new FK.Models.User(prefetch.user)
  FK.CurrentUser.set(logged_in: true, silent: true) if prefetch.user != null

  
  FK.CurrentUser.set('country', 'US') unless FK.CurrentUser.has('country')

  FK.Data.Subkasts = new FK.Collections.SubkastList(prefetch.subkasts)
  FK.Data.MySubkasts = new FK.Collections.SubkastList(prefetch.mySubkasts)

  FK.Data.EventStore = new FK.EventStore
    events: prefetch.events,
    howManyStartingBlocks: 10,
    vent: FK.App.vent
    country: FK.CurrentUser.get('country')

  FK.Data.countries = new FK.Collections.CountryList(prefetch.countries)

  FK.Data.EventStore.fetchStartupEvents()

  FK.App.appRouter = new FK.Routers.AppRouter()
