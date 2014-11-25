class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :comments]
  authorize_resource :only => [:destroy, :create]

  def index
    # Include reminders
    # Include comment count
    # Include image
    country = params[:country] || 'CA'
    subkasts = params[:subkasts] || Subkast.all.map(&:code)
    date = params[:date] || DateTime.now.beginning_of_day.to_s
    @repository = EventRepository.new(browser_timezone, country, subkasts)
    @time_zone = browser_timezone
    @events = @repository.events_from_date(date, 7)
    @subkasts = Subkast.by_user(current_user)
    @countries = Country.all.sort_by(&:en_name)
    @top_events = @repository.top_ranked_events(date, (DateTime.parse(date) + 7.days).to_s, 10)

    render :index
  end

  def on_date
    country = params[:country] || 'CA'
    subkasts = params[:subkasts] || Subkast.all.map(&:code)
    date = params[:date]
    skip = params[:skip].to_i

    repo = EventRepository.new(browser_timezone, country, subkasts)

    @time_zone = browser_timezone
    @events = repo.events_on_date(date, skip)

    render :list_events, layout: false
  end

  def show
    # Include reminders
    # Include event comments
    # Include event image
    @event = Event.find(params[:id])
  end

  def edit
  end

  def create
    @event = Event.new()
    params = event_params.dup
    have_i_upvoted = params.delete :have_i_upvoted

    #Picture cropping parameters need to be ready before the image is added to the model
    #because the paperclip processor will try to use them
    @event.width = event_params[:width]
    @event.height = event_params[:height]
    @event.crop_x = event_params[:crop_x]
    @event.crop_y = event_params[:crop_y]

    @event.update_attributes(params)

    if (! event_params[:image] && event_params[:url])
      @event.image_from_url(event_params[:url])
    end

    if ( user_signed_in? )
      if ( have_i_upvoted == "true" )
        @event.add_upvote(current_user.username)
      else
        @event.remove_upvote(current_user.username)
      end
    end

    if @event.is_all_day == "true" or @event.is_all_day == true
      @event.is_all_day = true
    else
      @event.is_all_day = false
    end

    respond_to do |format|
      if @event.save
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params = event_params.dup
    have_i_upvoted = params.delete :have_i_upvoted

    @event.width = event_params[:width]
    @event.height = event_params[:height]
    @event.crop_x = event_params[:crop_x]
    @event.crop_y = event_params[:crop_y]

    #this whole block of code should be in the model?
    if (! event_params[:image] && event_params[:url])
      @event.update_image_from_url(event_params[:url])
    elsif !@event.image.nil?
      @event.image.reprocess!
    end

    if ( user_signed_in? )
      if ( have_i_upvoted == "true" )
        @event.add_upvote(current_user.username)
      else
        @event.remove_upvote(current_user.username)
      end
    end

    if @event.user == current_user.username
      @event.update_attributes(params)
    end

    if @event.is_all_day == "true" or @event.is_all_day == true
      @event.is_all_day = true
    else
      @event.is_all_day = false
    end


    respond_to do |format|
      if @event.update(params)
        format.json { render action: 'show', status: :ok, location: @event }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def startup_events
  end

  def comments
    @comments = @event.root_comments
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.where(id: params[:id]).first
      if @event.blank?
        redirect_to "/#events/new"
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
