require 'rails_helper'

RSpec.describe DbSweeper do
  describe '#call' do
    context 'when there is user data over 28 days old' do
      before :each do
        create(:user_data, created_at: 30.days.ago)
        create(:user_data, created_at: 5.days.ago)
      end

      it 'destroys the older records' do
        expect do
          subject.call
        end.to change(UserData, :count).by(-1)
      end
    end

    context 'when there is no user data over 28 days old' do
      before :each do
        create(:user_data, created_at: 5.days.ago)
      end

      it 'leaves records intact' do
        expect do
          subject.call
        end.to_not change(UserData, :count)
      end
    end
  end
end
