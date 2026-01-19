---
name: testing-strategies
description: Comprehensive testing strategies and best practices
license: MIT
compatibility: opencode
metadata:
  stack: testing, qa, pytest, jest
  audience: developers, qa-engineers
---

## What I do

I provide comprehensive testing strategies including:

- Test pyramid and testing levels
- Unit, integration, and E2E test patterns
- Test setup and configuration
- Mocking and fixtures
- CI/CD integration
- Coverage strategies
- Performance testing patterns

## When to use me

Use this skill when:

- Setting up testing infrastructure for a new project
- Improving test coverage
- Implementing test automation
- Setting up CI/CD testing pipelines
- Writing specific types of tests
- Debugging flaky tests
- Implementing performance tests

## Testing Pyramid Strategy

```
        ╱╲
       ╱E2E╲          ← 10% - Few, slow, expensive
      ╱──────╲           - Full user journeys
     ╱ Integr.╲       ← 20% - Medium speed/cost
    ╱──────────╲         - Component interactions
   ╱   Unit Tests╲    ← 70% - Many, fast, cheap
  ╱──────────────╲       - Single functions/classes
 ╱________________╲
```

**Distribution Guidelines:**
- **70% Unit Tests** - Test individual functions/methods
- **20% Integration Tests** - Test component interactions
- **10% E2E Tests** - Test complete user flows

## Unit Testing Patterns

### Basic Test Structure (AAA Pattern)

```python
def test_user_creation():
    # Arrange - Set up test data and dependencies
    user_data = {
        "username": "testuser",
        "email": "test@example.com"
    }
    service = UserService()
    
    # Act - Execute the function being tested
    result = service.create_user(user_data)
    
    # Assert - Verify the outcome
    assert result.username == user_data["username"]
    assert result.email == user_data["email"]
    assert result.id is not None
```

### Test Fixtures (pytest)

```python
# conftest.py - Shared fixtures
import pytest
from app.database import Database
from app.services.user_service import UserService

@pytest.fixture(scope="session")
def database():
    """Create database connection for test session."""
    db = Database("postgresql://test:test@localhost/test_db")
    db.create_tables()
    yield db
    db.drop_tables()
    db.close()

@pytest.fixture(scope="function")
def db_session(database):
    """Create new session for each test."""
    session = database.create_session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def user_service(db_session):
    """Create UserService with test database."""
    return UserService(db_session)

@pytest.fixture
def sample_user():
    """Sample user data for tests."""
    return {
        "username": "testuser",
        "email": "test@example.com",
        "password": "SecurePass123!"
    }

# Usage in tests
def test_create_user(user_service, sample_user):
    """Test user creation with fixtures."""
    user = user_service.create(sample_user)
    assert user.username == sample_user["username"]
```

### Mocking Dependencies

```python
import pytest
from unittest.mock import Mock, patch, MagicMock

# Mocking with pytest-mock
def test_send_email_on_registration(mocker, user_service):
    """Test email is sent when user registers."""
    # Mock the email service
    mock_email = mocker.patch('app.services.email_service.send_email')
    mock_email.return_value = True
    
    # Register user
    user = user_service.register({
        "email": "test@example.com",
        "username": "test"
    })
    
    # Verify email was sent
    mock_email.assert_called_once()
    assert mock_email.call_args[0][0] == "test@example.com"

# Mocking external API
def test_fetch_external_data(mocker):
    """Test fetching data from external API."""
    mock_response = Mock()
    mock_response.json.return_value = {"data": "test"}
    mock_response.status_code = 200
    
    mocker.patch('requests.get', return_value=mock_response)
    
    result = fetch_data_from_api()
    assert result == {"data": "test"}

# Mocking database
def test_get_user_from_db(mocker):
    """Test retrieving user from database."""
    mock_db = mocker.Mock()
    mock_db.query().filter().first.return_value = User(id=1, name="Test")
    
    service = UserService(mock_db)
    user = service.get_user(1)
    
    assert user.name == "Test"
```

### Parameterized Tests

```python
import pytest

@pytest.mark.parametrize("email,expected", [
    ("valid@example.com", True),
    ("invalid.email", False),
    ("@example.com", False),
    ("user@", False),
    ("user@domain.com", True),
])
def test_email_validation(email, expected):
    """Test email validation with various inputs."""
    result = validate_email(email)
    assert result == expected

@pytest.mark.parametrize("age,can_vote", [
    (17, False),
    (18, True),
    (25, True),
    (0, False),
])
def test_voting_eligibility(age, can_vote):
    """Test voting eligibility by age."""
    assert check_voting_eligibility(age) == can_vote
```

## Integration Testing Patterns

### API Integration Tests

```python
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
class TestUserAPI:
    """Integration tests for User API endpoints."""
    
    async def test_create_and_retrieve_user(self, client: AsyncClient):
        """Test creating and retrieving a user."""
        # Create user
        create_response = await client.post("/api/v1/users", json={
            "username": "integrationtest",
            "email": "integration@test.com",
            "password": "Test123!"
        })
        assert create_response.status_code == 201
        user_id = create_response.json()["id"]
        
        # Retrieve user
        get_response = await client.get(f"/api/v1/users/{user_id}")
        assert get_response.status_code == 200
        user_data = get_response.json()
        assert user_data["username"] == "integrationtest"
    
    async def test_authentication_flow(self, client: AsyncClient):
        """Test complete authentication flow."""
        # Register
        register_response = await client.post("/api/v1/auth/register", json={
            "username": "authtest",
            "email": "auth@test.com",
            "password": "SecurePass123!"
        })
        assert register_response.status_code == 201
        
        # Login
        login_response = await client.post("/api/v1/auth/login", json={
            "email": "auth@test.com",
            "password": "SecurePass123!"
        })
        assert login_response.status_code == 200
        token = login_response.json()["access_token"]
        
        # Access protected endpoint
        headers = {"Authorization": f"Bearer {token}"}
        profile_response = await client.get(
            "/api/v1/users/me",
            headers=headers
        )
        assert profile_response.status_code == 200
        assert profile_response.json()["username"] == "authtest"
```

### Database Integration Tests

```python
import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from app.models import User, Post
from app.repositories import UserRepository, PostRepository

@pytest.mark.asyncio
async def test_user_post_relationship(db_session: AsyncSession):
    """Test relationship between users and posts."""
    user_repo = UserRepository(db_session)
    post_repo = PostRepository(db_session)
    
    # Create user
    user = await user_repo.create({
        "username": "author",
        "email": "author@test.com"
    })
    
    # Create posts for user
    post1 = await post_repo.create({
        "title": "First Post",
        "content": "Content 1",
        "user_id": user.id
    })
    post2 = await post_repo.create({
        "title": "Second Post",
        "content": "Content 2",
        "user_id": user.id
    })
    
    # Verify relationships
    user_posts = await post_repo.get_by_user(user.id)
    assert len(user_posts) == 2
    assert user_posts[0].title == "First Post"
    assert user_posts[1].title == "Second Post"

@pytest.mark.asyncio
async def test_transaction_rollback(db_session: AsyncSession):
    """Test transaction rollback on error."""
    user_repo = UserRepository(db_session)
    
    try:
        async with db_session.begin():
            # Create first user
            user1 = await user_repo.create({
                "username": "user1",
                "email": "user1@test.com"
            })
            
            # Try to create duplicate (should fail)
            user2 = await user_repo.create({
                "username": "user1",  # Duplicate username
                "email": "user2@test.com"
            })
    except Exception:
        pass
    
    # Verify rollback - first user should not exist
    users = await user_repo.get_all()
    assert len(users) == 0
```

## End-to-End Testing Patterns

### Playwright Tests

```python
import pytest
from playwright.async_api import async_playwright, Page

@pytest.mark.e2e
@pytest.mark.asyncio
async def test_user_registration_flow():
    """Test complete user registration in browser."""
    async with async_playwright() as p:
        # Launch browser
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        try:
            # Navigate to registration
            await page.goto("http://localhost:3000/register")
            
            # Fill form
            await page.fill('input[name="username"]', "e2euser")
            await page.fill('input[name="email"]', "e2e@test.com")
            await page.fill('input[name="password"]', "SecurePass123!")
            await page.fill('input[name="confirmPassword"]', "SecurePass123!")
            
            # Submit
            await page.click('button[type="submit"]')
            
            # Wait for success message
            await page.wait_for_selector('.success-message', timeout=5000)
            
            # Verify redirect to dashboard
            await page.wait_for_url("**/dashboard")
            
            # Verify user is logged in
            welcome = await page.text_content('h1')
            assert "Welcome" in welcome
            
        finally:
            await browser.close()

@pytest.mark.e2e
@pytest.mark.asyncio
async def test_create_edit_delete_post():
    """Test CRUD operations for posts."""
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        
        # Login first
        await login_user(page, "test@example.com", "password")
        
        # Create post
        await page.click('a:has-text("New Post")')
        await page.fill('input[name="title"]', "E2E Test Post")
        await page.fill('textarea[name="content"]', "Test content")
        await page.click('button:has-text("Publish")')
        
        # Verify creation
        await page.wait_for_selector('h2:has-text("E2E Test Post")')
        
        # Edit post
        await page.click('button:has-text("Edit")')
        await page.fill('input[name="title"]', "Updated Title")
        await page.click('button:has-text("Save")')
        await page.wait_for_selector('h2:has-text("Updated Title")')
        
        # Delete post
        await page.click('button:has-text("Delete")')
        await page.click('button:has-text("Confirm")')
        
        # Verify deletion
        await page.wait_for_selector('.no-posts-message')
        
        await browser.close()
```

## Test Configuration

### pytest Configuration

```ini
# pytest.ini
[pytest]
# Test discovery
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Markers
markers =
    unit: Unit tests (fast, isolated)
    integration: Integration tests (database, external services)
    e2e: End-to-end tests (full application)
    slow: Slow running tests
    smoke: Quick smoke tests

# Coverage
addopts =
    --cov=app
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
    --strict-markers
    --verbose

# Async
asyncio_mode = auto

# Warnings
filterwarnings =
    error
    ignore::DeprecationWarning
```

### Jest/Vitest Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'tests/',
        '**/*.test.ts',
        '**/*.spec.ts',
      ],
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
    setupFiles: ['./tests/setup.ts'],
  },
});
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: ['3.11', '3.12']
    
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov pytest-asyncio
      
      - name: Run unit tests
        run: pytest tests/unit -m unit --cov=app
      
      - name: Run integration tests
        run: pytest tests/integration -m integration
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/test_db
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: true
  
  e2e:
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install Playwright
        run: |
          pip install playwright pytest-playwright
          playwright install chromium
      
      - name: Run E2E tests
        run: pytest tests/e2e -m e2e
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-results
          path: test-results/
```

## Performance Testing

### Load Testing with Locust

```python
from locust import HttpUser, task, between
import random

class APIUser(HttpUser):
    """Simulate API user behavior."""
    
    wait_time = between(1, 3)
    
    def on_start(self):
        """Login before tasks."""
        response = self.client.post("/api/v1/auth/login", json={
            "email": "test@example.com",
            "password": "password123"
        })
        self.token = response.json()["access_token"]
        self.headers = {"Authorization": f"Bearer {self.token}"}
    
    @task(5)  # Weight: 5x
    def list_users(self):
        """Get user list."""
        self.client.get("/api/v1/users", headers=self.headers)
    
    @task(3)
    def get_user(self):
        """Get specific user."""
        user_id = random.randint(1, 100)
        self.client.get(f"/api/v1/users/{user_id}", headers=self.headers)
    
    @task(1)
    def create_post(self):
        """Create new post."""
        self.client.post("/api/v1/posts", headers=self.headers, json={
            "title": f"Load Test {random.randint(1, 10000)}",
            "content": "Test content"
        })
    
    @task(2)
    def search(self):
        """Search posts."""
        query = random.choice(["test", "example", "demo"])
        self.client.get(f"/api/v1/posts/search?q={query}", headers=self.headers)
```

## Test Best Practices

### 1. Test Naming

```python
# Good: Descriptive test names
def test_create_user_with_valid_data_returns_user():
    pass

def test_login_with_invalid_password_raises_authentication_error():
    pass

def test_get_user_when_not_found_returns_none():
    pass

# Bad: Vague test names
def test_user():
    pass

def test_login():
    pass
```

### 2. Single Responsibility

```python
# Bad: Testing multiple things
def test_user_operations():
    user = create_user()
    assert user.id is not None
    updated = update_user(user.id, {"name": "New"})
    assert updated.name == "New"
    delete_user(user.id)

# Good: One assertion per test
def test_create_user_generates_id():
    user = create_user()
    assert user.id is not None

def test_update_user_changes_name():
    user = create_user()
    updated = update_user(user.id, {"name": "New"})
    assert updated.name == "New"

def test_delete_user_removes_from_db():
    user = create_user()
    delete_user(user.id)
    assert get_user(user.id) is None
```

### 3. Test Independence

```python
# Bad: Tests depend on each other
user_id = None

def test_create_user():
    global user_id
    user = create_user()
    user_id = user.id

def test_update_user():
    update_user(user_id, {"name": "Updated"})

# Good: Independent tests with fixtures
@pytest.fixture
def user():
    return create_user()

def test_create_user():
    user = create_user()
    assert user.id is not None

def test_update_user(user):
    updated = update_user(user.id, {"name": "Updated"})
    assert updated.name == "Updated"
```

### 4. Clear Assertions

```python
# Bad: Unclear what's being tested
def test_user_data():
    user = get_user(1)
    assert user

# Good: Explicit assertions
def test_get_user_returns_user_with_correct_data():
    user = get_user(1)
    assert user is not None
    assert user.username == "expected_username"
    assert user.email == "expected@email.com"
```

## Test Data Management

### Factory Pattern

```python
from factory import Factory, Faker, SubFactory
from app.models import User, Post

class UserFactory(Factory):
    class Meta:
        model = User
    
    username = Faker('user_name')
    email = Faker('email')
    full_name = Faker('name')
    is_active = True

class PostFactory(Factory):
    class Meta:
        model = Post
    
    title = Faker('sentence')
    content = Faker('text')
    user = SubFactory(UserFactory)

# Usage
def test_with_factory():
    user = UserFactory.create()
    post = PostFactory.create(user=user)
    assert post.user_id == user.id
```

## Coverage Goals

- **Overall Coverage:** ≥ 80%
- **Critical Paths:** ≥ 95%
- **New Code:** ≥ 90%
- **Bug Fixes:** 100% (add tests for bugs)

## Running Tests

```bash
# Run all tests
pytest

# Run specific markers
pytest -m unit
pytest -m integration
pytest -m "not slow"

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific file
pytest tests/test_users.py

# Run specific test
pytest tests/test_users.py::test_create_user

# Verbose output
pytest -v

# Stop on first failure
pytest -x

# Run last failed tests
pytest --lf

# Parallel execution
pytest -n auto
```
