class CreateMobiles < ActiveRecord::Migration[5.2]
  def change
    create_table :mobiles, id: :uuid do |t|
      t.string :service_slug
      t.string :mobile
      t.text :encrypted_email
      t.text :encrypted_payload
      t.datetime :expires_at
      t.string :validity, null: false, default: 'valid'
      t.string :code, null: false

      t.timestamps
    end

    add_index :mobiles, [:service_slug, :encrypted_email]
  end
end
