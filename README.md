# dotfiles

A Nix-based dotfiles setup focused on clear abstraction boundaries between users, systems, and shared modules.

These dotfiles are primarily built for personal use, but structured so they’re understandable, reproducible, and extensible by others familiar with Nix.

**User Profiles**
 - [eureka-cpu]()
 - [andrewvious]()

```mermaid
graph TD
A[users] --> B[User Profile]

B --> C[home-manager *modules*]
B --> D[nixos *modules*]

B --> E[systems]
E --> F[Host A]
E --> G[Host B]

C --> H{flake output}
D --> H
F --> H
G --> H
```

**Conceptual flow:**
- **users**        → per-user configuration (home-manager)
- **systems**      → host-specific system definitions
- **nixos**        → shared system-level modules
- **flake output** → single entry point tying everything together
