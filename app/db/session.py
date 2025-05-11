from sqlmodel import Session, create_engine

sqlite_file = "costs.db"
engine = create_engine(f"sqlite:///{sqlite_file}", echo=True)

def get_session():
    with Session(engine) as session:
        yield session
