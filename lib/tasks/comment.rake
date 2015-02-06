namespace :comment do
  task :rebalance => :environment do |t, args|
    event = Event.find(ENV['id'])
    event.rebalance_comments
  end

  task :rebalance_all => :environment do |t, args|
    Event.all.each do |e|
      e.rebalance_comments
    end
  end
end
