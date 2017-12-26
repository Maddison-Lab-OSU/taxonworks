module Queries

  # Species ex. Bembidion louisella, DNA1250 should be picked up
  # Ancestor Species ex. Bembidion louisella and all children of it
  # Collection Object by Identifiers ex. Voucher#
  # Gene Name ex. 28S
  # Status ex. Final, default of Finals
  class SequenceFilterQuery < Queries::Query

    # Query variables
    attr_accessor :query_otu_id
    attr_accessor :query_otu_descendants
    attr_accessor :query_collection_object_namespace_id
    attr_accessor :query_collection_object_identifier
    attr_accessor :query_gene_descriptor_id

    def initialize(params)
      params.reject! { |k, v| v.blank? }

      @query_otu_id = params[:otu_id]
      @query_otu_descendants = params[:otu_descendants]
      @query_collection_object_namespace_id = params[:collection_object_namespace_id]
      @query_collection_object_identifier = params[:collection_object_identifier]
      @query_gene_descriptor_id = params[:gene_descriptor_id]
    end

    def otu_scope
      sequences = Sequence.none
      inner_scope = query_otu_descendants == "true" ? Otu.self_and_descendants_of(query_otu_id) : Otu.where(id: query_otu_id)
      
      inner_scope.each do |otu|
        sequences = sequences.or(otu.sequences)
      end

      sequences.distinct
    end

    def collection_object_scope
      sequences = Sequence.none
      namespace = Namespace.find_by(id: query_collection_object_namespace_id)
      collection_objects = CollectionObject.with_namespaced_identifier(namespace.name, query_collection_object_identifier)

      collection_objects.each do |collection_object|
        sequences = sequences.or(collection_object.sequences)
      end

      sequences.distinct
    end
    
    def gene_descriptor_scope
      Descriptor.find_by(id: query_gene_descriptor_id).sequences
    end
    
    def applied_scopes
      scopes = []
      scopes.push :otu_scope if query_otu_id.present?
      scopes.push :collection_object_scope if query_collection_object_namespace_id.present? && query_collection_object_identifier.present?
      scopes.push :gene_descriptor_scope if query_gene_descriptor_id.present?
      scopes
    end

    def result
      return Sequence.none if applied_scopes.empty?

      sequences = Sequence.all

      applied_scopes.each do |scope|
        sequences = sequences.merge(self.send(scope))
      end

      sequences
    end
  end
end
