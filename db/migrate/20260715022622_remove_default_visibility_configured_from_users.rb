class RemoveDefaultVisibilityConfiguredFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :default_visibility_configured, :boolean
  end
end
