# == Schema Information
#
# Table name: contributions
#
#  id             :integer          not null, primary key
#  score          :integer
#  money_received :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  project_id     :integer
#


require 'test_helper'

class ContributionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
