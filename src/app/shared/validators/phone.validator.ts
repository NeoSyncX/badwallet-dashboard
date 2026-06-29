import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function phoneValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;
    const cleaned = control.value.replace(/[\s\-\+]/g, '');
    const withCountryCode = /^221[7-8][0-9]{8}$/.test(cleaned);
    const localFormat = /^[7-8][0-9]{8}$/.test(cleaned);
    return (withCountryCode || localFormat) ? null : { invalidPhone: { value: control.value } };
  };
}

export function differentPhoneValidator(currentPhone: string): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    const destination = group.get('destination')?.value;
    if (!destination || !currentPhone) return null;
    const normDest = destination.replace(/[\s\-\+]/g, '').replace(/^221/, '');
    const normCurrent = currentPhone.replace(/[\s\-\+]/g, '').replace(/^221/, '');
    return normDest === normCurrent ? { samePhone: true } : null;
  };
}
