# ios-event-feed-assignment

## Architecture & Design Choices
The app uses **MVVM + Repository pattern** with **SwiftData** for local caching:

- **MVVM:** Separates UI, business logic, and state for maintainability and testability.
- **Repository:** Centralizes API access and caching, enabling offline support.
- **Networking:** `APIClient` handles async network calls; DTOs map JSON responses to models.
- **Offline support:** Events, event details, and profile persist locally; UI shows network state.
- **File downloads:** `FileDownloadService` manages large (~1GB) downloads with progress and local storage.
- **Event feed:** Every 5th event includes a **Download Log** button for large files.

This architecture balances **clarity, scalability, and resilience**, demonstrating production-ready patterns while keeping code simple and readable.

---

## Running the App and Backend

### Backend (Go)
1. Install Go: [https://golang.org/dl/](https://golang.org/dl/)
2. Navigate to the `server` folder.
3. Run:
```bash
go run main.go
```
4. Backend runs at `http://localhost:8080`
5. Hardcoded credentials:
   - Email: `test@demo.com`
   - Password: `password`

### iOS App
1. Open `AlcatrazEvents.xcodeproj` in **Xcode 17+**.
2. Build & run on Simulator or Device.
3. Log in using the credentials above.
4. Navigate tabs:
   - **Events:** Event feed with pagination & refresh; every 5th event includes a **Download Log** button.
   - **Event Details:** Metadata and downloadable logs.
   - **Profile:** User info and downloaded logs.

> On a device, replace `localhost` with your machine IP in `APIClient` and `FileDownloadService`.

---

## Known Limitations & Trade-offs
- **Token storage & Autologin:** Currently hardcoded for simplicity; Keychain storage and auto-login could be added.
- **Sign out:** Not implemented; would require clearing token and cached user.
- **Networking layer:** Minimal error handling; could add retries, backoff, and logging.
- **Logging & Observability:** Errors mostly printed; a proper logging framework would help in production.
- **Unit/UI tests:** Limited; could add repository tests, snapshot/UI tests for major screens.
- **Localization:** Not implemented; all strings are currently English.
- **Design System:** No shared component library; UI uses constants per screen, could unify.

**Known improvements:**
- Persistent backend storage.
- Enhanced offline caching strategies.
- Detailed download feedback & retry logic.
- More comprehensive testing and logging.
