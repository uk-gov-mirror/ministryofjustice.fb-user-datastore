class CreateCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :codes do |t|
      t.text :service_slug, null: false
      t.text :encrypted_email, null: false
      t.text :code, null: false
      t.text :validity, default: 'valid', null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :codes, [:service_slug, :encrypted_email]
  end
end
