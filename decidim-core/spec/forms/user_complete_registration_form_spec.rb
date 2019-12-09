# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserCompleteRegistrationForm do
    subject do
      described_class.new(
        avatar: avatar,
        remove_avatar: remove_avatar,
        personal_url: personal_url,
        about: about,
        scopes: scopes
      ).with_context(
        current_organization: organization,
        current_user: user
      )
    end

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:avatar) { File.open("spec/assets/avatar.jpg") }
    let(:remove_avatar) { false }
    let(:personal_url) { "http://example.org" }
    let(:about) { "This is a description about me" }
    let(:scope_first_intereset) { UserInterestScopeForm.new(name: "Intereset 1", checked: true) }
    let(:scope_second_intereset) { UserInterestScopeForm.new(name: "Intereset 2", checked: false) }
    let(:scopes) { [scope_first_intereset, scope_second_intereset] }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    describe "personal_url" do
      context "when it doesn't start with http" do
        let(:personal_url) { "example.org" }

        it "adds it" do
          expect(subject.personal_url).to eq("http://example.org")
        end
      end

      context "when it's not a valid URL" do
        let(:personal_url) { "foobar, aa" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
