from pathlib import Path
import pandas as pd

from misc import database_as_json


def main():
    save_folder = Path(__file__).parent / "export"
    db = database_as_json(
        certificate_path=Path(__file__).parent / "monstageenimages-firebase-adminsdk-1owio-26b3311e20.json",
        save_folder=save_folder,
        force_download=False,
        download_storage=True,
    )

    teachers = pd.DataFrame([user for user in db["users"] if isinstance(user, dict) and user["userType"] == 1])
    students = pd.DataFrame([user for user in db["users"] if isinstance(user, dict) and user["userType"] == 2])

    title_timestamp = "Timestamp"
    title_id_student = "Id élève"
    title_id_teacher = "Id enseignant\u00b7e"
    title_first_name_teacher = "Prénom enseignant\u00b7e"
    title_last_name_teacher = "Nom enseignant\u00b7e"
    title_id_question = "Id question"
    title_metier = "MÉTIER"
    title_id_answer = "Id réponse"
    title_content_type = "Question/Répondant"
    title_content_text = "Text"

    output = pd.DataFrame(
        columns=[
            title_timestamp,
            title_id_student,
            title_id_teacher,
            title_first_name_teacher,
            title_last_name_teacher,
            title_id_question,
            title_metier,
            title_id_answer,
            title_content_type,
            title_content_text,
        ]
    )
    for student_id in students["id"]:
        teacher_id = students[students["id"] == student_id]["supervisedBy"].values[0]
        teacher_first_name = teachers[teachers["id"] == teacher_id]["firstName"].values[0]
        teacher_last_name = teachers[teachers["id"] == teacher_id]["lastName"].values[0]

        answer_ids = db["answers"][student_id]
        for question_id in answer_ids:
            if question_id == "id" or question_id not in db["questions"].loc[teacher_id]:
                continue

            question = db["questions"].loc[teacher_id][question_id]
            metier = "MÉTIER"[question["section"]]
            output.loc[len(output)] = [
                "",
                student_id,
                teacher_id,
                teacher_first_name,
                teacher_last_name,
                question_id,
                metier,
                "",
                "Question",
                question["text"],
            ]

            if "discussion" not in answer_ids[question_id]:
                continue

            for discussion_id in answer_ids[question_id]["discussion"]:
                tp = answer_ids[question_id]["discussion"][discussion_id]
                time_stamp = pd.to_datetime(tp["creationTimeStamp"], unit="us").strftime("%Y-%m-%d %H:%M:%S")
                author = "student" if tp["creatorId"] == student_id else "teacher"
                content = tp["text"]

                output.loc[len(output)] = [
                    time_stamp,
                    student_id,
                    teacher_id,
                    teacher_first_name,
                    teacher_last_name,
                    question_id,
                    metier,
                    discussion_id,
                    author,
                    content,
                ]

    # Sort and save the output
    output = output.sort_values(
        by=[title_last_name_teacher, title_first_name_teacher, title_id_student, title_id_question, title_timestamp]
    )
    output.to_excel(save_folder / "output.xlsx", index=False)


if __name__ == "__main__":
    main()
