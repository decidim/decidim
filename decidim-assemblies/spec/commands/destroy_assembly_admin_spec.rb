# frozen_string_literal: true

require "spec_helper"

describe "Decidim::Admin::ParticipatorySpace::DestroyAdmin", versioning: true do
  subject { Decidim::Admin::ParticipatorySpace::DestroyAdmin.new(role, current_user) }

  let(:my_process) { create(:assembly) }
  let(:role) { create(:assembly_user_role, user:, assembly: my_process, role: :admin) }

  include_examples "destroys participatory space role"
end
