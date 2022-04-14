# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserBaseEntity do
    subject { user }

    let(:organization) { create(:organization) }
    let(:user) { build(:user, organization: organization) }

    let(:user_followed) { create(:user, organization: user.organization) }
    let(:public_resource) { create(:dummy_resource, :published) }
    let(:user_blocked) { create(:user, organization: user.organization, blocked: true) }

    before do
      create(:follow, user: user, followable: user_followed)
      create(:follow, user: user, followable: public_resource)
      create(:follow, user: user, followable: user_blocked)
    end

    describe "public followings" do
      it "return all the things followed unless the blocked users" do
        expect(subject.public_followings).to eq([public_resource, user_followed])
      end
    end
  end
end
