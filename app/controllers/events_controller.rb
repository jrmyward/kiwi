class EventsController < ApplicationController
  authorize_resource :only => [:destroy, :create]
  before_action :get_time_zone, only: [:index, :new, :edit, :show]

  def index
    url_subkast = [Subkast.by_slug(params[:subkast_slug]).code] if params[:subkast_slug]

    @time_zone = client_timezone

    if params[:country] && current_user
      current_user.country = params[:country]
      current_user.save
    end

    if current_user
      @country = current_user.country || 'US'
    else
      @country = params[:country] || 'US'
    end

    @subkast = Subkast.by_slug(params[:subkast_slug])

    @subkasts = params[:subkasts] || url_subkast || Subkast.by_user(current_user).map(&:code)
    @datetime = ActiveSupport::TimeZone.new(@time_zone).utc_to_local(DateTime.now.utc)
    date = params[:date] || @datetime.beginning_of_day.to_s
    @repository = EventRepository.new(client_timezone, @country, @subkasts)
    @events = @repository.events_from_date(date, 7, 5)
    @all_subkasts = Subkast.by_user(current_user)
    @all_countries = Country.all.sort_by(&:en_name)
    @top_events = @repository.top_ranked_events(date, (DateTime.parse(date) + 7.days).to_s, 10)
    @recent_events = @repository.most_recent_events(50)

    render :index
  end

  def on_date
    country = params[:country]
    subkasts = params[:subkasts]
    date = params[:date]
    skip = params[:skip].to_i

    repo = EventRepository.new(client_timezone, country, subkasts)

    @time_zone = client_timezone
    @events = repo.events_on_date(date, skip)

    render :list_events, layout: false
  end

  def from_date
    @country = params[:country]
    @subkasts = params[:subkasts]
    date = params[:date]

    @repository = EventRepository.new(client_timezone, @country, @subkasts)

    @time_zone = client_timezone
    @events = @repository.events_from_date(date, 5, 5)

    render :list_days, layout: false
  end

  def show
    @event = Event.find(params[:id])
    @timezone = client_timezone

    # temporary for app backwards compatability

    respond_to do |format|
      # keep format.html first so facebook doesn't have a crawling problem when it's liked
      format.html
      format.json
    end
  end

  def new
    authenticate_user!

    @event = Event.new
    @event.country = current_user.last_posted_country || current_user.country || 'US'
  end

  def edit
    authenticate_user!

    @event = Event.find(params[:id])
  end

  def destroy
    event = Event.find(params[:id])
    event.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def get_time_zone
    return unless request.format == 'html'
    return if browser_timezone.present?
    redirect_to "/welcome?continue=#{request.path}"
  end

  def client_timezone
    browser_timezone || "America/New_York"
  end
end
