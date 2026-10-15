require "test_helper"

class InteractionsControllerTest < ActionDispatch::IntegrationTest
  def interaction_with_issue(primary_need: :housing, other_detail: nil)
    Interaction.create!(age: :twenties, gender: :female, estimated_time: :ten_minutes,
      issues_attributes: [ { primary_need: primary_need, primary_need_other_detail: other_detail,
        interaction_description: "Needed help" } ])
  end

  test "GET /interactions/:id requires authentication" do
    get interaction_path(interaction_with_issue)
    assert_redirected_to login_path
  end

  test "GET /interactions/:id renders the issue details inside the matching turbo frame" do
    interaction = interaction_with_issue(primary_need: :other, other_detail: "Needs a ride")
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    get interaction_path(interaction)

    assert_response :success
    assert_select "turbo-frame#details_interaction_#{interaction.id}" do
      assert_select "p", text: "Other"
      assert_select "p", text: "Needs a ride"
      assert_select "p", text: "Needed help"
    end
  end

  test "GET /interactions/new requires authentication" do
    get new_interaction_path
    assert_redirected_to login_path
  end

  test "unapproved user sees the pending-approval page instead of the form" do
    post login_path, params: { email: users(:pending).email, password: "password" }
    get new_interaction_path
    assert_match "wait for an admin", response.body
  end

  test "GET /interactions/new renders the form for an approved user" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get new_interaction_path
    assert_response :success
  end

  test "POST /interactions with valid params creates an interaction and its issues" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    assert_difference [ "Interaction.count", "Issue.count" ], 1 do
      post interactions_path, params: {
        interaction: {
          age: "twenties",
          gender: "female",
          estimated_time: "ten_minutes",
          issues_attributes: {
            "0" => { primary_need: "food", interaction_description: "Needed groceries" }
          }
        }
      }
    end

    assert_redirected_to root_path
  end

  test "POST /interactions with an other primary_need requires a detail" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    assert_no_difference "Interaction.count" do
      post interactions_path, params: {
        interaction: {
          age: "twenties",
          gender: "female",
          estimated_time: "ten_minutes",
          issues_attributes: {
            "0" => { primary_need: "other", interaction_description: "Something else" }
          }
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST /interactions with invalid params re-renders the form" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    assert_no_difference "Interaction.count" do
      post interactions_path, params: { interaction: { age: "", gender: "", estimated_time: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "GET /interactions/:id/edit requires authentication" do
    get edit_interaction_path(interaction_with_issue)
    assert_redirected_to login_path
  end

  test "GET /interactions/:id/edit renders the form pre-filled with the existing issue" do
    interaction = interaction_with_issue(primary_need: :food)
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    get edit_interaction_path(interaction)

    assert_response :success
    assert_select "textarea", text: "Needed help"
  end

  test "PATCH /interactions/:id updates the interaction's own fields" do
    interaction = interaction_with_issue
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    patch interaction_path(interaction), params: {
      interaction: {
        age: "thirties", gender: "male", estimated_time: "twenty_minutes",
        issues_attributes: {
          "0" => { id: interaction.issues.first.id, primary_need: "food", interaction_description: "Needed help" }
        }
      }
    }

    assert_redirected_to root_path
    interaction.reload
    assert interaction.thirties?
    assert interaction.male?
    assert interaction.twenty_minutes?
  end

  test "PATCH /interactions/:id can edit an existing issue in place" do
    interaction = interaction_with_issue(primary_need: :housing)
    issue = interaction.issues.first
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    patch interaction_path(interaction), params: {
      interaction: {
        age: "twenties", gender: "female", estimated_time: "ten_minutes",
        issues_attributes: {
          "0" => { id: issue.id, primary_need: "medical", interaction_description: "Needed a checkup" }
        }
      }
    }

    assert_redirected_to root_path
    assert_equal 1, interaction.issues.count
    issue.reload
    assert issue.medical?
    assert_equal "Needed a checkup", issue.interaction_description
  end

  test "PATCH /interactions/:id destroys an issue flagged with _destroy, leaving the other intact" do
    interaction = interaction_with_issue(primary_need: :housing)
    interaction.issues.create!(primary_need: :food, interaction_description: "Second issue")
    keep, drop = interaction.issues.order(:id)
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    assert_difference "Issue.count", -1 do
      patch interaction_path(interaction), params: {
        interaction: {
          age: "twenties", gender: "female", estimated_time: "ten_minutes",
          issues_attributes: {
            "0" => { id: keep.id, primary_need: "housing", interaction_description: "Needed help" },
            "1" => { id: drop.id, primary_need: "food", interaction_description: "Second issue", _destroy: "1" }
          }
        }
      }
    end

    assert_redirected_to root_path
    assert Issue.exists?(keep.id)
    assert_not Issue.exists?(drop.id)
  end

  test "PATCH /interactions/:id with invalid params re-renders the edit form" do
    interaction = interaction_with_issue
    post login_path, params: { email: users(:caseworker).email, password: "password" }

    patch interaction_path(interaction), params: { interaction: { age: "" } }

    assert_response :unprocessable_entity
  end
end
