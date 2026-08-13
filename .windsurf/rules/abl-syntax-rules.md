---
trigger: always_on
---

# Buffer Usage

When accessing database tables, always define an explicit, named buffer for that table and use the buffer for the access. This improves code clarity and maintainability.

**Incorrect:**

FOR EACH Customer WHERE Customer.Country = 'USA':
    /* ... */
END.

**Correct:**

DEFINE BUFFER bCustomer FOR Customer.

FOR EACH bCustomer WHERE bCustomer.Country = 'USA':
    /* ... */
END.
