FK.Controllers.MainController = {
  notfound: () ->
    FK.App.vent.trigger('notfound')

  events: (action) ->
    FK.App.vent.trigger('container:all')

  show: (id) ->
    event = new FK.Models.Event
      _id: id
    event.fetch(
      error: () ->
        FK.App.vent.trigger('notfound')
    ).done =>
      FK.App.vent.trigger('container:show', event)

  edit: (id) ->
    event = new FK.Models.Event
      _id: id
    event.fetch(
      error: () ->
        FK.App.vent.trigger('notfound')
    ).done =>
      FK.App.vent.trigger('container:new', event)

   new: ->
     FK.App.vent.trigger('container:new')

  default: ->
    @events('all')

  subkast: (subkast) =>
    subkastCode = FK.Data.Subkasts.getCodeByUrl(subkast)
    if subkastCode
      FK.App.vent.trigger('container:all')
      FK.App.request('eventStore').filterBySubkasts(subkastCode)
    else
      FK.App.vent.trigger('notfound')
}

class FK.Routers.AppRouter extends Backbone.Marionette.AppRouter
  controller: FK.Controllers.MainController
  appRoutes: {
    'notfound':  'notfound'
    'events/show/:id':  'show'
    'events/edit/:id':  'edit'
    'events/new/': 'new'
    'events/:action': 'events'
    ':subkast': 'subkast'
    '': 'default'
    '_=_': 'default' #facebook callback route
  }

