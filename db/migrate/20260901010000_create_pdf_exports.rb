# frozen_string_literal: true

class CreatePdfExports < ActiveRecord::Migration[7.1]
  def change
    create_table :pdf_exports do |t|
      t.date :target_month, null: false
      t.string :status, null: false, default: 'processing'
      t.integer :pdf_count, null: false, default: 0
      t.string :zip_filename
      t.integer :created_by_id

      t.timestamps
    end

    add_index :pdf_exports, :created_at
    add_index :pdf_exports, :created_by_id
  end
end
