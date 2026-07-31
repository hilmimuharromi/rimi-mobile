# Rimi Mobile

Flutter app untuk **Rimi Baby Shop & Rewards** — member-facing mobile client.

Design source: [Google Stitch — Rimi App UI Design](https://stitch.withgoogle.com/projects/3601805917375330502)

## Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24+ / Dart 3.5+ |
| State | Riverpod 2.x |
| Routing | go_router |
| HTTP | Dio + JWT interceptors |
| Fonts | Quicksand + Plus Jakarta Sans (google_fonts) |
| API | `https://rimi-api.miromi.id/api/v1` |

## Design System (Stitch)

| Token | Value | Use |
|-------|-------|-----|
| Primary | `#BFE3FF` | Header, soft surfaces, brand |
| Secondary | `#FF8B76` | CTA, accent, alerts |
| Tertiary | `#FFC24B` | Rewards, highlights |
| Neutral | `#4A5568` | Body text, borders |
| Headline | Quicksand | Titles |
| Body | Plus Jakarta Sans | Labels, body |

## Setup

```bash
# Requires Flutter SDK >= 3.24
flutter pub get
flutter run
```

Env: copy `.env.example` → set `API_BASE_URL` if needed (default production domain baked in `lib/core/constants/app_config.dart`).

## Demo login (seed data)

```
Email:    budi@email.com
Password: member123
```

## Screens (Phase 1)

1. Splash → Onboarding
2. Login / Register
3. Home shell (BottomNav: Beranda · Produk · Keranjang · Rewards · Profil)
4. Product list + detail
5. Profile + member card shell

## API map (member)

| Feature | Endpoint |
|---------|----------|
| Login | `POST /api/v1/auth/login` |
| Me | `GET /api/v1/auth/me` |
| Products | `GET /api/v1/products` |
| Categories | `GET /api/v1/categories` |
| Cart | `GET/POST/PATCH/DELETE /api/v1/cart` |
| Orders | `/api/v1/orders` |
| Wallet | `/api/v1/wallet` |
| Redemption | `/api/v1/redemption/*` |
| Referral | `/api/v1/referral/*` |

## Repo

```
lib/
  core/          # api, theme, router, constants
  features/      # auth, home, product, cart, profile, rewards
  shared/        # models, widgets, providers
```
