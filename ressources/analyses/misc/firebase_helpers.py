import json
from pathlib import Path

import firebase_admin
from firebase_admin import db, storage
import pandas


def database_as_json(
    certificate_path: str, save_folder: str, force_download: bool = False, download_storage: bool = True
) -> pandas.DataFrame:
    certificate_path: Path = Path(certificate_path)
    save_filepath: Path = Path(save_folder) / "firebase_export.json"

    if not save_filepath.exists() or force_download:
        # Initialize Firebase Admin SDK
        cred = firebase_admin.credentials.Certificate(certificate_path)
        firebase_admin.initialize_app(cred, {"databaseURL": "https://monstageenimages-default-rtdb.firebaseio.com"})

        # Reference to the database
        ref = db.reference("/")  # Root of the database

        # Fetch data
        data = ref.get()

        # Save data to JSON file
        save_filepath.parent.mkdir(parents=True, exist_ok=True)
        with open(save_filepath, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)

    if download_storage:
        _list_and_download_files(certificate_path, save_folder, force_download)

    return pandas.read_json(save_filepath)


def _list_and_download_files(certificate_path: str, save_folder: str, force_download: bool = False):
    certificate_path: Path = Path(certificate_path)
    save_folder: Path = Path(save_folder) / "storage"

    if not save_folder.exists() or force_download:
        # Initialize Firebase if not already initialized
        if not firebase_admin._apps:
            cred = firebase_admin.credentials.Certificate(certificate_path)
            firebase_admin.initialize_app(cred, {"storageBucket": "monstageenimages.appspot.com"})

        # Get a reference to Firebase Storage
        bucket = storage.bucket()

        # List all blobs (files) in the storage bucket
        blobs = bucket.list_blobs()

        # Download all files
        save_folder.mkdir(parents=True, exist_ok=True)
        print("Downloading all the files, this may take a while...")
        for blob in blobs:
            file_path: Path = save_folder / blob.name
            file_path.parent.mkdir(parents=True, exist_ok=True)
            blob.download_to_filename(str(file_path))
