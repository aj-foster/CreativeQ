class CreateOrders < ActiveRecord::Migration
  def change
    execute 'create extension hstore'
    create_table :orders do |t|
      t.string :name
      t.date :due
      t.text :description
      t.hstore :event
      t.hstore :needs
      t.string :status
      t.references :owner, index: true
      t.references :organization, index: true
      t.references :creative, index: true

      t.timestamps
    end
  end
end
