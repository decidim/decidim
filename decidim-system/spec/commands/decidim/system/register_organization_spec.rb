# frozen_string_literal: true
require "spec_helper"

describe Decidim::System::RegisterOrganization, :db do
  describe 'call' do
    let(:form) do
      Decidim::System::OrganizationForm.new(params)
    end

    let(:command) { described_class.new(form) }

    context 'when the form is valid' do
      let(:params) do
        {
          name: 'Gotham City',
          host: 'decide.gotham.gov',
          organization_admin_email: 'f.laguardia@gotham.gov'
        }
      end

      it 'returns a valid response' do
        expect { command.call }.to broadcast(:ok)
      end

      it 'creates a new organization' do
        expect { command.call }.to change { Decidim::Organization.count }.by(1)
        organization = Decidim::Organization.last

        expect(organization.name).to eq('Gotham City')
        expect(organization.host).to eq('decide.gotham.gov')
      end

      it 'invites a user as organization admin' do
        expect { command.call }.to change { Decidim::User.count }.by(1)
        admin = Decidim::User.last

        expect(admin.email).to eq('f.laguardia@gotham.gov')
        expect(admin.organization.name).to eq('Gotham City')
        expect(admin).to be_admin
        expect(admin).to be_created_by_invite
      end
    end

    context 'when the form is invalid' do
      let(:params) do
        {
          name: nil,
          host: 'foo.com'
        }
      end

      it 'returns an invalid response' do
        expect { command.call }.to broadcast(:invalid)
      end
    end
  end
end
