# Automated Incident Response Platform

**Copyright (c) 2025 Bibas Gautam. All rights reserved.** (MIT-licensed, see `LICENSE`)

A defensive security orchestration platform that turns detections into
structured response playbooks, with human approval gates and reversible,
**simulated** containment actions — built for authorized lab, training, and
SOC-process-design environments.

> ⚠️ **Safety by design:** every "containment" action (isolate host, block
> IP, disable account, etc.) is *simulated*. Nothing in this codebase makes
> real calls to firewalls, EDR agents, or identity providers. Wiring in a
> real integration is a deliberate, separate step you would take outside
> this project if and when you're ready — see
> `backend/app/services/containment_simulator.py`.

## Key features

| Feature | Where it lives |
|---|---|
| Alert-to-incident workflow | `POST /api/alerts`, `POST /api/alerts/{id}/promote` |
| Playbooks (ordered steps: automated / approval-required / manual) | `app/routers/playbooks.py`, `app/services/playbook_engine.py` |
| Approval gates before any containment action runs | `app/routers/approvals.py` — role-restricted to `approver` / `incident_commander` / `admin` |
| Evidence collection with chain-of-custody log | `app/routers/evidence.py` |
| Task assignment | `app/routers/tasks.py` |
| Action audit trail (append-only) | `app/routers/audit.py`, `app/services/audit_service.py` |
| Notification system (in-app, extensible to email/webhook) | `app/services/notification_service.py` |
| Case timeline | `GET /api/incidents/{id}/timeline` |
| Safe containment simulation + reversal | `app/services/containment_simulator.py` |

## Stack

- **Backend:** Python, FastAPI, SQLAlchemy, PostgreSQL, JWT auth
- **Frontend:** React (Vite), React Router, Axios
- **Async/optional:** Celery + Redis (auto-expires stale approval requests; the API works fully without it)
- **Packaging:** Docker + Docker Compose

## Quick start (Windows)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop) and make sure it's running.
2. Double-click **`start.bat`** (or run it from a terminal in this folder).
3. The script builds and starts everything, then opens the UI at
   `http://localhost:5173`.
4. Log in with the default seeded account, then register any additional
   analyst/approver accounts you need from the web UI:

   | Username | Password | Role |
   |---|---|---|
   | `admin` | `ChangeMe123!` | admin |

   **Change this password after first login** — there's no in-app "change
   password" screen yet, so either register a new account with your own
   credentials and role, or update the `hashed_password` column for the
   `admin` row directly in PostgreSQL. The API docs (Swagger) are at
   `http://localhost:8000/docs`.
5. Run **`stop.bat`** when you're done.

## Quick start (macOS/Linux)

```bash
chmod +x start.sh
./start.sh
```

## Manual / local dev setup (no Docker)

**Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate   # venv\Scripts\activate on Windows
pip install -r requirements.txt
# Point DATABASE_URL at a running local PostgreSQL instance, e.g.:
export DATABASE_URL=postgresql://irp_user:irp_password@localhost:5432/irp_db
uvicorn app.main:app --reload
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

## Roles & the approval gate

Users have one of: `analyst`, `incident_commander`, `approver`, `admin`.
Only `approver`, `incident_commander`, or `admin` accounts can decide a
pending approval (`POST /api/approvals/{id}/decide`). A playbook step marked
`approval_required` is **never** auto-executed — it sits in
`awaiting_approval` until someone with the right role approves or rejects
it, and the decision (plus who made it) is written to both the case
timeline and the immutable audit log.

## Project layout

```
irp/
├── backend/
│   └── app/
│       ├── main.py              FastAPI app + router wiring + demo playbook seed
│       ├── models.py            SQLAlchemy models (users, alerts, incidents, ...)
│       ├── schemas.py           Pydantic request/response schemas
│       ├── auth.py              JWT auth + role guards
│       ├── celery_app.py        Optional background worker (approval expiry sweep)
│       ├── routers/             One router per feature area
│       └── services/
│           ├── playbook_engine.py         Step orchestration + approval gate logic
│           ├── containment_simulator.py   Safe, reversible simulated actions
│           ├── audit_service.py           Append-only audit log + timeline
│           └── notification_service.py    In-app notifications
├── frontend/
│   └── src/
│       ├── App.jsx, pages/*.jsx  Dashboard, Incidents, Playbooks, Approvals, Audit
│       └── api/client.js         Axios client with JWT attach
├── docker-compose.yml
├── start.bat / stop.bat / start.sh
├── LICENSE
└── README.md
```

## Extending to real systems (outside this project's scope)

If you later want a step to trigger a *real* EDR/firewall/IdP call instead
of a simulation, that's a deliberate integration you'd add yourself in
`containment_simulator.py` (or a new service module) with your own
credentials, scoping, and safety review — it is intentionally not included
here.

---

© 2025 Bibas Gautam. All rights reserved. Licensed under the MIT License
(see `LICENSE`).
