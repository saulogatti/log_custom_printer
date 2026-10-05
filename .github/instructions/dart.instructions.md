# AI Instructions — Dart (`log_custom_printer` library)

This repository is a **Dart library** (no Flutter dependency in `pubspec`).
The Flutter visual console moved to a **separate package**. This repository contains only the pure-Dart core.

> Important: also follow `.github/copilot-instructions.md`.

## Repository rules

1. **Never duplicate code.**
2. **Keep classes focused and reusable components in separate files.**
3. **Evolve toward clear domain, data, and utility boundaries incrementally.**
4. **Preserve the stable public exports in `lib/log_custom_printer.dart`.**

## Architecture guidelines

- Organize by layers when applicable:
  - **Integration** (consumer adapters and output strategies)
  - **Domain** (rules, entities, use cases)
  - **Data** (repositories, data sources, DTOs)
  - **Core** (shared utilities)
- Keep low coupling and clear responsibilities.
- Prefer composition over inheritance.
- Keep dependencies pointing inward.

## Dart rules

- Follow Effective Dart and `analysis_options.yaml`.
- Use clear naming.
- Keep code simple and focused.
- Handle errors explicitly.
- Preserve strong null safety; avoid unchecked `!`.
- Document public APIs with `///` when meaningful.

## Testing

- Follow Arrange-Act-Assert.
- Prioritize domain, serialization, cache, file-concurrency, and query tests.
- Prefer fakes/stubs over mocks when viable.

## Logging and observability

- Do not use loose `print` calls.
- Use this project’s logging strategy.
- Prefer structured logging where applicable.

## Code generation

- Do not edit `*.g.dart` manually.
- Regenerate code with `build_runner` after `json_serializable` model changes.

## Dependencies

- Add external packages only with clear benefit.
- Prefer existing project solutions first.

## Language requirement

- Write documentation, comments, and AI responses in **English**.

## Final checklist

- Code duplication removed?
- Classes focused?
- Reusable components extracted?
- Business logic separated from I/O?
- Async flows handled safely?
