
import os
from dotenv import load_dotenv

load_dotenv()


BQ_PROJECT = os.getenv("BQ_PROJECT") or os.getenv("GCP_PROJECT_ID")
BQ_DATASET = os.getenv("BQ_DATASET")


if not BQ_PROJECT:
	raise ValueError("BQ_PROJECT or GCP_PROJECT_ID must be set in .env")
if not BQ_DATASET:
	raise ValueError("BQ_DATASET must be set in .env")


GCP_CRED = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if GCP_CRED:
	if not os.path.isabs(GCP_CRED):
		base_dir = os.path.dirname(__file__)
		resolved = os.path.abspath(os.path.join(base_dir, GCP_CRED))
	else:
		resolved = GCP_CRED

	if not os.path.exists(resolved):
		raise FileNotFoundError(f"GOOGLE_APPLICATION_CREDENTIALS file not found: {resolved}")

	os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = resolved
else:
	pass
