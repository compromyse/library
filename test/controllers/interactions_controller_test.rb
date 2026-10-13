require "test_helper"

class InteractionsControllerTest < ActionDispatch::IntegrationTest
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
end
