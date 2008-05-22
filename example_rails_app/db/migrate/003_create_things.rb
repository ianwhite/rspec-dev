class CreateThings < ActiveRecord::Migration
  def self.up
    create_table :things do |t|
      t.column :name,      :string, :default => nil
    end rescue nil
  end

  def self.down
    drop_table :things rescue nil
  end
end
 
