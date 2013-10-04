FK.App.module 'ImageTrimmer', (ImageTrimmer, App, Backbone, Marionette, $, _) ->
  
  class this.ImageChooseView extends Marionette.ItemView
    template: FK.Template('image_trimmer_choose')
    className: 'image-trimmer-input-container'

    events:
      'change input[type="file"]': 'startImageTrimmerFromUpload'

    startImageTrimmerFromUpload: (evt) =>
      file = evt.target.files[0]
      reader = new FileReader()

      reader.onload = (readFile) =>
        @controller.trigger 'new:image:url', readFile.target.result

      reader.readAsDataURL(file)

    initialize: (options) ->
      @controller = options.controller
      @listenTo @controller, 'new:image:size', @refreshHiddenImageSizeInputs
      @listenTo @controller, 'new:image:coords', @refreshHiddenImageCoordsInputs

    refreshHiddenImageSizeInputs: (size) =>
      @$('[name="width"]').val size.width
      @$('[name="height"]').val size.height

    refreshHiddenImageCoordsInputs: (coords) =>
      @$('[name="crop_x"]').val coords.left
      @$('[name="crop_y"]').val coords.top
