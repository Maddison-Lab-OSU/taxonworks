# Shared code for attaching protocols to data objects.
#
module Shared::ProtocolRelationships

  extend ActiveSupport::Concern

  included do

    ::ProtocolRelationship.related_foreign_keys.push self.name.foreign_key

    has_many :protocol_relationships, as: :protocol_relationship_object, dependent: :destroy
    has_many :protocols, through: :protocol_relationships

    accepts_nested_attributes_for :protocol_relationships, allow_destroy: true, reject_if: :reject_protocol_relationships
    accepts_nested_attributes_for :protocols, allow_destroy: true, reject_if: :reject_protocols
  end

  def protocolled?
    protocols.any?
  end

  protected
  # Not tested!
  # def reject_protocol_relationships(attributed)
  #   attributed['protocol_relationships_attributes'].blank? ||  attributed['image_protocol_relationships']['protocol_id'].blank?
  # end


  # # Not tested!
  # def reject_protocols(attributed)
  #   attributed['protocol_id'].blank? 
  # end

end
