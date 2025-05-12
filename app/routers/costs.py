from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlmodel import Session, select
from app.models.cost import CostEntry
from app.db.session import get_session

router = APIRouter(prefix="/costs")

@router.get("")
def read_costs(
    service: Optional[str] = Query(None),
    region: Optional[str] = Query(None),
    tag: Optional[str] = Query(None),
    session: Session = Depends(get_session)
):
    query = select(CostEntry)
    
    if service:
        query = query.where(CostEntry.service == service)
    if region:
        query = query.where(CostEntry.region == region)
    if tag:
        query = query.where(CostEntry.tag == tag)

    results = session.exec(query)
    return results.all()
