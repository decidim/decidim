# frozen_string_literal: true
require "zip"

module Decidim
  # The controller to handle the user's download_my_data page.
  class DataPortabilityController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      enforce_permission_to :show, :user, current_user: current_user

      @account = form(AccountForm).from_model(current_user)
    end

    def export
      enforce_permission_to :export, :user, current_user: current_user
      name = current_user.name

      # DataPortabilityExportJob.perform_later(current_user, name, export_format)
      # flash[:notice] = t("decidim.admin.exports.notice")
      #
      # redirect_back(fallback_location: data_portability_path)

      # objects = ActiveRecord::Base.descendants.select{|c| c.included_modules.include?(Decidim::DataPortability)}

      objects = [
                  Decidim::Budgets::Order,
                  Decidim::Messaging::Conversation,
                  Decidim::User,
                  Decidim::UserGroup,
                  Decidim::Meetings::Registration,
                  Decidim::Comments::Comment,
                  Decidim::Proposals::Proposal,
                  Decidim::Proposals::ProposalVote,
                  Decidim::Proposals::ProposalEndorsement,
                  Decidim::Debates::Debate,
                  Decidim::Follow,
                  Decidim::Report,
                  Decidim::Notification,
                  Decidim::Identity,
                ]

      #Temporary#
      format = export_format
      user = current_user

      export_data = []
      objects.each do |object|
        export_data << [ object.model_name.name.parameterize.pluralize, Decidim::Exporters.find_exporter(format).new(object.user_collection(user), object.export_serializer).export ]
      end

      compressed_filestream = Zip::OutputStream.write_buffer do |zos|
        export_data.each do |element|
          filename = element.last.filename(element.first.parameterize)
          zos.put_next_entry(filename)
          if element.last.read.presence
            zos.write element.last.read
          else
            zos.write "No data"
          end
        end
      end
      compressed_filestream.rewind
      send_data compressed_filestream.read, filename: "exported.zip"

    end


    private

    def export_format
      "CSV"
    end
  end
end
