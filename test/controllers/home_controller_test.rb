require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  def create_interaction(created_at: Time.current)
    interaction = Interaction.create!(age: :twenties, gender: :female, estimated_time: :ten_minutes,
      issues_attributes: [ { primary_need: :food, interaction_description: "placeholder" } ])
    interaction.update_column(:created_at, created_at)
    interaction
  end

  test "GET / requires authentication" do
    get root_path
    assert_redirected_to login_path
  end

  test "unapproved user sees the pending-approval page" do
    post login_path, params: { email: users(:pending).email, password: "password" }
    get root_path
    assert_match "wait for an admin", response.body
  end

  test "shows a message when no interactions were logged today" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path
    assert_match "No interactions logged today.", response.body
  end

  test "lists an interaction logged today but not one logged yesterday" do
    create_interaction(created_at: Time.current)
    create_interaction(created_at: 1.day.ago)

    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path

    assert_select "tbody tr", count: 1
  end

  test "shows at most 5 rows without hiding the rest, plus a show-all button with the total count" do
    7.times { create_interaction }

    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path

    assert_select "tbody tr", count: 7
    assert_select "tbody tr.hidden", count: 2
    assert_select "button[data-expandable-target='button']", text: "Show all (7)"
  end

  test "does not show a show-all button for 5 or fewer interactions" do
    5.times { create_interaction }

    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path

    assert_select "button[data-expandable-target='button']", count: 0
  end
end
