class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant.to_s]
  end

end