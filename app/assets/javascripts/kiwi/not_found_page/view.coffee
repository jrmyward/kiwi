FK.App.module "Events.NotFound", (NotFound, App, Backbone, Marionette, $, _) ->

  @startWithParent = false

  @addInitializer () ->
    @view = new NotFoundView()
    @view.onClose = () =>
      @stop()
      $("body").removeClass('not-found')

    @.on 'start', () =>
      FK.App.chrome.main.show @view
      $("body").addClass('not-found')

  @addFinalizer () ->
    @view.close()
    @stopListening()

  class NotFoundView extends Marionette.ItemView
    template: FK.Template('not_found_page/view')
    className: 'container'
