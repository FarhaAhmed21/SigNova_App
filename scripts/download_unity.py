import os
import gdown
import zipfile

UNITY_PATH = "android/unityLibrary"
FILE_ID = "1EhUnpIFTEZ-4vx8bMd6yj_SgETvnOK6H"

URL = f"https://drive.google.com/uc?id={FILE_ID}"

ZIP_PATH = "unityLibrary.zip"

if not os.path.exists(UNITY_PATH):
    print("Downloading UnityLibrary...")

    gdown.download(URL, ZIP_PATH, quiet=False)

    print("Extracting UnityLibrary...")

    with zipfile.ZipFile(ZIP_PATH, "r") as zip_ref:
        zip_ref.extractall("android")

    os.remove(ZIP_PATH)

    print("UnityLibrary is ready ✅")

else:
    print("UnityLibrary already exists ✅")