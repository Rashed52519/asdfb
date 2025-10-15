"""Pydantic models for Codex service responses."""

from __future__ import annotations

from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, Field


class Customer(BaseModel):
    name: str = Field(..., description="Customer name as captured in Shopify")
    phone: str = Field(..., description="E.164 formatted phone number")


class Address(BaseModel):
    text: str = Field(..., description="Human readable delivery address")
    lat: Optional[float] = Field(None, description="Latitude if available")
    lon: Optional[float] = Field(None, description="Longitude if available")


class EligibleOrder(BaseModel):
    order_id: str = Field(..., description="Shopify order number")
    shop_order_gid: str = Field(..., description="Shopify order global id")
    customer: Customer
    address: Address
    cod_sar: Decimal = Field(Decimal("0"), description="Cash on delivery amount in SAR")
    notes: str = Field("", description="Additional handling notes")

    class Config:
        json_encoders = {Decimal: lambda value: float(value)}
