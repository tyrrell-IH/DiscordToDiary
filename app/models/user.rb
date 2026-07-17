class User < ApplicationRecord
  enum :default_visibility, { unconfigured: 0, everyone: 1, members_only: 2, only_me: 3 }
end
