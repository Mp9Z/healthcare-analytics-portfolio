import os
from urllib.parse import quote_plus
import pandas as pd
from sqlalchemy import create_engine

password = quote_plus(os.environ["PGPASSWORD"])
engine = create_engine(f"postgresql+psycopg2://postgres:{password}@localhost:5432/healthcare")

tables = ["patients", "encounters", "payers", "organizations",
          "providers", "conditions", "medications", "procedures"]
date_cols = ["start", "stop", "birthdate", "deathdate"]

for t in tables:
    df = pd.read_csv(f"data/raw/{t}.csv")
    df.columns = [c.lower() for c in df.columns]
    for c in date_cols:
        if c in df.columns:
            df[c] = pd.to_datetime(df[c], errors="coerce", utc=True).dt.tz_localize(None)
    df.to_sql(t, engine, if_exists="replace", index=False, chunksize=20000)
    print(f"{t}: {len(df):,} rows loaded")
