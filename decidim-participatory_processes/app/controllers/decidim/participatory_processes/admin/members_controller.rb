# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process members
      class MembersController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::ParticipatorySpace::Concerns::HasMembers
      end
    end
  end
end
