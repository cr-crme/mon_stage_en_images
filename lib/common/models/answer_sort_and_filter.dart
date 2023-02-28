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
    this.sorting = AnswerSorting.byStudent,
    this.filled = AnswerFilledFilter.withAtLeastOneAnswer,
    List<AnswerFromWhomFilter>? fromWhomFilter,
    List<AnswerContentFilter>? contentFilter,
  })  : fromWhomFilter = fromWhomFilter ??
            [
              AnswerFromWhomFilter.teacherOnly,
              AnswerFromWhomFilter.studentOnly
            ],
        contentFilter = contentFilter ??
            [AnswerContentFilter.textOnly, AnswerContentFilter.photoOnly];

  AnswerSorting sorting;
  AnswerFilledFilter filled;
  List<AnswerFromWhomFilter> fromWhomFilter;
  List<AnswerContentFilter> contentFilter;
}
