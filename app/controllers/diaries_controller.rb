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

    date = if params[:diary_month].blank?
      @diaries.maximum(:date)
    else
      Date.strptime(params[:diary_month], "%Y-%m")
    end

    @diaries = @diaries.where(date: date.all_month).includes(
      diary_entries: {
        diary_attachments: { file_attachment: :blob }
      }
    )
  end
end
