"""Codex service package."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:  # pragma: no cover
    from fastapi import FastAPI


def create_app() -> "FastAPI":
    """Lazily import and create the FastAPI application."""

    from .app import create_app as _create_app

    return _create_app()


__all__ = ["create_app"]
