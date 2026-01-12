
import os
import logging
import pandas as pd

logger = logging.getLogger(__name__)


def extract_csv(path, parse_dates=None, dtype=None):

    
    if not os.path.isabs(path):
        base = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
        path = os.path.join(base, path)

    logger.info("Extracting CSV: %s", path)
    if not os.path.exists(path):
        logger.error("File not found: %s", path)
        raise FileNotFoundError(path)

    df = pd.read_csv(path, parse_dates=parse_dates, dtype=dtype)
    if df.empty:
        logger.error("Empty dataset at: %s", path)
        raise ValueError("Empty dataset")
    return df
