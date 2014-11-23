class FK.UpvoteCounterComponent extends Marionette.Controller
  initialize: (opts) =>
    @model = new FK.UpvoteCounter(opts)
    @view = new FK.UpvoteCounterView(model: @model)
    @regions = new Marionette.RegionManager()

  renderIn: (selector) =>
    @regions.addRegion('spot', selector)
    @regions.get('spot').show(@view)


class FK.UpvoteCounterView extends Marionette.ItemView
  template: FK.Template('components/upvote')


class FK.UpvoteCounter extends Backbone.Model
  defaults: () =>
    {
      upvoted: false,
      upvote_count: 0,
      event_id: null
    }
