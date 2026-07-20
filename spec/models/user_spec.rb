require 'rails_helper'

RSpec.describe User, type: :model do
  it "is invalid without a discord_user_name" do
    user = FactoryBot.build(:user, discord_user_name: nil)

    expect(user).to be_invalid
  end

  it "is invalid without a discord_user_id" do
    user = FactoryBot.build(:user, discord_user_id: nil)

    expect(user).to be_invalid
  end

  it "is invalid with a duplicate discord_user_id" do
    FactoryBot.create(:user, discord_user_id: '123')

    new_user = FactoryBot.build(:user, discord_user_id: '123')

    expect(new_user).to be_invalid
    expect(new_user.errors[:discord_user_id]).to include("has already been taken")
  end

  it "is invalid without a default_visibility" do
    user = FactoryBot.build(:user, default_visibility: nil)

    expect(user).to be_invalid
  end
end
