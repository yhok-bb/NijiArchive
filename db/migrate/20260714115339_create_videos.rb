class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto"

    create_table :videos, id: :uuid do |t|
      t.string :title
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :videos, :status
  end
end
