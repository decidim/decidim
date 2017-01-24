# frozen_string_literal: true
module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meetings from a Participatory Process
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::Attachable

        def attachable
          meeting
        end
      end
    end
  end
end

