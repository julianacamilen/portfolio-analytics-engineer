"""
Generates plausible synthetic data for the portfolio project.
NO real company data is used here -- everything is generated with Faker +
statistical distributions chosen to look realistic (Pareto for customer
value, daily traffic variation, payment success rates with noise, etc).

Output: 3 CSVs in seeds/, used as the shared base for the project's 4 marts:
  - customers.csv    -> used by: cohort/retention, segmentation
  - transactions.csv -> used by: cohort/retention, payments funnel, segmentation
  - sessions.csv     -> used by: site kpis (week 1)
"""

import csv
import random
from datetime import datetime, timedelta, timezone

from faker import Faker

fake = Faker()
Faker.seed(42)
random.seed(42)

OUT_DIR = "seeds"

# Data window: 6 months, ending "today" (simulated)
END_DATE = datetime(2026, 6, 30, tzinfo=timezone.utc)
START_DATE = END_DATE - timedelta(days=180)

N_CUSTOMERS = 3000


def random_date(start: datetime, end: datetime) -> datetime:
    delta = end - start
    seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=seconds)


# ---------------------------------------------------------------------------
# 1. CUSTOMERS
#    signup_date determines the acquisition "cohort". Signup volume grows
#    slightly month over month to simulate organic "business" growth.
# ---------------------------------------------------------------------------
customers = []
for i in range(1, N_CUSTOMERS + 1):
    signup_date = random_date(START_DATE, END_DATE)
    # acquisition channel (used later for segmentation/marketing analysis)
    channel = random.choices(
        ["organic", "paid_search", "affiliate", "social", "referral"],
        weights=[0.35, 0.25, 0.20, 0.12, 0.08],
    )[0]
    country = random.choices(
        ["BR", "PT", "US", "DE", "ES"], weights=[0.4, 0.15, 0.2, 0.15, 0.1]
    )[0]
    customers.append(
        {
            "customer_id": f"cust_{i:06d}",
            "signup_date": signup_date.strftime("%Y-%m-%d"),
            "acquisition_channel": channel,
            "country": country,
        }
    )

with open(f"{OUT_DIR}/customers.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=customers[0].keys())
    writer.writeheader()
    writer.writerows(customers)

print(f"customers.csv -> {len(customers)} rows")

# ---------------------------------------------------------------------------
# 2. TRANSACTIONS
#    Pareto-style distribution: a few high-value customers, many low-value
#    ones -- this later becomes the basis for segmentation (Bronze..Platinum).
#    Each customer can only transact after their signup_date.
# ---------------------------------------------------------------------------
transactions = []
txn_id = 1
customer_lookup = {c["customer_id"]: c for c in customers}

# Pareto: 20% of customers generate ~80% of transaction volume
high_value_customers = set(
    random.sample([c["customer_id"] for c in customers], k=int(N_CUSTOMERS * 0.2))
)

for c in customers:
    signup = datetime.strptime(c["signup_date"], "%Y-%m-%d").replace(tzinfo=timezone.utc)
    if signup >= END_DATE:
        continue

    is_high_value = c["customer_id"] in high_value_customers
    n_txns = random.randint(3, 15) if is_high_value else random.randint(0, 4)

    for _ in range(n_txns):
        txn_date = random_date(signup, END_DATE)
        amount = round(random.uniform(50, 500) if is_high_value else random.uniform(5, 80), 2)

        txn_type = random.choices(["deposit", "withdrawal"], weights=[0.75, 0.25])[0]

        status = random.choices(
            ["successful", "failed", "refunded", "pending", "cancelled"],
            weights=[0.88, 0.06, 0.02, 0.02, 0.02],
        )[0]

        transactions.append(
            {
                "transaction_id": f"txn_{txn_id:07d}",
                "customer_id": c["customer_id"],
                "transaction_type": txn_type,
                "status": status,
                "amount": amount,
                "created_at": txn_date.strftime("%Y-%m-%d %H:%M:%S"),
            }
        )
        txn_id += 1

with open(f"{OUT_DIR}/transactions.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=transactions[0].keys())
    writer.writeheader()
    writer.writerows(transactions)

print(f"transactions.csv -> {len(transactions)} rows")

# ---------------------------------------------------------------------------
# 3. SESSIONS  (week 1 focus -- site_kpis mart)
#    Realistic hourly traffic pattern (daytime peak, overnight trough) and
#    variable session duration, including bounces (short sessions).
# ---------------------------------------------------------------------------
HOURLY_WEIGHTS = [
    1, 1, 1, 1, 2, 3,        # 00h-05h (overnight, low traffic)
    5, 8, 12, 15, 16, 17,    # 06h-11h
    18, 17, 16, 15, 16, 18,  # 12h-17h
    20, 19, 15, 10, 6, 3,    # 18h-23h (evening peak)
]

sessions = []
session_id = 1
n_days = (END_DATE - START_DATE).days

active_customer_ids = [c["customer_id"] for c in customers]

for day_offset in range(n_days):
    day = START_DATE + timedelta(days=day_offset)
    # slight upward trend in sessions over the period
    base_sessions_today = int(60 + (day_offset / n_days) * 40 + random.gauss(0, 8))
    base_sessions_today = max(base_sessions_today, 10)

    for _ in range(base_sessions_today):
        hour = random.choices(range(24), weights=HOURLY_WEIGHTS)[0]
        minute = random.randint(0, 59)
        started_at = day.replace(hour=hour, minute=minute, second=random.randint(0, 59))

        is_bounce = random.random() < 0.17  # ~17% bounce rate
        if is_bounce:
            duration_seconds = random.randint(1, 30)
            end_reason = "no_activity"
        else:
            duration_seconds = int(random.lognormvariate(mu=6.0, sigma=1.0))  # long tail
            duration_seconds = min(duration_seconds, 7200)
            end_reason = random.choices(
                ["no_activity", "timeout", "logout"], weights=[0.78, 0.15, 0.07]
            )[0]

        # ~45% of sessions belong to an identified customer; the rest are anonymous
        customer_id = random.choice(active_customer_ids) if random.random() < 0.45 else ""

        device_type = random.choices(
            ["desktop", "mobile", "tablet"], weights=[0.55, 0.4, 0.05]
        )[0]

        sessions.append(
            {
                "session_id": f"sess_{session_id:08d}",
                "customer_id": customer_id,
                "started_at": started_at.strftime("%Y-%m-%d %H:%M:%S"),
                "duration_seconds": duration_seconds,
                "end_reason": end_reason,
                "device_type": device_type,
            }
        )
        session_id += 1

with open(f"{OUT_DIR}/sessions.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=sessions[0].keys())
    writer.writeheader()
    writer.writerows(sessions)

print(f"sessions.csv -> {len(sessions)} rows")
print("\nOK - 3 files generated in seeds/")