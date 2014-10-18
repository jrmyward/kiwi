class FK.EventStore extends Marionette.Controller
  initialize: (options) =>
    options.events = [] if options.events is null
    @events = new FK.Collections.EventList()
    @blocks = new FK.Collections.EventBlockList()
    @topRanked = new FK.Collections.TopRankedEventList()

    @config = new FK.EventStoreConfig

    @config.set('country', options.country) if options.country
    @config.set('subkasts', options.subkasts) if options.subkasts

    @howManyDaysInBlocks = 3

    @vent = options.vent

    @listenTo @events, 'sync', @resetTopRanked
    @listenTo @events, 'add', @addEventToBlock
    @listenTo @blocks, 'change:event_limit', @loadNextEventsForBlock

    @listenTo @config, 'change:country', @refresh
    @listenTo @config, 'change:subkasts', @refresh

    @events.add options.events

  fetchStartupEvents: () =>
    # completely fill the next 5 events/day * 7 days
    # 7 days because thats how many days ahead we calculate top ranked events for
    @events.fetchStartupEvents(@country(), @subkasts(), 10, 5, 35)

  loadNextEvents: (howManyMoreEvents) =>
    return if @blocks.length == 0
    date = @blocks.last().relativeDate().add('days', 1)
    @events.fetchMoreEventsAfterDate(date, @country(), @subkasts(), howManyMoreEvents)

  loadNextEventsForBlock: (block, newLimit) =>
    howManyMoreEvents = newLimit - block.events.length
    date = block.relativeDate()
    events = @events.eventsByDate(date, @country(), @subkasts(), howManyMoreEvents, block.events.models)

    _.each(events, @addEventToBlock)

    @events.fetchMoreEventsByDate(
      date,
      @country(),
      @subkasts(),
      howManyMoreEvents,
      block.events.length
    )

  resetTopRanked: () =>
    @topRanked.reset @events.topRanked(10, moment().startOf('day'), moment().add('days', 6).endOf('day'), @country(), @subkasts())

  addEventToBlock: (event) =>
    return if (event.get('country') isnt @country() and event.get('location_type') is 'national')
    return if (not _.contains(@subkasts(), event.get('subkast')))
    @blocks.addEventToBlock moment(event.get('fk_datetime').startOf('day')), @country(), @subkasts(), event, @events

  addNewEventToBlock: (event) =>
    @events.add(event, {merge: true})
    block = @blocks.getBlockForEvent(event)

    if block
      block.checkEventCount()

  filterByCountry: (country) =>
    @config.set('country', country)

  filterBySubkasts: (subkast) =>
    @config.setSubkast(subkast)

  refresh: () =>
    @events.reset()
    @topRanked.reset()
    @blocks.reset()
    @fetchStartupEvents()

  configModel: () =>
    @config

  getSingleSubkast: () =>
    @config.getSingleSubkast()

  country: () =>
    @config.get('country')

  subkasts: () =>
    @config.get('subkasts')

class FK.EventStoreConfig extends Backbone.Model
  defaults: () =>
    return {
      country: 'US'
      countryName: 'United States'
      subkasts: FK.Data.MySubkasts.codes()
    }

  getSingleSubkast: () =>
    return 'ALL' if @get('subkasts').length == FK.Data.MySubkasts.length
    if @get('subkasts').length == 1
      return @get('subkasts')[0]
    else
      return false

  setSubkast: (subkast) =>
    subkast = FK.Data.MySubkasts.codes() if subkast is 'ALL'
    subkast = [ subkast ] unless _.isArray(subkast)
    @set 'subkasts', subkast

  setCountry: (country) =>
    @set 'country', country
    @set 'countryName', App.request('countryName', country)
