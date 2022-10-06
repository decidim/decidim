# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe VotingSerializer do
      subject do
        described_class.new(voting)
      end

      let!(:voting) { create(:voting) }
      let!(:scope) { create :scope, organization: voting.organization }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(participatory_space_id: voting.id)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", voting.slug)
        end

        it "serializes the title" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:title], locale:)).to eq(translated(voting.title, locale:))
          end
        end

        it "serializes the description" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:description], locale:)).to eq(translated(voting.description, locale:))
          end
        end

        it "serializes the voting type" do
          I18n.available_locales.each do |locale|
            expect(translated(serialized[:voting_type], locale:)).to eq(I18n.t(voting.voting_type, scope: "decidim.votings.admin.votings.form.voting_type"))
          end
        end

        it "serializes the banner image url" do
          expect(serialized).to include(banner_image_url: Decidim::Votings::VotingPresenter.new(voting).banner_image_url)
        end

        it "serializes the introductory image url" do
          expect(serialized).to include(introductory_image_url: Decidim::Votings::VotingPresenter.new(voting).introductory_image_url)
        end

        it "serializes the scope" do
          expect(serialized[:scope]).to include(id: voting.scope.id)
          expect(serialized[:scope]).to include(name: voting.scope.name)
        end
      end
    end
  end
end
