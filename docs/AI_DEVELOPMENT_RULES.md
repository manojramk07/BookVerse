# BookVerse - AI Development Rules & Engineering Standards

These rules govern all AI-assisted coding sessions and development activities on the **BookVerse** project. Every AI agent and developer working on this codebase must strictly adhere to these principles.

---

## 1. Core Principles

### Rule 1: Do Not Rewrite Working Code Unnecessarily
* Never perform wholesale rewrites or wipe out existing files that are already working as intended.
* Apply targeted, surgical modifications that respect existing structures and naming conventions.

### Rule 2: Inspect Existing Code Before Modifying It
* Always read and analyze the affected files, imported models, and calling widgets before authoring changes.
* Understand the context, parameters, and current lifecycle behavior before introducing edits.

### Rule 3: Preserve Existing Functionality
* Upgrades or feature additions must never break, downgrade, or remove previously working features.
* If a refactor is required, ensure all previous capabilities and navigation paths remain fully operational.

### Rule 4: Prevent Duplicate Files & Functionality
* Do not introduce duplicate model classes, redundant helper utilities, or overlapping widget definitions.
* Check `lib/widgets/` and `lib/models/` to reuse existing components before creating new ones.

### Rule 5: Keep Code Beginner-Friendly & Maintainable
* Write clear, clean, idiomatic Dart code with descriptive variable and method names.
* Avoid overly complex architectural abstractions, excessive boilerplate, or convoluted metaprogramming.

### Rule 6: Use Reusable Widgets When Appropriate
* Extract repeated UI patterns (e.g., cards, chips, headers, progress indicators) into dedicated `StatelessWidget` or `StatefulWidget` classes in `lib/widgets/`.
* Avoid creating widgets as raw top-level functions (e.g., prefer `class SectionTitle extends StatelessWidget` over `Widget sectionTitle()`).

### Rule 7: Keep Features Modular & Well-Organized
* Structure code within designated feature directories under `lib/screens/<feature_name>/`.
* Maintain clear boundaries between domain models, presentation screens, and reusable widgets.

### Rule 8: Minimize External Dependencies
* Do not add third-party packages unless they are strictly necessary for core requirements (e.g., local storage persistence).
* Always leverage Flutter's rich built-in standard library and Material components first.

### Rule 9: Justify New Dependencies Explicitly
* Whenever proposing or introducing a new package to `pubspec.yaml`, provide a clear, concise technical justification explaining why standard Flutter widgets or Dart utilities are insufficient.

### Rule 10: Verify & Test Changes After Implementation
* After modifying or adding code, verify syntax and lint health using `flutter analyze`.
* Verify that null-safety guarantees are maintained and no runtime exceptions or deprecation warnings are introduced.

### Rule 11: Fix Errors Before Moving to the Next Feature
* Never leave broken imports, compilation errors, or unresolved warnings behind.
* Resolve any current task issues completely before commencing work on subsequent phases or features.

### Rule 12: Keep Documentation Synchronized
* When architecture, models, or major features are updated, immediately update the relevant documents in `docs/` (`ARCHITECTURE.md`, `FEATURES.md`, `DATA_MODEL.md`, etc.).

### Rule 13: Strictly Scope Pull Requests & Code Changes
* Never make large, unrelated modifications across multiple disparate subsystems while working on a single feature.
* Keep changes focused, predictable, and directly tied to the requested task.

---

## 2. Code Style & Quality Checklist

Before completing any task, ensure the following checklist passes:
- [ ] Code formatted according to Dart standard guidelines.
- [ ] All variables and parameters are strongly typed and null-safe.
- [ ] `const` constructors used wherever possible for optimal Flutter rendering performance.
- [ ] Widget properties properly annotated with `@override` and `super.key`.
- [ ] `flutter analyze` executed with 0 errors and 0 warnings.
- [ ] Meaningful comments added for non-obvious business logic.
