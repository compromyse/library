class InteractionsController < ApplicationController
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

  private

  def interaction_params
    params.require(:interaction).permit(
      :age, :gender, :estimated_time,
      issues_attributes: [ :primary_need, :primary_need_other_detail, :interaction_description ]
    )
  end
end
