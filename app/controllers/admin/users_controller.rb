class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :edit, :update ]

  def index
    scope = User.order(:name)
    if params[:q].present?
      q = "%#{params[:q]}%"
      scope = scope.where("name ILIKE ? OR email ILIKE ?", q, q)
    end
    @pagy, @users = pagy(scope, limit: 20)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.status = :approved
    if @user.save
      redirect_to admin_users_path, notice: "User added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = user_params
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?
    if @user.update(attributes)
      redirect_to admin_users_path, notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    user = User.find(params[:id])
    return reject_status_change(user) if user.admin?
    user.update!(status: :approved)
    redirect_to admin_users_path, notice: "#{user.name} approved."
  end

  def deny
    user = User.find(params[:id])
    return reject_status_change(user) if user.admin?
    user.update!(status: :denied)
    redirect_to admin_users_path, notice: "#{user.name} denied."
  end

  def unapprove
    user = User.find(params[:id])
    return reject_status_change(user) if user.admin?
    user.update!(status: :pending)
    redirect_to admin_users_path, notice: "#{user.name} is pending approval again."
  end

  private

  def reject_status_change(user)
    redirect_to admin_users_path, alert: "Cannot change #{user.name}'s approval status -- they're an admin."
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
  end
end
