FK.App.module 'Events.EventForm', (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.NotYourEventView extends Marionette.ItemView
    template: FK.Template('event_form_page/not_your_event')
