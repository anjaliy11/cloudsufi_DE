
import logging
import pandas as pd

logger = logging.getLogger(__name__)


def clean_dates(df: pd.DataFrame, cols):
    """Convert specified columns to datetime, coercing errors to NaT."""
    for col in cols:
        if col not in df.columns:
            logger.warning("Column %s not found in DataFrame; skipping date clean", col)
            continue
        df[col] = pd.to_datetime(df[col], errors='coerce')
    return df


def validate_required_columns(df: pd.DataFrame, required_cols):
    missing = [c for c in required_cols if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")
    return True
