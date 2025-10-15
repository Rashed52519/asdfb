"""Unit tests for CodexService eligibility filtering."""

from decimal import Decimal
from typing import Any, Dict, List

import pytest

from backend.services.codex.models import EligibleOrder
from backend.services.codex.service import CodexService


class DummyShopifyClient:
    def __init__(self, orders: List[Dict[str, Any]]) -> None:
        self._orders = orders

    async def fetch_orders(self) -> List[Dict[str, Any]]:
        return self._orders


def _base_order() -> Dict[str, Any]:
    return {
        "id": "gid://shopify/Order/1",
        "name": "#1001",
        "displayFinancialStatus": "PAID",
        "fulfillmentStatus": "UNFULFILLED",
        "paymentGatewayNames": ["visa"],
        "totalOutstandingSet": {"shopMoney": {"amount": "0.00", "currencyCode": "SAR"}},
        "shippingAddress": {
            "name": "ريم",
            "phone": "+966500000001",
            "address1": "حي الياسمين",
            "address2": None,
            "city": "Riyadh",
            "province": "Riyadh",
            "latitude": 24.774265,
            "longitude": 46.738586,
        },
        "lineItems": {
            "edges": [
                {
                    "node": {
                        "id": "gid://shopify/LineItem/1",
                        "title": "Robe",
                        "requiresShipping": True,
                        "fulfillableQuantity": 1,
                        "fulfillmentService": {"type": "MANUAL"},
                    }
                }
            ]
        },
        "customer": {"displayName": "ريم"},
    }


@pytest.mark.asyncio
async def test_paid_order_is_eligible() -> None:
    client = DummyShopifyClient([_base_order()])
    service = CodexService(client)

    result = await service.list_eligible_orders()

    assert len(result) == 1
    eligible = result[0]
    assert isinstance(eligible, EligibleOrder)
    assert eligible.order_id == "#1001"
    assert eligible.cod_sar == Decimal("0")


@pytest.mark.asyncio
async def test_cod_order_sets_amount() -> None:
    order = _base_order()
    order["displayFinancialStatus"] = "PENDING"
    order["paymentGatewayNames"] = ["Cash on Delivery"]
    order["totalOutstandingSet"] = {
        "shopMoney": {"amount": "249.00", "currencyCode": "SAR"}
    }
    client = DummyShopifyClient([order])
    service = CodexService(client)

    result = await service.list_eligible_orders()

    assert len(result) == 1
    assert result[0].cod_sar == Decimal("249.00")
    assert result[0].notes == "COD"


@pytest.mark.asyncio
async def test_no_fulfillable_quantity_excluded() -> None:
    order = _base_order()
    order["fulfillmentStatus"] = "PARTIALLY_FULFILLED"
    order["lineItems"]["edges"][0]["node"]["fulfillableQuantity"] = 0
    client = DummyShopifyClient([order])
    service = CodexService(client)

    result = await service.list_eligible_orders()

    assert result == []


@pytest.mark.asyncio
async def test_missing_phone_excluded() -> None:
    order = _base_order()
    order["shippingAddress"]["phone"] = ""
    client = DummyShopifyClient([order])
    service = CodexService(client)

    result = await service.list_eligible_orders()

    assert result == []
