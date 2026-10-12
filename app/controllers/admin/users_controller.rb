class Admin::UsersController < Admin::BaseController
  def index
    @pending_users, @approved_users = User.order(:name).partition { |user| !user.approved? }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.approved = true
    if @user.save
      redirect_to admin_users_path, notice: "User added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    user = User.find(params[:id])
    user.update!(approved: true)
    redirect_to admin_users_path, notice: "#{user.name} approved."
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
  end
end
