class FK.ImageTrimmer.ImageTrimmerLayout extends Marionette.Layout
  template: FK.Template('event_form_page/image_trimmer_layout')
  className: 'image-trimmer'
  regions:
    'imageTrimmerRegion': '#image-trimmer-region'
    'imageChooseRegion': '#image-chooser-region'

  initialize: (options) ->
    @controller = options.controller
    @model = options.model

  modelEvents:
    'change:width': 'refreshImageWidthField'
    'change:height': 'refreshImageHeightField'
    'change:crop_x': 'refreshImageXField'
    'change:crop_y': 'refreshImageYField'

  refreshImageWidthField: (model) =>
    @$('input[name="image_width"]').val(model.widthValue())

  refreshImageHeightField: (model) =>
    @$('input[name="image_height"]').val(model.heightValue())

  refreshImageXField: (model) =>
    @$('input[name="image_x"]').val(model.cropXValue())

  refreshImageYField: (model) =>
    @$('input[name="image_y"]').val(model.cropYValue())

  onRender: () ->
    @imageChooseRegion.show new FK.ImageTrimmer.ImageChooseView
      controller: @controller
      model: @model
    @imageTrimmerRegion.show new FK.ImageTrimmer.ImageTrimmerView
      controller: @controller
      model: @model
