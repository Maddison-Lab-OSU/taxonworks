class TaxonNameRelationship::Combination::Species < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants + NomenclaturalRank::Icn::Species + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants + NomenclaturalRank::Icn::Species + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

end
