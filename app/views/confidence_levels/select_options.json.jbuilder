@confidence_levels.keys.each do |group|
  json.set!(group) do
    json.array! @confidence_levels[group] do |k|
      json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: k
    end
  end
end
