#= require application

# Force all test cases to use Jan 16 at 2:20 pm as the current date time
sinon.useFakeTimers(1389891600000, "Date")

# EVENTS

SpecHelpers =
  Events:
    SimpleEvents: [
      #new FK.Models.Event { _id: 1, upvotes: 2, datetime: moment(), country: 'CA', subkast: 'ST'}
      #new FK.Models.Event { _id: 2, upvotes: 5, datetime: moment().add('minutes', 3), country: 'CA', subkast: 'ST' }
      #new FK.Models.Event { _id: 3, upvotes: 3, datetime: moment().add('minutes', 7), country: 'CA', subkast: 'ST' }
      #new FK.Models.Event { _id: 4, upvotes: 1, datetime: moment().add('days', 3), country: 'CA', subkast: 'ST' }
    ]
    TodayEvents: [
      #new FK.Models.Event { _id: 1, datetime: moment().add('seconds', 2) }
      #new FK.Models.Event { _id: 2, datetime: moment().add('minutes', 3) }
      #new FK.Models.Event { _id: 3, datetime: moment().add('minutes', 7) }
      #new FK.Models.Event { _id: 4, datetime: moment().add('hours', 3) }
    ]
    BlockEvents: [
      { _id: 1, upvotes: 2, datetime: moment(), country: 'CA', subkast: 'OTH' }
      { _id: 2, upvotes: 5, datetime: moment().add('minutes', 3), country: 'CA', subkast: 'OTH' }
      { _id: 3, upvotes: 3, datetime: moment().add('minutes', 7), country: 'CA', subkast: 'OTH' }
      { _id: 4, upvotes: 3, datetime: moment().add('minutes', 20), country: 'CA', subkast: 'OTH' }
      { _id: 5, upvotes: 6, datetime: moment().add('hours', 2), country: 'CA', subkast: 'OTH'  }
      { _id: 6, upvotes: 3, datetime: moment().add('hours', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 7, upvotes: 5, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 8, upvotes: 9, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 9, upvotes: 2, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 10, upvotes: 10, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 11, upvotes: 3, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 12, upvotes: 8, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
      { _id: 13, upvotes: 9, datetime: moment().add('days', 3), country: 'CA', subkast: 'OTH'  }
    ]
    PastTodayEvents: [
      { name: 'event 1', datetime: moment().subtract('hours', 4) }
      { name: 'event 2', datetime: moment().subtract('minutes', 20) }
      { name: 'event 3', datetime: moment().add('days', 2) }
    ]
    UpvotedEvents: [
        { name: 'event 1', upvotes: 9, datetime: moment().subtract('days', 1), country: 'CA', subkast: 'ST'  }
        { name: 'event 2', upvotes: 8, datetime: moment().subtract('days', 1), country: 'CA', subkast: 'ST' }
        { name: 'event 2a', upvotes: 8, datetime: moment().subtract('hours', 1), country: 'CA', subkast: 'ST' }
        { name: 'event 3', upvotes: 7, datetime: moment().add('days', 1), country: 'CA', subkast: 'ST' }
        { name: 'event 4', upvotes: 9, datetime: moment(), country: 'CA', subkast: 'ST', subkast: 'ST' }
        { name: 'event 5', upvotes: 11, datetime: moment().add('days', 1), country: 'CA', subkast: 'ST' }
        { name: 'event 6', upvotes: 11, datetime: moment().add('days', 4), country: 'CA', subkast: 'ST' }
        { name: 'event 7', upvotes: 12, datetime: moment().add('days', 10), country: 'CA', subkast: 'ST' }
        { name: 'event 8', upvotes: 4, datetime: moment().add('days', 2), country: 'CA', subkast: 'ST' }
        { name: 'event 9', upvotes: 3, datetime: moment().add('days', 3), country: 'CA', subkast: 'ST' }
        { name: 'event 10', upvotes: 2, datetime: moment().add('days', 7), country: 'CA', subkast: 'ST' }
        { name: 'event 11', upvotes: 5, datetime: moment().add('days', 1), country: 'CA', subkast: 'ST' }
        { name: 'event 12', upvotes: 3, datetime: moment().add('days', 5), country: 'CA', subkast: 'ST' }
        { name: 'event 13', upvotes: 2, datetime: moment().add('days', 4), country: 'CA', subkast: 'ST' }
        { name: 'event 14', upvotes: 2, datetime: moment().add('days', 2), country: 'CA', subkast: 'ST' }
        { name: 'event 15', upvotes: 5, datetime: moment().add('days', 3), country: 'CA', subkast: 'ST' }
    ],
    UpvotedEventsWithCountries: [
        { name: 'event 1', upvotes: 9, datetime: moment().subtract('days', 1), country: 'CA', location_type: 'national', subkast: 'TVM'}
        { name: 'event 2', upvotes: 8, datetime: moment().subtract('days', 1), country: 'CA', location_type: 'national', subkast: 'HA'}
        { name: 'event 2a', upvotes: 8, datetime: moment().subtract('hours', 1), country: 'US', location_type: 'national', subkast: 'TVM'}
        { name: 'event 3', upvotes: 7, datetime: moment().add('days', 1), country: 'US', location_type: 'national', subkast: 'ST'}
        { name: 'event 4', upvotes: 9, datetime: moment(), country: 'US', location_type: 'national', subkast: 'ST' }
        { name: 'event 5', upvotes: 11, datetime: moment().add('days', 1), country: 'CA', location_type: 'national', subkast: 'PRP' }
        { name: 'event 6', upvotes: 11, datetime: moment().add('days', 4), country: 'US', location_type: 'national', subkast: 'HA' }
        { name: 'event 7', upvotes: 12, datetime: moment().add('days', 10), country: 'CA', location_type: 'national', subkast: 'HA' }
        { name: 'event 8', upvotes: 4, datetime: moment().add('days', 2), country: 'CA', location_type: 'national', subkast: 'OTH' }
        { name: 'event 9', upvotes: 3, datetime: moment().add('days', 3), country: 'US', location_type: 'national', subkast: 'PRP' }
        { name: 'event 10', upvotes: 2, datetime: moment().add('days', 7), country: 'CA', location_type: 'national', subkast: 'ST' }
        { name: 'event 11', upvotes: 5, datetime: moment().add('days', 1), location_type: 'international', subkast: 'ST' }
        { name: 'event 12', upvotes: 3, datetime: moment().add('days', 5), country: 'AM', location_type: 'national', subkast: 'TVM' }
        { name: 'event 13', upvotes: 2, datetime: moment().add('days', 4), country: 'CA', location_type: 'national', subkast: 'ST' }
        { name: 'event 14', upvotes: 2, datetime: moment().add('days', 2), country: 'CA', location_type: 'national', subkast: 'PRP' }
        { name: 'event 15', upvotes: 5, datetime: moment().add('days', 3), country: 'CA', location_type: 'national', subkast: 'TVM' }
    ]
    FilterableEvents: [
      { name: 'event 1', country: 'CA', subkast: 'ST', datetime: moment(), location_type: 'national' }
      { name: 'event 2', country: 'US', subkast: 'ST', datetime: moment(), location_type: 'international' }
      { name: 'event 3', country: 'US', subkast: 'SE', datetime: moment(), location_type: 'national' }
      { name: 'event 4', country: 'CA', subkast: 'SE', datetime: moment(), location_type: 'national' }
    ]

# SUBKASTS
  Subkasts:
    SimpleSubkasts: [
      { name: 'Production Releases / Promotions', code: 'PRP', url: 'productionreleasespromotions' }
      { name: 'Science and Technology', code: 'ST', url: 'scienceandtechnology' }
      { name: 'Holidays and Anniversaries', code: 'HA', url: 'holidaysandanniversaries' }
      { name: 'TV and Movies', code: 'TVM', url: 'tvandmovies' }
      { name: 'Other', code: 'OTH', url: 'other' }
    ]




# STARTUP

#FK.Data.Subkasts = new FK.Collections.SubkastList(FK.SpecHelpers.Subkasts.SimpleSubkasts)
#FK.Data.MySubkasts = new FK.Collections.SubkastList(FK.SpecHelpers.Subkasts.SimpleSubkasts)
