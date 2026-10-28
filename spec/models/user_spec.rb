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
    let(:global_name) { "test_global_name" }
    let(:auth_info) do
      OmniAuth::AuthHash.new(
        provider: "discord",
        uid: "12345",
        info: {
          name: "test_user_name",
          image: "https://example.com/image.png"
        },
        extra: {
          raw_info: {
            global_name: global_name
          }
        }
      )
    end

    context "when the user doesn't exist" do
      it "creates and returns a new user" do
        user = nil

        expect {
          user = User.sync_with_discord(auth_info)
        }.to change(User, :count).by(1)
        expect(user.reload).to have_attributes(
                                 discord_user_id: auth_info.uid,
                                 discord_user_name: auth_info.info.name,
                                 discord_global_name: auth_info.extra.raw_info.global_name,
                                 avatar_url: auth_info.info.image
                               )
      end
    end

    context "when the user exists" do
      let(:global_name) { nil }

      it "updates and returns the existing user" do
        existing_user = FactoryBot.create(:user,
                                          discord_user_id: auth_info.uid,
                                          discord_user_name: "old_user_name",
                                          discord_global_name: "old_global_name",
                                          avatar_url: "old/image.png")
        returned_user = User.sync_with_discord(auth_info)

        expect(existing_user).to eq(returned_user)
        expect(returned_user.reload).to have_attributes(
                                          discord_user_name: auth_info.info.name,
                                          discord_global_name: nil,
                                          avatar_url: auth_info.info.image
                                        )
      end
    end
  end

  describe "#display_name" do
    context "when the discord_global_name exists" do
      let(:user) { FactoryBot.create(:user,
                                     discord_user_name: "test_user_name",
                                     discord_global_name: "test_global_name") }

      it "returns the discord_global_name" do
        expect(user.display_name).to eq("test_global_name")
      end
    end

    context "when the discord_global_name does not exists" do
      let(:user) { FactoryBot.create(:user,
                                     discord_user_name: "test_user_name",
                                     discord_global_name: nil) }

      it "returns the discord_user_name" do
        expect(user.display_name).to eq("test_user_name")
      end
    end
  end
end
