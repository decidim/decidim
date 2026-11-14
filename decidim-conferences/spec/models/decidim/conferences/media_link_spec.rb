# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    describe MediaLink do
      subject { media_link }

      let(:media_link) { create(:media_link) }

      it { is_expected.to be_valid }
    end
  end
end
