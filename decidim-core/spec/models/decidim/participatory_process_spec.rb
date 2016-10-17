# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcess do
    let(:participatory_process) { build(:participatory_process) }

    it "is valid" do
      expect(participatory_process).to be_valid
    end
  end
end
