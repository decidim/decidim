# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { create(:user_group) }

    it_behaves_like "acts as author"
  end
end
