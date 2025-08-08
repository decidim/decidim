# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe DashboardStatisticChartsPresenter do
      let(:organization) { create(:organization) }

      subject(:presenter) { described_class.new({ organization: }) }

      describe "#scope_entity" do
        it "returns the organization" do
          expect(presenter.scope_entity).to eq(organization)
        end
      end

      describe "#highlighted" do
        let(:high_priority_stats) do
          [
            { name: :proposals_count, data: [3], admin: false },
            { name: :custom_stat, data: [10], admin: true }
          ]
        end

        let(:medium_priority_stats) do
          [
            { name: :comments_count, data: [5], admin: true },
            { name: :other_stat, data: [7], admin: false }
          ]
        end

        before do
          allow(presenter).to receive(:collection) do |priority:|
            case priority
            when StatsRegistry::HIGH_PRIORITY then high_priority_stats
            when StatsRegistry::MEDIUM_PRIORITY then medium_priority_stats
            else []
            end
          end
        end

        it "returns filtered and merged stats with admin: true" do
          result = presenter.highlighted

          expect(result).to include(
            { name: :custom_stat, data: [10], admin: true },
            { name: :comments_count, data: [5], admin: true }
          )
          expect(result).not_to include(
            { name: :proposals_count, data: [3], admin: false },
            { name: :other_stat, data: [7], admin: false }
          )
        end

        it "does not include duplicated stats like :meetings_count" do
          high_priority_stats << { name: :meetings_count, data: [2], admin: true }
          result = presenter.highlighted

          expect(result).to include(admin: true, name: :meetings_count, data: [2])
        end
      end
    end
  end
end
