# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ShortLinkHelper do
    describe "#short_url" do
      subject { helper.short_url(**kwargs) }

      let(:kwargs) { { route_name: route_name, params: params }.compact }
      let(:route_name) { nil }
      let(:params) { nil }
      let(:target) { create(:dummy_resource) }
      let(:organization) { target.organization }

      let(:current_routes) { mounted_helpers.public_send(mounted_engine_name).routes }
      let(:mounted_helpers) do
        Class.new { include Rails.application.routes.mounted_helpers }.new
      end
      let(:mounted_engine_name) { :decidim }

      before do
        allow(helper).to receive(:_routes).and_return(current_routes)
      end

      shared_examples "working short link" do |target_route_name|
        let(:organization_url) { "http://#{organization.host}:#{Capybara.server_port}" }
        let(:expected_url_pattern) { %r{^#{organization_url}/s/[a-zA-Z0-9]{10}$} }
        let(:short_link) { Decidim::ShortLink.order(:id).last }

        before do
          expect { subject }.to change(Decidim::ShortLink, :count).by(1)
        end

        it "returns the short URL to a resource" do
          expect(subject).to match(expected_url_pattern)
        end

        it "maps the correct attributes to the short link" do
          expect(short_link.target).to eq(expected_target)
          expect(short_link.organization).to eq(organization)
          expect(short_link.mounted_engine_name).to eq(mounted_engine_name.to_s)
          expect(short_link.route_name).to eq("root")
          expect(short_link.params).to eq({})
        end

        context "and a route name" do
          let(:route_name) { target_route_name }

          it "maps the correct route name attribute to the short link" do
            expect(short_link.route_name).to eq(target_route_name.to_s)
          end

          it "generates the correct target URL" do
            expect(short_link.target_url).to eq(expected_resource_url)
          end
        end

        context "and parameters" do
          let(:params) { { foo: "bar", baz: "biz" } }

          it "maps the correct params attribute to the short link" do
            expect(short_link.params).to eq("baz" => "biz", "foo" => "bar")
          end
        end
      end

      context "with a component" do
        let(:mounted_engine_name) { :decidim_participatory_process_dummy }
        let(:expected_target) { target.component }

        before do
          allow(helper).to receive(:current_component).and_return(target.component)
        end

        it_behaves_like "working short link", :dummy_resources do
          let(:expected_resource_url) { "#{organization_url}/processes/#{target.participatory_space.slug}/f/#{target.component.id}/dummy_resources" }
        end
      end

      context "with a participatory space" do
        let(:mounted_engine_name) { :decidim_participatory_processes }
        let(:expected_target) { target.participatory_space }

        before do
          allow(helper).to receive(:current_participatory_space).and_return(target.participatory_space)
        end

        it_behaves_like "working short link", :participatory_process do
          let(:expected_resource_url) { "#{organization_url}/processes/#{target.participatory_space.slug}" }
        end
      end

      context "with an organization" do
        let(:organization) { create(:organization) }
        let(:target) { organization }
        let(:expected_target) { organization }

        before do
          allow(helper).to receive(:current_organization).and_return(target)
        end

        it_behaves_like "working short link", :pages do
          let(:expected_resource_url) { "#{organization_url}/pages" }
        end
      end
    end
  end
end
