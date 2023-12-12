# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EngineRouter do
    let(:organization) do
      build(:organization)
    end

    let(:participatory_process) do
      build(:participatory_process, slug: "my-process", organization:)
    end

    describe ".admin_proxy" do
      describe "#components_path" do
        subject { described_class.admin_proxy(participatory_process).components_path }

        it { is_expected.to eq("/admin/participatory_processes/my-process/components") }
      end
    end
  end
end
