class DiariesController < ApplicationController
  def index
    @diaries = Diary.order(date: :asc).includes(
      diary_entries: {
        diary_attachments: { file_attachment: :blob }
      }
    )
  end
end
