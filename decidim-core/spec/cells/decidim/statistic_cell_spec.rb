# frozen_string_literal: true

require "spec_helper"

describe Decidim::StatisticCell, type: :cell do
  subject(:cell) { described_class.new(model) }

  let(:model) do
    {
      name: "Dummy Resource",
      data: [1234, 5678],
      sub_title: "votes",
      tooltip_key: "proposals_count_tooltip",
      icon_name: "chat-new-line"
    }
  end

  describe "#stat_number" do
    it "returns the first number formatted" do
      expect(cell.send(:stat_number)).to eq("1,234")
    end
  end

  describe "#second_stat_number" do
    it "returns the second number formatted" do
      expect(cell.send(:second_stat_number)).to eq("5,678")
    end

    context "when there is only one data point" do
      let(:model) { super().merge(data: [999]) }

      it "returns nil" do
        expect(cell.send(:second_stat_number)).to be_nil
      end
    end
  end

  describe "#stat_dom_class" do
    it "returns the stat name" do
      expect(cell.send(:stat_dom_class)).to eq("Dummy Resource")
    end
  end

  describe "#stat_sub_title" do
    it "translates the subtitle if present" do
      expect(cell.send(:stat_sub_title)).to eq(I18n.t("votes", scope: "decidim.statistics"))
    end

    context "when sub_title is blank" do
      let(:model) { super().merge(sub_title: "") }

      it "returns nil" do
        expect(cell.send(:stat_sub_title)).to be_nil
      end
    end
  end

  describe "#information_tooltip" do
    it "renders the tooltip if tooltip_key is present" do
      expect(cell.send(:information_tooltip)).to include("information-line")
      expect(cell.send(:information_tooltip)).to include(I18n.t("proposals_count_tooltip", scope: "decidim.statistics"))
    end

    context "when tooltip_key is blank" do
      let(:model) { super().merge(tooltip_key: "") }

      it "returns nil" do
        expect(cell.send(:information_tooltip)).to be_nil
      end
    end
  end

  describe "#stat_icon" do
    it "returns an icon when icon_name is present" do
      expect(cell.send(:stat_icon)).to include("chat-new-line")
    end

    context "when icon_name is blank" do
      let(:model) { super().merge(icon_name: nil) }

      it "returns nil" do
        expect(cell.send(:stat_icon)).to be_nil
      end
    end
  end
end
