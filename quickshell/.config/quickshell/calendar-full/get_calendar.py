#!/usr/bin/env python3
"""
Google Calendar Event Fetcher
Fetches ICS files from Google Calendar and outputs formatted events
"""

import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from urllib.request import urlopen
from urllib.error import URLError

try:
    from icalendar import Calendar
except ImportError:
    print("Error: icalendar library not found. Install with: pip3 install icalendar", file=sys.stderr)
    sys.exit(1)

# Configuration
SCRIPT_DIR = Path(__file__).parent
ENV_FILE = SCRIPT_DIR / ".env.calendar"
CACHE_DIR = Path.home() / ".cache" / "quickshell" / "calendar"
CACHE_FILE = CACHE_DIR / "google_events.json"

CACHE_DIR.mkdir(parents=True, exist_ok=True)

def load_env():
    """Load GOOGLE_ICAL_URLS from .env.calendar"""
    if not ENV_FILE.exists():
        print(f"Error: {ENV_FILE} not found", file=sys.stderr)
        return []

    urls = []
    with open(ENV_FILE) as f:
        for line in f:
            if line.startswith("GOOGLE_ICAL_URLS="):
                # Extract URLs between quotes
                urls_str = line.split('=', 1)[1].strip().strip('"')
                urls = [url.strip() for url in urls_str.split('|') if url.strip()]
    return urls

def fetch_ics(url):
    """Fetch ICS file from URL"""
    try:
        with urlopen(url, timeout=10) as response:
            return response.read().decode('utf-8')
    except (URLError, Exception) as e:
        print(f"Warning: Failed to fetch {url}: {e}", file=sys.stderr)
        return None

def parse_events(ics_content):
    """Parse ICS content and extract events"""
    events = []
    try:
        cal = Calendar.from_ical(ics_content)

        for component in cal.walk():
            if component.name != "VEVENT":
                continue

            try:
                summary = str(component.get('summary', 'Untitled'))
                dtstart = component.get('dtstart')
                dtend = component.get('dtend')
                description = str(component.get('description', ''))

                if not dtstart:
                    continue

                # Extract datetime objects
                start_dt = dtstart.dt if dtstart else None
                end_dt = dtend.dt if dtend else start_dt

                # Convert to datetime if it's a date
                if isinstance(start_dt, type(datetime.now().date())):
                    start_dt = datetime.combine(start_dt, datetime.min.time())
                if isinstance(end_dt, type(datetime.now().date())):
                    end_dt = datetime.combine(end_dt, datetime.min.time())

                # Convert to timestamps
                start_epoch = int(start_dt.timestamp()) if start_dt else 0
                end_epoch = int(end_dt.timestamp()) if end_dt else start_epoch

                # Format date and time strings
                date_str = start_dt.strftime("%Y-%m-%d") if start_dt else ""
                time_str = start_dt.strftime("%H:%M") if start_dt else ""

                if start_epoch > 0:
                    events.append({
                        "summary": summary,
                        "date": date_str,
                        "time": time_str,
                        "start": start_epoch,
                        "end": end_epoch,
                        "desc": description,
                        "type": "event",
                        "is_compact": False
                    })
            except Exception as e:
                print(f"Warning: Failed to parse event: {e}", file=sys.stderr)
                continue

    except Exception as e:
        print(f"Error: Failed to parse ICS: {e}", file=sys.stderr)

    return events

def get_upcoming_events(all_events, days_ahead=7):
    """Filter for upcoming events"""
    now = datetime.now()
    cutoff = (now + timedelta(days=days_ahead)).timestamp()

    upcoming = [e for e in all_events if e['start'] >= now.timestamp() and e['start'] <= cutoff]
    return sorted(upcoming, key=lambda x: x['start'])

def main():
    urls = load_env()

    if not urls:
        print("Error: No GOOGLE_ICAL_URLS found in .env.calendar", file=sys.stderr)
        output = {"events": [], "cached_at": datetime.now().isoformat(), "error": "No calendars configured"}
        with open(CACHE_FILE, 'w') as f:
            json.dump(output, f)
        return

    all_events = []

    # Fetch and parse events from all calendars
    for url in urls:
        print(f"Fetching: {url}", file=sys.stderr)
        ics_content = fetch_ics(url)

        if ics_content:
            events = parse_events(ics_content)
            all_events.extend(events)
            print(f"  Found {len(events)} events", file=sys.stderr)

    # Filter for upcoming events
    upcoming = get_upcoming_events(all_events)

    # Write cache
    output = {
        "events": upcoming,
        "cached_at": datetime.now().isoformat(),
        "total_fetched": len(all_events)
    }

    with open(CACHE_FILE, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"Cached {len(upcoming)} upcoming events", file=sys.stderr)

    # If --json flag, output to stdout
    if "--json" in sys.argv:
        print(json.dumps({"events": upcoming}))

if __name__ == "__main__":
    main()
