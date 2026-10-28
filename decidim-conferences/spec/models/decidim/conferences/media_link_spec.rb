# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe MediaLink do
      subject { media_link }

      let(:media_link) { create(:media_link) }

      it { is_expected.to be_valid }

      it "uses the conference's media_links association as the inverse" do
        expect(media_link.conference.media_links.first.conference).to be(media_link.conference)
      end
    end
  end
end
