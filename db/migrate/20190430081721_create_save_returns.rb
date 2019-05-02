class CreateSaveReturns < ActiveRecord::Migration[5.2]
  def change
    create_table :save_returns do |t|
      t.text :encrypted_email, null: false
      t.text :encrypted_payload, null: false

      t.text :service, null: false

      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :save_returns, [:service, :encrypted_email], unique: true
  end
end
