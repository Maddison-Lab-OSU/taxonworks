class ObservationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  skip_before_action :verify_authenticity_token

  before_action :set_observation, only: [:show, :edit, :update, :destroy, :annotations]

  # GET /observations
  # GET /observations.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Observation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @observations = Observation.where(filter_params).with_project_id(sessions_current_project_id)
      }
    end
  end

  # GET /observations/1
  # GET /observations/1.json
  def show
  end

  # GET /observations/new
  def new
    @observation = Observation.new
  end

  # GET /observations/1/edit
  def edit
  end

  def list
    @observations = Observation.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /observations
  # POST /observations.json
  def create
    @observation = Observation.new(observation_params)

    respond_to do |format|
      if @observation.save
        format.html { redirect_to observation_path(@observation.metamorphosize), notice: 'Observation was successfully created.' }
        format.json { render :show, status: :created, location: @observation.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @observation.metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observations/1
  # PATCH/PUT /observations/1.json
  def update
    respond_to do |format|
      if @observation.update(observation_params)
        format.html { redirect_to @observation.metamorphosize, notice: 'Observation was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @observation..metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observations/1
  # DELETE /observations/1.json
  def destroy
    @observation.destroy
    respond_to do |format|
      format.html { redirect_to observations_url, notice: 'Observation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /annotations
  def annotations
    @object = @observation
    render '/shared/data/all/annotations'
  end

  private

  def set_observation
    @observation = Observation.find(params[:id])
  end

  def observation_params
    params.require(:observation).permit(
      :descriptor_id, :otu_id, :collection_object_id,
      :character_state_id, :frequency,
      :continuous_value, :continuous_unit,
      :sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample, :sample_standard_error,
      :presence,
      :description,
      :type)
  end

  def filter_params
    params.permit(:otu_id, :descriptor_id, :collection_object_id)
  end
end
