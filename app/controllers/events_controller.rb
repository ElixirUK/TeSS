require 'redis'

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :update_packages, :add_topic, :reject_topic,
                                   :redirect, :report, :update_report, :add_data, :reject_data]
  before_action :set_breadcrumbs
  before_action :disable_pagination, only: :index, if: lambda { |controller| controller.request.format.ics? or controller.request.format.csv? }

  include SearchableIndex
  include ActionView::Helpers::TextHelper
  include FieldLockEnforcement
  include TopicCuration

  # GET /events
  # GET /events.json
  def index
    respond_to do |format|
      format.json
      format.json_api { render({ json: @events }.merge(api_collection_properties)) }
      format.html
      format.csv
      format.ics
    end
  end

  # GET /events/1
  # GET /events/1.json
  # GET /events/1.ics
  def show
    respond_to do |format|
      format.html
      format.json
      format.json_api { render json: @event }
      format.ics { render text: @event.to_ical }
    end
  end

  # GET /events/new
  def new
    authorize Event
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
    authorize @event
  end

  # GET /events/1/report
  def report
    authorize @event, :edit_report?
  end

  # PATCH /events/1/report
  def update_report
    authorize @event, :edit_report?

    respond_to do |format|
      if @event.update(event_report_params)
        @event.create_activity(:report, owner: current_user) if @event.log_update_activity?

        format.html { redirect_to event_path(@event, anchor: 'report'), notice: 'Event report successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :report }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /events/check_exists
  # POST /events/check_exists.json
  def check_exists
    @event = Event.check_exists(event_params)

    if @event
      respond_to do |format|
        format.html { redirect_to @event }
        format.json { render :show, location: @event }
      end
    else
      respond_to do |format|
        format.html { render :nothing => true, :status => 200, :content_type => 'text/html' }
        format.json { render json: {}, :status => 200, :content_type => 'application/json' }
      end
    end

  end

  # POST /events
  # POST /events.json
  def create
    authorize Event
    @event = Event.new(event_params)
    @event.user = current_user

    respond_to do |format|
      if @event.save
        @event.create_activity :create, owner: current_user
        look_for_topics(@event)
        geocoding_check(@event)
        #current_user.events << @event
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    authorize @event
    respond_to do |format|
      if @event.update(event_params)
        @event.create_activity(:update, owner: current_user) if @event.log_update_activity?
        # TODO: Consider whether this is proper behaviour or whether a user should explicitly delete this
        # TODO: suggestion, somehow.
        @event.edit_suggestion.destroy if @event.edit_suggestion
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    authorize @event
    @event.create_activity :destroy, owner: current_user
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /events/1/update_packages
  # POST /events/1/update_packages.json
  def update_packages
    # Go through each selected package
    # and update its resources to include this one.
    # Go through each other package
    packages = params[:event][:package_ids].select{|p| !p.blank?}
    packages = packages.collect{|package| Package.find_by_id(package)}
    packages_to_remove = @event.packages - packages
    packages.each do |package|
      package.update_resources_by_id(nil, (package.events + [@event.id]).uniq)
    end
    packages_to_remove.each do |package|
      package.update_resources_by_id(nil, (package.events.collect{|x| x.id} - [@event.id]).uniq)
    end
    flash[:notice] = "Event has been included in #{pluralize(packages.count, 'package')}"
    redirect_to @event
  end

  def redirect
    @event.widget_logs.create(widget_name: params[:widget],
                              action: "#{controller_name}##{action_name}",
                              data: @event.url, params: params)

    redirect_to @event.url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:external_id, :title, :subtitle, :url, :organizer, :last_scraped,
                                  :scraper_record, :description, {:scientific_topic_names => []},
                                  {:scientific_topic_uris => []}, {:event_types => []},
                                  {:keywords => []}, :start, :end, :sponsor, :online, :for_profit, :venue,
                                  :city, :county, :country, :postcode, :latitude, :longitude, :timezone,
                                  :content_provider_id, {:package_ids => []}, {:node_ids => []}, {:node_names => []},
                                  {:target_audience => []}, {:eligibility => []},
                                  {:host_institutions => []}, :capacity, :contact,
                                  external_resources_attributes: [:id, :url, :title, :_destroy], material_ids: [],
                                  locked_fields: [])
  end

  def event_report_params
    params.require(:event).permit(:funding, :attendee_count, :applicant_count, :trainer_count, :feedback, :notes)
  end

  def disable_pagination
    params[:per_page] = 2 ** 10
  end


  # If no latitude or longitude, create a GeocodingWorker to find them.
  # This should run a minute after the last one is set to run (last run time stored by Redis).
  def geocoding_check(event)
    run_at = Time.now.to_i
=begin
    begin
      redis = Redis.new
      last_geocode = (redis.get 'last_geocode').to_i # will cast to 0 if nil
      if last_geocode > run_at
        run_at = last_geocode
      end
    rescue
      puts 'Unable to connect to Redis.'
    end
=end

    redis = Redis.new
    last_geocode = (redis.get 'last_geocode').to_i # will cast to 0 if nil
    if last_geocode > run_at
      run_at = last_geocode
    end

    locations = [
        event.city,
        event.county,
        event.country,
        event.postcode,
    ].select { |x| !x.nil? and x != '' }

    # Only proceed if there's at least one location field to look up.
    if locations.empty?
      # Mark this record to not be queried again, i.e. set the
      # nominatim_queries value to the maximum immediately.
      event.nominatim_count = 3
      event.save!
    else
      # submit event_id, and locations to worker.
      location = locations.reject(&:blank?).join(',')
      GeocodingWorker.perform_at(run_at + 1.minute, [e.id, location])
      redis.set 'last_geocode', run_at + 1.minute
    end

  end

end
