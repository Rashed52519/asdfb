"""FastAPI application entrypoint for Codex service."""

from __future__ import annotations

from fastapi import FastAPI

from .routes import router


def create_app() -> FastAPI:
    """Create and configure FastAPI application."""

    app = FastAPI(title="Frova Codex Service", version="0.1.0")
    app.include_router(router)
    return app


app = create_app()
