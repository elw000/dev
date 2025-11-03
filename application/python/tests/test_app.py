import pytest
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_page(client):
    """Test the home page"""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Hello from DevOps Project!' in response.data

def test_health_endpoint(client):
    """Test health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert 'status' in data
    assert 'version' in data

def test_metrics_endpoint(client):
    """Test Prometheus metrics endpoint"""
    response = client.get('/metrics')
    assert response.status_code == 200
    assert b'app_requests_total' in response.data

def test_visitors_api(client):
    """Test visitors API endpoint"""
    response = client.get('/api/visitors')
    assert response.status_code in [200, 503]  # May fail if Redis not available

def test_data_api_get(client):
    """Test data API GET endpoint"""
    response = client.get('/api/data')
    assert response.status_code in [200, 503]  # May fail if DB not available

def test_404_error(client):
    """Test 404 error handling"""
    response = client.get('/nonexistent')
    assert response.status_code == 404
