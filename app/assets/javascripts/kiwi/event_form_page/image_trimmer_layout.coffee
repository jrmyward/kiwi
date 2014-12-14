class FK.ImageTrimmer.ImageTrimmerLayout extends Marionette.Layout
  template: FK.Template('event_form_page/image_trimmer_layout')
  className: 'image-trimmer'
  regions:
    'imageTrimmerRegion': '#image-trimmer-region'
    'imageChooseRegion': '#image-chooser-region'

  initialize: (options) ->
    @controller = options.controller
    @model = options.model

  onRender: () ->
    @imageChooseRegion.show new FK.ImageTrimmer.ImageChooseView
      controller: @controller
      model: @model
    @imageTrimmerRegion.show new FK.ImageTrimmer.ImageTrimmerView
      controller: @controller
      model: @model
