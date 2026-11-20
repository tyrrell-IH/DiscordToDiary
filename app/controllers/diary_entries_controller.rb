class DiaryEntriesController < ApplicationController
  def edit
    set_entry_and_user

    raise ActiveRecord::RecordNotFound unless current_user == @user
  end

  def update
    set_entry_and_user

    raise ActiveRecord::RecordNotFound unless current_user == @user

    if @entry.update(diary_entry_params)
      redirect_to diary_path(@entry.diary), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def diary_entry_params
    params.require(:diary_entry).permit(:content)
  end

  def set_entry_and_user
    @entry = DiaryEntry.find(params[:id])
    @user = @entry.diary.user
  end
end
