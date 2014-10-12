FK.App.module "Chrome", (Chrome, App, Backbone, Marionette, $, _) ->
  
  @startWithParent = false
  
  @addInitializer () ->
    FK.App.chrome = new Chrome.Layout()
    FK.App.chrome.render()
    FK.App.chrome.footer.show(new Chrome.Footer())

  class Chrome.Layout extends Backbone.Marionette.Layout
    template: FK.Template('chrome/layout')
    el: '#chrome-container'
    regions:
      'navbar': '#navbar-region'
      'main': '#main-region'
      'footer': '#footer'
  
  class Chrome.Footer extends Marionette.ItemView
    className: 'footer-text'
    template: FK.Template('chrome/footer')
