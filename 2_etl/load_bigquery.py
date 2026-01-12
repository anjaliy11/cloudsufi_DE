

import logging
import time
from google.cloud import bigquery
from google.api_core.exceptions import GoogleAPIError

logger = logging.getLogger(__name__)


def ensure_dataset(client: bigquery.Client, dataset_id: str):
    try:
        client.get_dataset(dataset_id)
        logger.debug("Dataset exists: %s", dataset_id)
    except Exception:
        logger.info("Creating dataset: %s", dataset_id)
        dataset = bigquery.Dataset(dataset_id)
        client.create_dataset(dataset)


def load_to_bq(df, table, dataset, project, write_disposition='WRITE_APPEND', max_retries=3):
    """Load a DataFrame to BigQuery with simple retry and dataset creation.

    Args:
        df (pd.DataFrame): dataframe to load
        table (str): table name
        dataset (str): dataset name
        project (str): GCP project id
        write_disposition (str): BigQuery write disposition (WRITE_TRUNCATE/WRITE_APPEND)
    """
    client = bigquery.Client(project=project)
    dataset_id = f"{project}.{dataset}"
    ensure_dataset(client, dataset_id)

    table_id = f"{project}.{dataset}.{table}"
    job_config = bigquery.LoadJobConfig()
    job_config.write_disposition = write_disposition
    job_config.autodetect = True

    attempt = 0
    while attempt < max_retries:
        try:
            logger.info("Loading %d rows into %s", len(df), table_id)
            job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
            job.result()
            logger.info("Load complete: %s", table_id)
            return job
        except GoogleAPIError as e:
            attempt += 1
            logger.warning("BigQuery load failed (attempt %d/%d): %s", attempt, max_retries, e)
            if attempt >= max_retries:
                logger.error("Exceeded max retries for %s", table_id)
                raise
            time.sleep(2 ** attempt)
        except Exception as e:
            logger.exception("Unexpected error during BigQuery load: %s", e)
            raise
