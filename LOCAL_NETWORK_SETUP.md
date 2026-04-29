# Local Network Setup (Backend + Mobile)

Use this flow to run SwapStyle locally and access it from any device on the same Wi-Fi.

## 1) Start backend in LAN mode

**Option A: With Docker (if installed)**
From project root:
```
run_local_lan.cmd
```

**Option B: Without Docker (PostgreSQL + local Node)**
From project root:
```
run_local_simple.cmd
```

What it does:
- detects your LAN IP
- checks PostgreSQL 17 (or any version) is running
- runs prisma migrations
- starts NestJS API on 0.0.0.0:3001

API base URL for phones/tablets:
http://YOUR_LAN_IP:3001/api/v1

## 2) Build mobile APK for LAN backend

From mobile folder:

run_build_apk_lan.cmd

Or pass IP manually:

run_build_apk_lan.cmd 192.168.1.23

APK output:
mobile/build/app/outputs/flutter-apk/app-debug.apk

## 3) Optional direct build command

You can also use the base script directly:

run_build_apk.cmd http://192.168.1.23:3001/api/v1

## 4) Windows firewall (if phone cannot connect)

Open inbound TCP 3001 once (run as Administrator):

netsh advfirewall firewall add rule name="SwapStyle API 3001" dir=in action=allow protocol=TCP localport=3001

## 5) Quick connectivity test from another device

Open in mobile browser:

http://YOUR_LAN_IP:3001/api

If Swagger opens, your API is reachable on LAN.

## Notes

- Backend already listens on 0.0.0.0 in api/src/main.ts.
- Android cleartext HTTP is already enabled in mobile/android/app/src/main/AndroidManifest.xml.
- Phone and development machine must be on the same network/subnet.
