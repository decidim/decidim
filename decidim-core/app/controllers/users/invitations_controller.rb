# frozen_string_literal: true
#
# We're overriding the default behavior because we want admins to
# go to their organization dashboard when invited.
#
class Users::InvitationsController < Devise::InvitationsController
  private

  def after_accept_path_for
    return super unless resource.admin?
    after_sign_in_path_for(resource)
  end
end
