from sqlmodel import SQLModel, Session, create_engine
from models.cost import CostEntry
from datetime import date

engine = create_engine("sqlite:///costs.db", echo=True)

SQLModel.metadata.create_all(engine)

dummy_data = [
    CostEntry(service="EC2", amount=27.89, usage_date=date.today(), tag="dev", region="eu-west-2"),
    CostEntry(service="S3", amount=4.50, usage_date=date.today(), tag="backup", region="us-east-1"),
    CostEntry(service="RDS", amount=13.25, usage_date=date.today(), tag="db", region="eu-west-1"),
]

with Session(engine) as session:
    for entry in dummy_data:
        session.add(entry)
    session.commit()
