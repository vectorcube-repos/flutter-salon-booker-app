# Fix: SQL ambiguous column `id` (services + salon_service)

**Error:** `Column 'id' in field list is ambiguous`

**Cause:** A query joins `services` and `salon_service`. Both tables have `id`. Selecting or plucking bare `id` is invalid.

## What to change in your Laravel API

Search your project for code that:

- joins `services` with `salon_service`, and  
- uses `select('id')`, `pluck('id')`, or similar without a table prefix.

### Fix pattern

| Wrong | Correct |
|-------|---------|
| `->select('id')` | `->select('services.id')` or `->select('services.*')` |
| `->pluck('id')` | `->pluck('services.id')` |
| `->get(['id'])` | `->get(['services.id'])` |

### Example (query builder)

```php
// Before
DB::table('services')
    ->join('salon_service', 'services.id', '=', 'salon_service.service_id')
    ->where('salon_service.salon_id', $salonId)
    ->pluck('id'); // ❌ ambiguous

// After
DB::table('services')
    ->join('salon_service', 'services.id', '=', 'salon_service.service_id')
    ->where('salon_service.salon_id', $salonId)
    ->pluck('services.id'); // ✅
```

### Example (Eloquent)

```php
Service::query()
    ->join('salon_service', 'services.id', '=', 'salon_service.service_id')
    ->where('salon_service.salon_id', $salonId)
    ->select('services.id', 'services.name', /* ... */)
    ->get();
```

### If you use `belongsToMany`

When loading services for a salon, avoid selecting only `id` without a prefix:

```php
// On the relationship or when chaining:
$salon->services()->select('services.*')->get();
```

---

**Find the file:** In your API repo run:

```bash
rg "salon_service" app/ --type php
rg "join.*services" app/ --type php
```

Open the controller, repository, or model that builds the query for “services for salon `X`” and qualify every `id` column as `services.id` (or `salon_service.id` if you need the pivot row id).
