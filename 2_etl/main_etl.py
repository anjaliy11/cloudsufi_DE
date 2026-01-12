
import logging
import sys
from pathlib import Path

from extract import extract_csv
from transform import clean_dates, validate_required_columns
from load_bigquery import load_to_bq
from config import BQ_PROJECT, BQ_DATASET

logger = logging.getLogger(__name__)


def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
        stream=sys.stdout,
    )


TABLES = {
    "sales_transactions": {"date_cols": ["transaction_date"], "required": ["transaction_id"]},
    "returns": {"date_cols": ["return_date"], "required": ["return_id"]},
}


def run():
    setup_logging()
    logger.info("Starting ETL to BigQuery project=%s dataset=%s", BQ_PROJECT, BQ_DATASET)

    base = Path(__file__).resolve().parents[1]
    for table, meta in TABLES.items():
        csv_path = base / f"sample_data/{table}.csv"
        try:
            df = extract_csv(str(csv_path), parse_dates=meta.get("date_cols"))
            validate_required_columns(df, meta.get("required", []))
            df = clean_dates(df, meta.get("date_cols", []))
            
            load_to_bq(df, table, BQ_DATASET, BQ_PROJECT)
        except Exception as e:
            logger.exception("ETL failed for table %s: %s", table, e)
    logger.info("ETL run completed")


if __name__ == "__main__":
    run()
