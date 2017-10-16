# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Accountability
    describe TimelineEntry do
      let(:timeline_entry) { build :timeline_entry }
      subject { timeline_entry }

      it { is_expected.to be_valid }
    end
  end
end
