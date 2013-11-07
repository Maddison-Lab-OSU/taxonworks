class TaxonNameRelationship::Combination::Variety < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  def self.assignable
    true
  end

end
