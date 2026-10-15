require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "GET /admin/users requires admin" do
    post login_path, params: { email: users(:caseworker).email, password: "password" }
    get admin_users_path
    assert_response :forbidden
  end

  test "GET /admin/users lists users regardless of status" do
    post login_path, params: { email: users(:admin).email, password: "password" }
    get admin_users_path

    assert_response :success
    assert_match users(:pending).name, response.body
    assert_match users(:caseworker).name, response.body
    assert_match users(:denied).name, response.body
  end

  test "GET /admin/users?q= filters by name or email" do
    post login_path, params: { email: users(:admin).email, password: "password" }
    get admin_users_path, params: { q: users(:pending).name }

    assert_response :success
    assert_match users(:pending).name, response.body
    assert_no_match users(:caseworker).name, response.body
  end

  test "GET /admin/users paginates" do
    25.times { |i| User.create!(name: "Bulk User #{i}", email: "bulk#{i}@example.com", password: "password") }
    post login_path, params: { email: users(:admin).email, password: "password" }

    get admin_users_path
    assert_select ".px-6.py-5", count: 20

    get admin_users_path, params: { page: 2 }
    assert_select ".px-6.py-5", count: 9
  end

  test "POST /admin/users creates an already-approved user" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    assert_difference "User.count", 1 do
      post admin_users_path, params: {
        user: { name: "New Caseworker", email: "newcw@example.com", password: "password", password_confirmation: "password" }
      }
    end

    assert User.find_by(email: "newcw@example.com").approved?
  end

  test "PATCH /admin/users/:id/approve approves a pending user" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch approve_admin_user_path(users(:pending))

    assert_redirected_to admin_users_path
    assert users(:pending).reload.approved?
  end

  test "PATCH /admin/users/:id/deny denies a pending user" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch deny_admin_user_path(users(:pending))

    assert_redirected_to admin_users_path
    assert users(:pending).reload.denied?
  end

  test "PATCH /admin/users/:id/approve can reverse a denial" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch approve_admin_user_path(users(:denied))

    assert users(:denied).reload.approved?
  end

  test "PATCH /admin/users/:id/unapprove reverts an approved user to pending" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch unapprove_admin_user_path(users(:caseworker))

    assert_redirected_to admin_users_path
    assert users(:caseworker).reload.pending?
  end

  test "PATCH /admin/users/:id/unapprove on an admin (even yourself) is rejected" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch unapprove_admin_user_path(users(:admin))

    assert_redirected_to admin_users_path
    assert users(:admin).reload.approved?
  end

  test "PATCH /admin/users/:id/deny on an admin (even yourself) is rejected" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch deny_admin_user_path(users(:admin))

    assert_redirected_to admin_users_path
    assert users(:admin).reload.approved?
  end

  test "PATCH /admin/users/:id/deny on another admin is rejected" do
    other_admin = User.create!(name: "Other Admin", email: "otheradmin@example.com", password: "password",
      admin: true, status: :approved)
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch deny_admin_user_path(other_admin)

    assert_redirected_to admin_users_path
    assert other_admin.reload.approved?
  end

  test "PATCH /admin/users/:id/approve on a pending admin is rejected" do
    pending_admin = User.create!(name: "Pending Admin", email: "pendingadmin@example.com", password: "password",
      admin: true, status: :pending)
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch approve_admin_user_path(pending_admin)

    assert_redirected_to admin_users_path
    assert pending_admin.reload.pending?
  end

  test "GET /admin/users/:id/edit renders the form pre-filled" do
    post login_path, params: { email: users(:admin).email, password: "password" }

    get edit_admin_user_path(users(:caseworker))

    assert_response :success
    assert_select "input[value=?]", users(:caseworker).name
  end

  test "PATCH /admin/users/:id updates name and email without touching the password" do
    user = users(:caseworker)
    original_digest = user.password_digest
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch admin_user_path(user), params: { user: { name: "Renamed", email: user.email, password: "" } }

    assert_redirected_to admin_users_path
    user.reload
    assert_equal "Renamed", user.name
    assert_equal original_digest, user.password_digest
  end

  test "PATCH /admin/users/:id can set a new password" do
    user = users(:caseworker)
    post login_path, params: { email: users(:admin).email, password: "password" }

    patch admin_user_path(user), params: { user: { name: user.name, email: user.email, password: "newpassword" } }

    user.reload
    assert user.authenticate("newpassword")
  end
end
