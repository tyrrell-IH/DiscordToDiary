class DiaryEntriesController < ApplicationController
  def edit
    set_entry_and_user

    raise ActiveRecord::RecordNotFound unless current_user == @user
  end

  def update
    set_entry_and_user

    raise ActiveRecord::RecordNotFound unless current_user == @user

    ids = remove_attachment_ids

    DiaryEntry.transaction do
      @entry.update!(diary_entry_params)

      @entry.diary_attachments.where(id: ids).each do |attachment|
        attachment.destroy!
      end
    end

    redirect_to diary_path(@entry.diary), status: :see_other

  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  private

  def diary_entry_params
    params.require(:diary_entry).permit(:content)
  end

  def remove_attachment_ids
    params.permit(remove_attachment_ids: [])
          .fetch(:remove_attachment_ids, [])
  end

  def set_entry_and_user
    @entry = DiaryEntry.find(params[:id])
    @user = @entry.diary.user
  end
end
