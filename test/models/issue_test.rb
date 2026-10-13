require "test_helper"

class IssueTest < ActiveSupport::TestCase
  def interaction
    @interaction ||= Interaction.create!(age: :twenties, gender: :female, estimated_time: :ten_minutes,
      issues_attributes: [ { primary_need: :food, interaction_description: "placeholder" } ])
  end

  test "valid with a primary_need and description" do
    issue = Issue.new(interaction: interaction, primary_need: :housing, interaction_description: "Needs housing")
    assert issue.valid?
  end

  test "invalid without interaction_description" do
    issue = Issue.new(interaction: interaction, primary_need: :housing, interaction_description: nil)
    assert_not issue.valid?
  end

  test "invalid without primary_need" do
    issue = Issue.new(interaction: interaction, primary_need: nil, interaction_description: "Needs housing")
    assert_not issue.valid?
  end

  test "requires primary_need_other_detail when primary_need is other" do
    issue = Issue.new(interaction: interaction, primary_need: :other, interaction_description: "Something else")
    assert_not issue.valid?
    assert_includes issue.errors[:primary_need_other_detail], "can't be blank"
  end

  test "does not require primary_need_other_detail when primary_need is not other" do
    issue = Issue.new(interaction: interaction, primary_need: :housing, interaction_description: "Needs housing")
    assert issue.valid?
  end

  test "valid when primary_need is other and other_detail is present" do
    issue = Issue.new(interaction: interaction, primary_need: :other, interaction_description: "Something else",
      primary_need_other_detail: "Needs a ride to the clinic")
    assert issue.valid?
  end
end
