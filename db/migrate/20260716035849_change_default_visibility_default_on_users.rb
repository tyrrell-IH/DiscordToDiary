class ChangeDefaultVisibilityDefaultOnUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :default_visibility, from: 2, to: 0
  end
end
