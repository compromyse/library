require "test_helper"

class InteractionTest < ActiveSupport::TestCase
  def valid_interaction
    Interaction.new(age: :twenties, gender: :female, estimated_time: :ten_minutes).tap do |i|
      i.issues.build(primary_need: :food, interaction_description: "Needed groceries")
    end
  end

  test "valid with age, gender, estimated_time, and at least one issue" do
    assert valid_interaction.valid?
  end

  test "invalid without age" do
    interaction = valid_interaction
    interaction.age = nil
    assert_not interaction.valid?
  end

  test "invalid without gender" do
    interaction = valid_interaction
    interaction.gender = nil
    assert_not interaction.valid?
  end

  test "invalid without estimated_time" do
    interaction = valid_interaction
    interaction.estimated_time = nil
    assert_not interaction.valid?
  end

  test "invalid without any issues" do
    interaction = Interaction.new(age: :twenties, gender: :female, estimated_time: :ten_minutes)
    assert_not interaction.valid?
  end

  test "destroying an interaction destroys its issues" do
    interaction = valid_interaction
    interaction.save!
    issue = interaction.issues.first
    interaction.destroy
    assert_raises(ActiveRecord::RecordNotFound) { issue.reload }
  end
end
