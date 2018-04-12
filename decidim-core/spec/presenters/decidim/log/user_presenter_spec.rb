# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::UserPresenter, type: :helper do
  subject { described_class.new(user, helper, extra).present }

  let!(:user) { create :user }
  let(:user_nickname) { h(user.nickname) }
  let(:extra) do
    {
      "name" => user.name,
      "nickname" => user.nickname
    }
  end

  describe "#present" do
    context "when the user exists" do
      it "links to their profile" do
        expect(subject).to include("href=\"/profiles/#{user_nickname}\">")
      end
    end

    context "when the user doesn't exist" do
      let(:user) { nil }
      let(:extra) do
        {
          "name" => "John O'Hara",
          "nickname" => "johnohara"
        }
      end

      it "doesn't link to their profile" do
        expect(subject).not_to include("href=\"/profiles/")
        expect(subject).to include("John O'Hara")
      end
    end
  end
end
