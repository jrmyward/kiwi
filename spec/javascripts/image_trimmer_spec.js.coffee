describe 'Image Trimmer', () ->

  beforeEach () ->
    FK.App.ImageTrimmer.start()
    @imageTrimmer = FK.App.ImageTrimmer.create()
    $('body').append @imageTrimmer.View.render().el

  afterEach () ->
    FK.App.ImageTrimmer.stop()

  it 'should be able to close the image dialog on click of the X button', () ->
    $('.close-box').click()
    expect($('.image-trimmer-dialog').length).toBe(0)

  it 'should be able to close the image dialog on click of the cancel button', () ->
    $('.close-box').click()
    expect($('.image-trimmer-dialog').length).toBe(0)