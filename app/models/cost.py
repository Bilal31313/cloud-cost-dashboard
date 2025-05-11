from sqlmodel import SQLModel, Field
from typing import Optional
from datetime import date

class CostEntry(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    service: str
    amount: float
    usage_date: date
    tag: Optional[str] = None
    region: Optional[str] = None
