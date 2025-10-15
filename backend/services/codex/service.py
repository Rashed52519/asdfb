"""Business logic for Codex eligible orders."""

from __future__ import annotations

import logging
import unicodedata
from decimal import Decimal
from typing import Any, Dict, Iterable, List, Optional

from .models import Address, Customer, EligibleOrder
from .shopify import ShopifyClientProtocol

LOGGER = logging.getLogger(__name__)

_FULFILLMENT_STATUSES = {"UNFULFILLED", "PARTIALLY_FULFILLED"}
_COD_KEYWORDS = {"cash", "delivery"}
_RIYADH_KEYWORDS = {"riyadh", "ar riyadh", "ar-riyadh", "الرياض"}


class CodexService:
    """Service encapsulating Codex eligibility logic."""

    def __init__(self, shopify_client: ShopifyClientProtocol) -> None:
        self._shopify_client = shopify_client

    async def list_eligible_orders(self) -> List[EligibleOrder]:
        """Return eligible Shopify orders for delivery."""

        raw_orders = await self._shopify_client.fetch_orders()
        eligible: List[EligibleOrder] = []
        for order in raw_orders:
            reason = self._eligibility_reason(order)
            if reason is not None:
                LOGGER.info("Order %s excluded: %s", order.get("id"), reason)
                continue
            eligible.append(self._to_eligible_order(order))
        return eligible

    def _eligibility_reason(self, order: Dict[str, Any]) -> Optional[str]:
        if order.get("displayFinancialStatus") not in {"PAID", "PENDING"}:
            return "financial_status_not_supported"

        if order.get("fulfillmentStatus") not in _FULFILLMENT_STATUSES:
            return "fulfillment_status_not_supported"

        shipping_address = order.get("shippingAddress")
        if not shipping_address:
            return "missing_shipping_address"
        if not shipping_address.get("phone"):
            return "missing_phone"
        if not self._is_riyadh(shipping_address):
            return "outside_riyadh"

        line_items = self._iter_line_items(order.get("lineItems"))
        has_fulfillable = any(self._is_fulfillable_item(item) for item in line_items)
        if not has_fulfillable:
            return "no_fulfillable_items"

        if order.get("displayFinancialStatus") == "PENDING" and not self._is_cod_gateway(order.get("paymentGatewayNames", [])):
            return "pending_without_cod_gateway"

        if order.get("displayFinancialStatus") == "PENDING" and not self._cod_amount(order):
            return "cod_amount_missing"

        return None

    def _to_eligible_order(self, order: Dict[str, Any]) -> EligibleOrder:
        cod_amount = self._cod_amount(order)
        notes = "COD" if cod_amount > 0 else ""

        address = self._build_address(order["shippingAddress"])
        customer = Customer(
            name=order["shippingAddress"].get("name", "").strip() or order.get("customer", {}).get("displayName", ""),
            phone=order["shippingAddress"]["phone"],
        )

        return EligibleOrder(
            order_id=order.get("name", ""),
            shop_order_gid=order["id"],
            customer=customer,
            address=address,
            cod_sar=cod_amount,
            notes=notes,
        )

    def _build_address(self, address: Dict[str, Any]) -> Address:
        components = [
            address.get("address1"),
            address.get("address2"),
            address.get("city"),
            address.get("province"),
        ]
        text = "، ".join([component for component in components if component]) or ""
        return Address(
            text=text,
            lat=address.get("latitude"),
            lon=address.get("longitude"),
        )

    def _cod_amount(self, order: Dict[str, Any]) -> Decimal:
        if order.get("displayFinancialStatus") != "PENDING":
            return Decimal("0")

        outstanding = order.get("totalOutstandingSet") or {}
        shop_money = outstanding.get("shopMoney") or {}
        amount_str = shop_money.get("amount")
        if not amount_str:
            return Decimal("0")
        try:
            return Decimal(str(amount_str))
        except Exception:  # noqa: BLE001
            LOGGER.warning("Invalid COD amount for order %s", order.get("id"))
            return Decimal("0")

    def _is_cod_gateway(self, gateways: Iterable[str]) -> bool:
        if not gateways:
            return False
        normalized = [gateway.lower() for gateway in gateways if gateway]
        for gateway in normalized:
            if all(keyword in gateway for keyword in _COD_KEYWORDS):
                return True
        return False

    def _iter_line_items(self, line_items_node: Optional[Dict[str, Any]]) -> Iterable[Dict[str, Any]]:
        if not line_items_node:
            return []
        edges = line_items_node.get("edges", [])
        return [edge.get("node", {}) for edge in edges]

    def _is_fulfillable_item(self, item: Dict[str, Any]) -> bool:
        if not item.get("requiresShipping"):
            return False
        fulfillment_service = (item.get("fulfillmentService") or {}).get("type")
        if fulfillment_service != "MANUAL":
            return False
        fulfillable_qty = item.get("fulfillableQuantity")
        try:
            return int(fulfillable_qty) > 0
        except (TypeError, ValueError):
            return False

    def _is_riyadh(self, address: Dict[str, Any]) -> bool:
        for key in ("city", "province"):
            value = address.get(key)
            if not value:
                continue
            normalized = self._normalize(value)
            for keyword in _RIYADH_KEYWORDS:
                if keyword in normalized:
                    return True
        return False

    @staticmethod
    def _normalize(value: str) -> str:
        normalized = unicodedata.normalize("NFKD", value).casefold()
        return normalized
