import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Facture {
  id: number;
  walletCode: string;
  reference: string;
  serviceName: string;
  unite: string;
  amount: number;
  dueDate: string;
  paid: boolean;
  createdAt: string;
}

@Injectable({ providedIn: 'root' })
export class BillingApiService {
  private readonly BASE = `${environment.apiBaseUrl}/external/factures`;
  private http = inject(HttpClient);

  getCurrentFactures(walletCode: string, unite?: string): Observable<Facture[]> {
    let params = new HttpParams();
    if (unite) params = params.set('unite', unite);
    return this.http.get<Facture[]>(`${this.BASE}/${walletCode}/current`, { params });
  }

  getFacturesByPeriod(walletCode: string, debut: string, fin: string, serviceName?: string): Observable<Facture[]> {
    let params = new HttpParams().set('debut', debut).set('fin', fin);
    if (serviceName) params = params.set('serviceName', serviceName);
    return this.http.get<Facture[]>(`${this.BASE}/${walletCode}/periode`, { params });
  }
}