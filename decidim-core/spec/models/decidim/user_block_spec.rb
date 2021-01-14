# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserBlock do
    it { is_expected.to respond_to :user }
    it { is_expected.to respond_to :blocking_user }
  end
end
