import azure.functions as func
import json
import pytest
from function_app import visitors
from unittest.mock import Mock


@pytest.fixture
def mock_db_container():
    """Mock Cosmos DB container."""
    container = Mock(spec=['read_item', 'upsert_item'])
    container.mocked_item = {"id": "mock-counter-id", "partition_key": "v1", "count": 42}
    container.read_item.return_value = container.mocked_item
    container.upsert_item.return_value = container.mocked_item
    return container

@pytest.fixture
def mock_http_request():
    """Mock HTTP request factory."""
    def _create_request(method):
        req = Mock(spec=func.HttpRequest)
        req.method = method
        return req
    return _create_request


class TestVisitorsFunction:
    """Tests for the visitors HTTP function."""

    def test_get_visitor_count(self, mock_db_container, mock_http_request):
        """Test GET request returns current visitor count."""
        req = mock_http_request("GET")

        response = visitors(req, mock_db_container)

        assert response.status_code == 200
        body = json.loads(response.get_body())
        assert body == {"visitors": 42}

    def test_increment_visitor_count(self, mock_db_container, mock_http_request):
        """Test POST request increments visitor count."""
        req = mock_http_request("POST")

        response = visitors(req, mock_db_container)

        assert response.status_code == 200
        body = json.loads(response.get_body())
        assert body == {"visitors": 43}

    def test_unsupported_http_method(self, mock_db_container, mock_http_request):
        """Test unsupported HTTP methods."""
        req = mock_http_request("DELETE")

        response =visitors(req, mock_db_container)

        assert response.status_code == 405
