json.extract! otu, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at, :taxon_name_id
json.partial! '/shared/data/all/metadata', object: otu


