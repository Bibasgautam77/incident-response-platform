#!/usr/bin/env bash
# Automated Incident Response Platform
# Copyright (c) 2025 Bibas Gautam. All rights reserved.
set -e
echo "Building and starting the Automated Incident Response Platform..."
docker compose build
docker compose up -d
echo ""
echo "Frontend: http://localhost:5173"
echo "Backend API docs: http://localhost:8000/docs"
