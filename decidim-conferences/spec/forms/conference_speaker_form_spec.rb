# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ConferenceSpeakerForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:context) do
          {
            current_organization: organization
          }
        end

        let(:full_name) { "Full name" }
        let(:position) { Decidim::Faker::Localized.word }
        let(:affiliation) { Decidim::Faker::Localized.word }
        let(:short_bio) { Decidim::Faker::Localized.sentence }
        let(:twitter_handle) { "full_name" }
        let(:personal_url) { "http://decidim.org" }
        let(:avatar) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:existing_user) { false }
        let(:user_id) { nil }
        let(:attributes) do
          {
            "conference_speaker" => {
              "full_name" => full_name,
              "position" => position,
              "affiliation" => affiliation,
              "short_bio" => short_bio,
              "twitter_handle" => twitter_handle,
              "personal_url" => personal_url,
              "avatar" => avatar,
              "existing_user" => existing_user,
              "user_id" => user_id
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when full name is missing" do
          let(:full_name) { nil }

          it { is_expected.to be_invalid }
        end

        context "when position is missing" do
          let(:position) { nil }

          it { is_expected.to be_invalid }
        end

        context "when affiliation is missing" do
          let(:affiliation) { nil }

          it { is_expected.to be_invalid }
        end

        context "when existing user is present" do
          let(:existing_user) { true }

          context "and no user is provided" do
            it { is_expected.to be_invalid }
          end

          context "and user exists" do
            let(:user_id) { create(:user, organization: organization).id }

            it { is_expected.to be_valid }
          end

          context "and no such user exists" do
            let(:user_id) { 999_999 }

            it { is_expected.to be_invalid }
          end
        end

        describe "user" do
          subject { form.user }

          context "when the user exists" do
            let(:user_id) { create(:user, organization: organization).id }

            it { is_expected.to be_kind_of(Decidim::User) }
          end

          context "when the user does not exist" do
            let(:user_id) { 999_999 }

            it { is_expected.to eq(nil) }
          end

          context "when the user is from another organization" do
            let(:user_id) { create(:user).id }

            it { is_expected.to eq(nil) }
          end
        end
      end
    end
  end
end
