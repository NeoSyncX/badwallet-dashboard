import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { NotificationService } from '../services/notification.service';
import { AuthService } from '../services/auth.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const notification = inject(NotificationService);
  const auth = inject(AuthService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let message = 'Une erreur est survenue';
      if (error.status === 0) message = 'Impossible de contacter le serveur.';
      else if (error.status === 401) { message = 'Session expirée.'; auth.logout(); }
      else if (error.status === 403) message = 'Accès non autorisé.';
      else if (error.status === 404) message = 'Ressource non trouvée.';
      else if (error.status === 400) message = error.error?.message || 'Requête invalide.';
      else if (error.status >= 500) message = 'Erreur serveur.';
      if (error.error?.message) message = error.error.message;
      notification.error(message);
      return throwError(() => error);
    })
  );
};
