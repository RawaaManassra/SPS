# Smart Parking Research Notes

Source document:
- `C:/Users/ASUS/Downloads/Graduiation_project (10).pdf`

Saved references:
- Extracted raw text: [research_extracted.txt](C:\flut\notes\research_extracted.txt)
- This notes file: [research_notes.md](C:\flut\notes\research_notes.md)

## Project Identity
- Project title: Smart Parking Palestine
- Context: graduation project at Palestine Polytechnic University
- Initial city scope: Hebron, Palestine
- Core goal: replace malfunction-prone physical parking meters with a digital parking management system

## Main Problem Being Solved
- Traditional parking meters in Hebron malfunction frequently.
- Drivers can receive unfair violations even when they paid.
- Manual enforcement increases the chance of unfair fines and corruption.
- Drivers must physically return to the car to extend parking time.
- Municipality lacks real-time oversight and structured parking data.

## High-Level Solution
- One mobile system for drivers and inspectors
- One web dashboard for municipal authorities
- Digital parking sessions instead of depending on physical meters
- Wallet-based payments with local payment methods
- Real-time verification for inspectors
- Full traceability for sessions, payments, violations, and inspector actions

## Target Users
- Drivers / vehicle owners
- Parking enforcement officers / inspectors
- Municipal authorities / administrators

## Important Research Findings
- Up to 30% of busy city-center traffic can come from drivers searching for parking.
- Smart parking systems in other cities reduced search time and improved compliance/revenue.
- Examples referenced in the paper: San Francisco SFpark, Cologne, Barcelona.

## Why Existing Apps Are Not Enough
- International apps often charge transaction/service fees.
- They assume strong connectivity and global payment infrastructure.
- They do not match Palestinian municipal rules and local payment methods well.
- They are not designed specifically for anti-corruption traceability.
- Apps discussed: ParkMobile, PayByPhone, EasyPark.

## Local Design Decisions Justified by the Research
- Use a wallet-based model instead of charging per transaction.
- Support local payment methods: Reflect, Jawwal Pay, and cash deposits at municipality offices.
- Keep full transaction records for accountability.
- Design for local infrastructure constraints and municipal workflows.
- Support intermittent or lower-quality connectivity better than typical commercial apps.

## Scope of the Project
### Included
- Driver mobile app
- Inspector mobile app
- Municipal admin web dashboard
- Digital wallet
- Parking session management
- QR-code-based session start
- GPS location capture
- Push notifications
- Parking map
- Violation management
- Clamp tracking
- Reports and dashboard analytics
- Auditability / transparency

### Out of Scope / Future Work
- Advanced navigation / route optimization
- Government system integration
- Parking reservations / pre-booking
- Dynamic pricing
- Multi-city deployment
- Full offline mode

## Driver Features
- Register as vehicle owner
- Provide personal info and vehicle details
- Complete identity verification
- Manage profile
- Start parking session
- Extend active parking session remotely
- View parking history
- View parking map
- Pay violations
- Submit complaint / report issue

Important details:
- Starting a parking session requires registered account, at least one vehicle, and sufficient wallet balance.
- Session start flow includes vehicle selection, QR scan or manual location entry, fee calculation, wallet deduction, confirmation, and adding a blue marker to the map.
- Extending session includes viewing remaining time, selecting extra duration, recalculating the fee, wallet payment, and confirmation.
- Violation payment requires login, unpaid violation, and sufficient wallet balance.

## Inspector Features
- Inspector login with assigned account
- Scan or manually enter license plate
- View current parking status
- Issue violation
- Capture violation evidence
- Clamp vehicle
- Remove clamp
- View daily activity summary

Important inspector details:
- Plate verification can be manual or camera-based if technically feasible.
- View status shows active, expired, or none.
- Violation flow includes choosing violation type, checking registration, notifying owner if registered, and logging the action.
- Evidence capture requires photo(s), GPS, and timestamp.
- Clamp flow records status, GPS, adds a red map marker, and links clamp to the violation.
- Remove clamp flow verifies payment, removes clamp, removes red marker, and resolves the violation.

## Admin Features
- Manage inspector accounts
- View active parking sessions
- View parking map
- View violations
- Manage complaints
- View reports
- View statistics dashboard

Important admin details:
- Inspector management includes create, update, activate, deactivate, and credential generation.
- Violations view includes vehicle, inspector, timestamp, status, evidence photos, and filters.
- Reports include parking, payments, and violations.
- Dashboard includes usage metrics, revenue summaries, and enforcement charts.

## Non-Functional Requirements
### Usability
- New users should register and start first parking session within 5 minutes.
- At least 80% of users should complete core tasks on first attempt.
- SUS target score: at least 70.

### Performance
- Start parking session: under 2 seconds.
- Process payment: under 3 seconds.
- Extend parking session: under 2 seconds.
- Push notification delivery: under 5 seconds.
- Support 500+ concurrent users.
- Availability target: 99% during operating hours.

### Security
- Encrypted communication between app and server.
- Certified third-party payment gateways.
- Secure password storage.
- Session timeout after 30 minutes of inactivity.
- Limit login attempts to 5 tries before a 15-minute lock.

## Architecture Notes
- Architecture pattern: Layered Architecture.
- Layers: Presentation, Business Logic, Data Access.
- External services: payment gateways, notification services, map providers.
- Presentation: mobile app for drivers/inspectors and web dashboard for admins.
- Business logic: sessions, violations, payments, notifications, reports.
- Data access: database operations, consistency, integrity.

## Technical Platform from the Research
- Mobile: Flutter for Android/iOS
- Web admin: responsive web dashboard
- Backend: Node.js RESTful API
- Real-time updates: WebSocket
- Integrations: QR codes, GPS, push notifications, payment gateways, maps (Google Maps or OpenStreetMap)

## Visual / Diagram Notes
- Use case diagram
- Class diagram
- Context diagram
- Sequence diagram: driver extends parking session
- Sequence diagram: inspector verifies parking session
- State machine diagram: parking session
- System architecture diagram
- Entity-relationship diagram
- UI mockups for driver app, inspector app, and admin dashboard

## Frontend Implications to Remember
- Driver and inspector are separate role experiences even if they share one codebase.
- Wallet is central to many flows.
- QR scanning is part of starting a session.
- Map is part of the proposed system.
- Violation evidence is mandatory in inspector workflows.
- Clamp status and map markers are in scope.
- Complaints are in scope.
- Identity verification is explicitly mentioned in registration.
- Admin dashboard is operational, not just analytical.

## Notes About Scope Differences
- This research explicitly includes wallet-based payments, QR-code session start, complaints management, clamp/unclamp workflows, and identity verification.
- If later discussions differ, this file should be treated as a source-of-truth reference unless the team approved a newer spec.
