# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe ProjectsHelper do
      describe "#projects_base_url" do
        subject { helper.projects_base_url }

        before { allow(helper).to receive(:root_url).and_return("http://localhost:3000/processes/similique-odit/f/13/") }

        it { is_expected.to eq("http://localhost:3000/processes/similique-odit/f/13/") }

        context "when query string is present" do
          before { allow(helper).to receive(:root_url).and_return("http://localhost:3000/processes/similique-odit/f/13/?locale=es&extra=1") }

          it { is_expected.to eq("http://localhost:3000/processes/similique-odit/f/13/") }
        end
      end
    end
  end
end
