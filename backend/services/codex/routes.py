"""API routes for Codex service."""

from __future__ import annotations

from typing import List

from fastapi import APIRouter, Depends

from .dependencies import get_codex_service
from .models import EligibleOrder
from .service import CodexService

router = APIRouter()


@router.get("/codex/eligible", response_model=List[EligibleOrder])
async def list_eligible_orders(service: CodexService = Depends(get_codex_service)) -> List[EligibleOrder]:
    """Return Shopify orders eligible for Codex deliveries."""

    return await service.list_eligible_orders()
