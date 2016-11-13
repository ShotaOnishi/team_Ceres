class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.text :file
      t.string :comment
      t.timestamp
    end
  end
end
