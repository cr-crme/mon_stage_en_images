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
    List<AnswerFromWhomFilter>? fromWhomFilter,
    this.contentFilter = AnswerContentFilter.textAndPhotos,
  }) : fromWhomFilter = fromWhomFilter ??
            [
              AnswerFromWhomFilter.teacherOnly,
              AnswerFromWhomFilter.studentOnly
            ];

  AnswerSorting sorting;
  AnswerFilledFilter filled;
  List<AnswerFromWhomFilter> fromWhomFilter;
  AnswerContentFilter contentFilter;
}
