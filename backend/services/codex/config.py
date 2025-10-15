"""Configuration handling for the Codex service."""

from __future__ import annotations

import os
from dataclasses import dataclass
from functools import lru_cache


@dataclass(frozen=True)
class Settings:
    """Runtime settings loaded from environment variables."""

    shop_domain: str
    admin_api_token: str
    graphql_api_version: str = "2024-07"
    page_size: int = 50


def _env(name: str) -> str:
    try:
        value = os.environ[name].strip()
    except KeyError as exc:
        raise RuntimeError(f"Missing required environment variable: {name}") from exc

    if not value:
        raise RuntimeError(f"Environment variable {name} must not be empty")
    return value


def _build_settings() -> Settings:
    page_size_str = os.getenv("SHOPIFY_PAGE_SIZE")
    page_size = int(page_size_str) if page_size_str else 50
    if page_size < 1 or page_size > 250:
        raise RuntimeError("SHOPIFY_PAGE_SIZE must be between 1 and 250")

    return Settings(
        shop_domain=_env("SHOP_DOMAIN"),
        admin_api_token=_env("ADMIN_API_TOKEN"),
        graphql_api_version=os.getenv("SHOPIFY_API_VERSION", "2024-07"),
        page_size=page_size,
    )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return cached Settings constructed from the process environment."""

    return _build_settings()
