class TweakGeographicArea2 < ActiveRecord::Migration[4.2]
  def change
    add_column :geographic_areas, :iso_3166_year, :integer
    add_column :geographic_areas, :tdwg_parent_id, :integer
  end
end
