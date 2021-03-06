class ChgSourceTitle2text < ActiveRecord::Migration[4.2]
  def change
    reversible do |dir|
      change_table :sources do |t|
        dir.up do
          t.change :title, :text
        end

        dir.down do
          t.change :title, :string
        end
      end
    end
  end
end
