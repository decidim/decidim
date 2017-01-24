# frozen_string_literal: true
module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage meetings from a Participatory Process
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::Attachable

        def after_destroy_path
          meetings_path
        end

        def attachable
          meeting
        end
      end
    end
  end
end

