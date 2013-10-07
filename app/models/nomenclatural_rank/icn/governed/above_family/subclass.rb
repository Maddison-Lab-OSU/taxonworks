class NomenclaturalRank::Icn::Governed::AboveFamily::Subclass < NomenclaturalRank::Icn::Governed::AboveFamily

  def self.parent_rank
    NomenclaturalRank::Icn::Governed::AboveFamily::ClassRank
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -idae, -phycidae, or -mycetidae') if not(taxon_name.name =~ /.*idae|mycetidae|phycidae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -viridae') if (taxon_name.name =~ /.*viridae\Z/)
  end


end
