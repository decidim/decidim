# frozen_string_literal: true

require "decidim/dev/test/rspec_support/capybara_data_picker"

module Capybara
  module ProposalsPicker
    include DataPicker

    RSpec::Matchers.define :have_proposals_picked do |expected|
      match do |proposals_picker|
        data_picker = proposals_picker.data_picker

        expected.each do |proposal|
          expect(data_picker).to have_selector(".picker-values div input[value='#{proposal.id}']", visible: :all)
          expect(data_picker).to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,\"#{translated(proposal.title)}\")]]")
        end
      end
    end

    RSpec::Matchers.define :have_proposals_not_picked do |expected|
      match do |proposals_picker|
        data_picker = proposals_picker.data_picker

        expected.each do |proposal|
          expect(data_picker).not_to have_selector(".picker-values div input[value='#{proposal.id}']", visible: :all)
          expect(data_picker).not_to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,\"#{translated(proposal.title)}\")]]")
        end
      end
    end

    def proposals_pick(proposals_picker, proposals)
      data_picker = proposals_picker.data_picker

      expect(data_picker).to have_selector(".picker-prompt")
      data_picker.find(".picker-prompt").click

      proposals.each do |proposal|
        data_picker_choose_value(proposal.id)
      end
      data_picker_close

      expect(proposals_picker).to have_proposals_picked(proposals)
    end

    def proposals_remove(proposals_picker, proposals)
      data_picker = proposals_picker.data_picker

      proposals.each do |proposal|
        data_picker.find("a", text: proposal.title["en"]).find("span").click
      end

      expect(proposals_picker).to have_proposals_not_picked(proposals)
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::ProposalsPicker, type: :system
end
