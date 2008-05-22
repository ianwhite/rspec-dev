class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :name, :string, :default => nil
      t.column :address, :text
    end rescue nil
  end

  def self.down
    drop_table :people rescue nil
  end
end
