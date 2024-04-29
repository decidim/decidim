# frozen_string_literal: true

require "spec_helper"

shared_examples "generates routes without query strings on slug" do
  let(:organization) { create(:organization, host: "1.lvh.me") }
  let(:participatory_space) { create(factory_name, organization: organization) }
  let(:component) { create(:component, id: 1, participatory_space: participatory_space) }
  let(:resource) { create(:dummy_resource, id: 1, component: component) }

  context "with a component resource" do
    describe "#url" do
      subject { described_class.new(resource).url }

      it { is_expected.to eq("http://1.lvh.me:#{Capybara.server_port}/#{route_fragment}/f/1/dummy_resources/1") }

      context "when specific port configured" do
        before do
          allow(ActionMailer::Base)
            .to receive(:default_url_options)
            .and_return(port: 3000)
        end

        it { is_expected.to eq("http://1.lvh.me:3000/#{route_fragment}/f/1/dummy_resources/1") }
      end
    end

    describe "#path" do
      subject { described_class.new(resource).path }

      it { is_expected.to eq("/#{route_fragment}/f/1/dummy_resources/1") }
    end

    describe "#show" do
      subject { described_class.new(participatory_space).show }

      it { is_expected.to eq("/admin/#{admin_route_fragment}") }
    end

    describe "#edit" do
      subject { described_class.new(participatory_space).edit }

      it { is_expected.to eq("/admin/#{admin_route_fragment}/edit") }
    end
  end

  context "with a polymorphic resource" do
    let(:nested_resource) do
      create(:nested_dummy_resource, id: 1, dummy_resource: resource)
    end

    describe "#url" do
      subject { described_class.new([resource, nested_resource]).url }

      it { is_expected.to eq("http://1.lvh.me:#{Capybara.server_port}/#{route_fragment}/f/1/dummy_resources/1/nested_dummy_resources/1") }

      context "when specific port configured" do
        before do
          allow(ActionMailer::Base)
            .to receive(:default_url_options)
            .and_return(port: 3000)
        end

        it { is_expected.to eq("http://1.lvh.me:3000/#{route_fragment}/f/1/dummy_resources/1/nested_dummy_resources/1") }
      end
    end

    describe "#path" do
      subject { described_class.new([resource, nested_resource]).path }

      it { is_expected.to eq("/#{route_fragment}/f/1/dummy_resources/1/nested_dummy_resources/1") }
    end

    describe "#index" do
      subject { described_class.new([resource, nested_resource]).index }

      it { is_expected.to eq("/#{route_fragment}/f/1/dummy_resources/1/nested_dummy_resources") }
    end

    describe "#admin_index" do
      subject { described_class.new([resource, nested_resource]).admin_index }

      it { is_expected.to eq("/admin/#{admin_route_fragment}/components/1/manage/dummy_resources/1/nested_dummy_resources") }
    end

    describe "#show" do
      subject { described_class.new([resource, nested_resource]).show }

      it { is_expected.to eq("/admin/#{admin_route_fragment}/components/1/manage/dummy_resources/1/nested_dummy_resources/1") }
    end

    describe "#edit" do
      subject { described_class.new([resource, nested_resource]).edit }

      it { is_expected.to eq("/admin/#{admin_route_fragment}/components/1/manage/dummy_resources/1/nested_dummy_resources/1/edit") }
    end
  end

  context "with a participatory_space" do
    describe "#url" do
      subject { described_class.new(participatory_space).url }

      it { is_expected.to eq("http://1.lvh.me:#{Capybara.server_port}/#{route_fragment}") }

      context "when specific port configured" do
        before do
          allow(ActionMailer::Base)
            .to receive(:default_url_options)
            .and_return(port: 3000)
        end

        it { is_expected.to eq("http://1.lvh.me:3000/#{route_fragment}") }
      end
    end

    describe "#path" do
      subject { described_class.new(participatory_space).path }

      it { is_expected.to eq("/#{route_fragment}") }
    end

    describe "#show" do
      subject { described_class.new(participatory_space).show }

      it { is_expected.to eq("/admin/#{admin_route_fragment}") }
    end

    describe "#edit" do
      subject { described_class.new(participatory_space).edit }

      it { is_expected.to eq("/admin/#{admin_route_fragment}/edit") }
    end
  end
end
