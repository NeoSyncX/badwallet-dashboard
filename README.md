# BadWallet Dashboard - Angular SPA

Application Angular 16+ de gestion de portefeuilles électroniques.

## 🚀 Lancer le projet

```bash
npm install
ng serve
Puis ouvrir http://localhost:4200

🔗 Backend
L'API doit tourner sur http://localhost:8080

👥 Rôles
Client : Dashboard, Transfert, Factures, Historique

Agent : Liste portefeuilles, Création, Recherche, Dépôt/Retrait

🛠️ Technologies
Angular 16+ (Standalone Components)

Signals (State Management)

Reactive Forms

RxJS / HttpClient

Pipes personnalisés (XOF, Téléphone)

📁 Architecture
core/ - Services, Guards, Interceptors

shared/ - Pipes, Validators, Composants UI

features/ - Dashboard, Transfer, Bills, Admin, Login