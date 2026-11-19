# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Service do
      subject { service }

      let(:service) { create(:service) }

      it { is_expected.to be_valid }
    end
  end
end
