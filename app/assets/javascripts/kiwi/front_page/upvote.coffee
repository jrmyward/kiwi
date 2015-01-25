class FK.UpvoteCounterComponent extends Marionette.Controller
  initialize: (opts) =>
    model = _.omit(opts, 'inline')
    @model = new FK.UpvoteCounter(model)

    viewOpts = _.pick(opts, 'inline')
    viewOpts = _.extend(viewOpts, { model: @model })

    @view = new FK.UpvoteCounterView(viewOpts)
    @regions = new Marionette.RegionManager()

    @view.on 'hide', () =>
      @regions.close()

  renderIn: (selector) =>
    $(selector).attr('data-rendered', 'true')
    @regions.addRegion('spot', selector)
    @regions.get('spot').show(@view)


class FK.UpvoteCounterView extends Marionette.ItemView
  template: FK.Template('components/upvote')
  className: 'upvote-counter black'

  getTemplate: () =>
    if (@inline)
      return FK.Template('components/inline_upvote')
    else
      return FK.Template('components/upvote')

  events:
    'click .glyphicon-chevron-up': 'upvote'
    'click .glyphicon-ok': 'downvote'

  modelEvents:
    'change:upvote_count': 'render'
    'change:upvoted': 'render'

  initialize: (opts) =>
    @inline = opts.inline

  upvote: =>
    @model.upvote()

  downvote: =>
    @model.downvote()

  tooltip: () =>
    return if @model.get('logged_in')
    @$el.tooltip(title: 'Login to upvote.')

  onShow: () =>
    @tooltip()

class FK.UpvoteCounter extends Backbone.Model
  defaults: () =>
    {
      upvoted: false,
      upvote_count: 0,
      event_id: null,
      logged_in: true
    }

  upvote: () =>
    return unless @get('logged_in')
    @set('upvote_count', @get('upvote_count') + 1)
    @set('upvoted', true)
    $.post("/api/1/events/#{@get('event_id')}/upvote")

  downvote: () =>
    @set('upvote_count', @get('upvote_count') - 1)
    @set('upvoted', false)
    $.ajax(url: "/api/1/events/#{@get('event_id')}/upvote", method: 'DELETE')
