require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it "destroys associated diaries when the user is destroyed" do
      user = FactoryBot.create(:user)
      diary = FactoryBot.create(:diary, user:)

      user.destroy

      expect(Diary.exists?(diary.id)).to be false
    end
  end

  describe "validations" do
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

  describe ".sync_with_discord" do
    let(:auth_info) do
      OmniAuth::AuthHash.new(
        provider: "discord",
        uid: "12345",
        info: {
          name: "test",
          image: "https://example.com/image.png"
        }
      )
    end

    context "when the user doesn't exist" do
      it "creates and returns a new user" do
        user = nil

        expect {
          user = User.sync_with_discord(auth_info)
        }.to change(User, :count).by(1)
        expect(user).to have_attributes(
                          discord_user_id: auth_info.uid,
                          discord_user_name: auth_info.info.name,
                          avatar_url: auth_info.info.image
                        )
      end
    end

    context "when the user exists" do
      it "updates and returns the existing user" do
        existing_user = FactoryBot.create(:user,
                                          discord_user_id: auth_info.uid,
                                          discord_user_name: "old_user_name",
                                          avatar_url: "old/image.png")
        returned_user = User.sync_with_discord(auth_info)

        expect(existing_user).to eq(returned_user)
        expect(returned_user).to have_attributes(
                                   discord_user_name: auth_info.info.name,
                                   avatar_url: auth_info.info.image
                                 )
      end
    end
  end
end
