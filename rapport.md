# Rapport Technique - BadWallet Dashboard

## Choix d'architecture
- **Standalone Components** : Architecture recommandée par Angular 16+, sans NgModules
- **Signals** : Pour le state management réactif du solde en temps réel
- **Lazy Loading** : Chaque feature chargée à la demande via loadComponent
- **Pattern Proxy** : BillingApiService encapsule les appels HTTP vers le payment-service externe

## Difficultés rencontrées
- **CORS** : Configuration nécessaire côté backend pour autoriser localhost:4200
- **DTOs non alignés** : Adaptation des interfaces TypeScript aux réponses réelles de l'API
- **walletCode vs phoneNumber** : Distinction entre l'identifiant wallet et le numéro de téléphone pour les appels factures
- **getBalance retourne un objet** : L'API renvoie {balance, currency} et non un number direct

## Solutions apportées
- Ajout de CorsConfig.java dans le backend
- Typage any avec extraction des champs nécessaires
- Uniformisation des services pour matcher les vrais endpoints

## Compétences validées
- HttpClient & RxJS : Services centralisés avec Observable
- Reactive Forms : Validateurs personnalisés (phoneValidator, differentPhoneValidator)
- Pipes : XofPipe (format devise), PhoneFormatPipe (format téléphone)
- State Management : BalanceStore avec Signals et computed()
- Gestion d'erreurs : ErrorInterceptor + NotificationService (toasts)