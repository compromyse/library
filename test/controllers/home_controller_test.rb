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
    today = create_interaction(created_at: Time.current)
    create_interaction(created_at: 1.day.ago)

    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path

    # one summary row plus its (collapsed) detail row
    assert_select "tbody tr", count: 2
    assert_select "tr[data-action='click->row-details#toggle']", count: 1
    assert_select "turbo-frame#details_interaction_#{today.id}[data-src]"
  end

  test "shows at most 5 rows without hiding the rest, plus a show-all button with the total count" do
    7.times { create_interaction }

    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path

    # each interaction renders a summary row and a (collapsed) detail row
    assert_select "tbody tr", count: 14
    assert_select "tr[data-action='click->row-details#toggle']", count: 7
    # 2 summary rows hidden until "show all", plus all 7 detail rows start collapsed
    assert_select "tbody tr.hidden", count: 9
    assert_select "button[data-expandable-target='button']", text: "Show all (7)"
  end

  test "does not show a show-all button for 5 or fewer interactions" do
    5.times { create_interaction }

    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get root_path

    assert_select "button[data-expandable-target='button']", count: 0
  end
end
