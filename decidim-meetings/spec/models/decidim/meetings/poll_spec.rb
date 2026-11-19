# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Poll do
      subject { poll }

      let(:poll) { create(:poll) }

      it { is_expected.to be_valid }
    end
  end
end
