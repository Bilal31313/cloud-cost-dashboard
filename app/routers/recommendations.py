from fastapi import APIRouter
from sqlmodel import Session, select
from db.session import engine
from models import CostEntry

router = APIRouter()

# Fake CPU usage per service ID — in production you'd store real metrics
cpu_usage_map = {
    1: 18.0,  # EC2 (dev)
    2: 55.0,  # S3 (skip)
    3: 72.0   # RDS (skip)
}

# Recommendation table
downgrade_map = {
    "t3.medium": "t3.small",
    "t3.large": "t3.medium"
}

@router.get("/recommendations")
def get_cost_recommendations():
    recommendations = []

    with Session(engine) as session:
        results = session.exec(select(CostEntry).where(CostEntry.service == "EC2")).all()

        for cost in results:
            cpu_avg = cpu_usage_map.get(cost.id, 100.0)  # assume healthy unless flagged

            if cpu_avg < 20.0:
                recommendations.append({
                    "instance": cost.tag or "t3.medium",  # fallback
                    "region": cost.region,
                    "cpu_avg": cpu_avg,
                    "recommendation": f"Consider downgrading to {downgrade_map.get(cost.tag, 't3.small')} to reduce costs"
                })

    return recommendations
