# Setup: BigQuery Sandbox + dbt

BigQuery Sandbox lets you use BigQuery **without a credit card**, with
generous free limits for a portfolio project (1 TB of free queries/month,
10 GB of free storage).

## 1. Create the project on Google Cloud

1. Go to https://console.cloud.google.com/ and sign in with your personal Google account.
2. Click **"Select a project" → "New Project"**.
3. Give it a name (e.g. `portfolio-analytics-engineer`) and create it.
   - This automatically enables BigQuery in Sandbox mode — you do **not**
     need to add a credit card or enable billing for light usage.
4. Note down the **Project ID** (shown under the project name, something
   like `portfolio-analytics-engineer-123456`) — you'll need it in
   `profiles.yml`.

## 2. Install the Google Cloud CLI

This lets dbt authenticate without needing to generate/store a JSON key
(safer for a project that's going to be public on GitHub).

- **Mac**: `brew install --cask google-cloud-sdk`
- **Windows/Linux**: follow https://cloud.google.com/sdk/docs/install

After installing:

```bash
gcloud init                                    # connects the CLI to your Google account
gcloud auth application-default login          # generates local credentials that dbt will use
```

## 3. Configure your local profiles.yml

`profiles.yml` **never** goes into Git (that's why it's in `.gitignore`).
It lives in `~/.dbt/profiles.yml`, outside the repository:

```yaml
portfolio_analytics_engineer:
  target: prod
  outputs:
    prod:
      type: bigquery
      method: oauth
      project: YOUR_PROJECT_ID_HERE     # the Project ID from step 1
      dataset: portfolio_analytics_engineer
      threads: 4
      location: US
```

## 4. Install the BigQuery adapter

```bash
pip install dbt-bigquery
```

## 5. Test the connection

```bash
dbt debug
```

If you see `All checks passed!`, you're ready. Now just run as usual:

```bash
dbt seed
dbt run
dbt test
dbt docs generate
```

The data will show up in BigQuery, inside the `portfolio_analytics_engineer`
dataset, organized into `raw` (seeds), `staging` and `marts` — visible in
the BigQuery console under **BigQuery Studio → your project**.

## Costs

For this project's volume (< 30 thousand rows), you stay well below the
Sandbox's free limits. Even so, it's good practice to never enable
billing on the project while it's just a portfolio piece — that makes it
physically impossible to generate any charge.