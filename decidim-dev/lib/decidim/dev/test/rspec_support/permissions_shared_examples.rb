# frozen_string_literal: true

shared_examples "permission is not set" do
  it "raises an error" do
    expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
  end
end

shared_examples "delegates permissions to" do |delegated_class|
  it "the #{delegated_class.name} permissions class" do
    delegated_permissions = instance_double(delegated_class, permissions: :foo)
    delegated_permission_action = instance_double(Decidim::PermissionAction, allowed?: true)

    allow(delegated_class)
      .to receive(:new)
      .with(user, permission_action, context)
      .and_return delegated_permissions

    expect(delegated_permissions)
      .to receive(:permissions)
      .and_return(delegated_permission_action)

    subject
  end
end
