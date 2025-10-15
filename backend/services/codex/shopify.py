"""Shopify GraphQL client utilities."""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import Any, AsyncIterator, Dict, List, Optional, Protocol

import httpx

from .config import Settings

LOGGER = logging.getLogger(__name__)

_GRAPHQL_QUERY = """
query CodexEligibleOrders($cursor: String, $pageSize: Int!) {
  orders(first: $pageSize, after: $cursor, sortKey: CREATED_AT, reverse: true, query: "status:open") {
    edges {
      cursor
      node {
        id
        name
        displayFinancialStatus
        fulfillmentStatus
        paymentGatewayNames
        totalOutstandingSet {
          shopMoney {
            amount
            currencyCode
          }
        }
        shippingAddress {
          name
          phone
          address1
          address2
          city
          province
          country
          zip
          latitude
          longitude
        }
        lineItems(first: 250) {
          edges {
            node {
              id
              title
              requiresShipping
              fulfillableQuantity
              fulfillmentService {
                type
              }
            }
          }
        }
        customer {
          displayName
        }
      }
    }
    pageInfo {
      hasNextPage
    }
  }
}
"""


class ShopifyClientProtocol(Protocol):
    async def fetch_orders(self) -> List[Dict[str, Any]]:
        ...


class ShopifyGraphQLClient(ShopifyClientProtocol):
    """Minimal Shopify GraphQL client for order retrieval."""

    def __init__(self, settings: Settings, *, http_client: Optional[httpx.AsyncClient] = None) -> None:
        self._settings = settings
        self._http_client = http_client

    @property
    def _api_url(self) -> str:
        return (
            f"https://{self._settings.shop_domain}/admin/api/"
            f"{self._settings.graphql_api_version}/graphql.json"
        )

    async def fetch_orders(self) -> List[Dict[str, Any]]:
        """Fetch orders from Shopify using pagination."""

        cursor: Optional[str] = None
        orders: List[Dict[str, Any]] = []

        async with self._client() as client:
            while True:
                response = await client.post(
                    self._api_url,
                    json={"query": _GRAPHQL_QUERY, "variables": {"cursor": cursor, "pageSize": self._settings.page_size}},
                )
                response.raise_for_status()
                payload = response.json()
                if "errors" in payload:
                    LOGGER.error("Shopify GraphQL returned errors: %s", payload["errors"])
                    raise RuntimeError("Shopify GraphQL request failed")

                orders_node = payload["data"]["orders"]
                edges: List[Dict[str, Any]] = orders_node["edges"]
                for edge in edges:
                    orders.append(edge["node"])

                if not orders_node["pageInfo"]["hasNextPage"]:
                    break
                if not edges:
                    break
                cursor = edges[-1]["cursor"]

        return orders

    @asynccontextmanager
    async def _client(self) -> AsyncIterator[httpx.AsyncClient]:
        if self._http_client is not None:
            yield self._http_client
            return

        headers = {
            "X-Shopify-Access-Token": self._settings.admin_api_token,
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        timeout = httpx.Timeout(15.0, connect=5.0)
        async with httpx.AsyncClient(headers=headers, timeout=timeout) as client:
            yield client
