class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_authentication
  before_action :require_approval

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_authentication
    redirect_to login_path unless current_user
  end

  def require_approval
    return unless current_user
    return if current_user.approved?
    render "shared/pending_approval"
  end

  def require_admin
    render plain: "Access denied", status: :forbidden unless current_user&.admin?
  end
end
