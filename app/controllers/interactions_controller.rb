class InteractionsController < ApplicationController
  layout false, only: :show

  def show
    @interaction = Interaction.includes(:issues).find(params[:id])
  end

  def new
    @interaction = Interaction.new
    @interaction.issues.build
  end

  def create
    @interaction = Interaction.new(interaction_params)
    if @interaction.save
      redirect_to root_path, notice: "Interaction logged."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @interaction = Interaction.includes(:issues).find(params[:id])
  end

  def update
    @interaction = Interaction.find(params[:id])
    if @interaction.update(interaction_params)
      redirect_to root_path, notice: "Interaction updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def interaction_params
    params.require(:interaction).permit(
      :age, :gender, :estimated_time,
      issues_attributes: [ :id, :primary_need, :primary_need_other_detail, :interaction_description, :_destroy ]
    )
  end
end
