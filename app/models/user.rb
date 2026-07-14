class User < ApplicationRecord
  enum :default_visibility, { public: 0, members_only: 1, private: 2 }
end
