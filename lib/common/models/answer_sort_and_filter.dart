enum AnswerSorting {
  byDate,
  byStudent,
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
    this.fromWhomFilter = AnswerFromWhomFilter.teacherAndStudent,
    this.contentFilter = AnswerContentFilter.textAndPhotos,
  });

  AnswerSorting sorting;
  AnswerFromWhomFilter fromWhomFilter;
  AnswerContentFilter contentFilter;
}
