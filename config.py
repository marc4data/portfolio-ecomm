# config.py — BigQuery connection settings
#
# CREDENTIALS_PATH resolution order:
#   1. GOOGLE_APPLICATION_CREDENTIALS environment variable (CI/CD, other machines)
#   2. credentials/credentials.json relative to this file (local dev)
#
# To set up locally:
#   - Copy credentials/credentials_template.json → credentials/credentials.json
#   - Populate it with your GCP service account key
#   - The credentials/ directory is gitignored; your key will never be committed.

import os
from pathlib import Path

PROJECT_ID = 'portfolio-thelook'

_here = Path(__file__).parent
_local_key = _here / 'credentials' / 'credentials.json'

if 'GOOGLE_APPLICATION_CREDENTIALS' not in os.environ:
    if _local_key.exists():
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = str(_local_key)
    else:
        raise FileNotFoundError(
            f"No credentials found. Either set the GOOGLE_APPLICATION_CREDENTIALS "
            f"environment variable or place your service account key at:\n  {_local_key}"
        )

print(f"Credentials: {os.environ['GOOGLE_APPLICATION_CREDENTIALS']}")
print(f"Project ID:  {PROJECT_ID}")
