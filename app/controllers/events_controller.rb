class EventsController < ApplicationController
  authorize_resource :only => [:destroy, :create]

  def index
    # Include reminders
    # Include comment count
    # Include image

    url_subkast = [Subkast.by_slug(params[:subkast_slug]).code] if params[:subkast_slug]

    if params[:country] && current_user
      current_user.country = params[:country]
      current_user.save
    end

    if current_user
      @country = current_user.country
    else
      @country = params[:country] || 'CA'
    end

    @subkasts = params[:subkasts] || url_subkast || Subkast.by_user(current_user).map(&:code)
    date = params[:date] || DateTime.now.beginning_of_day.to_s
    @repository = EventRepository.new(browser_timezone, @country, @subkasts)
    @time_zone = browser_timezone
    @events = @repository.events_from_date(date, 5)
    @all_subkasts = Subkast.by_user(current_user)
    @all_countries = Country.all.sort_by(&:en_name)
    @top_events = @repository.top_ranked_events(date, (DateTime.parse(date) + 7.days).to_s, 10)

    render :index
  end

  def on_date
    country = params[:country]
    subkasts = params[:subkasts]
    date = params[:date]
    skip = params[:skip].to_i

    repo = EventRepository.new(browser_timezone, country, subkasts)

    @time_zone = browser_timezone
    @events = repo.events_on_date(date, skip)

    render :list_events, layout: false
  end

  def from_date
    country = params[:country]
    subkasts = params[:subkasts]
    date = params[:date]

    @repository = EventRepository.new(browser_timezone, country, subkasts)

    @time_zone = browser_timezone
    @events = @repository.events_from_date(date, 4)

    render :list_days, layout: false
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    authenticate_user!
  end

  def edit
    authenticate_user!
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def comments
    @comments = @event.root_comments
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.where(id: params[:id]).first
      if @event.blank?
        redirect_to "/events/new"
      end
    end

    def event_params
      params.permit(:details,
                    :user,
                    :datetime,
                    :name,
                    :image,
                    :url,
                    :width,
                    :height,
                    :crop_x,
                    :crop_y,
                    :is_all_day,
                    :time_format,
                    :tv_time,
                    :creation_timezone,
                    :local_time,
                    :local_date,
                    :description,
                    :have_i_upvoted,
                    :country,
                    :location_type,
                    :subkast
                   )
    end
end
