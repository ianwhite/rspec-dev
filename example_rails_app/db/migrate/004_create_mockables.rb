class CreateMockables < ActiveRecord::Migration
  def self.up
    create_table :mockable_models do |t|
      t.column :name, :string
    end rescue nil
    create_table :associated_models do |t|
      t.column :mockable_model_id, :integer
    end rescue nil
  end

  def self.down
    drop_table :mockable_models rescue nil
    drop_table :associated_models rescue nil
  end
end
 
