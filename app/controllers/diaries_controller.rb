class DiariesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @diaries =
      if @user == current_user
        @user.diaries
      elsif current_user
        @user.diaries.where(visibility: %w[members_only everyone])
      else
        @user.diaries.where(visibility: "everyone")
      end

    return if @diaries.empty?

    if params[:diary_month].blank?
      date = @diaries.maximum(:date)
      @diaries = @diaries.where(date: date.all_month)
    end

    @diaries = @diaries.includes(
      diary_entries: {
        diary_attachments: { file_attachment: :blob }
      }
    )
  end
end
