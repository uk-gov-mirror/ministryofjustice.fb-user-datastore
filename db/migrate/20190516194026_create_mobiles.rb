class CreateMobiles < ActiveRecord::Migration[5.2]
  def change
    create_table :mobiles, id: :uuid do |t|
      t.text :service_slug, null: false
      t.text :encrypted_email, null: false
      t.text :encrypted_payload, null: false
      t.datetime :expires_at, null: false
      t.text :validity, null: false, default: 'valid'
      t.text :code, null: false

      t.timestamps
    end

    add_index :mobiles, [:service_slug, :encrypted_email]
  end
end
