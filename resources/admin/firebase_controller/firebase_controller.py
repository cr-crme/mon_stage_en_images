import json
from functools import cached_property
import os
from pathlib import Path
from typing import Any

import firebase_admin
from firebase_admin import db, storage, auth
import pandas

_app_version = "1.2.2"
_database_version = "v0_1_0"


class FirebaseController:
    def __init__(
        self, certificate_path: Path, temporary_folder: Path, force_refresh: bool = False, use_emulator: bool = True
    ):

        if use_emulator:
            os.environ["FIREBASE_DATABASE_EMULATOR_HOST"] = "localhost:9000"
            os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = "localhost:9099"
            os.environ["STORAGE_EMULATOR_HOST"] = "http://localhost:9199"

        self._certificate_path = certificate_path
        self._database_url = "https://monstageenimages-default-rtdb.firebaseio.com"
        self._bucket_url = "monstageenimages.appspot.com"

        self._temporary_folder = temporary_folder
        self._temporary_database_filepath = self._temporary_folder / "firebase_export.json"
        self._temporary_bucket_folder = self._temporary_folder / "storage"

        self._initialize_database()
        self._database: pandas.DataFrame = None
        if force_refresh or use_emulator:
            self.to_pandas(force_download=True)

    def user(self, user_id: str) -> dict | None:
        if user_id not in self._users:
            return None
        return self._users[user_id]

    def set_required_app_version(self) -> None:
        db.reference("appInfo").child("requiredVersion").set(_app_version)

    def set_user(self, user: dict) -> None:
        db.reference(f"/{_database_version}").child("users").child(user["id"]).set(user)

    def delete_user(self, user_id: str) -> None:
        # Remove the questions this user has registered
        db.reference(f"/{_database_version}").child("questions").child(user_id).delete()

        # Remove the answers provided by the user
        for token in self.teaching_tokens:
            # Remove the answers associated with that token
            db.reference(f"/{_database_version}").child("answers").child(token).child(user_id).delete()

            # Remove all the storage files associated with that token
            for blob in storage.bucket().list_blobs(prefix=user_id + "/"):
                blob.delete()

            # Fix the tokens
            if self.teacher_id(teaching_token=token) == user_id:
                # If we are the teacher disconnect all the students
                for student_id in self.student_ids(teaching_token=token):
                    db.reference(f"/{_database_version}").child("users").child(student_id).child("tokens").child(
                        "connected"
                    ).child(token).delete()
                    db.reference(f"/{_database_version}").child("users").child(student_id).child("tokens").child(
                        "userWithExtendedPermissions"
                    ).child(user_id).delete()
                db.reference(f"/{_database_version}").child("tokens").child(token).delete()
                db.reference(f"/{_database_version}").child("tokens").child("existing").child(token).delete()
            else:
                # Disconnect from the token if we are connected
                db.reference(f"/{_database_version}").child("tokens").child(token).child("connectedUsers").child(
                    user_id
                ).delete()

        # Remove the user from the users list
        db.reference(f"/{_database_version}").child("users").child(user_id).delete()

        # Delete the user from Firebase Authentication
        try:
            auth.delete_user(user_id)
        except:
            pass

    @cached_property
    def authenticated_users(self) -> dict[str, str]:
        return {user.uid: user.email for user in auth.list_users().iterate_all()}

    @cached_property
    def teaching_tokens(self) -> tuple[str]:
        return tuple(
            token
            for token in self.database["tokens"].keys()
            if isinstance(self.database["tokens"][token], dict) and "metadata" in self.database["tokens"][token]
        )

    def teacher_id(self, teaching_token: str) -> str | None:
        try:
            return self.database["tokens"][teaching_token]["metadata"]["createdBy"]
        except KeyError:
            return None

    def student_ids(self, teaching_token: str) -> tuple[str]:
        try:
            return tuple(user_id for user_id in self.database["tokens"][teaching_token]["connectedUsers"].keys())
        except KeyError:
            return ()

    def answers(self, teaching_token: str, student_id: str) -> dict:
        try:
            return self.database["answers"][teaching_token][student_id]
        except KeyError:
            return {}

    def questions(self, teacher_id: str) -> dict:
        try:
            questions = self.database["questions"][teacher_id]
            return questions if isinstance(questions, dict) else {}
        except KeyError:
            return {}

    def question(self, teacher_id: str, question_id: str) -> dict | None:
        questions = self.questions(teacher_id=teacher_id)
        if question_id not in questions:
            return None
        return questions[question_id]

    @cached_property
    def _users(self) -> dict:
        return {user["id"]: user for user in self.database["users"] if isinstance(user, dict) and "firstName" in user}

    @property
    def database(self) -> pandas.DataFrame:
        if self._database is None:
            self.to_pandas()
        return self._database

    def to_pandas(self, force_download: bool = False) -> pandas.DataFrame:
        if self._database is not None and not force_download:
            return self._database

        if not self._temporary_database_filepath.exists() or force_download:
            print("Downloading the database...")
            # Fetch data
            data = self._full_database()

            # Save data to JSON file
            self._temporary_database_filepath.parent.mkdir(parents=True, exist_ok=True)
            with open(self._temporary_database_filepath, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
        else:
            print("Using the predownloaded database...")

        self._database = pandas.read_json(self._temporary_database_filepath)
        return self._database

    def download_storage(self, force_download: bool = False):
        if not self._temporary_bucket_folder.exists() or force_download:
            print("Downloading all the files, this may take a while...")

            # Download all files
            self._temporary_bucket_folder.mkdir(parents=True, exist_ok=True)
            for blob in storage.bucket().list_blobs():
                file_path: Path = self._temporary_bucket_folder / blob.name
                file_path.parent.mkdir(parents=True, exist_ok=True)
                blob.download_to_filename(str(file_path))

    def _full_database(self) -> Any:
        return db.reference(f"/{_database_version}").get()

    def _initialize_database(self):
        # Initialize Firebase Admin SDK
        cred = firebase_admin.credentials.Certificate(self._certificate_path)
        firebase_admin.initialize_app(
            cred,
            {"databaseURL": self._database_url, "storageBucket": self._bucket_url},
        )
