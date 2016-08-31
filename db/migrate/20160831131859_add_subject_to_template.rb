class AddSubjectToTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :email_templates, :subject, :string, default: ''
  end
end
