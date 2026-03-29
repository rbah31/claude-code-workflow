---
paths:
  - "src/api/**"
  - "src/routes/**"
  - "src/controllers/**"
  - "src/middleware/**"
---

# Backend API Conventions

## Endpoints
- Use RESTful naming: plural nouns for resources (`/users`, `/orders`).
- Use kebab-case for URL paths (`/user-profiles`, not `/userProfiles`).
- Version APIs in the URL path (`/v1/`, `/v2/`).
- Return consistent response shapes: `{ data, error, meta }`.

## Validation & errors
- Validate all inputs at the boundary (controller/route level). Never trust client data.
- Return appropriate HTTP status codes. Do not use 200 for everything.
- Include actionable error messages. `"email is required"` not `"validation error"`.
- Log errors with enough context to debug (request ID, user ID, input summary).

## Authentication & authorization
- Verify auth on every protected endpoint. Do not rely on client-side checks.
- Use middleware for auth — do not repeat auth logic in each handler.
- Check authorization (permissions) separately from authentication (identity).

## Performance
- Paginate list endpoints. Never return unbounded result sets.
- Use database indexes for frequently queried fields.
- Avoid N+1 queries. Use eager loading or batch queries when fetching related data.

## Security
- Sanitize inputs to prevent injection (SQL, NoSQL, command injection).
- Set security headers (CORS, CSP, X-Frame-Options) at the middleware level.
- Rate-limit public endpoints. Use stricter limits on auth endpoints.