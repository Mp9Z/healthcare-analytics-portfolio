import pandas as pd
from sqlalchemy import create_engine

# If your password has special characters (@ # : /), URL-encode them
engine = create_engine("postgresql+psycopg2://postgres:123@localhost:5432/healthcare")

tables = ["patients", "encounters", "payers", "organizations",
          "providers", "conditions", "medications", "procedures"]
date_cols = ["start", "stop", "birthdate", "deathdate"]

for t in tables:
    df = pd.read_csv(f"data/raw/{t}.csv")
    df.columns = [c.lower() for c in df.columns]
    for c in date_cols:
        if c in df.columns:
            df[c] = pd.to_datetime(df[c], errors="coerce").dt.tz_localize(None)
    df.to_sql(t, engine, if_exists="replace", index=False, chunksize=20000)
    print(f"{t}: {len(df):,} rows loaded")