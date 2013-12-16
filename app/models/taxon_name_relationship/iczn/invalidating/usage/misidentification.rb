class TaxonNameRelationship::Iczn::Invalidating::Usage::Misidentification < TaxonNameRelationship::Iczn::Invalidating::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.descendants.collect{|t| t.to_s}
  end

  def self.assignable
    true
  end

end