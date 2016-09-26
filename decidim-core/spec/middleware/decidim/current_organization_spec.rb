require "spec_helper"

module Decidim
  describe CurrentOrganization do
    let(:app) { ->(env) { [200, env, "app"] } }
    let(:env) { Rack::MockRequest.env_for("https://#{host}", {}) }
    let(:host) { "city.domain.org" }
    let(:middleware) { described_class.new(app) }

    context "when an organization exists for the current host" do
      let!(:organization) { create(:organization, host: host) }

      it "sets the organization" do
        _code, new_env = middleware.call(env)

        expect(new_env["decidim.current_organization"]).to eq(organization)
      end
    end

    context "when no orgazanization exists for the current host" do
      let!(:organization) { create(:organization, host: 'fake.host.com') }

      it "doesn't set the organization" do
        _code, new_env = middleware.call(env)

        expect(new_env["decidim.current_organization"]).to be_nil
      end
    end
  end
end
