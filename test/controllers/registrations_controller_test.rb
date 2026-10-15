require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "GET /signup renders the form" do
    get signup_path
    assert_response :success
  end

  test "GET /signup redirects to root if already logged in" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get signup_path
    assert_redirected_to root_path
  end

  test "POST /signup creates a pending user and logs them in" do
    assert_difference "User.count", 1 do
      post signup_path, params: { user: { name: "New Person", email: "newperson@example.com", password: "password" } }
    end

    user = User.find_by(email: "newperson@example.com")
    assert user.pending?
    assert_redirected_to root_path

    follow_redirect!
    assert_match "wait for an admin", response.body
  end

  test "POST /signup with a duplicate email re-renders the form" do
    assert_no_difference "User.count" do
      post signup_path, params: { user: { name: "Dupe", email: users(:caseworker).email, password: "password" } }
    end

    assert_response :unprocessable_entity
  end

  test "POST /signup without a password re-renders the form" do
    assert_no_difference "User.count" do
      post signup_path, params: { user: { name: "No Password", email: "nopass@example.com", password: "" } }
    end

    assert_response :unprocessable_entity
  end
end
