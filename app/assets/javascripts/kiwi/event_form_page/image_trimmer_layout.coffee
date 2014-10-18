FK.App.module "ImageTrimmer", (ImageTrimmer, App, Backbone, Marionette, $, _) ->

  class this.ImageTrimmerLayout extends Marionette.Layout
    template: FK.Template('event_form_page/image_trimmer_layout')
    className: 'image-trimmer'
    regions:
      'imageTrimmerRegion': '#image-trimmer-region'
      'imageChooseRegion': '#image-chooser-region'

    initialize: (options) ->
      @controller = options.controller
      @model = options.model

    onRender: () ->
      @imageChooseRegion.show new ImageTrimmer.ImageChooseView
        controller: @controller
        model: @model
      @imageTrimmerRegion.show new ImageTrimmer.ImageTrimmerView
        controller: @controller
        model: @model
