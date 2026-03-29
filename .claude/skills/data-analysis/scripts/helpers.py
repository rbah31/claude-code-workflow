"""
Data analysis helper template.

Replace this with project-specific query functions. The pattern:
- Each function encodes domain knowledge in its docstring (gotchas, edge cases)
- Claude composes these functions into investigation scripts on the fly
- Keep functions small and focused — one query pattern per function

Example usage by Claude (generated on the fly):
    from scripts.helpers import fetch_signups, by_source
    mon, tue = fetch_signups("2026-03-10"), fetch_signups("2026-03-11")
    print(by_source(tue) - by_source(mon))  # → see what changed
"""


def fetch_events(day: str, event_type: str) -> list:
    """Fetch events for one day.

    Gotchas:
    - Use ISO date format: "2026-03-11"
    - event_type must match exactly (case-sensitive)
    - Returns raw records — dedupe before counting if needed
    """
    raise NotImplementedError("Replace with your project's data fetching logic")


def count_unique(events: list, key: str = "user_id") -> int:
    """Count unique values for a given key.

    Gotchas:
    - user_id may be null for anonymous events — filter or count separately
    - For DynamoDB: use consistent reads if counting after a recent write
    """
    raise NotImplementedError("Replace with your implementation")


def by_segment(events: list, segment_key: str) -> dict:
    """Group events by a segment (source, plan, region, etc.).

    Gotchas:
    - Normalize segment values (lowercase, strip whitespace)
    - Empty/null segments should be grouped as "unknown", not dropped
    """
    raise NotImplementedError("Replace with your implementation")