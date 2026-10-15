class HomeController < ApplicationController
  def index
    @todays_interactions = Interaction.where(created_at: Time.current.all_day)
      .order(created_at: :desc)
  end
end
