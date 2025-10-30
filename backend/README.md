# Expense Tracker Backend

A lightweight Shelf server that exposes CRUD endpoints for the Flutter app and
persists transactions inside the project `data/` directory.

## Usage

```powershell
cd ..\Expense-Tracker
dart pub get --directory backend
dart run backend/bin/server.dart
```

The server listens on port `8080` by default. Override by setting the `PORT`
environment variable.

## Endpoints

| Method | Path                 | Description                              |
| ------ | -------------------- | ---------------------------------------- |
| GET    | `/transactions`      | Returns all transactions as JSON.        |
| POST   | `/transactions`      | Creates a new transaction.               |
| PUT    | `/transactions/<id>` | Updates an existing transaction.         |
| DELETE | `/transactions/<id>` | Deletes the transaction with the given ID. |

All endpoints respond with the full list of transactions after the mutation.
