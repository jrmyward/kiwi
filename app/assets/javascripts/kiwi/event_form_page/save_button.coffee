FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.SaveButton extends Marionette.ItemView
    tagName: 'button'
    className: 'btn btn-focus'
    template: FK.Template('event_form_page/save_button')
    triggers:
      'click': 'save'
