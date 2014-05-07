class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.references :user, index: true
      t.references :organization, index: true
      t.string :role

      t.timestamps
    end
  end
end
