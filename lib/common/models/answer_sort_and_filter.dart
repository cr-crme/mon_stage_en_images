enum AnswerSorting {
  byDate,
  byStudent,
}

enum AnswerFilledFilter {
  all,
  withAtLeastOneAnswer,
}

enum AnswerFromWhomFilter {
  studentOnly,
  teacherOnly,
  teacherAndStudent,
}

enum AnswerContentFilter {
  textOnly,
  photoOnly,
  textAndPhotos,
}

class AnswerSortAndFilter {
  AnswerSortAndFilter({
    this.sorting = AnswerSorting.byDate,
    this.filled = AnswerFilledFilter.withAtLeastOneAnswer,
    this.fromWhomFilter = AnswerFromWhomFilter.teacherAndStudent,
    this.contentFilter = AnswerContentFilter.textAndPhotos,
  });

  AnswerSorting sorting;
  AnswerFilledFilter filled;
  AnswerFromWhomFilter fromWhomFilter;
  AnswerContentFilter contentFilter;
}
