# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages meetings attachments", type: :feature do
  let(:user) { process_admin }

  include_context "admin"

  it_behaves_like "manage meetings attachments"
end
