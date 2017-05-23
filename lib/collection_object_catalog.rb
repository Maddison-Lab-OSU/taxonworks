# Concept is a chronological history of the collection object
module CollectionObjectCatalog

  # An arbitrary vocabulary of human-readable event names (tags)
  # in the lifetime of a collection object
  EVENT_TYPES = [
    :born,
    :died,
    :collected_on,
    :determined,
    :described,
    :given_identifier,
    :georeferenced,
    :destroyed,
    :placed_in_repository,
    :sent_for_loan,
    :returned_from_loan,
    :updated_metadata,
    :added_note,
    :annotated,
    :cited,
    :containerized,
    :imaged,
    :extracted_from,
    :sequenced,
    :dissected,
    :tagged,
    :typified,
    :added_attribute,
    :fossilized_between, # chronological time period b/w which specimen was fossilized
  ]

  def self.data_for(collection_object)
    o = collection_object
    data = CollectionObjectCatalog::CatalogEntry.new(o)
    
    data.items << CollectionObjectCatalog::EntryItem.new(type: :collected_on, object: o.collecting_event, start_date: o.collecting_event.start_date, end_date: o.collecting_event.end_date) 

    o.versions.each do |v|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :updated_metadata, object: v, start_date: v.created_at.to_time) 
    end

    o.georeferences.each do |g|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :georeferenced, object: g, start_date: g.created_at.to_time)
    end

    o.taxon_determinations.each do |td|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :determined, object: td, start_date: td.sort_date) 
    end

    o.identifiers.each do |i|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :given_identifier, object: i, start_date: i.created_at) 
    end

    o.loans.each do |l|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :sent_for_loan, object: l, start_date: l.date_sent.to_time) if l.date_sent
      data.items << CollectionObjectCatalog::EntryItem.new(type: :returned_from_loan, object: l, start_date: l.date_closed.to_time) if l.date_closed
    end

    o.tags.each do |t|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :tagged, object: t, start_date: t.created_at.to_time) 
    end

    o.data_attributes.each do |d|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :added_attribute, object: d, start_date: d.created_at.to_time) 
    end

    o.notes.each do |n|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :added_note, object: n, start_date: n.created_at.to_time) 
    end

    data
  end

end

