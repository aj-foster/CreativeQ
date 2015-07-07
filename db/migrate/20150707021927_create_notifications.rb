class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title, null: false, default: ""
      t.text :message, null: false, default: ""
      t.boolean :read, null: false, default: false
      t.references :user, index: true
      t.references :order, index: true

      t.timestamps
    end
  end
end
