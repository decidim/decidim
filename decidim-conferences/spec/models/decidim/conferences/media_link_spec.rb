# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe MediaLink do
      subject { media_link }

      let(:media_link) { create(:media_link) }

      it { is_expected.to be_valid }

      it "is reachable from the conference media links association" do
        expect(media_link.conference.media_links).to contain_exactly(media_link)
      end
    end
  end
end
