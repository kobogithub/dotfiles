---
name: fastapi-best-practices
description: FastAPI project structure and best practices guide
license: MIT
compatibility: opencode
metadata:
  stack: python, fastapi, pydantic
  audience: backend-developers
---

## What I do

I provide a comprehensive guide for structuring FastAPI projects following industry best practices, including:

- Recommended project structure for scalability
- Dependency injection patterns
- Error handling strategies
- Authentication and authorization setup
- Database integration patterns
- Testing strategies
- Documentation best practices

## When to use me

Use this skill when:

- Starting a new FastAPI project from scratch
- Refactoring an existing FastAPI codebase
- Need guidance on project organization
- Setting up authentication/authorization
- Implementing database patterns
- Writing tests for FastAPI endpoints

## Project Structure

```
project/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app initialization
│   ├── api/
│   │   ├── __init__.py
│   │   ├── dependencies.py     # Reusable dependencies
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── endpoints/
│   │       │   ├── __init__.py
│   │       │   ├── users.py
│   │       │   ├── auth.py
│   │       │   └── posts.py
│   │       └── router.py       # V1 API router
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py           # Settings with pydantic-settings
│   │   ├── security.py         # Auth utilities (JWT, passwords)
│   │   └── database.py         # Database session management
│   ├── models/                 # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── post.py
│   ├── schemas/                # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── post.py
│   │   └── token.py
│   ├── services/               # Business logic layer
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   └── post_service.py
│   ├── repositories/           # Data access layer
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user_repository.py
│   │   └── post_repository.py
│   └── utils/                  # Helper utilities
│       ├── __init__.py
│       └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_api/
│   │   ├── test_auth.py
│   │   └── test_users.py
│   └── test_services/
├── alembic/                    # Database migrations
│   ├── versions/
│   └── env.py
├── .env.example
├── .gitignore
├── alembic.ini
├── pyproject.toml
├── poetry.lock
└── README.md
```

## Core Patterns

### 1. Configuration Management

```python
# app/core/config.py
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    # App
    PROJECT_NAME: str = "My API"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"
    
    # Database
    DATABASE_URL: str
    DB_ECHO: bool = False
    
    # Security
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:3000"]
    
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )

settings = Settings()
```

### 2. Database Session Dependency

```python
# app/core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.core.config import settings

engine = create_async_engine(settings.DATABASE_URL, echo=settings.DB_ECHO)
AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
```

### 3. Repository Pattern

```python
# app/repositories/base.py
from typing import Generic, TypeVar, Type, Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

ModelType = TypeVar("ModelType")

class BaseRepository(Generic[ModelType]):
    def __init__(self, model: Type[ModelType], db: AsyncSession):
        self.model = model
        self.db = db
    
    async def get(self, id: int) -> Optional[ModelType]:
        result = await self.db.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()
    
    async def get_all(self, skip: int = 0, limit: int = 100) -> list[ModelType]:
        result = await self.db.execute(
            select(self.model).offset(skip).limit(limit)
        )
        return result.scalars().all()
    
    async def create(self, obj_in: dict) -> ModelType:
        db_obj = self.model(**obj_in)
        self.db.add(db_obj)
        await self.db.commit()
        await self.db.refresh(db_obj)
        return db_obj
    
    async def update(self, id: int, obj_in: dict) -> Optional[ModelType]:
        db_obj = await self.get(id)
        if not db_obj:
            return None
        for key, value in obj_in.items():
            setattr(db_obj, key, value)
        await self.db.commit()
        await self.db.refresh(db_obj)
        return db_obj
    
    async def delete(self, id: int) -> bool:
        db_obj = await self.get(id)
        if not db_obj:
            return False
        await self.db.delete(db_obj)
        await self.db.commit()
        return True
```

### 4. Service Layer

```python
# app/services/user_service.py
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash

class UserService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo
    
    async def create_user(self, user_in: UserCreate):
        user_dict = user_in.model_dump()
        user_dict["hashed_password"] = get_password_hash(user_dict.pop("password"))
        return await self.user_repo.create(user_dict)
    
    async def get_user_by_email(self, email: str):
        return await self.user_repo.get_by_email(email)
```

### 5. Dependency Injection

```python
# app/api/dependencies.py
from typing import Annotated
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.security import verify_token
from app.repositories.user_repository import UserRepository
from app.services.user_service import UserService

# Database dependency
DBSession = Annotated[AsyncSession, Depends(get_db)]

# Repository dependencies
def get_user_repository(db: DBSession) -> UserRepository:
    return UserRepository(db)

UserRepo = Annotated[UserRepository, Depends(get_user_repository)]

# Service dependencies
def get_user_service(user_repo: UserRepo) -> UserService:
    return UserService(user_repo)

UserServiceDep = Annotated[UserService, Depends(get_user_service)]

# Current user dependency
async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    user_service: UserServiceDep
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
    )
    payload = verify_token(token)
    user_id = payload.get("sub")
    if user_id is None:
        raise credentials_exception
    user = await user_service.get_user(user_id)
    if user is None:
        raise credentials_exception
    return user

CurrentUser = Annotated[User, Depends(get_current_user)]
```

### 6. Exception Handling

```python
# app/main.py
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError

app = FastAPI()

class AppException(Exception):
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code

@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.message},
    )

@app.exception_handler(SQLAlchemyError)
async def sqlalchemy_exception_handler(request: Request, exc: SQLAlchemyError):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Database error occurred"},
    )
```

### 7. Testing Setup

```python
# tests/conftest.py
import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.main import app
from app.core.database import get_db, Base

TEST_DATABASE_URL = "postgresql+asyncpg://test:test@localhost/test_db"

engine = create_async_engine(TEST_DATABASE_URL, echo=True)
TestSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

@pytest_asyncio.fixture
async def db_session():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    async with TestSessionLocal() as session:
        yield session
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture
async def client(db_session):
    async def override_get_db():
        yield db_session
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()

@pytest.fixture
def test_user_data():
    return {
        "email": "test@example.com",
        "password": "testpass123",
        "username": "testuser"
    }
```

## Authentication Pattern

```python
# app/core/security.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None
```

## Tips

- Always separate concerns: routers → services → repositories → models
- Use Pydantic schemas for request/response validation
- Implement comprehensive error handling
- Write tests for all endpoints
- Use async/await consistently
- Document all endpoints with docstrings
- Use dependency injection for testability
- Keep business logic in services, not routers
- Use Alembic for database migrations
- Configure proper logging
