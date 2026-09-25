@echo off
REM ============================================================
REM  Automated Incident Response Platform
REM  Copyright (c) 2025 Bibas Gautam. All rights reserved.
REM
REM  Starts the full stack (PostgreSQL, Redis, FastAPI backend,
REM  React frontend) using Docker Compose.
REM ============================================================

title Automated Incident Response Platform - Launcher
color 0A

echo ============================================================
echo   Automated Incident Response Platform
echo   Copyright (c) 2025 Bibas Gautam. All rights reserved.
echo ============================================================
echo.

where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker was not found on this machine.
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    echo then re-run this script.
    pause
    exit /b 1
)

docker info >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker Desktop does not appear to be running.
    echo Please start Docker Desktop and re-run this script.
    pause
    exit /b 1
)

echo [1/3] Building images (this may take a few minutes the first time)...
docker compose build
if %errorlevel% neq 0 (
    echo [ERROR] Build failed. See the output above for details.
    pause
    exit /b 1
)

echo.
echo [2/3] Starting services (PostgreSQL, Redis, backend API, frontend)...
docker compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start services. See the output above for details.
    pause
    exit /b 1
)

echo.
echo [3/3] Waiting for the backend to become healthy...
timeout /t 8 /nobreak >nul

echo.
echo ============================================================
echo   Platform is starting up.
echo.
echo   Frontend (web UI):   http://localhost:5173
echo   Backend API docs:    http://localhost:8000/docs
echo.
echo   Default login:
echo     Username: admin
echo     Password: ChangeMe123!
echo   Please change this password after your first login.
echo.
echo   Register additional analyst/approver accounts from the web UI.
echo   To grant elevated roles (approver / incident_commander / admin),
echo   set the role at registration via POST /api/auth/register, or
echo   update the user's "role" column directly in PostgreSQL.
echo.
echo   Run "stop.bat" to stop the platform.
echo ============================================================
echo.

start "" http://localhost:5173

pause
