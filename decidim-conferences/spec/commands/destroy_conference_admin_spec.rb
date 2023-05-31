# frozen_string_literal: true

require "spec_helper"

describe "Decidim::Admin::ParticipatorySpace::DestroyAdmin", versioning: true do
  subject { Decidim::Admin::ParticipatorySpace::DestroyAdmin.new(role, current_user) }

  let(:my_process) { create(:conference) }
  let(:role) { create(:conference_user_role, user:, conference: my_process, role: :admin) }

  include_examples "destroys participatory space role"
end
