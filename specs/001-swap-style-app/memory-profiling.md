# Memory Profiling Guide — Swap Style

## Backend (NestJS)

### Tools
- **Node.js `--inspect` + Chrome DevTools Heap Snapshots**
- **`clinic.js`**: `npm install -g clinic && clinic heap -- node dist/main`
- **`node --expose-gc`**: Manual GC trigger during profiling

### Key monitoring points

| Area | Risk | Notes |
|------|------|-------|
| Redis connection pool | Medium | `maxRetriesPerRequest: 3` already set; watch for connection leaks |
| WebSocket connections | High | Each `match:{id}` room kept in memory; rooms auto-cleanup when match expires (14 days) |
| BullMQ job queue | Medium | `match-expiry` + `streak-reset` queues; monitor Redis memory with `redis-cli info memory` |
| Prisma connection pool | Medium | Default pool = `min(cpu_count * 2 + 1, 10)`; override with `?connection_limit=5` in `DATABASE_URL` for low-RAM VMs |

### Profiling steps

```bash
# 1. Start with inspector
NODE_OPTIONS="--inspect" npm run start:dev

# 2. Open chrome://inspect → "Open dedicated DevTools for Node"
# 3. Take a heap snapshot baseline
# 4. Run k6 load test: k6 run k6-load-test.js
# 5. Take heap snapshot after load
# 6. Compare snapshots → look for retained DOM/EventEmitter/Socket growth
```

### Memory leak indicators
- Heap size grows monotonically without plateau after GC
- Large number of `Socket` or `EventEmitter` objects in heap snapshot
- Redis `used_memory` grows without bound after load test

---

## Mobile (Flutter)

### Tools
- **Flutter DevTools Memory tab**: `flutter run --profile && flutter pub global run devtools`
- **`dart:developer`**: `debugger()` calls for pause-and-inspect

### Key monitoring points

| Widget / Provider | Risk | Notes |
|---|---|---|
| `ConversationScreen` Socket.IO listener | Medium | Disposed in `dispose()` — verify teardown on pop |
| `DiscoveryScreen` Swipe cards | Low | Offscreen cards garbage collected by Flutter framework |
| Image cache (NetworkImage) | Medium | Add `PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024` (100 MB cap) |
| `chatMessagesProvider` | Low | `autoDispose` — released when screen is popped |

### Profiling steps

```bash
# 1. Run in profile mode
flutter run --profile

# 2. Open Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 3. Navigate to Memory tab
# 4. Perform: open chat thread → send messages → back → re-open
# 5. Trigger GC → check for leaked ChatRepository or Socket instances
```

### Leak prevention checklist
- [ ] `chatRepository.dispose()` called in `chat_repository.dart` when stream subscription is cancelled
- [ ] `SocketIO.disconnect()` called in `ConversationScreen.dispose()`
- [ ] `filterProvider` SharedPreferences writes are debounced
- [ ] Image cache size capped in `main.dart`
