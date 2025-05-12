from fastapi import APIRouter, Depends
from sqlmodel import Session, select
from app.db.session import get_session
from app.models.cost import CostEntry

router = APIRouter()

cpu_usage_map = {1: 18.0, 2: 55.0, 3: 72.0}
downgrade_map = {"t3.medium": "t3.small", "t3.large": "t3.medium"}

@router.get("/recommendations")
def get_cost_recommendations(session: Session = Depends(get_session)):
    recommendations = []
    results = session.exec(select(CostEntry).where(CostEntry.service == "EC2")).all()

    for cost in results:
        cpu_avg = cpu_usage_map.get(cost.id, 100.0)
        if cpu_avg < 20.0:
            recommendations.append({
                "instance": cost.tag or "t3.medium",
                "region": cost.region,
                "cpu_avg": cpu_avg,
                "recommendation": f"Consider downgrading to {downgrade_map.get(cost.tag, 't3.small')}"
            })
    return recommendations
