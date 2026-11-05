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

    date =
      if params[:diary_month].blank?
        @diaries.maximum(:date)
      else
        parse_diary_month(params[:diary_month])
      end

    @diaries =
      @diaries.where(date: date.all_month).includes(
        diary_entries: {
          diary_attachments: { file_attachment: :blob }
        }
      )

  rescue Date::Error
    render plain: "年月の指定が不正です。", status: :bad_request
  end

  private

  def parse_diary_month(diary_month)
    unless diary_month.is_a?(String) && diary_month.match?(/\A[0-9]{4}-[0-9]{2}\z/)
      raise Date::Error, "invalid month format"
    end

    Date.strptime(diary_month, "%Y-%m")
  end
end
