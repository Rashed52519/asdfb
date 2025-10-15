"""FastAPI dependency wiring for Codex service."""

from __future__ import annotations

from functools import lru_cache

from .config import get_settings
from .service import CodexService
from .shopify import ShopifyGraphQLClient


@lru_cache(maxsize=1)
def _get_shopify_client() -> ShopifyGraphQLClient:
    settings = get_settings()
    return ShopifyGraphQLClient(settings)


def get_codex_service() -> CodexService:
    """Return CodexService singleton for FastAPI dependency injection."""

    return CodexService(_get_shopify_client())
