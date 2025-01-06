# Generator test cases

## 1. Throw an error in case
- `AUTOINCREMENT` is applied to a non-integer field.
- There are duplicate SQLite column names.
- `UNIQUE` is applied to a nullable field.
- `PRIMARY KEY` is applied to a nullable field.

## 2. Accept
- `AUTOINCREMENT` is applied to a nullable field.

## 3. Do not generate code for fields in case
- Field is `static`.
- Field is private.
- Field is annotated with @Ignore().
- Field is getter or setter.
