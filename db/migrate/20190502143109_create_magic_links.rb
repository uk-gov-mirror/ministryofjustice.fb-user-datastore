class CreateMagicLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :magic_links, id: :uuid do |t|
      t.text :service, null: false
      t.text :email, null: false
      t.text :encrypted_email, null: false
      t.text :validity, null: false, default: 'valid'
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :magic_links, :encrypted_email
  end
end
