class DocumentationController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_documentation, only: [:show, :edit, :update, :destroy]

  # GET /documentation
  # GET /documentation.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Documentation.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @documenation = Documentation.where(project_id: sessions_current_project_id).where(
          polymorphic_filter_params('documentation_object', Documentation.related_foreign_keys )
        )
      }
    end
  end

  # GET /documentation/1
  # GET /documentation/1.json
  def show
  end

  # GET /documentation/new
  def new
    @documentation = Documentation.new
  end

  # GET /documentation/1/edit
  def edit
  end

  # POST /documentation
  # POST /documentation.json
  def create
    @documentation = Documentation.new(documentation_params)

    respond_to do |format|
      if @documentation.save
        format.html { redirect_to @documentation.metamorphosize, notice: 'Documentation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @documentation }
      else
        format.html { render action: 'new' }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/1
  # PATCH/PUT /documentation/1.json
  def update
    respond_to do |format|
      if @documentation.update(documentation_params)
        format.html { redirect_to @documentation.metamorphosize, notice: 'Documentation was successfully updated.' }
        format.json { render :show, status: :ok, location: @documentation }
      else
        format.html { render :edit }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/1
  # DELETE /documentation/1.json
  def destroy
    @documentation.destroy
    respond_to do |format|
      format.html { redirect_to documentation_index_url, notice: 'Documentation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @documentation = Documentation.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10)
  end

  def search
    if params[:id].blank?
      redirect_to documentation_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to documentation_path(params[:id])
    end
  end

  def autocomplete
    @documentation = Documentation.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @documentation.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.documentation_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html: ApplicationController.helpers.documentation_autocomplete_selected_tag(t)
      }
    end

    render :json => data
  end

  private
  def set_documentation
    @documentation = Documentation.find(params[:id])
  end

  def documentation_params
    params.require(:documentation).permit(
      :documentation_object_id, :documentation_object_type, :document_id, :annotated_global_entity,
      document_attributes: [:document_file] 
    )
  end
end
