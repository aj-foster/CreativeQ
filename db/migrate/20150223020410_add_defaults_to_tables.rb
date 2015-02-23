class AddDefaultsToTables < ActiveRecord::Migration
  def change
    change_column :users, :first_name, :string, default: ""
    change_column :users, :last_name, :string, default: ""
    change_column :users, :role, :string, default: "Unapproved"
    change_column :users, :phone, :string, default: ""
    change_column :users, :flavor, :string, default: ""

    change_column :orders, :name, :string, default: ""
    change_column :orders, :description, :text, default: ""
    change_column :orders, :event, :hstore, default: "", null: false
    change_column :orders, :needs, :hstore, default: "", null: false
    change_column :orders, :status, :string, default: "Unapproved"

    change_column :organizations, :name, :string, default: ""

    change_column :assignments, :role, :string, default: "Member"

    change_column :comments, :message, :text, default: ""
  end
end