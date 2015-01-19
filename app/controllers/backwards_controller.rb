class BackwardsController < ApplicationController
  def by_date
    params[:datetime]
    params[:zone_offset]
    params[:country]
    params[:subkasts]
    params[:howManyEvents]
    params[:skip]

    params[:subkasts] = [params[:subkasts]] unless params[:subkasts].is_a?(Array)

    @events = EventRepository.events_on_date_by_offset(DateTime.parse(params[:datetime]), params[:zone_offset].to_i, params[:country], params[:subkasts], params[:howManyEvents].to_i, params[:skip].to_i)

    render 'events/events_by_date'
  end

  def comments
    event = Event.find(params[:id])

    @comments = event.root_comments

    render 'events/comments'
  end
end
