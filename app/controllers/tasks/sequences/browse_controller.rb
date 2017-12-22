class Tasks::Sequences::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # POST
  def sequences
    render :json => Queries::SequenceFilterQuery.new(filter_params).result
  end

  def filter_params
    params.permit(:otu_id, :otu_descendants, :collection_object_namespace_id, :collection_object_identifier, :gene_descriptor_id)
  end
end
