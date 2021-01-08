# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserSuspension do
    it { is_expected.to respond_to :user }
    it { is_expected.to respond_to :suspending_user }
  end
end
