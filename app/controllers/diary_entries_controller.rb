class DiaryEntriesController < ApplicationController
  def edit
    @entry = DiaryEntry.find(params[:id])
    @user = @entry.diary.user

    raise ActiveRecord::RecordNotFound unless current_user == @user
  end

  def update
    entry = DiaryEntry.find(params[:id])

    if entry.update(diary_entry_params)
      redirect_to diary_path(entry.diary), status: :see_other
    end
  end

  private

  def diary_entry_params
    params.require(:diary_entry).permit(:content)
  end
end
