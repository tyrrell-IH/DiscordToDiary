class DiariesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @diaries = viewable_diaries(@user.diaries)

    @diary_months = @diaries.pluck(:date)
                            .map(&:beginning_of_month)
                            .uniq
                            .sort
                            .reverse

    @diary_date =
      if params[:diary_month].blank?
        @diaries.maximum(:date)
      else
        parse_diary_month(params[:diary_month])
      end

    return if @diaries.empty?

    @diaries =
      @diaries.where(date: @diary_date.all_month).includes(
        diary_entries: {
          diary_attachments: { file_attachment: :blob }
        }
      )

  rescue Date::Error
    render plain: "年月の指定が不正です。", status: :bad_request
  end

  def show
    @diary = viewable_diaries(Diary.all).includes(
      diary_entries: {
        diary_attachments: { file_attachment: :blob }
      }
    ).find(params[:id])

    @user = @diary.user
  end

  private

  def parse_diary_month(diary_month)
    unless diary_month.is_a?(String) && diary_month.match?(/\A[0-9]{4}-[0-9]{2}\z/)
      raise Date::Error, "invalid month format"
    end

    Date.strptime(diary_month, "%Y-%m")
  end

  def viewable_diaries(diary_scope)
    if current_user
      diary_scope.where(user_id: current_user.id)
                 .or(diary_scope.where(visibility: %w[members_only everyone]))
    else
      diary_scope.where(visibility: "everyone")
    end
  end
end
