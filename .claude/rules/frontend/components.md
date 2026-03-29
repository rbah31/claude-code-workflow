---
paths:
  - "src/components/**"
  - "src/pages/**"
  - "src/views/**"
  - "src/app/**"
---

# Frontend Component Conventions

## Components
- Use PascalCase for component names and filenames (`UserProfile.tsx`).
- One component per file. Collocate styles, tests, and types with the component.
- Keep components small. If a component exceeds ~150 lines, split it.
- Prefer composition over props drilling. Use context or state management for deep trees.

## State management
- Keep state as local as possible. Lift only when necessary.
- Derive computed values instead of storing them in state.
- Avoid redundant state — if it can be calculated from other state, calculate it.

## Styling
- Use the project's styling solution consistently (Tailwind, CSS modules, styled-components).
- Do not mix styling approaches in the same component.
- Use design tokens or variables for colors, spacing, and typography. No magic numbers.

## Accessibility
- Include alt text on all images. Use empty alt (`alt=""`) for decorative images.
- Use semantic HTML elements (`<button>`, `<nav>`, `<main>`) not generic `<div>` for everything.
- Ensure keyboard navigability. All interactive elements must be focusable and operable.
- Use ARIA attributes only when semantic HTML is insufficient.

## Performance
- Lazy-load routes and heavy components. Do not bundle everything upfront.
- Memoize expensive computations and callbacks only when measured necessary.
- Optimize images: use appropriate formats, serve responsive sizes.

## Error handling
- Display user-friendly error messages. Never show raw error objects or stack traces.
- Implement error boundaries to catch and handle component-level failures.
- Handle loading, error, and empty states explicitly for every data-fetching component.