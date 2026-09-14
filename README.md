# my-awesome-plantuml

A small seed repository for consistent, architecture-oriented PlantUML diagrams.

The repository contains a **shared palette**, reusable visual themes and five examples built around a simple microservice e-commerce system using both **synchronous APIs** and **asynchronous queues/events**.

## What is included

```text
my-awesome-plantuml/
├── README.md
├── Makefile
├── .gitignore
├── themes/
│   ├── palette.puml
│   ├── common.puml
│   ├── activity-theme.puml
│   ├── sequence-theme.puml
│   ├── component-theme.puml
│   ├── state-theme.puml
│   ├── deployment-theme.puml
│   └── theme.puml
└── examples/
    └── ecommerce/
        ├── 01-sequence-checkout.puml
        ├── 02-activity-order-processing.puml
        ├── 03-components-microservices.puml
        ├── 04-state-order-lifecycle.puml
        └── 05-deployment.puml
```

## The core idea

Diagrams should describe **architecture and behavior**, not contain visual design decisions.

Every diagram imports one file:

```plantuml
!include ../../themes/theme.puml
```

`theme.puml` loads the diagram-specific styles, and those styles load:

```text
theme.puml
    ↓
*-theme.puml
    ↓
common.puml
    ↓
palette.puml
```

All colors live in **`themes/palette.puml`**.

Changing the palette changes all diagrams without touching their sources.

---

# Visual language

The theme intentionally keeps the number of visual concepts small.

## Activities

| Style | Meaning |
|---|---|
| `<<primary>>` | main business/system action |
| `<<secondary>>` | supporting action or result |
| `<<optional>>` | optional side effect |
| `<<rule>>` | rule, invariant or constraint |
| `<<important>>` | important business milestone |
| `<<success>>` | successful end/result |
| `<<failure>>` | business/technical failure |

Example:

```plantuml
:Create order; <<primary>>
:Persist price snapshot; <<secondary>>
:Send analytics event; <<optional>>
:Price snapshot is immutable.; <<rule>>
:Confirm order; <<important>>
```

For modern PlantUML activity diagrams, put the stereotype at the **end of the activity line**.

## Communication

The repository uses line style as architecture semantics:

```text
────────────►  synchronous API / local call / DB call

- - - - - -►  asynchronous event / queue / notification
```

Do not reuse a dashed line for a different meaning in the same repository.

For sequence diagrams, asynchronous messaging is represented with a dashed open arrow:

```plantuml
Order -->> EventBus : OrderConfirmed
```

For architecture/deployment diagrams:

```plantuml
Order -[COLOR_ARROW_SYNC]-> Payment : REST
Order -[COLOR_ARROW_ASYNC,dashed]-> EventBus : OrderConfirmed
```

There are **no hex colors in diagram files**.

---

# Swimlanes

Activity diagrams use pastel swimlane backgrounds to separate responsibilities.

```plantuml
|COLOR_LANE_BLUE|order| **Order Service**
|COLOR_LANE_GREEN|inventory| **Inventory Service**
|COLOR_LANE_RED|payment| **Payment Service**
```

After an alias is declared, switch lanes using only the alias:

```plantuml
|order|
:Create order; <<primary>>

|inventory|
:Reserve stock; <<primary>>
```

The colors differentiate lanes; they do not encode domain semantics.

---

# Examples

## 1. Sequence — checkout

`examples/ecommerce/01-sequence-checkout.puml`

Shows one request crossing several microservices:

```text
Customer
  ↓
Web Store
  ↓ REST
API Gateway
  ↓ REST
Order Service
  ├── REST → Inventory Service
  ├── REST → Payment Service
  └── async → Event Bus → Notification Service
```

Use a sequence diagram when the main question is:

> **Who talks to whom, in what order, for one scenario?**

---

## 2. Activity — order processing

`examples/ecommerce/02-activity-order-processing.puml`

Shows responsibilities, business decisions and alternative paths across swimlanes.

Use an activity diagram when the main question is:

> **What is the end-to-end process and which component owns each step?**

This is the diagram type that most closely matches process maps with swimlanes.

---

## 3. Components — microservice architecture

`examples/ecommerce/03-components-microservices.puml`

Shows:

- clients,
- API Gateway,
- microservices,
- database-per-service,
- event bus,
- synchronous APIs,
- asynchronous event relationships.

Use a component diagram when the main question is:

> **What are the major software building blocks and how are they connected?**

---

## 4. State machine — order lifecycle

`examples/ecommerce/04-state-order-lifecycle.puml`

Shows the order lifecycle independently from the implementation flow:

```text
DRAFT
  ↓
PENDING_STOCK
  ↓
PENDING_PAYMENT
  ↓
CONFIRMED
  ↓
FULFILLING
  ↓
COMPLETED
```

with failure and cancellation branches.

Use a state diagram when the main question is:

> **Which states can this entity/process be in and what transitions are legal?**

---

## 5. Deployment — production topology

`examples/ecommerce/05-deployment.puml`

Shows a simple production topology:

- public edge/load balancer,
- API Gateway,
- Kubernetes,
- service replicas,
- broker cluster,
- managed PostgreSQL databases.

Use a deployment diagram when the main question is:

> **Where does the software run and how do runtime nodes communicate?**

---

# Creating a new diagram

Copy the nearest example:

```bash
cp examples/ecommerce/02-activity-order-processing.puml \
   examples/my-domain/my-process.puml
```

Then keep the import:

```plantuml
@startuml
!include ../../themes/theme.puml

title My process

' diagram...

@enduml
```

If the directory depth changes, adjust only the include path.

---

# Changing colors globally

Edit:

```text
themes/palette.puml
```

For example:

```plantuml
!define COLOR_PRIMARY_BG       #EAF5FF
!define COLOR_BORDER_PRIMARY   #60A5FA
!define COLOR_ARROW_SYNC       #334155
```

No diagram should contain a raw color such as:

```plantuml
#60A5FA
```

Instead, use a palette token:

```plantuml
COLOR_BORDER_PRIMARY
```

This lets you later introduce a corporate palette, print-friendly palette, or dark palette without rewriting diagrams.

---

# Recommended conventions

Keep the visual language boring and predictable:

1. Use **solid arrows** for synchronous communication.
2. Use **dashed arrows** for queue/event-based communication.
3. Use `<<primary>>` for normal domain actions.
4. Use `<<secondary>>` sparingly for supporting actions.
5. Use `<<optional>>` only for genuine side effects.
6. Use `<<rule>>` for invariants/constraints, not normal process steps.
7. Use `<<important>>` for at most a few business milestones.
8. Put lifecycle logic in a **state diagram**, not into every activity/sequence diagram.
9. Prefer one diagram = one architectural question.
10. Do not put raw colors into business diagrams.

If a reader needs the legend every 20 seconds, there are too many visual concepts.

---

# Rendering

If `plantuml` is available on your PATH:

```bash
make svg
```

or directly:

```bash
plantuml -tsvg examples/ecommerce/*.puml
```

PNG:

```bash
make png
```

Generated files are written to `out/`.

If you use a PlantUML IDE/plugin, open any `.puml` file and render it normally; the relative `!include` paths will resolve from the source file.

---

# Suggested documentation split

A useful architecture documentation convention is:

| Question | Diagram |
|---|---|
| What happens during one interaction? | Sequence |
| How does the business/process flow? | Activity |
| What software building blocks exist? | Component |
| What lifecycle is legal? | State |
| Where does it run? | Deployment |

For higher-level C4 documentation, Structurizr can remain the source of truth for system/container views, while these PlantUML diagrams document detailed behavior and runtime concerns.

---

# Extending the repository

Good next additions would be:

```text
examples/
├── ecommerce/
├── payments/
└── identity/

themes/
├── palette.puml
├── ...
└── sequence-theme.puml
```

Potential future diagram standards:

- domain event map,
- integration sequence,
- error/retry flow,
- saga/state machine,
- data-flow/security diagram,
- disaster-recovery deployment.

Keep `palette.puml` as the single visual color source.
