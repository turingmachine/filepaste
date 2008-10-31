class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.string :filename
      t.text :description
      t.string :hash_key
      t.string :content_type

      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
